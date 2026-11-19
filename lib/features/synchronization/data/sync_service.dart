import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';
import '../../../core/utils/stream_combine.dart';
import '../domain/cloud_models.dart';
import 'cloud_gateway.dart';

@immutable
class PushReport {
  const PushReport({
    this.applied = 0,
    this.conflicts = 0,
    this.rejected = 0,
    this.offline = false,
  });

  final int applied;
  final int conflicts;
  final int rejected;
  final bool offline;
}

@immutable
class SyncReport {
  const SyncReport({
    required this.pushed,
    required this.pulled,
    required this.conflicts,
    required this.offline,
  });

  final int pushed;
  final int pulled;
  final int conflicts;
  final bool offline;
}

@immutable
class SyncOverview {
  const SyncOverview({
    required this.pendingOps,
    required this.failedOps,
    required this.openConflicts,
    required this.lastSuccessAt,
  });

  final int pendingOps;
  final int failedOps;
  final int openConflicts;
  final DateTime? lastSuccessAt;
}

/// Offline-first synchronisation of shared groups (docs/SYNC_ARCHITECTURE.md).
///
/// * **Push** — outbox operations are sent in the order they were written.
///   A change is marked synced only after the server confirms it. Network
///   failures back off exponentially; retries reuse the op id, so the server
///   applies each operation at most once.
/// * **Pull** — change events after the stored cursor are saved to the inbox
///   and applied when the local copy is older and has no unsent changes.
/// * **Conflicts** — a server rejection because of a newer revision creates a
///   `sync_conflicts` row holding both versions. Nothing is overwritten until
///   the user chooses which version to keep.
class SyncService {
  SyncService({
    required this._db,
    required this._cloud,
    required this._clock,
    required this._ids,
  });

  final AppDatabase _db;
  final CloudGateway _cloud;
  final Clock _clock;
  final IdGenerator _ids;

  static const cursorKey = 'sync.cursor';
  static const lastSuccessKey = 'sync.lastSuccess';
  static const _pageSize = 500;

  static const _tables = {
    'group': 'groups_cache',
    'member': 'group_members_cache',
    'expense': 'group_expenses_cache',
    'settlement': 'group_settlements_cache',
  };

  /// 5 s, 10 s, 20 s … capped at 30 minutes.
  static Duration backoff(int attempts) =>
      Duration(seconds: min(5 * pow(2, max(0, attempts - 1)).toInt(), 1800));

  String? get _myUserId => _cloud.currentSession?.userId;

  // ------------------------------------------------------------- settings

