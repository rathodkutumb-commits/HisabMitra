import 'package:flutter/foundation.dart';

import '../../../core/domain/enums.dart';

enum LedgerStatus { open, partial, settled }

@immutable
class LedgerEntrySummary {
  const LedgerEntrySummary({
    required this.principalPaise,
    required this.repaidPaise,
    required this.outstandingPaise,
    required this.status,
  });

  final int principalPaise;
  final int repaidPaise;
  final int outstandingPaise;
  final LedgerStatus status;
}

sealed class RepaymentCheck {
  const RepaymentCheck();
}

class RepaymentOk extends RepaymentCheck {
  const RepaymentOk();
}

class RepaymentInvalidAmount extends RepaymentCheck {
  const RepaymentInvalidAmount();
}

/// The repayment is larger than what is still owed. The UI offers to record
/// [excessPaise] as a separate advance/credit entry in the opposite
/// direction instead of silently over-paying (see TD-12).
class RepaymentExceedsOutstanding extends RepaymentCheck {
  const RepaymentExceedsOutstanding(this.excessPaise);
  final int excessPaise;
}

@immutable
class LedgerEntryAmounts {
  const LedgerEntryAmounts(
    this.direction,
    this.principalPaise,
    this.repaymentsPaise,
  );

  final LedgerDirection direction;
  final int principalPaise;
  final List<int> repaymentsPaise;
}

@immutable
class PersonLedgerBalance {
  const PersonLedgerBalance({
    required this.receivablePaise,
    required this.payablePaise,
    required this.totalGivenPaise,
    required this.totalTakenPaise,
  });

  static const zero = PersonLedgerBalance(
    receivablePaise: 0,
    payablePaise: 0,
    totalGivenPaise: 0,
    totalTakenPaise: 0,
  );

  /// Outstanding amount the person owes me.
  final int receivablePaise;

  /// Outstanding amount I owe the person.
  final int payablePaise;

  /// Lifetime principal lent / borrowed (history, not balance).
  final int totalGivenPaise;
  final int totalTakenPaise;

  /// Positive → they owe me; negative → I owe them.
  int get netPaise => receivablePaise - payablePaise;
}

/// Personal ledger rules. Loan principal and repayments are *not* income or
/// expense and are never counted in income/expense reports.
abstract final class LedgerCalculator {
  static LedgerEntrySummary summarize({
    required int principalPaise,
    required List<int> repaymentsPaise,
  }) {
    final repaid = repaymentsPaise.fold<int>(0, (a, b) => a + b);
    final outstanding = principalPaise - repaid;
    final status = outstanding <= 0
        ? LedgerStatus.settled
        : repaid > 0
        ? LedgerStatus.partial
        : LedgerStatus.open;
    return LedgerEntrySummary(
      principalPaise: principalPaise,
      repaidPaise: repaid,
      outstandingPaise: outstanding < 0 ? 0 : outstanding,
      status: status,
    );
  }

  static RepaymentCheck validateRepayment({
    required int outstandingPaise,
    required int amountPaise,
  }) {
    if (amountPaise <= 0) return const RepaymentInvalidAmount();
    if (amountPaise > outstandingPaise) {
      return RepaymentExceedsOutstanding(amountPaise - outstandingPaise);
    }
    return const RepaymentOk();
  }

  static PersonLedgerBalance personBalance(List<LedgerEntryAmounts> entries) {
    var receivable = 0;
    var payable = 0;
    var given = 0;
    var taken = 0;
    for (final e in entries) {
      final outstanding = summarize(
        principalPaise: e.principalPaise,
        repaymentsPaise: e.repaymentsPaise,
      ).outstandingPaise;
      switch (e.direction) {
        case LedgerDirection.given:
          receivable += outstanding;
          given += e.principalPaise;
        case LedgerDirection.taken:
          payable += outstanding;
          taken += e.principalPaise;
      }
    }
    return PersonLedgerBalance(
      receivablePaise: receivable,
      payablePaise: payable,
      totalGivenPaise: given,
      totalTakenPaise: taken,
    );
  }
}
