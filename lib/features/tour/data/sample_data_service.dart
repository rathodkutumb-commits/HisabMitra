import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../../groups/data/group_repository.dart';
import '../../groups/domain/group_models.dart';
import '../../groups/domain/split_calculator.dart';
import '../../money_ledger/data/ledger_repository.dart';
import '../../money_ledger/domain/ledger_models.dart';
import '../../people/data/people_repository.dart';
import '../../profile/data/profile_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_models.dart';

/// Ids of everything the sample data created, so it can be removed exactly.
class _SampleIds {
  _SampleIds();

  factory _SampleIds.fromJson(Map<String, Object?> j) {
    List<String> list(String k) =>
        ((j[k] as List?) ?? const []).cast<String>().toList();
    return _SampleIds()
      ..transactions.addAll(list('transactions'))
      ..persons.addAll(list('persons'))
      ..ledger.addAll(list('ledger'))
      ..repayments.addAll(list('repayments'))
      ..groups.addAll(list('groups'))
      ..expenses.addAll(list('expenses'))
      ..settlements.addAll(list('settlements'));
  }

  final transactions = <String>[];
  final persons = <String>[];
  final ledger = <String>[];
  final repayments = <String>[];
  final groups = <String>[];
  final expenses = <String>[];
  final settlements = <String>[];

  Map<String, Object?> toJson() => {
    'transactions': transactions,
    'persons': persons,
    'ledger': ledger,
    'repayments': repayments,
    'groups': groups,
    'expenses': expenses,
    'settlements': settlements,
  };
}

/// Sample texts in the app language. They are data, not UI strings: once
/// created they behave like the user's own entries.
Map<String, String> _texts(String languageCode) => languageCode == 'gu'
    ? const {
        'rahul': 'રાહુલ પટેલ',
        'priya': 'પ્રિયા શાહ',
        'amit': 'અમિત મહેતા',
        'salary': 'માસિક પગાર',
        'freelance': 'વેબસાઇટ પ્રોજેક્ટ',
        'rent': 'ઘરનું ભાડું',
        'groceries': 'મહિનાનું કરિયાણું',
        'electricity': 'વીજળી બિલ',
        'mobile': 'મોબાઇલ રિચાર્જ',
        'fuel': 'પેટ્રોલ',
        'sweets': 'દિવાળીની મીઠાઈ',
        'medicine': 'દવાઓ',
        'movie': 'ફિલ્મ',
        'shoes': 'નવા બૂટ',
        'loanRahul': 'બાઇક રિપેર માટે ઉધાર',
        'loanPriya': 'સ્કૂલ ફી માટે લીધા',
        'group': 'ગોવા પ્રવાસ',
        'groupDesc': 'નમૂનાનું ગ્રુપ',
        'hotel': 'હોટેલ',
        'dinner': 'દરિયાકાંઠે ડિનર',
        'taxi': 'ટેક્સી',
        'sample': 'નમૂનો',
      }
    : const {
        'rahul': 'Rahul Patel',
        'priya': 'Priya Shah',
        'amit': 'Amit Mehta',
        'salary': 'Monthly salary',
        'freelance': 'Website project',
        'rent': 'House rent',
        'groceries': 'Monthly groceries',
        'electricity': 'Electricity bill',
        'mobile': 'Mobile recharge',
        'fuel': 'Petrol',
        'sweets': 'Diwali sweets',
        'medicine': 'Medicines',
        'movie': 'Movie night',
        'shoes': 'New shoes',
        'loanRahul': 'Loan for bike repair',
        'loanPriya': 'Borrowed for school fees',
        'group': 'Goa Trip',
        'groupDesc': 'Sample group',
        'hotel': 'Hotel',
        'dinner': 'Dinner at the beach',
        'taxi': 'Taxi',
        'sample': 'Sample',
      };

/// Creates and removes the guided tour's sample data: two months of income
/// and expenses, money lent and borrowed, and a split trip group. Everything
/// is created through the normal repositories, so it follows the same money
/// rules as the user's own records.
class SampleDataService {
  SampleDataService(this._ref);

  final Ref _ref;

