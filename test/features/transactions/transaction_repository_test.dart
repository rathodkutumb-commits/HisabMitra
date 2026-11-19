import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/core/utils/date_range.dart';
import 'package:hisabmitra/features/categories/data/category_repository.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/test_db.dart';

class _FixedClock extends Clock {
  _FixedClock(this.value);
  DateTime value;
  @override
  DateTime now() => value;
}

void main() {
  late AppDatabase db;
  late TransactionRepository txns;
  late CategoryRepository categories;
  final clock = _FixedClock(DateTime(2026, 3, 15, 10));

  TransactionDraft draft({
    TransactionType type = TransactionType.expense,
    int amount = 10000,
    String category = 'cat_food',
    DateTime? date,
    String description = 'Lunch',
    PaymentMethod method = PaymentMethod.upi,
    String? personId,
  }) => TransactionDraft(
    type: type,
    amountPaise: amount,
    categoryId: category,
    date: date ?? DateTime(2026, 3, 10),
    paymentMethod: method,
    description: description,
    personId: personId,
  );

  setUp(() {
    db = newTestDatabase();
    txns = TransactionRepository(db, clock, const IdGenerator());
    categories = CategoryRepository(db, clock, const IdGenerator());
  });
  tearDown(() => db.close());

  group('save', () {
    test('creates and reads back a transaction with its category', () async {
      final id = await txns.save(draft());
      final view = await txns.getById(id);
      expect(view!.txn.amountPaise, 10000);
      expect(view.category.id, 'cat_food');
      expect(view.txn.ownerId, localOwnerId);
    });

    test('updates an existing transaction and bumps updatedAt', () async {
      final id = await txns.save(draft());
      clock.value = DateTime(2026, 3, 16);
      await txns.save(draft(amount: 25050).copyWith(id: id));
      final view = await txns.getById(id);
      expect(view!.txn.amountPaise, 25050);
      expect(view.txn.updatedAt, DateTime(2026, 3, 16));
      expect(view.txn.createdAt, DateTime(2026, 3, 15, 10));
    });

    test('rejects a category of the wrong type', () async {
      expect(
        () => txns.save(
          draft(type: TransactionType.income, category: 'cat_food'),
        ),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('rejects non-positive amounts', () async {
      expect(
        () => txns.save(draft(amount: 0)),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test('deletes a transaction', () async {
      final id = await txns.save(draft());
      await txns.delete(id);
      expect(await txns.getById(id), isNull);
    });
  });

  group('query', () {
    setUp(() async {
      await txns.save(draft(amount: 10000, description: 'Lunch at Swati'));
      await txns.save(
        draft(
          amount: 50000,
          category: 'cat_groceries',
          description: 'Kariyana',
        ),
      );
      await txns.save(
        draft(
          type: TransactionType.income,
          amount: 5000000,
          category: 'cat_salary',
          description: 'March salary',
          method: PaymentMethod.bankTransfer,
        ),
      );
      await txns.save(
        draft(amount: 7000, date: DateTime(2026, 2, 20), description: 'Chai'),
      );
    });

    test('filters by date range', () async {
      final march = await txns
          .watch(TransactionFilter(range: DateRange.month(2026, 3)))
          .first;
      expect(march.length, 3);
    });

    test('filters by type and category', () async {
      final expenses = await txns
          .watch(const TransactionFilter(type: TransactionType.expense))
          .first;
      expect(expenses.length, 3);
      final groceries = await txns
          .watch(const TransactionFilter(categoryId: 'cat_groceries'))
          .first;
      expect(groceries.single.txn.description, 'Kariyana');
    });

    test('searches description case-insensitively', () async {
      final result = await txns
          .watch(const TransactionFilter(query: 'swati'))
          .first;
      expect(result.single.txn.amountPaise, 10000);
    });

    test('searches by category name', () async {
      final result = await txns
          .watch(const TransactionFilter(query: 'Salary'))
          .first;
      expect(result.single.txn.type, TransactionType.income);
    });

    test('lists newest first', () async {
      final all = await txns.watch(const TransactionFilter()).first;
      expect(all.last.txn.description, 'Chai');
    });

    test('period summary separates income and expense', () async {
      final s = await txns.watchSummary(DateRange.month(2026, 3)).first;
      expect(s.incomePaise, 5000000);
      expect(s.expensePaise, 60000);
      expect(s.balancePaise, 4940000);
    });

    test('category totals sorted by amount', () async {
      final totals = await txns
          .watchCategoryTotals(
            DateRange.month(2026, 3),
            TransactionType.expense,
          )
          .first;
      expect(totals.map((t) => t.category.id).toList(), [
        'cat_groceries',
        'cat_food',
      ]);
      expect(totals.first.totalPaise, 50000);
    });

    test('monthly totals per bucket', () async {
      final months = await txns.watchMonthly([
        DateRange.month(2026, 2),
        DateRange.month(2026, 3),
      ]).first;
      expect(months[0].expensePaise, 7000);
      expect(months[1].incomePaise, 5000000);
    });

    test('payment method totals for expenses', () async {
      final totals = await txns
          .watchPaymentMethodTotals(
            DateRange.month(2026, 3),
            TransactionType.expense,
          )
          .first;
      expect(totals.single.method, PaymentMethod.upi);
      expect(totals.single.totalPaise, 60000);
    });
  });

  group('categories', () {
    test('category in use cannot be deleted without reassignment', () async {
      await txns.save(draft());
      expect(
        () => categories.delete('cat_food'),
        throwsA(isA<InUseFailure>().having((f) => f.count, 'count', 1)),
      );
    });

    test('reassigns transactions then deletes the category', () async {
      final id = await txns.save(draft());
      await categories.delete('cat_food', reassignTo: 'cat_groceries');
      final view = await txns.getById(id);
      expect(view!.category.id, 'cat_groceries');
      final all = await categories.watchAll(TransactionType.expense).first;
      expect(all.any((c) => c.id == 'cat_food'), isFalse);
    });

    test('reassignment to a category of another type is rejected', () async {
      await txns.save(draft());
      expect(
        () => categories.delete('cat_food', reassignTo: 'cat_salary'),
        throwsA(isA<ValidationFailure>()),
      );
    });

    test(
      'creates a custom category and renaming a built-in clears its key',
      () async {
        final id = await categories.save(
          const CategoryDraft(
            name: 'Tiffin',
            type: TransactionType.expense,
            iconKey: 'restaurant',
            colorValue: 0xFF0F5C41,
          ),
        );
        final created = await categories.getById(id);
        expect(created!.systemKey, isNull);

        await categories.save(
          const CategoryDraft(
            id: 'cat_food',
            name: 'Bahar nu khavanu',
            type: TransactionType.expense,
            iconKey: 'restaurant',
            colorValue: 0xFFE76F3C,
          ),
        );
        final renamed = await categories.getById('cat_food');
        expect(renamed!.systemKey, isNull);
        expect(renamed.name, 'Bahar nu khavanu');
      },
    );
  });
}
