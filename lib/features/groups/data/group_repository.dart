import 'dart:collection';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/utils/stream_combine.dart';
import '../../settlements/domain/group_balance_calculator.dart';
import '../domain/group_models.dart';
import '../domain/split_calculator.dart';

/// Groups, members, expenses, splits and settlements.
///
/// * Rows are tombstoned (`deletedAt`) instead of hard-deleted so deletions
///   can propagate to other devices once a group is shared.
/// * For shared groups every change also writes an outbox operation in the
///   same DB transaction (see docs/SYNC_ARCHITECTURE.md).
class GroupRepository {
  GroupRepository(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  // ------------------------------------------------------------------ reads

  Stream<List<GroupMemberRow>> _membersOf(String groupId) =>
      (_db.select(_db.groupMembersCache)
            ..where((m) => m.groupId.equals(groupId))
            ..orderBy([
              (m) => OrderingTerm.asc(m.sortOrder),
              (m) => OrderingTerm.asc(m.joinedAt),
            ]))
          .watch();

  Stream<GroupDetail?> watchGroup(String groupId) {
    final group =
        (_db.select(_db.groupsCache)
              ..where((g) => g.id.equals(groupId) & g.deletedAt.isNull()))
            .watchSingleOrNull();
    final expenses =
        (_db.select(_db.groupExpensesCache)
              ..where((e) => e.groupId.equals(groupId) & e.deletedAt.isNull())
              ..orderBy([
                (e) => OrderingTerm.desc(e.expenseDate),
                (e) => OrderingTerm.desc(e.createdAt),
              ]))
            .watch();
    final splits =
        (_db.select(_db.groupExpenseSplitsCache).join([
              innerJoin(
                _db.groupExpensesCache,
                _db.groupExpensesCache.id.equalsExp(
                  _db.groupExpenseSplitsCache.expenseId,
                ),
              ),
            ])..where(_db.groupExpensesCache.groupId.equals(groupId)))
            .map((r) => r.readTable(_db.groupExpenseSplitsCache))
            .watch();
    final settlements =
        (_db.select(_db.groupSettlementsCache)
              ..where((s) => s.groupId.equals(groupId) & s.deletedAt.isNull())
              ..orderBy([
                (s) => OrderingTerm.desc(s.settledOn),
                (s) => OrderingTerm.desc(s.createdAt),
              ]))
            .watch();
    final attachmentCounts = _attachmentCounts();

    return combineLatestList<Object?, GroupDetail?>(
      [
        group,
        _membersOf(groupId),
        expenses,
        splits,
        settlements,
        attachmentCounts,
      ],
      (v) {
        final g = v[0] as GroupRow?;
        if (g == null) return null;
        return _buildDetail(
          g,
          v[1]! as List<GroupMemberRow>,
          v[2]! as List<GroupExpenseRow>,
          v[3]! as List<GroupSplitRow>,
          v[4]! as List<GroupSettlementRow>,
          v[5]! as Map<String, int>,
        );
      },
    );
  }

  Stream<Map<String, int>> _attachmentCounts() {
    final count = _db.attachments.id.count();
    final q = _db.selectOnly(_db.attachments)
      ..addColumns([_db.attachments.groupExpenseId, count])
      ..where(_db.attachments.groupExpenseId.isNotNull())
      ..groupBy([_db.attachments.groupExpenseId]);
    return q.watch().map(
      (rows) => {
        for (final r in rows)
          r.read(_db.attachments.groupExpenseId)!: r.read(count) ?? 0,
      },
    );
  }

  GroupDetail _buildDetail(
    GroupRow g,
    List<GroupMemberRow> members,
    List<GroupExpenseRow> expenses,
    List<GroupSplitRow> splits,
    List<GroupSettlementRow> settlements,
    Map<String, int> attachmentCounts,
  ) {
    final order = {for (var i = 0; i < members.length; i++) members[i].id: i};
    final splitsByExpense = <String, List<GroupSplitRow>>{};
    for (final s in splits) {
      splitsByExpense.putIfAbsent(s.expenseId, () => []).add(s);
    }
    final views = <ExpenseView>[];
    for (final e in expenses) {
      final list = (splitsByExpense[e.id] ?? [])
        ..sort(
          (a, b) => (order[a.memberId] ?? 0).compareTo(order[b.memberId] ?? 0),
        );
      views.add(
        ExpenseView(
          expense: e,
          splits: LinkedHashMap.fromEntries(
            list.map((s) => MapEntry(s.memberId, s.sharePaise)),
          ),
          splitInputs: {for (final s in list) s.memberId: s.inputValue},
          attachmentCount: attachmentCounts[e.id] ?? 0,
        ),
      );
    }
    final active = members
        .where((m) => m.status != MemberStatus.removed && m.deletedAt == null)
        .toList();
    final memberIds = members.map((m) => m.id).toList();
    final balanceExpenses = [
      for (final v in views)
        BalanceExpense(
          paidBy: v.expense.paidByMemberId,
          amountPaise: v.expense.amountPaise,
          shares: v.splits,
        ),
    ];
    final net = GroupBalanceCalculator.netBalances(
      memberIds: memberIds,
      expenses: balanceExpenses,
      settlements: [
        for (final s in settlements)
          BalanceSettlement(
            from: s.fromMemberId,
            to: s.toMemberId,
            amountPaise: s.amountPaise,
          ),
      ],
    );
    return GroupDetail(
      group: g,
      members: active,
      allMembers: {for (final m in members) m.id: m},
      expenses: views,
      settlements: settlements,
      netBalances: net,
      memberTotals: GroupBalanceCalculator.memberTotals(
        memberIds: memberIds,
        expenses: balanceExpenses,
      ),
      suggestions: GroupBalanceCalculator.suggestSettlements(net),
    );
  }

  Stream<List<GroupListItem>> watchGroups({bool includeArchived = false}) {
    final groups =
        (_db.select(_db.groupsCache)
              ..where((g) => g.deletedAt.isNull())
              ..orderBy([(g) => OrderingTerm.desc(g.updatedAt)]))
            .watch();
    final members = _db.select(_db.groupMembersCache).watch();
    final expenses = (_db.select(
      _db.groupExpensesCache,
    )..where((e) => e.deletedAt.isNull())).watch();
    final splits = _db.select(_db.groupExpenseSplitsCache).watch();
    final settlements = (_db.select(
      _db.groupSettlementsCache,
    )..where((s) => s.deletedAt.isNull())).watch();
    return combineLatestList<Object?, List<GroupListItem>>(
      [groups, members, expenses, splits, settlements],
      (v) {
        final allGroups = v[0]! as List<GroupRow>;
        final allMembers = v[1]! as List<GroupMemberRow>;
        final allExpenses = v[2]! as List<GroupExpenseRow>;
        final allSplits = v[3]! as List<GroupSplitRow>;
        final allSettlements = v[4]! as List<GroupSettlementRow>;
        final items = <GroupListItem>[];
        for (final g in allGroups) {
          if (!includeArchived && g.status == GroupStatus.archived) continue;
          final members = allMembers.where((m) => m.groupId == g.id).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          final expenses = allExpenses.where((e) => e.groupId == g.id).toList();
          final expenseIds = expenses.map((e) => e.id).toSet();
          final detail = _buildDetail(
            g,
            members,
            expenses,
            allSplits.where((s) => expenseIds.contains(s.expenseId)).toList(),
            allSettlements.where((s) => s.groupId == g.id).toList(),
            const {},
          );
          final self = detail.selfMember;
          var last = g.updatedAt;
          for (final e in expenses) {
            if (e.updatedAt.isAfter(last)) last = e.updatedAt;
          }
          items.add(
            GroupListItem(
              group: g,
              memberCount: detail.members.length,
              totalSpentPaise: detail.totalSpentPaise,
              myNetPaise: self == null ? 0 : detail.netBalances[self.id] ?? 0,
              lastActivity: last,
            ),
          );
        }
        items.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
        return items;
      },
    );
  }

  Stream<MyGroupsSummary> watchMySummary() => watchGroups().map((items) {
    var owe = 0;
    var owed = 0;
    for (final i in items) {
      if (i.myNetPaise < 0) owe += -i.myNetPaise;
      if (i.myNetPaise > 0) owed += i.myNetPaise;
    }
    return MyGroupsSummary(
      activeGroups: items.length,
      iOwePaise: owe,
      owedToMePaise: owed,
    );
  });

  // ------------------------------------------------------------- mutations

  Future<GroupRow> _group(String id) async {
    final g = await (_db.select(
      _db.groupsCache,
    )..where((x) => x.id.equals(id) & x.deletedAt.isNull())).getSingleOrNull();
    if (g == null) throw const NotFoundFailure();
    return g;
  }

  SyncState _stateFor(GroupRow g) =>
      g.isShared ? SyncState.pending : SyncState.localOnly;

  Future<String> createGroup(
    GroupDraft d, {
    required String selfName,
    List<MemberDraft> members = const [],
  }) {
    final name = d.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    return _db.transaction(() async {
      final now = _clock.now();
      final groupId = _ids.newId();
      final selfId = _ids.newId();
      await _db
          .into(_db.groupsCache)
          .insert(
            GroupsCacheCompanion.insert(
              id: groupId,
              name: name,
              description: Value(_clean(d.description)),
              groupType: d.groupType,
              createdBy: selfId,
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db
          .into(_db.groupMembersCache)
          .insert(
            GroupMembersCacheCompanion.insert(
              id: selfId,
              groupId: groupId,
              displayName: selfName.trim().isEmpty ? 'Me' : selfName.trim(),
              role: const Value(MemberRole.owner),
              isSelf: const Value(true),
              joinedAt: now,
              sortOrder: const Value(0),
              createdAt: now,
              updatedAt: now,
            ),
          );
      var order = 1;
      for (final m in members) {
        await _insertMember(groupId, m, order++, now, SyncState.localOnly);
      }
      return groupId;
    });
  }

  Future<String> _insertMember(
    String groupId,
    MemberDraft m,
    int order,
    DateTime now,
    SyncState state,
  ) async {
    final name = m.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    final id = m.id ?? _ids.newId();
    await _db
        .into(_db.groupMembersCache)
        .insert(
          GroupMembersCacheCompanion.insert(
            id: id,
            groupId: groupId,
            displayName: name,
            phone: Value(_clean(m.phone)),
            personId: Value(m.personId),
            joinedAt: now,
            sortOrder: Value(order),
            syncState: Value(state),
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  Future<void> updateGroup(GroupDraft d) => _db.transaction(() async {
    final g = await _group(d.id!);
    final name = d.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    final now = _clock.now();
    await (_db.update(_db.groupsCache)..where((x) => x.id.equals(g.id))).write(
      GroupsCacheCompanion(
        name: Value(name),
        description: Value(_clean(d.description)),
        groupType: Value(d.groupType),
        updatedAt: Value(now),
        syncState: Value(_stateFor(g)),
      ),
    );
    await _enqueueGroup(g.id, now);
  });

  Future<void> setArchived(String groupId, {required bool archived}) =>
      _db.transaction(() async {
        final g = await _group(groupId);
        final now = _clock.now();
        await (_db.update(
          _db.groupsCache,
        )..where((x) => x.id.equals(g.id))).write(
          GroupsCacheCompanion(
            status: Value(archived ? GroupStatus.archived : GroupStatus.active),
            updatedAt: Value(now),
            syncState: Value(_stateFor(g)),
          ),
        );
        await _enqueueGroup(g.id, now);
      });

  /// Deletes a group that is not shared. Shared groups are archived instead
  /// so that other members keep their history.
  Future<void> deleteLocalGroup(String groupId) => _db.transaction(() async {
    final g = await _group(groupId);
    if (g.isShared) throw const ValidationFailure('group_shared');
    await (_db.delete(
      _db.groupsCache,
    )..where((x) => x.id.equals(groupId))).go();
  });

  Future<String> addMember(String groupId, MemberDraft m) =>
      _db.transaction(() async {
        final g = await _group(groupId);
        final max = _db.groupMembersCache.sortOrder.max();
        final row =
            await (_db.selectOnly(_db.groupMembersCache)
                  ..addColumns([max])
                  ..where(_db.groupMembersCache.groupId.equals(groupId)))
                .getSingle();
        final now = _clock.now();
        final id = await _insertMember(
          groupId,
          m,
          (row.read(max) ?? 0) + 1,
          now,
          _stateFor(g),
        );
        await _touch(g, now);
        await _enqueueMember(g, id, now);
        return id;
      });

  Future<void> renameMember(String memberId, String name) =>
      _db.transaction(() async {
        final member = await (_db.select(
          _db.groupMembersCache,
        )..where((m) => m.id.equals(memberId))).getSingle();
        final g = await _group(member.groupId);
        if (name.trim().isEmpty) throw const ValidationFailure('required');
        final now = _clock.now();
        await (_db.update(
          _db.groupMembersCache,
        )..where((m) => m.id.equals(memberId))).write(
          GroupMembersCacheCompanion(
            displayName: Value(name.trim()),
            updatedAt: Value(now),
            syncState: Value(_stateFor(g)),
          ),
        );
        await _enqueueMember(g, memberId, now);
      });

  /// Removes a member who has no expenses, splits or settlements. Members
  /// referenced by history are kept (history must stay intact).
  Future<void> removeMember(String memberId) => _db.transaction(() async {
    final member = await (_db.select(
      _db.groupMembersCache,
    )..where((m) => m.id.equals(memberId))).getSingle();
    if (member.isSelf) throw const ValidationFailure('member_self');
    final g = await _group(member.groupId);
    final used = await _db
        .customSelect(
          'SELECT '
          '(SELECT COUNT(*) FROM group_expenses_cache WHERE paid_by_member_id = ?1 AND deleted_at IS NULL) + '
          '(SELECT COUNT(*) FROM group_expense_splits_cache s JOIN group_expenses_cache e ON e.id = s.expense_id '
          '   WHERE s.member_id = ?1 AND e.deleted_at IS NULL) + '
          '(SELECT COUNT(*) FROM group_settlements_cache WHERE (from_member_id = ?1 OR to_member_id = ?1) AND deleted_at IS NULL) AS c',
          variables: [Variable.withString(memberId)],
        )
        .getSingle();
    if ((used.data['c'] as int) > 0) {
      throw const ValidationFailure('member_in_use');
    }
    final now = _clock.now();
    await (_db.update(
      _db.groupMembersCache,
    )..where((m) => m.id.equals(memberId))).write(
      GroupMembersCacheCompanion(
        status: const Value(MemberStatus.removed),
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncState: Value(_stateFor(g)),
      ),
    );
    await _touch(g, now);
    await _enqueueMember(g, memberId, now, delete: true);
  });

  Future<String> saveExpense(ExpenseDraft d) {
    final description = d.description.trim();
    if (description.isEmpty) throw const ValidationFailure('required');
    if (d.amountPaise <= 0 || d.amountPaise > Money.maxPaise) {
      throw const ValidationFailure('amount_positive');
    }
    final outcome = SplitCalculator.calculate(
      totalPaise: d.amountPaise,
      method: d.splitMethod,
      participants: d.participants,
    );
    final shares = switch (outcome) {
      SplitSuccess(:final shares) => shares,
      SplitFailure(:final error) => throw SplitValidationFailure(error),
    };
    return _db.transaction(() async {
      final g = await _group(d.groupId);
      final members = await (_db.select(
        _db.groupMembersCache,
      )..where((m) => m.groupId.equals(g.id) & m.deletedAt.isNull())).get();
      final memberIds = members.map((m) => m.id).toSet();
      if (!memberIds.contains(d.paidByMemberId) ||
          !memberIds.containsAll(shares.keys)) {
        throw const ValidationFailure('member_unknown');
      }
      final now = _clock.now();
      final id = d.id ?? _ids.newId();
      final companion = GroupExpensesCacheCompanion(
        id: Value(id),
        groupId: Value(g.id),
        description: Value(description),
        categoryKey: Value(d.categoryKey),
        amountPaise: Value(d.amountPaise),
        paidByMemberId: Value(d.paidByMemberId),
        expenseDate: Value(DateTime(d.date.year, d.date.month, d.date.day)),
        splitMethod: Value(d.splitMethod),
        notes: Value(_clean(d.notes)),
        syncState: Value(_stateFor(g)),
        updatedAt: Value(now),
      );
      if (d.id == null) {
        await _db
            .into(_db.groupExpensesCache)
            .insert(companion.copyWith(createdAt: Value(now)));
      } else {
        final n =
            await (_db.update(_db.groupExpensesCache)
                  ..where((e) => e.id.equals(id) & e.deletedAt.isNull()))
                .write(companion);
        if (n == 0) throw const NotFoundFailure();
        await (_db.delete(
          _db.groupExpenseSplitsCache,
        )..where((s) => s.expenseId.equals(id))).go();
      }
      final inputs = {for (final p in d.participants) p.memberId: p.input};
      for (final entry in shares.entries) {
        await _db
            .into(_db.groupExpenseSplitsCache)
            .insert(
              GroupExpenseSplitsCacheCompanion.insert(
                id: _ids.newId(),
                expenseId: id,
                memberId: entry.key,
                sharePaise: entry.value,
                inputValue: Value(
                  d.splitMethod == SplitMethod.equal ? null : inputs[entry.key],
                ),
              ),
            );
      }
      await _touch(g, now);
      await _enqueueExpense(g, id, now);
      return id;
    });
  }

  Future<void> deleteExpense(String id) => _db.transaction(() async {
    final e = await (_db.select(
      _db.groupExpensesCache,
    )..where((x) => x.id.equals(id))).getSingleOrNull();
    if (e == null || e.deletedAt != null) throw const NotFoundFailure();
    final g = await _group(e.groupId);
    final now = _clock.now();
    await (_db.update(
      _db.groupExpensesCache,
    )..where((x) => x.id.equals(id))).write(
      GroupExpensesCacheCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncState: Value(_stateFor(g)),
      ),
    );
    await _touch(g, now);
    await _enqueueExpense(g, id, now, delete: true);
  });

  /// Records a full or partial settlement. The payer cannot pay more than
  /// they owe and the receiver cannot receive more than they are owed —
  /// otherwise balances would silently flip.
  Future<String> recordSettlement(SettlementDraft d) {
    if (d.amountPaise <= 0) throw const ValidationFailure('amount_positive');
    if (d.fromMemberId == d.toMemberId) {
      throw const ValidationFailure('settlement_same_member');
    }
    return _db.transaction(() async {
      final g = await _group(d.groupId);
      final detail = await watchGroup(g.id).first;
      final fromNet = detail!.netBalances[d.fromMemberId];
      final toNet = detail.netBalances[d.toMemberId];
      if (fromNet == null || toNet == null) {
        throw const ValidationFailure('member_unknown');
      }
      if (-fromNet < d.amountPaise || toNet < d.amountPaise) {
        throw const ValidationFailure('settlement_exceeds');
      }
      final now = _clock.now();
      final id = _ids.newId();
      await _db
          .into(_db.groupSettlementsCache)
          .insert(
            GroupSettlementsCacheCompanion.insert(
              id: id,
              groupId: g.id,
              fromMemberId: d.fromMemberId,
              toMemberId: d.toMemberId,
              amountPaise: d.amountPaise,
              settledOn: DateTime(d.date.year, d.date.month, d.date.day),
              paymentMethod: d.paymentMethod,
              notes: Value(_clean(d.notes)),
              syncState: Value(_stateFor(g)),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _touch(g, now);
      await _enqueueSettlement(g, id, now);
      return id;
    });
  }

  /// Deleting a settlement (e.g. recorded by mistake) is a visible, explicit
  /// action; the row is tombstoned, never silently altered.
  Future<void> deleteSettlement(String id) => _db.transaction(() async {
    final s = await (_db.select(
      _db.groupSettlementsCache,
    )..where((x) => x.id.equals(id))).getSingleOrNull();
    if (s == null || s.deletedAt != null) throw const NotFoundFailure();
    final g = await _group(s.groupId);
    final now = _clock.now();
    await (_db.update(
      _db.groupSettlementsCache,
    )..where((x) => x.id.equals(id))).write(
      GroupSettlementsCacheCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
        syncState: Value(_stateFor(g)),
      ),
    );
    await _touch(g, now);
    await _enqueueSettlement(g, id, now, delete: true);
  });

  /// Marks a group as shared and queues all of its current rows for upload.
  Future<void> markShared(
    String groupId, {
    String? ownerUserId,
  }) => _db.transaction(() async {
    final g = await _group(groupId);
    if (g.isShared) return;
    final now = _clock.now();
    await (_db.update(
      _db.groupsCache,
    )..where((x) => x.id.equals(groupId))).write(
      GroupsCacheCompanion(
        isShared: const Value(true),
        syncState: const Value(SyncState.pending),
        updatedAt: Value(now),
      ),
    );
    if (ownerUserId != null) {
      await (_db.update(_db.groupMembersCache)
            ..where((m) => m.groupId.equals(groupId) & m.isSelf.equals(true)))
          .write(GroupMembersCacheCompanion(userId: Value(ownerUserId)));
    }
    final shared = await _group(groupId);
    await _enqueueGroup(groupId, now);
    final members =
        await (_db.select(_db.groupMembersCache)
              ..where((m) => m.groupId.equals(groupId) & m.deletedAt.isNull())
              ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
            .get();
    for (final m in members) {
      // The owner's own member record is created by the server together
      // with the group (see the group op payload), so it is not sent again.
      if (m.isSelf) continue;
      await _markMemberPending(m.id);
      await _enqueueMember(shared, m.id, now);
    }
    final expenses =
        await (_db.select(_db.groupExpensesCache)
              ..where((e) => e.groupId.equals(groupId) & e.deletedAt.isNull())
              ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
            .get();
    for (final e in expenses) {
      await (_db.update(
        _db.groupExpensesCache,
      )..where((x) => x.id.equals(e.id))).write(
        const GroupExpensesCacheCompanion(syncState: Value(SyncState.pending)),
      );
      await _enqueueExpense(shared, e.id, now);
    }
    final settlements =
        await (_db.select(_db.groupSettlementsCache)
              ..where((s) => s.groupId.equals(groupId) & s.deletedAt.isNull())
              ..orderBy([(s) => OrderingTerm.asc(s.createdAt)]))
            .get();
    for (final s in settlements) {
      await (_db.update(
        _db.groupSettlementsCache,
      )..where((x) => x.id.equals(s.id))).write(
        const GroupSettlementsCacheCompanion(
          syncState: Value(SyncState.pending),
        ),
      );
      await _enqueueSettlement(shared, s.id, now);
    }
  });

  Future<void> _markMemberPending(String id) =>
      (_db.update(_db.groupMembersCache)..where((m) => m.id.equals(id))).write(
        const GroupMembersCacheCompanion(syncState: Value(SyncState.pending)),
      );

  Future<void> _touch(GroupRow g, DateTime now) =>
      (_db.update(_db.groupsCache)..where((x) => x.id.equals(g.id))).write(
        GroupsCacheCompanion(updatedAt: Value(now)),
      );

  static String? _clean(String? s) =>
      s == null || s.trim().isEmpty ? null : s.trim();

  // ---------------------------------------------------------------- outbox

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _enqueue({
    required GroupRow group,
    required String entityType,
    required String entityId,
    required bool delete,
    required int baseRevision,
    required Map<String, Object?> payload,
    required DateTime now,
  }) async {
    if (!group.isShared) return;
    await _db
        .into(_db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            opId: _ids.newId(),
            groupId: group.id,
            entityType: entityType,
            entityId: entityId,
            opType: delete ? 'delete' : 'upsert',
            payload: jsonEncode(payload),
            baseRevision: baseRevision,
            createdAt: now,
          ),
        );
  }

  Future<void> _enqueueGroup(String groupId, DateTime now) async {
    final g = await (_db.select(
      _db.groupsCache,
    )..where((x) => x.id.equals(groupId))).getSingle();
    final self =
        await (_db.select(_db.groupMembersCache)
              ..where((m) => m.groupId.equals(groupId) & m.isSelf.equals(true)))
            .getSingleOrNull();
    await _enqueue(
      group: g,
      entityType: 'group',
      entityId: g.id,
      delete: false,
      baseRevision: g.revision,
      now: now,
      payload: {
        'id': g.id,
        'name': g.name,
        'description': g.description,
        'group_type': g.groupType.name,
        'currency': g.currency,
        'status': g.status.name,
        // Used by the server only when it creates the group.
        'owner_member_id': ?self?.id,
        'owner_display_name': ?self?.displayName,
      },
    );
  }

  Future<void> _enqueueMember(
    GroupRow g,
    String memberId,
    DateTime now, {
    bool delete = false,
  }) async {
    final m = await (_db.select(
      _db.groupMembersCache,
    )..where((x) => x.id.equals(memberId))).getSingle();
    // Data minimisation: participant phone numbers are never uploaded.
    await _enqueue(
      group: g,
      entityType: 'member',
      entityId: m.id,
      delete: delete,
      baseRevision: m.revision,
      now: now,
      payload: {
        'id': m.id,
        'group_id': m.groupId,
        'user_id': m.userId,
        'display_name': m.displayName,
        'role': m.role.name,
        'status': m.status.name,
        'sort_order': m.sortOrder,
        'joined_at': m.joinedAt.toUtc().toIso8601String(),
      },
    );
  }

  Future<void> _enqueueExpense(
    GroupRow g,
    String id,
    DateTime now, {
    bool delete = false,
  }) async {
    final e = await (_db.select(
      _db.groupExpensesCache,
    )..where((x) => x.id.equals(id))).getSingle();
    final splits = await (_db.select(
      _db.groupExpenseSplitsCache,
    )..where((s) => s.expenseId.equals(id))).get();
    await _enqueue(
      group: g,
      entityType: 'expense',
      entityId: e.id,
      delete: delete,
      baseRevision: e.revision,
      now: now,
      payload: {
        'id': e.id,
        'group_id': e.groupId,
        'description': e.description,
        'category_key': e.categoryKey,
        'amount_paise': e.amountPaise,
        'paid_by_member_id': e.paidByMemberId,
        'expense_date': _date(e.expenseDate),
        'split_method': e.splitMethod.name,
        'notes': e.notes,
        'splits': [
          for (final s in splits)
            {
              'id': s.id,
              'member_id': s.memberId,
              'share_paise': s.sharePaise,
              'input_value': s.inputValue,
            },
        ],
      },
    );
  }

  Future<void> _enqueueSettlement(
    GroupRow g,
    String id,
    DateTime now, {
    bool delete = false,
  }) async {
    final s = await (_db.select(
      _db.groupSettlementsCache,
    )..where((x) => x.id.equals(id))).getSingle();
    await _enqueue(
      group: g,
      entityType: 'settlement',
      entityId: s.id,
      delete: delete,
      baseRevision: s.revision,
      now: now,
      payload: {
        'id': s.id,
        'group_id': s.groupId,
        'from_member_id': s.fromMemberId,
        'to_member_id': s.toMemberId,
        'amount_paise': s.amountPaise,
        'settled_on': _date(s.settledOn),
        'payment_method': s.paymentMethod.name,
        'notes': s.notes,
      },
    );
  }
}

final groupRepositoryProvider = Provider<GroupRepository>(
  (ref) => GroupRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final groupsProvider = StreamProvider.family<List<GroupListItem>, bool>(
  (ref, includeArchived) => ref
      .watch(groupRepositoryProvider)
      .watchGroups(includeArchived: includeArchived),
);

final groupDetailProvider = StreamProvider.family<GroupDetail?, String>(
  (ref, id) => ref.watch(groupRepositoryProvider).watchGroup(id),
);

final myGroupsSummaryProvider = StreamProvider<MyGroupsSummary>(
  (ref) => ref.watch(groupRepositoryProvider).watchMySummary(),
);
