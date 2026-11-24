import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';

/// Writes Family hisab rows from the account (feed events, snapshots and
/// "keep theirs") into the phone's copy, and keeps their upload state.
class FamilyRowApplier {
  FamilyRowApplier(this._db, this._clock, {required this.myUserId});

  final AppDatabase _db;
  final Clock _clock;

  /// The signed-in user, to recognise "You" among the people.
  final String? Function() myUserId;

  /// Removes local bill files whose records were deleted.
  Future<void> Function(List<String> storedNames)? onFilesRemoved;

  static const types = {'family', 'member', 'entry'};

  /// Writes [p] at [revision]. Returns false when the phone's copy is
  /// already at (or past) that revision, unless [force].
  Future<bool> apply(
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
      case 'family':
        final existing = await (_db.select(
          _db.familyHisabsCache,
        )..where((f) => f.id.equals(id))).getSingleOrNull();
        if (existing != null && !force && existing.revision >= revision) {
          return false;
        }
        final row = FamilyHisabsCacheCompanion(
          name: Value(p['name']! as String),
          openingBalancePaise: Value(
            (p['opening_balance_paise'] as num?)?.toInt() ?? 0,
          ),
          ownerUserId: Value(p['owner_id'] as String?),
          revision: Value(revision),
          syncState: const Value(SyncState.synced),
          deletedAt: Value(deletedAt),
          updatedAt: Value(now),
        );
        if (existing == null) {
          await _db
              .into(_db.familyHisabsCache)
              .insert(row.copyWith(id: Value(id), createdAt: Value(now)));
        } else {
          await (_db.update(
            _db.familyHisabsCache,
          )..where((f) => f.id.equals(id))).write(row);
        }
      case 'member':
        final existing = await (_db.select(
          _db.familyMembersCache,
        )..where((m) => m.id.equals(id))).getSingleOrNull();
        if (existing != null && !force && existing.revision >= revision) {
          return false;
        }
        final userId = p['user_id'] as String?;
        final me = myUserId();
        final row = FamilyMembersCacheCompanion(
          userId: Value(userId),
          name: Value(p['name']! as String),
          phone: Value(p['phone'] as String?),
          role: Value((p['role'] as String?) ?? 'member'),
          status: Value(
            deletedAt != null
                ? 'removed'
                : (p['status'] as String?) ?? 'active',
          ),
          isSelf: Value(userId != null && userId == me),
          sortOrder: Value((p['sort_order'] as num?)?.toInt() ?? 0),
          revision: Value(revision),
          syncState: const Value(SyncState.synced),
          deletedAt: Value(deletedAt),
          updatedAt: Value(now),
        );
        if (existing == null) {
          await _db
              .into(_db.familyMembersCache)
              .insert(
                row.copyWith(
                  id: Value(id),
                  familyId: Value(p['family_id']! as String),
                  createdAt: Value(now),
                ),
              );
        } else {
          await (_db.update(
            _db.familyMembersCache,
          )..where((m) => m.id.equals(id))).write(row);
        }
      case 'entry':
        final existing = await (_db.select(
          _db.familyEntriesCache,
        )..where((e) => e.id.equals(id))).getSingleOrNull();
        if (existing != null && !force && existing.revision >= revision) {
          return false;
        }
        // A delete event may carry only the id: keep what the phone has.
        if (existing == null && p['member_id'] == null) return false;
        final row = FamilyEntriesCacheCompanion(
          memberId: p['member_id'] == null
              ? const Value.absent()
              : Value(p['member_id']! as String),
          kind: p['kind'] == null
              ? const Value.absent()
              : Value(p['kind']! as String),
          amountPaise: p['amount_paise'] == null
              ? const Value.absent()
              : Value((p['amount_paise']! as num).toInt()),
          entryDate: p['entry_date'] == null
              ? const Value.absent()
              : Value(_date(p['entry_date'])),
          categoryId: Value(p['category_id'] as String?),
          categoryName: Value(p['category_name'] as String?),
          categoryNameGu: Value(p['category_name_gu'] as String?),
          categoryIcon: Value(p['category_icon'] as String?),
          categoryColor: Value((p['category_color'] as num?)?.toInt()),
          note: Value(p['note'] as String?),
          revision: Value(revision),
          syncState: const Value(SyncState.synced),
          deletedAt: Value(deletedAt),
          updatedAt: Value(now),
        );
        if (existing == null) {
          await _db
              .into(_db.familyEntriesCache)
              .insert(
                row.copyWith(
                  id: Value(id),
                  familyId: Value(p['family_id']! as String),
                  createdAt: Value(now),
                ),
              );
        } else if (p['member_id'] == null) {
          // Only the delete marker and revision are known.
          await (_db.update(
            _db.familyEntriesCache,
          )..where((e) => e.id.equals(id))).write(
            FamilyEntriesCacheCompanion(
              revision: Value(revision),
              syncState: const Value(SyncState.synced),
              deletedAt: Value(deletedAt),
              updatedAt: Value(now),
            ),
          );
        } else {
          await (_db.update(
            _db.familyEntriesCache,
          )..where((e) => e.id.equals(id))).write(row);
        }
      case 'attachment':
        if (deleted) {
          final rows = await (_db.select(
            _db.attachments,
          )..where((a) => a.id.equals(id))).get();
          if (rows.isEmpty) return false;
          await (_db.delete(
            _db.attachments,
          )..where((a) => a.id.equals(id))).go();
          final names = [
            for (final a in rows)
              if (a.storedName.isNotEmpty) a.storedName,
          ];
          if (names.isNotEmpty) await onFilesRemoved?.call(names);
          return true;
        }
        final mime = p['mime_type']! as String;
        // A bill from another member arrives without a local file; it is
        // downloaded when opened.
        final inserted = await _db
            .into(_db.attachments)
            .insert(
              AttachmentsCompanion.insert(
                id: id,
                familyEntryId: Value(p['entry_id']! as String),
                storedName: '',
                originalName:
                    'bill_${id.substring(0, 8)}${mime == 'application/pdf' ? '.pdf' : '.jpg'}',
                mimeType: mime,
                sizeBytes: (p['size_bytes']! as num).toInt(),
                sha256: p['sha256']! as String,
                remotePath: Value(p['storage_path'] as String?),
                createdAt: now,
              ),
              mode: InsertMode.insertOrIgnore,
            );
        return inserted > 0;
      default:
        return false;
    }
    return true;
  }

  /// Sets the server revision and/or upload state of one row.
  Future<void> setState(
    String type,
    String id, {
    int? revision,
    SyncState? state,
  }) async {
    final table = switch (type) {
      'family' => 'family_hisabs_cache',
      'member' => 'family_members_cache',
      'entry' => 'family_entries_cache',
      _ => null,
    };
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
      updates: {
        switch (type) {
          'family' => _db.familyHisabsCache,
          'member' => _db.familyMembersCache,
          _ => _db.familyEntriesCache,
        },
      },
    );
  }

  /// Removes a Family hisab from the phone (this user was removed from it):
  /// its entries, people, unsent uploads, feed rows and open conflicts.
  Future<void> forgetFamily(String familyId) async {
    final bills =
        await (_db.select(_db.attachments)..where(
              (a) => a.familyEntryId.isInQuery(
                _db.selectOnly(_db.familyEntriesCache)
                  ..addColumns([_db.familyEntriesCache.id])
                  ..where(_db.familyEntriesCache.familyId.equals(familyId)),
              ),
            ))
            .get();
    await _forget(familyId, [for (final b in bills) b.id]);
    final names = [
      for (final b in bills)
        if (b.storedName.isNotEmpty) b.storedName,
    ];
    if (names.isNotEmpty) await onFilesRemoved?.call(names);
  }

  Future<void> _forget(
    String familyId,
    List<String> billIds,
  ) => _db.transaction(() async {
    await (_db.delete(_db.attachments)..where((a) => a.id.isIn(billIds))).go();
    await (_db.delete(
      _db.familyEntriesCache,
    )..where((e) => e.familyId.equals(familyId))).go();
    await (_db.delete(
      _db.familyMembersCache,
    )..where((m) => m.familyId.equals(familyId))).go();
    await (_db.delete(
      _db.familyHisabsCache,
    )..where((f) => f.id.equals(familyId))).go();
    await (_db.delete(_db.syncOutbox)
          ..where((o) => o.scope.equals('family') & o.groupId.equals(familyId)))
        .go();
    await (_db.delete(_db.syncInbox)
          ..where((i) => i.scope.equals('family') & i.groupId.equals(familyId)))
        .go();
    await (_db.delete(_db.syncConflicts)
          ..where((c) => c.scope.equals('family') & c.groupId.equals(familyId)))
        .go();
  });

  /// The account creates "You" together with the Family hisab (revision 1).
  Future<void> markOwnerSynced(String familyId) => _db.customUpdate(
    "UPDATE family_members_cache SET revision = 1, sync_state = 'synced' "
    "WHERE family_id = ? AND role = 'owner' AND revision = 0",
    variables: [Variable.withString(familyId)],
    updates: {_db.familyMembersCache},
  );

  static DateTime? _ts(Object? v) =>
      v == null ? null : DateTime.tryParse(v as String)?.toLocal();

  static DateTime _date(Object? v) {
    final d = DateTime.parse(v! as String);
    return DateTime(d.year, d.month, d.day);
  }
}