  static const _idsKey = 'tour.sampleIds';

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  Future<void> load() async {
    final prefs = _ref.read(settingsControllerProvider);
    if (prefs.sampleDataLoaded) return;
    final t = _texts(prefs.languageCode);
    final ids = _SampleIds();
    final now = _ref.read(clockProvider).now();
    final today = DateTime(now.year, now.month, now.day);
    // Never in the future, even early in the month.
    DateTime thisMonth(int day) =>
        DateTime(now.year, now.month, day.clamp(1, now.day));
    DateTime lastMonth(int day) => DateTime(now.year, now.month - 1, day);

    // People
    final people = _ref.read(peopleRepositoryProvider);
    Future<String> person(String name) async {
      final id = await people.save(
        PersonDraft(name: name, description: t['sample']),
      );
      ids.persons.add(id);
      return id;
    }

    final rahul = await person(t['rahul']!);
    final priya = await person(t['priya']!);
    await person(t['amit']!);

    // Income and expense, this month and last month
    final txns = _ref.read(transactionRepositoryProvider);
    Future<void> txn(
      TransactionType type,
      int rupees,
      int paise,
      String category,
      DateTime date,
      PaymentMethod method,
      String text,
    ) async => ids.transactions.add(
      await txns.save(
        TransactionDraft(
          type: type,
          amountPaise: rupees * 100 + paise,
          categoryId: 'cat_$category',
          date: date,
          paymentMethod: method,
          description: t[text]!,
        ),
      ),
    );

    const income = TransactionType.income;
    const expense = TransactionType.expense;
    const bank = PaymentMethod.bankTransfer;
    const upi = PaymentMethod.upi;
    const cash = PaymentMethod.cash;
    await txn(income, 45000, 0, 'salary', thisMonth(1), bank, 'salary');
    await txn(income, 8000, 0, 'freelance', thisMonth(5), upi, 'freelance');
    await txn(expense, 15000, 0, 'rent', thisMonth(2), bank, 'rent');
    await txn(expense, 3250, 50, 'groceries', thisMonth(3), upi, 'groceries');
    await txn(expense, 1840, 0, 'bills', thisMonth(6), upi, 'electricity');
    await txn(expense, 599, 0, 'mobile', thisMonth(7), upi, 'mobile');
    await txn(
      expense,
      2000,
      0,
      'fuel',
      thisMonth(8),
      PaymentMethod.debitCard,
      'fuel',
    );
    await txn(expense, 1200, 0, 'festivals', thisMonth(10), cash, 'sweets');
    await txn(expense, 450, 0, 'health', thisMonth(12), cash, 'medicine');
    await txn(income, 45000, 0, 'salary', lastMonth(1), bank, 'salary');
    await txn(expense, 15000, 0, 'rent', lastMonth(2), bank, 'rent');
    await txn(expense, 2980, 0, 'groceries', lastMonth(4), upi, 'groceries');
    await txn(expense, 900, 0, 'entertainment', lastMonth(14), upi, 'movie');
    await txn(expense, 2499, 0, 'shopping', lastMonth(20), upi, 'shoes');

    // Khata: lent to Rahul (partly repaid), borrowed from Priya
    final ledger = _ref.read(ledgerRepositoryProvider);
    final lent = await ledger.saveEntry(
      LedgerDraft(
        personId: rahul,
        direction: LedgerDirection.given,
        principalPaise: 500000,
        date: today.subtract(const Duration(days: 20)),
        dueDate: today.add(const Duration(days: 15)),
        paymentMethod: upi,
        description: t['loanRahul']!,
      ),
    );
    ids.ledger.add(lent);
    ids.repayments.add(
      await ledger.addRepayment(
        RepaymentDraft(
          ledgerId: lent,
          amountPaise: 200000,
          date: today.subtract(const Duration(days: 5)),
          paymentMethod: upi,
        ),
      ),
    );
    ids.ledger.add(
      await ledger.saveEntry(
        LedgerDraft(
          personId: priya,
          direction: LedgerDirection.taken,
          principalPaise: 300000,
          date: today.subtract(const Duration(days: 8)),
          dueDate: today.add(const Duration(days: 10)),
          paymentMethod: cash,
          description: t['loanPriya']!,
        ),
      ),
    );

    // Group: a trip split three ways, with one settle-up
    final groups = _ref.read(groupRepositoryProvider);
    final selfName =
        (await _ref.read(profileRepositoryProvider).get())?.displayName ?? 'Me';
    final groupId = await groups.createGroup(
      GroupDraft(
        name: t['group']!,
        description: t['groupDesc'],
        groupType: GroupType.trip,
      ),
      selfName: selfName,
      members: [
        MemberDraft(name: t['rahul']!),
        MemberDraft(name: t['amit']!),
      ],
    );
    ids.groups.add(groupId);
    final members =
        await (_db.select(_db.groupMembersCache)
              ..where((m) => m.groupId.equals(groupId))
              ..orderBy([(m) => OrderingTerm.asc(m.sortOrder)]))
            .get();
    final me = members[0].id, mRahul = members[1].id, mAmit = members[2].id;
    final everyone = [for (final m in members) SplitParticipant(m.id, 0)];
    Future<void> groupExpense(
      String text,
      String category,
      int rupees,
      String paidBy,
      int daysAgo,
    ) async => ids.expenses.add(
      await groups.saveExpense(
        ExpenseDraft(
          groupId: groupId,
          description: t[text]!,
          categoryKey: category,
          amountPaise: rupees * 100,
          paidByMemberId: paidBy,
          date: today.subtract(Duration(days: daysAgo)),
          splitMethod: SplitMethod.equal,
          participants: everyone,
        ),
      ),
    );
    await groupExpense('hotel', 'stay', 12000, me, 12);
    await groupExpense('dinner', 'food', 3600, mRahul, 11);
    await groupExpense('taxi', 'travel', 1500, mAmit, 10);
    ids.settlements.add(
      await groups.recordSettlement(
        SettlementDraft(
          groupId: groupId,
          fromMemberId: mAmit,
          toMemberId: me,
          amountPaise: 200000,
          date: today.subtract(const Duration(days: 3)),
          paymentMethod: upi,
        ),
      ),
    );

    await _writeIds(ids);
    await _ref
        .read(settingsControllerProvider.notifier)
        .update((p) => p.copyWith(sampleDataLoaded: true));
  }

