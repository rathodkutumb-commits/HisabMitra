import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/money_ledger/data/ledger_repository.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_calculator.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_models.dart';
import 'package:hisabmitra/features/people/data/people_repository.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late PeopleRepository people;
  late LedgerRepository ledger;
  late String rahul;
  final now = DateTime(2026, 4, 1, 9);

  setUp(() async {
    db = newTestDatabase();
    final clock = _Fixed(now);
    people = PeopleRepository(db, clock, const IdGenerator());
    ledger = LedgerRepository(db, clock, const IdGenerator());
    rahul = await people.save(
      const PersonDraft(name: 'Rahul', phone: '9876543210'),
    );
  });
  tearDown(() => db.close());

  LedgerDraft given(
    int paise, {
    LedgerDirection direction = LedgerDirection.given,
  }) => LedgerDraft(
    personId: rahul,
    direction: direction,
    principalPaise: paise,
    date: DateTime(2026, 3, 1),
    paymentMethod: PaymentMethod.cash,
    description: 'Loan',
  );

  test('people repository normalises phone and validates name', () async {
    final p = await people.getById(rahul);
    expect(p!.phone, '+919876543210');
    expect(
      () => people.save(const PersonDraft(name: '  ')),
      throwsA(isA<ValidationFailure>()),
    );
    expect(
      () => people.save(const PersonDraft(name: 'X', phone: '123')),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('gave ₹5,000 then received ₹2,000 back → ₹3,000 receivable', () async {
    final id = await ledger.saveEntry(given(500000));
    await ledger.addRepayment(
      RepaymentDraft(
        ledgerId: id,
        amountPaise: 200000,
        date: DateTime(2026, 3, 5),
        paymentMethod: PaymentMethod.upi,
      ),
    );
    final entry = await ledger.watchEntry(id).first;
    expect(entry!.summary.outstandingPaise, 300000);
    expect(entry.summary.status, LedgerStatus.partial);
    expect(entry.repayments.length, 1);

    final balance = await people.watchBalance(rahul).first;
    expect(balance.receivablePaise, 300000);
    expect(balance.netPaise, 300000);
  });

  test('borrowed ₹10,000, returned ₹3,000 → ₹7,000 payable', () async {
    final id = await ledger.saveEntry(
      given(1000000, direction: LedgerDirection.taken),
    );
    await ledger.addRepayment(
      RepaymentDraft(
        ledgerId: id,
        amountPaise: 300000,
        date: DateTime(2026, 3, 5),
        paymentMethod: PaymentMethod.cash,
      ),
    );
    final totals = await ledger.watchTotals().first;
    expect(totals.payablePaise, 700000);
    expect(totals.receivablePaise, 0);
  });

  test('repayment above outstanding is rejected', () async {
    final id = await ledger.saveEntry(given(100000));
    expect(
      () => ledger.addRepayment(
        RepaymentDraft(
          ledgerId: id,
          amountPaise: 150000,
          date: now,
          paymentMethod: PaymentMethod.cash,
        ),
      ),
      throwsA(
        isA<RepaymentExceedsFailure>().having(
          (f) => f.excessPaise,
          'excess',
          50000,
        ),
      ),
    );
    final entry = await ledger.watchEntry(id).first;
    expect(entry!.repayments, isEmpty);
  });

  test('explicit advance: settles the entry and records the excess as a new opposite entry', () async {
    final id = await ledger.saveEntry(given(100000));
    await ledger.addRepayment(
      RepaymentDraft(
        ledgerId: id,
        amountPaise: 150000,
        date: now,
        paymentMethod: PaymentMethod.cash,
      ),
      recordExcessAsAdvance: true,
    );
    final entries = await ledger.watchEntries(personId: rahul).first;
    expect(entries.length, 2);
    final original = entries.firstWhere((e) => e.entry.id == id);
    expect(original.summary.status, LedgerStatus.settled);
    final advance = entries.firstWhere((e) => e.entry.id != id);
    expect(advance.entry.direction, LedgerDirection.taken);
    expect(advance.entry.principalPaise, 50000);

    final balance = await people.watchBalance(rahul).first;
    expect(balance.netPaise, -50000); // I now owe Rahul ₹500.
  });

  test('principal cannot be edited below the amount already repaid', () async {
    final id = await ledger.saveEntry(given(100000));
    await ledger.addRepayment(
      RepaymentDraft(
        ledgerId: id,
        amountPaise: 60000,
        date: now,
        paymentMethod: PaymentMethod.cash,
      ),
    );
    expect(
      () => ledger.saveEntry(given(50000).copyWith(id: id)),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('person with outstanding balance cannot be deleted', () async {
    await ledger.saveEntry(given(100000));
    expect(() => people.delete(rahul), throwsA(isA<ValidationFailure>()));
  });

  test(
    'person with settled history can be deleted (history cascades)',
    () async {
      final id = await ledger.saveEntry(given(100000));
      await ledger.addRepayment(
        RepaymentDraft(
          ledgerId: id,
          amountPaise: 100000,
          date: now,
          paymentMethod: PaymentMethod.cash,
        ),
      );
      await people.delete(rahul);
      expect(await ledger.watchEntries().first, isEmpty);
    },
  );

  test('due soon lists open entries with due dates in the window', () async {
    await ledger.saveEntry(
      given(100000).copyWith(dueDate: DateTime(2026, 4, 3)),
    );
    await ledger.saveEntry(
      given(200000).copyWith(dueDate: DateTime(2026, 6, 1)),
    );
    final due = await ledger.watchDueBefore(DateTime(2026, 4, 8)).first;
    expect(due.length, 1);
    expect(due.single.summary.outstandingPaise, 100000);
  });

  test(
    'settlement history lists repayments newest first with person',
    () async {
      final id = await ledger.saveEntry(given(500000));
      await ledger.addRepayment(
        RepaymentDraft(
          ledgerId: id,
          amountPaise: 100000,
          date: DateTime(2026, 3, 2),
          paymentMethod: PaymentMethod.cash,
        ),
      );
      await ledger.addRepayment(
        RepaymentDraft(
          ledgerId: id,
          amountPaise: 50000,
          date: DateTime(2026, 3, 9),
          paymentMethod: PaymentMethod.upi,
        ),
      );
      final history = await ledger.watchRepaymentHistory().first;
      expect(history.map((h) => h.repayment.amountPaise).toList(), [
        50000,
        100000,
      ]);
      expect(history.first.person.name, 'Rahul');
    },
  );
}

class _Fixed extends Clock {
  _Fixed(this.value);
  final DateTime value;
  @override
  DateTime now() => value;
}
