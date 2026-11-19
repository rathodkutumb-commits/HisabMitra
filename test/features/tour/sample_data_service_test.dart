import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';
import 'package:hisabmitra/features/money_ledger/data/ledger_repository.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_models.dart';
import 'package:hisabmitra/features/profile/data/profile_repository.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/tour/data/sample_data_service.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer c;

  setUp(() async {
    db = newTestDatabase();
    c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialPreferencesProvider.overrideWithValue(
          AppPreferences.fromMap(const {}).copyWith(onboardingComplete: true),
        ),
      ],
    );
    await c.read(profileRepositoryProvider).saveName('Hemang');
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<int> count(TableInfo<Table, Object?> t) async =>
      (await db.select(t).get()).length;

  test('loads a month of hisab, khata entries and a split group', () async {
    await c.read(sampleDataServiceProvider).load();

    expect(await count(db.transactions), 14);
    expect(await count(db.persons), 3);
    expect(await count(db.moneyLedger), 2);
    expect(await count(db.moneySettlements), 1);
    expect(await count(db.groupsCache), 1);
    expect(await count(db.groupMembersCache), 3);
    expect(await count(db.groupExpensesCache), 3);
    expect(await count(db.groupSettlementsCache), 1);
    expect(c.read(settingsControllerProvider).sampleDataLoaded, isTrue);

    // The group belongs to the user ("Hemang") and every split reconciles.
    final self = await (db.select(
      db.groupMembersCache,
    )..where((m) => m.isSelf.equals(true))).getSingle();
    expect(self.displayName, 'Hemang');
    for (final e in await db.select(db.groupExpensesCache).get()) {
      final splits = await (db.select(
        db.groupExpenseSplitsCache,
      )..where((s) => s.expenseId.equals(e.id))).get();
      expect(splits.fold(0, (a, s) => a + s.sharePaise), e.amountPaise);
    }
    // No entry is dated in the future.
    final now = DateTime.now();
    for (final t in await db.select(db.transactions).get()) {
      expect(t.txnDate.isAfter(now), isFalse, reason: t.description);
    }
  });

  test('loading twice does not duplicate', () async {
    await c.read(sampleDataServiceProvider).load();
    await c.read(sampleDataServiceProvider).load();
    expect(await count(db.transactions), 14);
    expect(await count(db.groupsCache), 1);
  });

  test('sample texts follow the app language', () async {
    await c
        .read(settingsControllerProvider.notifier)
        .update((p) => p.copyWith(languageCode: 'gu'));
    await c.read(sampleDataServiceProvider).load();
    final names = (await db.select(db.persons).get()).map((p) => p.name);
    expect(names, contains('રાહુલ પટેલ'));
  });

  test('removing deletes the sample data and keeps the user\'s own', () async {
    final own = await c
        .read(transactionRepositoryProvider)
        .save(
          TransactionDraft(
            type: TransactionType.expense,
            amountPaise: 9900,
            categoryId: 'cat_food',
            date: DateTime.now(),
            paymentMethod: PaymentMethod.cash,
            description: 'My own chai',
          ),
        );
    await c.read(sampleDataServiceProvider).load();
    await c.read(sampleDataServiceProvider).remove();

    final txns = await db.select(db.transactions).get();
    expect(txns.map((t) => t.id), [own]);
    expect(await count(db.persons), 0);
    expect(await count(db.moneyLedger), 0);
    expect(await count(db.moneySettlements), 0);
    expect(await count(db.groupsCache), 0);
    expect(await count(db.groupMembersCache), 0);
    expect(await count(db.groupExpenseSplitsCache), 0);
    expect(await count(db.categories), greaterThan(20), reason: 'seeds stay');
    expect(c.read(settingsControllerProvider).sampleDataLoaded, isFalse);
  });

  test('a sample person or group the user has used is kept', () async {
    await c.read(sampleDataServiceProvider).load();
    final rahul = (await db.select(db.persons).get()).firstWhere(
      (p) => p.name == 'Rahul Patel',
    );
    // The user lends Rahul money for real…
    await c
        .read(ledgerRepositoryProvider)
        .saveEntry(
          LedgerDraft(
            personId: rahul.id,
            direction: LedgerDirection.given,
            principalPaise: 50000,
            date: DateTime.now(),
            paymentMethod: PaymentMethod.cash,
            description: 'Real loan',
          ),
        );
    // …and adds a real expense to the sample trip.
    final group = await db.select(db.groupsCache).getSingle();
    final members = await (db.select(
      db.groupMembersCache,
    )..where((m) => m.groupId.equals(group.id))).get();
    await c
        .read(groupRepositoryProvider)
        .saveExpense(
          ExpenseDraft(
            groupId: group.id,
            description: 'Real breakfast',
            categoryKey: 'food',
            amountPaise: 60000,
            paidByMemberId: members.first.id,
            date: DateTime.now(),
            splitMethod: SplitMethod.equal,
            participants: [for (final m in members) SplitParticipant(m.id, 0)],
          ),
        );

    await c.read(sampleDataServiceProvider).remove();

    final people = await db.select(db.persons).get();
    expect(people.map((p) => p.name), ['Rahul Patel']);
    final ledger = await db.select(db.moneyLedger).get();
    expect(ledger.map((l) => l.description), ['Real loan']);
    expect(await count(db.groupsCache), 1, reason: 'group in use is kept');
    expect(await count(db.transactions), 0);
  });
}
