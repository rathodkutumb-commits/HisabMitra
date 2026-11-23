import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

class _Clock extends Clock {
  DateTime value = DateTime(2026, 11, 1, 10);
  @override
  DateTime now() => value;
}

class Device {
  Device(FakeCloudServer server, String uid) {
    cloud = FakeCloudClient(server, uid);
    groups = GroupRepository(db, clock, const IdGenerator());
    sync = SyncService(
      db: db,
      cloud: cloud,
      clock: clock,
      ids: const IdGenerator(),
    );
  }

  final db = newTestDatabase();
  final clock = _Clock();
  late final FakeCloudClient cloud;
  late final GroupRepository groups;
  late final SyncService sync;

  Future<GroupDetail> detail(String id) async =>
      (await groups.watchGroup(id).first)!;
}

void main() {
  late FakeCloudServer server;
  late Device a;
  late String groupId;
  late String meA;
  late String bhavna;

  ExpenseDraft hotel(
    String paidBy,
    List<String> people, {
    int amount = 100000,
    String? id,
  }) => ExpenseDraft(
    id: id,
    groupId: groupId,
    description: 'Hotel',
    categoryKey: 'stay',
    amountPaise: amount,
    paidByMemberId: paidBy,
    date: DateTime(2026, 11, 1),
    splitMethod: SplitMethod.equal,
    participants: [for (final p in people) SplitParticipant(p, 0)],
  );

  setUp(() async {
    server = FakeCloudServer();
    a = Device(server, 'user-a');
    groupId = await a.groups.createGroup(
      const GroupDraft(name: 'Goa', groupType: GroupType.trip),
      selfName: 'Amit',
      members: const [MemberDraft(name: 'Bhavna')],
    );
    final d = await a.detail(groupId);
    meA = d.selfMember!.id;
    bhavna = d.members.last.id;
    // Offline group work before sharing.
    await a.groups.saveExpense(hotel(meA, [meA, bhavna]));
  });

  tearDown(() => a.db.close());

  test(
    'sharing pushes the group, members and expenses; local rows become synced',
    () async {
      await a.groups.markShared(groupId, ownerUserId: 'user-a');
      final report = await a.sync.push();
      expect(report.applied, 3); // group (+owner member), Bhavna, expense
      expect(await a.db.select(a.db.syncOutbox).get(), isEmpty);
      expect(server.groups.keys, [groupId]);
      expect(server.members.length, 2);
      expect(server.expenses.length, 1);
      final d = await a.detail(groupId);
      expect(d.group.syncState, SyncState.synced);
      expect(d.expenses.single.expense.revision, 1);
      expect(d.expenses.single.expense.syncState, SyncState.synced);
      expect(d.selfMember!.revision, 1);
    },
  );

  test(
    'offline: operations stay queued with exponential backoff, then succeed',
    () async {
      await a.groups.markShared(groupId, ownerUserId: 'user-a');
      a.cloud.online = false;
      final report = await a.sync.push();
      expect(report.offline, isTrue);
      final ops = await a.db.select(a.db.syncOutbox).get();
      expect(ops.length, 3);
      expect(ops.first.attempts, 1);
      expect(ops.first.nextAttemptAt!.isAfter(a.clock.value), isTrue);

      a.cloud.online = true;
      expect(
        (await a.sync.push()).applied,
        0,
        reason: 'backoff not elapsed yet',
      );
      a.clock.value = a.clock.value.add(const Duration(minutes: 1));
      expect((await a.sync.push()).applied, 3);
    },
  );

  test(
    'a lost response is retried with the same op id without duplicating data',
    () async {
      await a.groups.markShared(groupId, ownerUserId: 'user-a');
      await a.sync.push();
      await a.groups.saveExpense(
        hotel(meA, [meA, bhavna], amount: 5000).copyWith(),
      );
      server.dropNextResponse = true;
      expect((await a.sync.push()).offline, isTrue);
      a.clock.value = a.clock.value.add(const Duration(minutes: 5));
      expect((await a.sync.push()).applied, 1);
      expect(server.expenses.length, 2);
      final opIds = a.cloud.applied;
      expect(
        opIds.last,
        opIds[opIds.length - 2],
        reason: 'retry reused the op id',
      );
    },
  );

  group('two devices', () {
    late Device b;
    late String bhavnaOnB;

    setUp(() async {
      await a.groups.markShared(groupId, ownerUserId: 'user-a');
      await a.sync.push();
      b = Device(server, 'user-b');
      final code = (await a.cloud.createInvitation(
        groupId: groupId,
        memberId: bhavna,
      )).code;
      final accepted = await b.cloud.acceptInvitation(
        code: code,
        displayName: 'Bhavna',
      );
      await b.sync.joinGroup(accepted.groupId!);
      bhavnaOnB = accepted.memberId;
      await a.sync.pull();
    });

    tearDown(() => b.db.close());

    test(
      'joining loads the full group and both devices agree on balances',
      () async {
        final onB = await b.detail(groupId);
        final onA = await a.detail(groupId);
        expect(onB.group.isShared, isTrue);
        expect(onB.members.length, 2);
        expect(onB.selfMember!.id, bhavnaOnB);
        expect(onB.expenses.single.expense.amountPaise, 100000);
        expect(onB.netBalances, onA.netBalances);
        expect(onA.members.firstWhere((m) => m.id == bhavna).userId, 'user-b');
      },
    );

    test('changes from one device reach the other', () async {
      final expenseId = (await b.detail(groupId)).expenses.single.expense.id;
      await b.groups.saveExpense(
        hotel(bhavnaOnB, [meA, bhavnaOnB], amount: 120000, id: expenseId),
      );
      await b.sync.syncOnce();
      await a.sync.syncOnce();
      final onA = await a.detail(groupId);
      expect(onA.expenses.single.expense.amountPaise, 120000);
      expect(onA.expenses.single.expense.paidByMemberId, bhavna);
      expect(onA.netBalances, (await b.detail(groupId)).netBalances);
    });

    test('deletions propagate as tombstones', () async {
      final expenseId = (await a.detail(groupId)).expenses.single.expense.id;
      await a.groups.deleteExpense(expenseId);
      await a.sync.syncOnce();
      await b.sync.syncOnce();
      expect((await b.detail(groupId)).expenses, isEmpty);
      final row = await (b.db.select(
        b.db.groupExpensesCache,
      )..where((e) => e.id.equals(expenseId))).getSingle();
      expect(row.deletedAt, isNotNull);
    });

    test('concurrent edits create a conflict instead of overwriting', () async {
      final expenseId = (await a.detail(groupId)).expenses.single.expense.id;
      await a.groups.saveExpense(
        hotel(meA, [meA, bhavna], amount: 110000, id: expenseId),
      );
      await b.groups.saveExpense(
        hotel(bhavnaOnB, [meA, bhavnaOnB], amount: 90000, id: expenseId),
      );
      await a.sync.syncOnce();
      final report = await b.sync.syncOnce();
      expect(report.conflicts, 1);
      final onB = await b.detail(groupId);
      expect(onB.expenses.single.expense.syncState, SyncState.conflict);
      expect(
        onB.expenses.single.expense.amountPaise,
        90000,
        reason: 'local data is not silently replaced',
      );
      final conflicts = await b.sync.openConflicts().first;
      expect(conflicts.single.entityId, expenseId);
    });

    test('resolving a conflict with the server version', () async {
      final expenseId = (await a.detail(groupId)).expenses.single.expense.id;
      await a.groups.saveExpense(
        hotel(meA, [meA, bhavna], amount: 110000, id: expenseId),
      );
      await b.groups.saveExpense(
        hotel(bhavnaOnB, [meA, bhavnaOnB], amount: 90000, id: expenseId),
      );
      await a.sync.syncOnce();
      await b.sync.syncOnce();
      final conflict = (await b.sync.openConflicts().first).single;
      await b.sync.resolveConflict(conflict.id, keepLocal: false);
      final onB = await b.detail(groupId);
      expect(onB.expenses.single.expense.amountPaise, 110000);
      expect(onB.expenses.single.expense.syncState, SyncState.synced);
      expect(await b.sync.openConflicts().first, isEmpty);
    });

    test(
      'resolving a conflict by keeping the local version re-sends it',
      () async {
        final expenseId = (await a.detail(groupId)).expenses.single.expense.id;
        await a.groups.saveExpense(
          hotel(meA, [meA, bhavna], amount: 110000, id: expenseId),
        );
        await b.groups.saveExpense(
          hotel(bhavnaOnB, [meA, bhavnaOnB], amount: 90000, id: expenseId),
        );
        await a.sync.syncOnce();
        await b.sync.syncOnce();
        final conflict = (await b.sync.openConflicts().first).single;
        await b.sync.resolveConflict(conflict.id, keepLocal: true);
        await b.sync.syncOnce();
        await a.sync.syncOnce();
        expect(
          (await a.detail(groupId)).expenses.single.expense.amountPaise,
          90000,
        );
        expect(
          (await b.detail(groupId)).expenses.single.expense.syncState,
          SyncState.synced,
        );
      },
    );

    test(
      'overview reports pending work and the last successful sync',
      () async {
        await b.groups.recordSettlement(
          SettlementDraft(
            groupId: groupId,
            fromMemberId: bhavnaOnB,
            toMemberId: meA,
            amountPaise: 10000,
            date: DateTime(2026, 11, 2),
            paymentMethod: PaymentMethod.upi,
          ),
        );
        var overview = await b.sync.watchOverview().first;
        expect(overview.pendingOps, 1);
        await b.sync.syncOnce();
        overview = await b.sync.watchOverview().first;
        expect(overview.pendingOps, 0);
        expect(overview.lastSuccessAt, isNotNull);
        await a.sync.syncOnce();
        expect((await a.detail(groupId)).settlements.single.amountPaise, 10000);
      },
    );
  });
}
