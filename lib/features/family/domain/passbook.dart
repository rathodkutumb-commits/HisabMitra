import '../../../core/utils/date_range.dart';
import '../../transactions/domain/transaction_models.dart';
import 'family_models.dart';

/// One month of a Family hisab, like a bank passbook: the opening balance is
/// the starting balance plus everything that came in, minus everything that
/// went out, **before** the month; the closing balance adds the month's own
/// money in and out. Editing or moving any entry changes every later month.
MonthStatement passbookMonth({
  required int startingBalancePaise,
  required List<FamilyEntry> entries,
  required List<String> memberOrder,
  required int year,
  required int month,
}) {
  final range = DateRange.month(year, month);
  var opening = startingBalancePaise;
  var moneyIn = 0;
  var moneyOut = 0;
  final inMonth = <FamilyEntry>[];
  final people = <String, (int, int)>{};
  for (final e in entries) {
    if (e.date.isBefore(range.start)) {
      opening += e.signedPaise;
    } else if (e.date.isBefore(range.endExclusive)) {
      inMonth.add(e);
      final (inSoFar, paidSoFar) = people[e.memberId] ?? (0, 0);
      if (e.kind.isMoneyIn) {
        moneyIn += e.amountPaise;
        people[e.memberId] = (inSoFar + e.amountPaise, paidSoFar);
      } else {
        moneyOut += e.amountPaise;
        people[e.memberId] = (inSoFar, paidSoFar + e.amountPaise);
      }
    }
  }
  inMonth.sort((a, b) => b.date.compareTo(a.date));
  final ordered = [
    for (final id in memberOrder)
      if (people.containsKey(id)) id,
    for (final id in people.keys)
      if (!memberOrder.contains(id)) id,
  ];
  return MonthStatement(
    year: year,
    month: month,
    openingPaise: opening,
    moneyInPaise: moneyIn,
    moneyOutPaise: moneyOut,
    entries: inMonth,
    byPerson: [
      for (final id in ordered)
        PersonLine(
          memberId: id,
          moneyInPaise: people[id]!.$1,
          paidPaise: people[id]!.$2,
        ),
    ],
  );
}

/// Money in and out per calendar month, for the Home screen's chart (money
/// in counts as income, money out as expense).
List<MonthTotals> familyMonthlyTotals(
  List<FamilyEntry> entries, {
  required DateTime from,
  required int months,
}) => [
  for (var i = 0; i < months; i++)
    () {
      final month = DateRange.month(from.year, from.month + i);
      final s = familyPeriodSummary(entries, month);
      return MonthTotals(
        month: month,
        incomePaise: s.incomePaise,
        expensePaise: s.expensePaise,
      );
    }(),
];

/// Money in and out within [range], as a [PeriodSummary].
PeriodSummary familyPeriodSummary(List<FamilyEntry> entries, DateRange range) {
  var moneyIn = 0;
  var moneyOut = 0;
  for (final e in entries) {
    if (e.date.isBefore(range.start) || !e.date.isBefore(range.endExclusive)) {
      continue;
    }
    if (e.kind.isMoneyIn) {
      moneyIn += e.amountPaise;
    } else {
      moneyOut += e.amountPaise;
    }
  }
  return PeriodSummary(incomePaise: moneyIn, expensePaise: moneyOut);
}