  Future<String?> _readSetting(String key) async => (await (_db.select(
    _db.appSettings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _writeSetting(String key, String value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: key,
          value: value,
          updatedAt: _clock.now(),
        ),
      );

  // ------------------------------------------------------------- overview

  Stream<List<ConflictRow>> openConflicts() =>
      (_db.select(_db.syncConflicts)
            ..where((c) => c.resolvedAt.isNull())
            ..orderBy([(c) => OrderingTerm.asc(c.detectedAt)]))
          .watch();

  Stream<List<OutboxRow>> watchFailedOps() => (_db.select(
    _db.syncOutbox,
  )..where((o) => o.status.equalsValue(OutboxStatus.failed))).watch();

  Stream<SyncOverview> watchOverview() => combineLatest3(
    _db.select(_db.syncOutbox).watch(),
    openConflicts(),
    (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(lastSuccessKey))).watchSingleOrNull(),
    (ops, conflicts, last) => SyncOverview(
      pendingOps: ops.where((o) => o.status == OutboxStatus.pending).length,
      failedOps: ops.where((o) => o.status == OutboxStatus.failed).length,
      openConflicts: conflicts.length,
      lastSuccessAt: last == null
          ? null
          : DateTime.tryParse(last.value)?.toLocal(),
    ),
  );

  // ------------------------------------------------------------------ sync

  Future<SyncReport> syncOnce() async {
    final push = await this.push();
    if (push.offline) {
      return SyncReport(
        pushed: push.applied,
        pulled: 0,
        conflicts: push.conflicts,
        offline: true,
      );
    }
    int pulled;
    try {
      pulled = await pull();
    } on NetworkFailure {
      return SyncReport(
        pushed: push.applied,
        pulled: 0,
        conflicts: push.conflicts,
        offline: true,
      );
    }
    await _writeSetting(lastSuccessKey, _clock.now().toUtc().toIso8601String());
    return SyncReport(
      pushed: push.applied,
      pulled: pulled,
      conflicts: push.conflicts,
      offline: false,
    );
  }

  Future<PushReport> push() async {
    final now = _clock.now();
    final ops =
        await (_db.select(_db.syncOutbox)
              ..where((o) => o.status.equalsValue(OutboxStatus.pending))
              ..orderBy([
                (o) => OrderingTerm.asc(o.createdAt),
                (_) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
              ]))
            .get();
    final blocked = {for (final c in await openConflicts().first) c.entityId};
    var applied = 0, conflicts = 0, rejected = 0;

    for (final row in ops) {
      if (blocked.contains(row.entityId)) continue;
      // Preserve order: later operations may depend on this one.
      if (row.nextAttemptAt != null && row.nextAttemptAt!.isAfter(now)) break;
      // The row may have been rebased or folded by an earlier iteration.
      final op = await (_db.select(
        _db.syncOutbox,
      )..where((o) => o.opId.equals(row.opId))).getSingleOrNull();
      if (op == null) continue;

      OpResult result;
      try {
        result = await _cloud.applyOp(
          OutboundOp(
            opId: op.opId,
            groupId: op.groupId,
            entityType: op.entityType,
            entityId: op.entityId,
            opType: op.opType,
            baseRevision: op.baseRevision,
            payload: (jsonDecode(op.payload) as Map).cast<String, Object?>(),
          ),
        );
      } on NetworkFailure {
        final attempts = op.attempts + 1;
        await (_db.update(
          _db.syncOutbox,
        )..where((o) => o.opId.equals(op.opId))).write(
          SyncOutboxCompanion(
            attempts: Value(attempts),
            nextAttemptAt: Value(now.add(backoff(attempts))),
            lastError: const Value('network'),
          ),
        );
        return PushReport(
          applied: applied,
          conflicts: conflicts,
          rejected: rejected,
          offline: true,
        );
      } on AppFailure {
        // Not signed in / not configured: treat like offline, keep the queue.
        return PushReport(
          applied: applied,
          conflicts: conflicts,
          rejected: rejected,
          offline: true,
        );
      }

      switch (result) {
        case OpApplied(:final revision):
          await _onApplied(op, revision);
          applied++;
        case OpConflict(:final revision, :final current):
          await _onConflict(op, revision, current);
          blocked.add(op.entityId);
          conflicts++;
        case OpRejected(:final code):
          SafeLogger.info('sync_op_rejected', {
            'code': code,
            'entity': op.entityType,
          });
          await (_db.update(
            _db.syncOutbox,
          )..where((o) => o.opId.equals(op.opId))).write(
            SyncOutboxCompanion(
              status: const Value(OutboxStatus.failed),
              lastError: Value(code),
            ),
          );
          rejected++;
      }
    }
    return PushReport(
      applied: applied,
      conflicts: conflicts,
      rejected: rejected,
    );
  }

  Future<void> _onApplied(OutboxRow op, int revision) =>
      _db.transaction(() async {
        await (_db.delete(
          _db.syncOutbox,
        )..where((o) => o.opId.equals(op.opId))).go();
        // Later queued edits of the same row were based on our pre-sync copy.
        await (_db.update(_db.syncOutbox)
              ..where((o) => o.entityId.equals(op.entityId)))
            .write(SyncOutboxCompanion(baseRevision: Value(revision)));
        final remaining = await (_db.select(
          _db.syncOutbox,
        )..where((o) => o.entityId.equals(op.entityId))).get();
        await _setEntityState(
          op.entityType,
          op.entityId,
          revision: revision,
          state: remaining.isEmpty ? SyncState.synced : SyncState.pending,
        );
        if (op.entityType == 'group' && op.baseRevision == 0) {
          // The server created the owner's member record with the group.
          await _markOwnerMemberSynced(op.groupId);
        }
      });

  Future<void> _markOwnerMemberSynced(String groupId) => _db.customUpdate(
    "UPDATE group_members_cache SET revision = 1, sync_state = 'synced' "
    'WHERE group_id = ? AND is_self = 1 AND revision = 0',
    variables: [Variable.withString(groupId)],
    updates: {_db.groupMembersCache},
  );

  Future<void> _onConflict(
    OutboxRow op,
    int revision,
    Map<String, Object?>? current,
  ) => _db.transaction(() async {
    // Fold every queued change of this row into one "local version".
    final queued =
        await (_db.select(_db.syncOutbox)
              ..where((o) => o.entityId.equals(op.entityId))
              ..orderBy([(o) => OrderingTerm.asc(o.createdAt)]))
            .get();
    final latest = queued.isEmpty ? op : queued.last;
    await _db
        .into(_db.syncConflicts)
        .insert(
          SyncConflictsCompanion.insert(
            id: _ids.newId(),
            groupId: op.groupId,
            entityType: op.entityType,
            entityId: op.entityId,
            opId: Value(op.opId),
            localPayload: jsonEncode({
              'op_type': latest.opType,
              'payload': jsonDecode(latest.payload),
            }),
            remotePayload: Value(current == null ? null : jsonEncode(current)),
            remoteRevision: revision,
            detectedAt: _clock.now(),
          ),
        );
    await (_db.delete(
      _db.syncOutbox,
    )..where((o) => o.entityId.equals(op.entityId))).go();
    await _setEntityState(
      op.entityType,
      op.entityId,
      state: SyncState.conflict,
    );
  });

  Future<void> _setEntityState(
    String type,
    String id, {
    int? revision,
    SyncState? state,
  }) async {
    final table = _tables[type];
    if (table == null) return;
    final sets = <String>[];
    final vars = <Variable<Object>>[];
    if (revision != null) {
      sets.add('revision = ?');
      vars.add(Variable.withInt(revision));
    }
    if (state != null) {
      sets.add('sync_state = ?');
      vars.add(Variable.withString(state.name));
    }
    if (sets.isEmpty) return;
    vars.add(Variable.withString(id));
    await _db.customUpdate(
      'UPDATE $table SET ${sets.join(', ')} WHERE id = ?',
      variables: vars,
      updates: {_tableInfo(type)},
    );
  }

  TableInfo<Table, Object?> _tableInfo(String type) => switch (type) {
    'member' => _db.groupMembersCache,
    'expense' => _db.groupExpensesCache,
    'settlement' => _db.groupSettlementsCache,
    _ => _db.groupsCache,
  };

  // ------------------------------------------------------------------ pull

  Future<int> pull() async {
    var cursor = int.tryParse(await _readSetting(cursorKey) ?? '') ?? 0;
    while (true) {
      final events = await _cloud.pullEvents(
        afterSeq: cursor,
        limit: _pageSize,
      );
      if (events.isEmpty) break;
      await _db.batch((b) {
        for (final e in events) {
          b.insert(
            _db.syncInbox,
            SyncInboxCompanion.insert(
              seq: Value(e.seq),
              groupId: e.groupId,
              entityType: e.entityType,
              entityId: e.entityId,
              opType: e.opType,
              payload: jsonEncode(e.payload),
              remoteRevision: e.revision,
              receivedAt: _clock.now(),
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      });
      cursor = events.last.seq;
      await _writeSetting(cursorKey, '$cursor');
      if (events.length < _pageSize) break;
    }
    return _applyInbox();
  }

  Future<int> _applyInbox() async {
    final pending =
        await (_db.select(_db.syncInbox)
              ..where((i) => i.appliedAt.isNull())
              ..orderBy([(i) => OrderingTerm.asc(i.seq)]))
            .get();
    final conflicted = {
      for (final c in await openConflicts().first) c.entityId,
    };
    final snapshotted = <String>{};
    var applied = 0;
    for (final e in pending) {
      final groupKnown = await (_db.select(
        _db.groupsCache,
      )..where((g) => g.id.equals(e.groupId))).getSingleOrNull();
      if (groupKnown == null && !snapshotted.contains(e.groupId)) {
        try {
          await joinGroup(e.groupId);
          snapshotted.add(e.groupId);
        } on AppFailure catch (err, s) {
          SafeLogger.error('sync_snapshot', err, s);
          continue;
        }
      }
      if (conflicted.contains(e.entityId)) continue;
      final hasLocalChanges = await (_db.select(
        _db.syncOutbox,
      )..where((o) => o.entityId.equals(e.entityId))).get();
      if (hasLocalChanges.isNotEmpty) continue;
      final payload = (jsonDecode(e.payload) as Map).cast<String, Object?>();
      try {
        final changed = await _applyRow(
          e.entityType,
          payload,
          e.remoteRevision,
          deleted: e.opType == 'delete',
        );
        if (changed) applied++;
        await (_db.update(
          _db.syncInbox,
        )..where((i) => i.seq.equals(e.seq))).write(
          SyncInboxCompanion(
            appliedAt: Value(_clock.now()),
            error: const Value(null),
          ),
        );
      } catch (err, s) {
        SafeLogger.error('sync_apply', err, s);
        await (_db.update(
          _db.syncInbox,
        )..where((i) => i.seq.equals(e.seq))).write(
          SyncInboxCompanion(error: Value(err.runtimeType.toString())),
        );
      }
    }
    return applied;
  }

  /// Loads the full current state of a group the user can access (after
  /// accepting an invitation, or when events arrive for an unknown group).
  Future<void> joinGroup(String groupId) async {
    final snapshot = await _cloud.fetchGroupSnapshot(groupId);
    await _db.transaction(() async {
      await _applyRow(
        'group',
        snapshot.group,
        (snapshot.group['revision'] as num).toInt(),
        force: true,
      );
      final members = [...snapshot.members]
        ..sort(
          (a, b) => ((a['sort_order'] as num?) ?? 0).compareTo(
            (b['sort_order'] as num?) ?? 0,
          ),
        );
      for (final m in members) {
        await _applyRow(
          'member',
          m,
          (m['revision'] as num).toInt(),
          force: true,
        );
      }
      for (final x in snapshot.expenses) {
        await _applyRow(
          'expense',
          x,
          (x['revision'] as num).toInt(),
          force: true,
        );
      }
      for (final s in snapshot.settlements) {
        await _applyRow(
          'settlement',
          s,
          (s['revision'] as num).toInt(),
          force: true,
        );
      }
      await (_db.update(_db.syncInbox)..where(
            (i) =>
                i.groupId.equals(groupId) &
                i.seq.isSmallerOrEqualValue(snapshot.maxSeq),
          ))
          .write(SyncInboxCompanion(appliedAt: Value(_clock.now())));
    });
  }

  static DateTime? _ts(Object? v) =>
      v == null ? null : DateTime.tryParse(v as String)?.toLocal();

  static DateTime _date(Object? v) {
    final d = DateTime.parse(v! as String);
    return DateTime(d.year, d.month, d.day);
  }

  static T _enum<T extends Enum>(List<T> values, Object? raw, T fallback) =>
      values.firstWhere((e) => e.name == raw, orElse: () => fallback);

  /// Writes a server row into the local cache. Returns false when the local
  /// copy is already at (or past) [revision], or has unsent/conflicting
  /// local changes (unless [force]).
  Future<bool> _applyRow(
    String type,
    Map<String, Object?> p,
    int revision, {
    bool deleted = false,
    bool force = false,
  }) async {
    final id = p['id']! as String;
    final now = _clock.now();
    final deletedAt = deleted
        ? (_ts(p['deleted_at']) ?? now)
        : _ts(p['deleted_at']);
    switch (type) {
      case 'group':
        final existing = await (_db.select(
          _db.groupsCache,
        )..where((g) => g.id.equals(id))).getSingleOrNull();
        if (existing != null && !force && existing.revision >= revision) {
          return false;
        }
        final companion = GroupsCacheCompanion(
          name: Value(p['name']! as String),
          description: Value(p['description'] as String?),
          groupType: Value(
            _enum(GroupType.values, p['group_type'], GroupType.other),
          ),
          status: Value(
            _enum(GroupStatus.values, p['status'], GroupStatus.active),
          ),
          isShared: const Value(true),
          revision: Value(revision),
          syncState: const Value(SyncState.synced),
          deletedAt: Value(deletedAt),
          updatedAt: Value(now),
        );
        if (existing == null) {
          await _db
              .into(_db.groupsCache)
              .insert(
                companion.copyWith(
                  id: Value(id),
                  createdBy: Value((p['owner_id'] as String?) ?? ''),
                  createdAt: Value(now),
                ),
              );
        } else {
          await (_db.update(
            _db.groupsCache,
          )..where((g) => g.id.equals(id))).write(companion);
        }
      case 'member':
        final existing = await (_db.select(
          _db.groupMembersCache,
        )..where((m) => m.id.equals(id))).getSingleOrNull();
        if (existing != null && !force && existing.revision >= revision) {
          return false;
        }
        final userId = p['user_id'] as String?;
        final companion = GroupMembersCacheCompanion(
          displayName: Value(p['display_name']! as String),
          userId: Value(userId),
          role: Value(_enum(MemberRole.values, p['role'], MemberRole.member)),
          status: Value(
            _enum(MemberStatus.values, p['status'], MemberStatus.active),
          ),
          sortOrder: Value((p['sort_order'] as num?)?.toInt() ?? 0),
          isSelf: Value(userId != null && userId == _myUserId),
          revision: Value(revision),
          syncState: const Value(SyncState.synced),
          deletedAt: Value(deletedAt),
          updatedAt: Value(now),
        );
        if (existing == null) {
          await _db
              .into(_db.groupMembersCache)
              .insert(
                companion.copyWith(
                  id: Value(id),
                  groupId: Value(p['group_id']! as String),
                  joinedAt: Value(_ts(p['joined_at']) ?? now),
                  createdAt: Value(now),
                ),
              );
        } else {
          await (_db.update(
            _db.groupMembersCache,
          )..where((m) => m.id.equals(id))).write(companion);
        }
      case 'expense':
        final existing = await (_db.select(
          _db.groupExpensesCache,
        )..where((e) => e.id.equals(id))).getSingleOrNull();
        if (existing != null && !force && existing.revision >= revision) {
          return false;
        }
        final companion = GroupExpensesCacheCompanion(
          description: Value(p['description']! as String),
          categoryKey: Value(p['category_key']! as String),
          amountPaise: Value((p['amount_paise']! as num).toInt()),
          paidByMemberId: Value(p['paid_by_member_id']! as String),
          expenseDate: Value(_date(p['expense_date'])),
          splitMethod: Value(
            _enum(SplitMethod.values, p['split_method'], SplitMethod.exact),
          ),
          notes: Value(p['notes'] as String?),
          revision: Value(revision),
          syncState: const Value(SyncState.synced),
          deletedAt: Value(deletedAt),
          updatedAt: Value(now),
        );
        if (existing == null) {
          await _db
              .into(_db.groupExpensesCache)
              .insert(
                companion.copyWith(
                  id: Value(id),
                  groupId: Value(p['group_id']! as String),
                  createdAt: Value(now),
                ),
              );
        } else {
          await (_db.update(
            _db.groupExpensesCache,
          )..where((e) => e.id.equals(id))).write(companion);
        }
        final splits = (p['splits'] as List?)?.cast<Map<String, Object?>>();
        if (splits != null) {
          await (_db.delete(
            _db.groupExpenseSplitsCache,
          )..where((s) => s.expenseId.equals(id))).go();
          for (final s in splits) {
            await _db
                .into(_db.groupExpenseSplitsCache)
                .insert(
                  GroupExpenseSplitsCacheCompanion.insert(
                    id: (s['id'] as String?) ?? _ids.newId(),
                    expenseId: id,
                    memberId: s['member_id']! as String,
                    sharePaise: (s['share_paise']! as num).toInt(),
                    inputValue: Value((s['input_value'] as num?)?.toInt()),
                  ),
                );
          }
        }
      case 'settlement':
        final existing = await (_db.select(
          _db.groupSettlementsCache,
        )..where((s) => s.id.equals(id))).getSingleOrNull();
        if (existing != null && !force && existing.revision >= revision) {
          return false;
        }
        final companion = GroupSettlementsCacheCompanion(
          fromMemberId: Value(p['from_member_id']! as String),
          toMemberId: Value(p['to_member_id']! as String),
          amountPaise: Value((p['amount_paise']! as num).toInt()),
          settledOn: Value(_date(p['settled_on'])),
          paymentMethod: Value(
            _enum(
              PaymentMethod.values,
              p['payment_method'],
              PaymentMethod.other,
            ),
          ),
          notes: Value(p['notes'] as String?),
          revision: Value(revision),
          syncState: const Value(SyncState.synced),
          deletedAt: Value(deletedAt),
          updatedAt: Value(now),
        );
        if (existing == null) {
          await _db
              .into(_db.groupSettlementsCache)
              .insert(
                companion.copyWith(
                  id: Value(id),
                  groupId: Value(p['group_id']! as String),
                  createdAt: Value(now),
                ),
              );
        } else {
          await (_db.update(
            _db.groupSettlementsCache,
          )..where((s) => s.id.equals(id))).write(companion);
        }
      case 'attachment':
        await _db
            .into(_db.attachments)
            .insert(
              AttachmentsCompanion.insert(
                id: id,
                groupExpenseId: Value(p['expense_id']! as String),
                storedName: '',
                originalName:
                    'shared_${id.substring(0, 8)}${(p['mime_type'] == 'application/pdf') ? '.pdf' : '.jpg'}',
                mimeType: p['mime_type']! as String,
                sizeBytes: (p['size_bytes']! as num).toInt(),
                sha256: p['sha256']! as String,
                remotePath: Value(p['storage_path'] as String?),
                createdAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      default:
        return false;
    }
    return true;
  }

  // ------------------------------------------------------------- conflicts

  /// Resolves a conflict explicitly chosen by the user.
  /// * keepLocal — re-send the local version on top of the server revision.
  /// * keepRemote — replace the local copy with the server version.
  Future<void> resolveConflict(
    String conflictId, {
    required bool keepLocal,
  }) async {
    final c = await (_db.select(
      _db.syncConflicts,
    )..where((x) => x.id.equals(conflictId))).getSingleOrNull();
    if (c == null || c.resolvedAt != null) return;
    await _db.transaction(() async {
      final local = (jsonDecode(c.localPayload) as Map).cast<String, Object?>();
      if (keepLocal) {
        await _db
            .into(_db.syncOutbox)
            .insert(
              SyncOutboxCompanion.insert(
                opId: _ids.newId(),
                groupId: c.groupId,
                entityType: c.entityType,
                entityId: c.entityId,
                opType: local['op_type']! as String,
                payload: jsonEncode(local['payload']),
                baseRevision: c.remoteRevision,
                createdAt: _clock.now(),
              ),
            );
        await _setEntityState(
          c.entityType,
          c.entityId,
          revision: c.remoteRevision,
          state: SyncState.pending,
        );
      } else if (c.remotePayload != null) {
        final remote = (jsonDecode(c.remotePayload!) as Map)
            .cast<String, Object?>();
        await _applyRow(c.entityType, remote, c.remoteRevision, force: true);
      } else {
        await _setEntityState(
          c.entityType,
          c.entityId,
          state: SyncState.synced,
        );
      }
      await (_db.update(
        _db.syncConflicts,
      )..where((x) => x.id.equals(conflictId))).write(
        SyncConflictsCompanion(
          resolvedAt: Value(_clock.now()),
          resolution: Value(keepLocal ? 'keepLocal' : 'keepRemote'),
        ),
      );
    });
    await _applyInbox();
  }

  /// Puts failed operations back into the queue (e.g. after the user fixed
  /// the reason, or to retry a transient server error).
  Future<void> retryFailed() =>
      (_db.update(
        _db.syncOutbox,
      )..where((o) => o.status.equalsValue(OutboxStatus.failed))).write(
        const SyncOutboxCompanion(
          status: Value(OutboxStatus.pending),
          attempts: Value(0),
          nextAttemptAt: Value(null),
        ),
      );
}
