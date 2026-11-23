import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';

/// What an entry is: money in (salary, extra income, contribution) or money
/// out (an expense). Nothing in a Family hisab is split between people.
enum FamilyEntryKind {
  salary('salary', true),
  extraIncome('extra_income', true),
  contribution('contribution', true),
  expense('expense', false);

  const FamilyEntryKind(this.wire, this.isMoneyIn);

  /// Name used on the server and in the phone's table.
  final String wire;
  final bool isMoneyIn;

  static FamilyEntryKind fromWire(String wire) =>
      values.firstWhere((k) => k.wire == wire, orElse: () => expense);

  static const moneyIn = [salary, extraIncome, contribution];
}

/// One entry of a Family hisab, as the passbook needs it.
@immutable
class FamilyEntry {
  const FamilyEntry({
    required this.id,
    required this.memberId,
    required this.kind,
    required this.amountPaise,
    required this.date,
    this.categoryId,
    this.categoryName,
    this.categoryNameGu,
    this.categoryIcon,
    this.categoryColor,
    this.note,
  });

  factory FamilyEntry.fromRow(FamilyEntryRow r) => FamilyEntry(
    id: r.id,
    memberId: r.memberId,
    kind: FamilyEntryKind.fromWire(r.kind),
    amountPaise: r.amountPaise,
    date: r.entryDate,
    categoryId: r.categoryId,
    categoryName: r.categoryName,
    categoryNameGu: r.categoryNameGu,
    categoryIcon: r.categoryIcon,
    categoryColor: r.categoryColor,
    note: r.note,
  );

  final String id;
  final String memberId;
  final FamilyEntryKind kind;
  final int amountPaise;
  final DateTime date;
  final String? categoryId;
  final String? categoryName;
  final String? categoryNameGu;
  final String? categoryIcon;
  final int? categoryColor;
  final String? note;

  /// + for money in, − for money out.
  int get signedPaise => kind.isMoneyIn ? amountPaise : -amountPaise;

  /// The category's name in the app's language (Gujarati when given).
  String? categoryLabel(String languageCode) =>
      languageCode == 'gu' && (categoryNameGu?.trim().isNotEmpty ?? false)
      ? categoryNameGu
      : categoryName;

  FamilyEntry copyWith({DateTime? date, int? amountPaise}) => FamilyEntry(
    id: id,
    memberId: memberId,
    kind: kind,
    amountPaise: amountPaise ?? this.amountPaise,
    date: date ?? this.date,
    categoryId: categoryId,
    categoryName: categoryName,
    categoryNameGu: categoryNameGu,
    categoryIcon: categoryIcon,
    categoryColor: categoryColor,
    note: note,
  );
}

/// One person's part of a month: what they put in and what they paid for.
@immutable
class PersonLine {
  const PersonLine({
    required this.memberId,
    required this.moneyInPaise,
    required this.paidPaise,
  });

  final String memberId;
  final int moneyInPaise;
  final int paidPaise;
}

/// A month of the passbook. Balances are calculated, never stored.
@immutable
class MonthStatement {
  const MonthStatement({
    required this.year,
    required this.month,
    required this.openingPaise,
    required this.moneyInPaise,
    required this.moneyOutPaise,
    required this.entries,
    required this.byPerson,
  });

  final int year;
  final int month;
  final int openingPaise;
  final int moneyInPaise;
  final int moneyOutPaise;

  /// The month's entries, newest first.
  final List<FamilyEntry> entries;

  /// People with an entry this month, in member order (removed people last).
  final List<PersonLine> byPerson;

  int get closingPaise => openingPaise + moneyInPaise - moneyOutPaise;
}
