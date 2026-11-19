import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/domain/enums.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_calculator.dart';

void main() {
  group('entry summary', () {
    test('no repayments → open with full outstanding', () {
      final s = LedgerCalculator.summarize(
        principalPaise: 500000,
        repaymentsPaise: const [],
      );
      expect(s.repaidPaise, 0);
      expect(s.outstandingPaise, 500000);
      expect(s.status, LedgerStatus.open);
    });

    test('partial repayments → partial with remaining balance', () {
      final s = LedgerCalculator.summarize(
        principalPaise: 1000000,
        repaymentsPaise: const [300000, 200000],
      );
      expect(s.repaidPaise, 500000);
      expect(s.outstandingPaise, 500000);
      expect(s.status, LedgerStatus.partial);
    });

    test('fully repaid → settled', () {
      final s = LedgerCalculator.summarize(
        principalPaise: 1000000,
        repaymentsPaise: const [1000000],
      );
      expect(s.outstandingPaise, 0);
      expect(s.status, LedgerStatus.settled);
    });
  });

  group('repayment validation', () {
    test('accepts a repayment up to the outstanding amount', () {
      expect(
        LedgerCalculator.validateRepayment(
          outstandingPaise: 5000,
          amountPaise: 5000,
        ),
        isA<RepaymentOk>(),
      );
      expect(
        LedgerCalculator.validateRepayment(
          outstandingPaise: 5000,
          amountPaise: 100,
        ),
        isA<RepaymentOk>(),
      );
    });

    test(
      'rejects a repayment above the outstanding amount with the excess',
      () {
        final result = LedgerCalculator.validateRepayment(
          outstandingPaise: 5000,
          amountPaise: 7000,
        );
        expect(result, isA<RepaymentExceedsOutstanding>());
        expect((result as RepaymentExceedsOutstanding).excessPaise, 2000);
      },
    );

    test('rejects zero or negative amounts', () {
      expect(
        LedgerCalculator.validateRepayment(
          outstandingPaise: 5000,
          amountPaise: 0,
        ),
        isA<RepaymentInvalidAmount>(),
      );
    });

    test('rejects repayment on a settled entry', () {
      expect(
        LedgerCalculator.validateRepayment(
          outstandingPaise: 0,
          amountPaise: 100,
        ),
        isA<RepaymentExceedsOutstanding>(),
      );
    });
  });

  group('person balance', () {
    test('receivable from given entries, payable from taken entries', () {
      final b = LedgerCalculator.personBalance(const [
        LedgerEntryAmounts(LedgerDirection.given, 500000, [200000]),
        LedgerEntryAmounts(LedgerDirection.given, 100000, []),
        LedgerEntryAmounts(LedgerDirection.taken, 1000000, [300000]),
      ]);
      expect(b.receivablePaise, 400000);
      expect(b.payablePaise, 700000);
      expect(b.netPaise, -300000); // I owe ₹3,000 net.
    });

    test('settled entries contribute nothing', () {
      final b = LedgerCalculator.personBalance(const [
        LedgerEntryAmounts(LedgerDirection.given, 500000, [500000]),
      ]);
      expect(b.receivablePaise, 0);
      expect(b.payablePaise, 0);
      expect(b.netPaise, 0);
    });

    test('lifetime totals track principal given and taken', () {
      final b = LedgerCalculator.personBalance(const [
        LedgerEntryAmounts(LedgerDirection.given, 500000, [500000]),
        LedgerEntryAmounts(LedgerDirection.taken, 200000, []),
      ]);
      expect(b.totalGivenPaise, 500000);
      expect(b.totalTakenPaise, 200000);
    });
  });
}
