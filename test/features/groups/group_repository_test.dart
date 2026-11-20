import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late GroupRepository groups;
  late String groupId;
  late Map<String, String> m; // name → member id

  setUp(() async {
    db = newTestDatabase();
    groups = GroupRepository(
      db,
      _Fixed(DateTime(2026, 5, 1)),
      const IdGenerator(),
    );
    groupId = await groups.createGroup(
      const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
      selfName: 'Me',
      members: const [
        MemberDraft(name: 'Amit'),
        MemberDraft(name: 'Priya'),
        MemberDraft(name: 'Ravi'),
      ],
    );
    final detail = await groups.watchGroup(groupId).first;
    m = {for (final mem in detail!.members) mem.displayName: mem.id};
  });
  tearDown(() => db.close());

  test('watchGroup().first resolves while the group screen is already listening', () async {
    // The group screen keeps watchGroup open; the expense form then asks for a
    // one-off snapshot of the same group.
    final screen = groups.watchGroup(groupId).listen((_) {});
    addTearDown(screen.cancel);
    await pumpEventQueue();

    final snapshot = await groups
        .watchGroup(groupId)
        .first
        .timeout(const Duration(seconds: 2));
    expect(snapshot!.members, hasLength(4));
  });

  ExpenseDraft expense(
    int paise,
    String payer, {
    SplitMethod method = SplitMethod.equal,
    List<SplitParticipant>? participants,
  }) => ExpenseDraft(
    groupId: groupId,
    description: 'Dinner',
    categoryKey: 'food',
    amountPaise: paise,
    paidByMemberId: m[payer]!,
    date: DateTime(2026, 5, 2),
    splitMethod: method,
    participants:
        participants ?? [for (final id in m.values) SplitParticipant(id, 0)],
  );

  test(
    'creating a group adds the owner first and the members in order',
    () async {
      final detail = await groups.watchGroup(groupId).first;
      expect(detail!.members.map((x) => x.displayName).toList(), [
        'Me',
        'Amit',
        'Priya',
        'Ravi',
      ]);
      expect(detail.members.first.isSelf, isTrue);
      expect(detail.members.first.role, MemberRole.owner);
    },
  );

  test('equal expense of ₹1,000 among 4 → payer +₹750, others −₹250', () async {
    await groups.saveExpense(expense(100000, 'Me'));
    final detail = await groups.watchGroup(groupId).first;
    expect(detail!.expenses.single.splits.values.toSet(), {25000});
    expect(detail.netBalances[m['Me']], 75000);
    expect(detail.netBalances[m['Amit']], -25000);
    expect(detail.suggestions.length, 3);
    expect(detail.totalSpentPaise, 100000);
  });

  test('invalid split is rejected and nothing is written', () async {
    expect(
      () => groups.saveExpense(
        expense(
          1000,
          'Me',
          method: SplitMethod.exact,
          participants: [
            SplitParticipant(m['Me']!, 400),
            SplitParticipant(m['Amit']!, 400),
          ],
        ),
      ),
      throwsA(isA<SplitValidationFailure>()),
    );
    final detail = await groups.watchGroup(groupId).first;
    expect(detail!.expenses, isEmpty);
  });

  test('editing an expense replaces its splits', () async {
    final id = await groups.saveExpense(expense(100000, 'Me'));
    await groups.saveExpense(
      expense(
        60000,
        'Amit',
        participants: [
          SplitParticipant(m['Me']!, 0),
          SplitParticipant(m['Amit']!, 0),
        ],
      ).copyWith(id: id),
    );
    final detail = await groups.watchGroup(groupId).first;
    final e = detail!.expenses.single;
    expect(e.splits, {m['Me']: 30000, m['Amit']: 30000});
    expect(detail.netBalances[m['Me']], -30000);
  });

  test(
    'partial settlement reduces the debt; over-settlement is rejected',
    () async {
      await groups.saveExpense(expense(100000, 'Me'));
      await groups.recordSettlement(
        SettlementDraft(
          groupId: groupId,
          fromMemberId: m['Amit']!,
          toMemberId: m['Me']!,
          amountPaise: 10000,
          date: DateTime(2026, 5, 3),
          paymentMethod: PaymentMethod.upi,
        ),
      );
      var detail = await groups.watchGroup(groupId).first;
      expect(detail!.netBalances[m['Amit']], -15000);
      expect(detail.settlements.length, 1);
      // The expense itself is unchanged by settlements.
      expect(detail.expenses.single.expense.amountPaise, 100000);

      expect(
        () => groups.recordSettlement(
          SettlementDraft(
            groupId: groupId,
            fromMemberId: m['Amit']!,
            toMemberId: m['Me']!,
            amountPaise: 20000,
            date: DateTime(2026, 5, 3),
            paymentMethod: PaymentMethod.upi,
          ),
        ),
        throwsA(isA<ValidationFailure>()),
      );
      detail = await groups.watchGroup(groupId).first;
      expect(detail!.settlements.length, 1);
    },
  );

  test('deleted expenses are tombstoned and excluded from balances', () async {
    final id = await groups.saveExpense(expense(100000, 'Me'));
    await groups.deleteExpense(id);
    final detail = await groups.watchGroup(groupId).first;
    expect(detail!.expenses, isEmpty);
    expect(detail.netBalances.values.every((v) => v == 0), isTrue);
    final row = await (db.select(
      db.groupExpensesCache,
    )..where((e) => e.id.equals(id))).getSingle();
    expect(row.deletedAt, isNotNull);
  });

  test('member with expenses cannot be removed; unused member can', () async {
    await groups.saveExpense(
      expense(
        1000,
        'Amit',
        participants: [
          SplitParticipant(m['Me']!, 0),
          SplitParticipant(m['Amit']!, 0),
        ],
      ),
    );
    expect(
      () => groups.removeMember(m['Amit']!),
      throwsA(isA<ValidationFailure>()),
    );
    await groups.removeMember(m['Ravi']!);
    final detail = await groups.watchGroup(groupId).first;
    expect(detail!.members.map((x) => x.displayName), isNot(contains('Ravi')));
  });

  test('archived groups are hidden from the active list', () async {
    await groups.setArchived(groupId, archived: true);
    final active = await groups.watchGroups().first;
    expect(active, isEmpty);
    final all = await groups.watchGroups(includeArchived: true).first;
    expect(all.single.group.status, GroupStatus.archived);
  });

  test('local groups write no outbox operations', () async {
    await groups.saveExpense(expense(100000, 'Me'));
    expect(await db.select(db.syncOutbox).get(), isEmpty);
  });

  test('shared groups enqueue an outbox op in the same transaction', () async {
    await groups.markShared(groupId);
    await db.delete(db.syncOutbox).go();
    final id = await groups.saveExpense(expense(100000, 'Me'));
    final ops = await db.select(db.syncOutbox).get();
    expect(ops.single.entityType, 'expense');
    expect(ops.single.entityId, id);
    expect(ops.single.opType, 'upsert');
    final row = await (db.select(
      db.groupExpensesCache,
    )..where((e) => e.id.equals(id))).getSingle();
    expect(row.syncState, SyncState.pending);
  });

  test('my summary across groups uses the self member', () async {
    await groups.saveExpense(expense(100000, 'Amit'));
    final summary = await groups.watchMySummary().first;
    expect(summary.activeGroups, 1);
    expect(summary.iOwePaise, 25000);
    expect(summary.owedToMePaise, 0);
  });

  group('groups are saved to the account', () {
    test('a new group is shared and queued when signed in', () async {
      final signedIn = GroupRepository(
        db,
        _Fixed(DateTime(2026, 5, 1)),
        const IdGenerator(),
        currentUserId: () => 'hemang',
      );
      await db.delete(db.syncOutbox).go();
      final id = await signedIn.createGroup(
        const GroupDraft(name: 'Family', groupType: GroupType.family),
        selfName: 'Hemang',
        members: const [MemberDraft(name: 'Priya')],
      );
      final g = (await signedIn.watchGroup(id).first)!;
      expect(g.group.isShared, isTrue);
      final self = g.members.firstWhere((x) => x.isSelf);
      expect(self.userId, 'hemang');
      final ops = await db.select(db.syncOutbox).get();
      expect(ops.map((o) => o.entityType), containsAll(['group', 'member']));
      expect(ops.every((o) => o.scope == 'group' && o.groupId == id), isTrue);
    });

    test('a new group stays on the phone when not signed in', () async {
      await db.delete(db.syncOutbox).go();
      final id = await groups.createGroup(
        const GroupDraft(name: 'Family', groupType: GroupType.family),
        selfName: 'Hemang',
      );
      expect((await groups.watchGroup(id).first)!.group.isShared, isFalse);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });

    test('a group made with cloud: false stays on the phone', () async {
      final signedIn = GroupRepository(
        db,
        _Fixed(DateTime(2026, 5, 1)),
        const IdGenerator(),
        currentUserId: () => 'hemang',
      );
      await db.delete(db.syncOutbox).go();
      final id = await signedIn.createGroup(
        const GroupDraft(name: 'Sample trip', groupType: GroupType.trip),
        selfName: 'Hemang',
        cloud: false,
      );
      expect((await signedIn.watchGroup(id).first)!.group.isShared, isFalse);
      expect(await db.select(db.syncOutbox).get(), isEmpty);
    });
  });
}

class _Fixed extends Clock {
  _Fixed(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}
