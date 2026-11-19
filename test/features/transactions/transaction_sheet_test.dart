import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_sheet.dart';

import '../../helpers/test_db.dart';

class _StepClock extends Clock {
  var _t = DateTime(2026, 3, 20, 9);
  @override
  DateTime now() => _t = _t.add(const Duration(minutes: 1));
}

void main() {
  late AppDatabase db;
  late TransactionRepository txns;

  setUp(() {
    db = newTestDatabase();
    txns = TransactionRepository(db, _StepClock(), const IdGenerator());
  });
  tearDown(() => db.close());

  Future<void> add(
    TransactionType type,
    int paise,
    DateTime date, [
    String description = '',
  ]) => txns.save(
    TransactionDraft(
      type: type,
      amountPaise: paise,
      categoryId: type == TransactionType.income ? 'cat_salary' : 'cat_food',
      date: date,
      paymentMethod: PaymentMethod.cash,
      description: description,
    ),
  );

  test('rows run oldest first with a running balance and totals', () async {
    await add(TransactionType.expense, 25050, DateTime(2026, 3, 5), 'Milk');
    await add(TransactionType.income, 4500000, DateTime(2026, 3, 1), 'Pay');
    await add(TransactionType.expense, 125000, DateTime(2026, 3, 5), 'Rent');
    // The repository lists newest first, as the list view shows them.
    final items = await txns.watch(const TransactionFilter()).first;

    final sheet = TransactionSheet.from(items);

    expect(
      [for (final r in sheet.rows) r.view.txn.description],
      [
        'Pay',
        'Milk', // same day: in the order they were entered
        'Rent',
      ],
    );
    expect([for (final r in sheet.rows) r.incomePaise], [4500000, 0, 0]);
    expect([for (final r in sheet.rows) r.expensePaise], [0, 25050, 125000]);
    expect(
      [for (final r in sheet.rows) r.runningBalancePaise],
      [4500000, 4474950, 4349950],
    );
    expect(sheet.totalIncomePaise, 4500000);
    expect(sheet.totalExpensePaise, 150050);
    expect(sheet.netPaise, 4349950);
    expect(sheet.netPaise, sheet.rows.last.runningBalancePaise);
  });

  test('an empty list gives an empty sheet with zero totals', () {
    final sheet = TransactionSheet.from(const []);
    expect(sheet.rows, isEmpty);
    expect(sheet.totalIncomePaise, 0);
    expect(sheet.totalExpensePaise, 0);
    expect(sheet.netPaise, 0);
  });

  test('balance can go negative and stays exact in paise', () async {
    await add(TransactionType.expense, 1, DateTime(2026, 3, 1));
    await add(TransactionType.expense, 2, DateTime(2026, 3, 2));
    final sheet = TransactionSheet.from(
      await txns.watch(const TransactionFilter()).first,
    );
    expect([for (final r in sheet.rows) r.runningBalancePaise], [-1, -3]);
  });
}