  /// Removes the sample data. Anything the user created stays: a sample
  /// person or group that the user has used for their own entries is kept
  /// (only the sample entries inside it are removed).
  Future<void> remove() async {
    final ids = await _readIds();
    if (ids != null) {
      final groups = _ref.read(groupRepositoryProvider);
      await _db.transaction(() async {
        await (_db.delete(
          _db.transactions,
        )..where((t) => t.id.isIn(ids.transactions))).go();

        await (_db.delete(
          _db.moneySettlements,
        )..where((s) => s.id.isIn(ids.repayments))).go();
        for (final entryId in ids.ledger) {
          final others = await (_db.select(
            _db.moneySettlements,
          )..where((s) => s.ledgerId.equals(entryId))).get();
          if (others.isEmpty) {
            await (_db.delete(
              _db.moneyLedger,
            )..where((l) => l.id.equals(entryId))).go();
          }
        }

        for (final groupId in ids.groups) {
          final group = await (_db.select(
            _db.groupsCache,
          )..where((g) => g.id.equals(groupId))).getSingleOrNull();
          if (group == null) continue;
          final ownExpenses =
              await (_db.select(_db.groupExpensesCache)..where(
                    (e) =>
                        e.groupId.equals(groupId) &
                        e.deletedAt.isNull() &
                        e.id.isNotIn(ids.expenses),
                  ))
                  .get();
          final ownSettlements =
              await (_db.select(_db.groupSettlementsCache)..where(
                    (s) =>
                        s.groupId.equals(groupId) &
                        s.deletedAt.isNull() &
                        s.id.isNotIn(ids.settlements),
                  ))
                  .get();
          if (ownExpenses.isEmpty &&
              ownSettlements.isEmpty &&
              !group.isShared) {
            await groups.deleteLocalGroup(groupId);
            continue;
          }
          // The user has used the group: keep it, remove only samples.
          for (final s in ids.settlements) {
            await _ignoreMissing(() => groups.deleteSettlement(s));
          }
          for (final e in ids.expenses) {
            await _ignoreMissing(() => groups.deleteExpense(e));
          }
        }

        for (final personId in ids.persons) {
          final used =
              await _exists(
                _db.select(_db.transactions)
                  ..where((t) => t.personId.equals(personId)),
              ) ||
              await _exists(
                _db.select(_db.moneyLedger)
                  ..where((l) => l.personId.equals(personId)),
              ) ||
              await _exists(
                _db.select(_db.groupMembersCache)
                  ..where((m) => m.personId.equals(personId)),
              ) ||
              await _exists(
                _db.select(_db.reminders)
                  ..where((r) => r.personId.equals(personId)),
              );
          if (!used) {
            await (_db.delete(
              _db.persons,
            )..where((p) => p.id.equals(personId))).go();
          }
        }
        await (_db.delete(
          _db.appSettings,
        )..where((s) => s.key.equals(_idsKey))).go();
      });
    }
    await _ref
        .read(settingsControllerProvider.notifier)
        .update((p) => p.copyWith(sampleDataLoaded: false));
  }

  static Future<bool> _exists<T extends HasResultSet, R>(
    SimpleSelectStatement<T, R> q,
  ) async => (await (q..limit(1)).get()).isNotEmpty;

  static Future<void> _ignoreMissing(Future<void> Function() action) async {
    try {
      await action();
    } on NotFoundFailure {
      // Already removed by the user.
    }
  }

  Future<void> _writeIds(_SampleIds ids) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: _idsKey,
          value: jsonEncode(ids.toJson()),
          updatedAt: _ref.read(clockProvider).now(),
        ),
      );

  Future<_SampleIds?> _readIds() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(_idsKey))).getSingleOrNull();
    if (row == null) return null;
    return _SampleIds.fromJson(
      (jsonDecode(row.value) as Map).cast<String, Object?>(),
    );
  }
}

final sampleDataServiceProvider = Provider<SampleDataService>(
  SampleDataService.new,
);
