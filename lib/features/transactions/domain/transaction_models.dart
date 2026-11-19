import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/date_range.dart';

/// Input for creating or updating an income/expense record.
@immutable
class TransactionDraft {
  const TransactionDraft({
    this.id,
    required this.type,
    required this.amountPaise,
    required this.categoryId,
    required this.date,
    required this.paymentMethod,
    this.personId,
    this.description = '',
    this.notes,
  });

  final String? id;
  final TransactionType type;
  final int amountPaise;
  final String categoryId;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? personId;
  final String description;
  final String? notes;

  TransactionDraft copyWith({String? id}) => TransactionDraft(
    id: id ?? this.id,
    type: type,
    amountPaise: amountPaise,
    categoryId: categoryId,
    date: date,
    paymentMethod: paymentMethod,
    personId: personId,
    description: description,
    notes: notes,
  );
}

@immutable
class TransactionFilter {
  const TransactionFilter({
    this.range,
    this.type,
    this.categoryId,
    this.paymentMethod,
    this.personId,
    this.query = '',
    this.limit,
  });

  final DateRange? range;
  final TransactionType? type;
  final String? categoryId;
  final PaymentMethod? paymentMethod;
  final String? personId;
  final String query;
  final int? limit;

  bool get hasFilters =>
      type != null ||
      categoryId != null ||
      paymentMethod != null ||
      personId != null ||
      range != null;

  TransactionFilter copyWith({
    DateRange? Function()? range,
    TransactionType? Function()? type,
    String? Function()? categoryId,
    PaymentMethod? Function()? paymentMethod,
    String? Function()? personId,
    String? query,
  }) => TransactionFilter(
    range: range != null ? range() : this.range,
    type: type != null ? type() : this.type,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    paymentMethod: paymentMethod != null ? paymentMethod() : this.paymentMethod,
    personId: personId != null ? personId() : this.personId,
    query: query ?? this.query,
    limit: limit,
  );

  @override
  bool operator ==(Object other) =>
      other is TransactionFilter &&
      other.range == range &&
      other.type == type &&
      other.categoryId == categoryId &&
      other.paymentMethod == paymentMethod &&
      other.personId == personId &&
      other.query == query &&
      other.limit == limit;

  @override
  int get hashCode => Object.hash(
    range,
    type,
    categoryId,
    paymentMethod,
    personId,
    query,
    limit,
  );
}

@immutable
class TransactionView {
  const TransactionView({
    required this.txn,
    required this.category,
    this.person,
    this.attachmentCount = 0,
  });

  final TransactionRow txn;
  final CategoryRow category;
  final PersonRow? person;
  final int attachmentCount;

  /// Signed amount: income positive, expense negative.
  int get signedPaise =>
      txn.type == TransactionType.income ? txn.amountPaise : -txn.amountPaise;
}

@immutable
class PeriodSummary {
  const PeriodSummary({required this.incomePaise, required this.expensePaise});

  static const zero = PeriodSummary(incomePaise: 0, expensePaise: 0);

  final int incomePaise;
  final int expensePaise;

  /// Savings for the period. Loan principal and repayments are excluded by
  /// design — they live in the personal ledger, not in transactions.
  int get balancePaise => incomePaise - expensePaise;
}

@immutable
class CategoryTotal {
  const CategoryTotal({
    required this.category,
    required this.totalPaise,
    required this.count,
  });

  final CategoryRow category;
  final int totalPaise;
  final int count;
}

@immutable
class MonthTotals {
  const MonthTotals({
    required this.month,
    required this.incomePaise,
    required this.expensePaise,
  });

  final DateRange month;
  final int incomePaise;
  final int expensePaise;
}

@immutable
class PaymentMethodTotal {
  const PaymentMethodTotal({
    required this.method,
    required this.totalPaise,
    required this.count,
  });

  final PaymentMethod method;
  final int totalPaise;
  final int count;
}
