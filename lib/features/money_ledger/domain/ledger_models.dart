import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import 'ledger_calculator.dart';

export '../../../core/errors/app_failure.dart' show RepaymentExceedsFailure;

@immutable
class LedgerDraft {
  const LedgerDraft({
    this.id,
    required this.personId,
    required this.direction,
    required this.principalPaise,
    required this.date,
    required this.paymentMethod,
    this.dueDate,
    this.description = '',
    this.notes,
  });

  final String? id;
  final String personId;
  final LedgerDirection direction;
  final int principalPaise;
  final DateTime date;
  final DateTime? dueDate;
  final PaymentMethod paymentMethod;
  final String description;
  final String? notes;

  LedgerDraft copyWith({String? id, DateTime? dueDate}) => LedgerDraft(
    id: id ?? this.id,
    personId: personId,
    direction: direction,
    principalPaise: principalPaise,
    date: date,
    paymentMethod: paymentMethod,
    dueDate: dueDate ?? this.dueDate,
    description: description,
    notes: notes,
  );
}

@immutable
class RepaymentDraft {
  const RepaymentDraft({
    required this.ledgerId,
    required this.amountPaise,
    required this.date,
    required this.paymentMethod,
    this.notes,
  });

  final String ledgerId;
  final int amountPaise;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? notes;
}

@immutable
class LedgerEntryView {
  const LedgerEntryView({
    required this.entry,
    required this.person,
    required this.repayments,
    required this.summary,
    this.attachmentCount = 0,
  });

  final LedgerEntryRow entry;
  final PersonRow person;

  /// Oldest first.
  final List<LedgerRepaymentRow> repayments;
  final LedgerEntrySummary summary;
  final int attachmentCount;

  bool isOverdue(DateTime now) =>
      entry.dueDate != null &&
      summary.status != LedgerStatus.settled &&
      entry.dueDate!.isBefore(DateTime(now.year, now.month, now.day));
}

@immutable
class RepaymentHistoryItem {
  const RepaymentHistoryItem({
    required this.repayment,
    required this.entry,
    required this.person,
  });

  final LedgerRepaymentRow repayment;
  final LedgerEntryRow entry;
  final PersonRow person;
}
