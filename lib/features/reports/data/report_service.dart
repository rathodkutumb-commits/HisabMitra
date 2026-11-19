import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/utils/date_range.dart';
import '../../groups/data/group_repository.dart';
import '../../money_ledger/data/ledger_repository.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_models.dart';

@immutable
class PersonLendingRow {
  const PersonLendingRow({
    required this.person,
    required this.givenPaise,
    required this.takenPaise,
    required this.receivedBackPaise,
    required this.paidBackPaise,
    required this.outstandingReceivablePaise,
    required this.outstandingPayablePaise,
  });

  final PersonRow person;

  /// Principal given / taken within the period.
  final int givenPaise;
  final int takenPaise;

  /// Repayments within the period.
  final int receivedBackPaise;
  final int paidBackPaise;

  /// Current outstanding (all time).
  final int outstandingReceivablePaise;
  final int outstandingPayablePaise;
}

@immutable
class GroupReportRow {
  const GroupReportRow({
    required this.group,
    required this.expenseCount,
    required this.spentPaise,
    required this.mySharePaise,
    required this.myPaidPaise,
    required this.settlementsPaise,
  });

  final GroupRow group;
  final int expenseCount;
  final int spentPaise;
  final int mySharePaise;
  final int myPaidPaise;
  final int settlementsPaise;
}

/// Everything a report needs for one period. All figures come from the
/// database; nothing is estimated.
@immutable
class ReportData {
  const ReportData({
    required this.range,
    required this.summary,
    required this.expenseByCategory,
    required this.incomeByCategory,
    required this.expenseByMethod,
    required this.monthly,
    required this.people,
    required this.groups,
    required this.loansGivenPaise,
    required this.loansTakenPaise,
    required this.repaymentsReceivedPaise,
    required this.repaymentsPaidPaise,
    required this.groupSettlementsPaise,
    required this.groupSettlementsCount,
    required this.topExpenses,
  });

  final DateRange range;

  /// Income and expense only — never loans, repayments or settlements.
  final PeriodSummary summary;
  final List<CategoryTotal> expenseByCategory;
  final List<CategoryTotal> incomeByCategory;
  final List<PaymentMethodTotal> expenseByMethod;
  final List<MonthTotals> monthly;
  final List<PersonLendingRow> people;
  final List<GroupReportRow> groups;
  final int loansGivenPaise;
  final int loansTakenPaise;
  final int repaymentsReceivedPaise;
  final int repaymentsPaidPaise;
  final int groupSettlementsPaise;
  final int groupSettlementsCount;
  final List<TransactionView> topExpenses;
}

class ReportService {
  ReportService(this._txns, this._ledger, this._groups);

  final TransactionRepository _txns;
  final LedgerRepository _ledger;
  final GroupRepository _groups;

  static List<DateRange> monthsIn(DateRange range) {
    final months = <DateRange>[];
    var cursor = DateTime(range.start.year, range.start.month);
    while (cursor.isBefore(range.endExclusive) && months.length < 24) {
      months.add(DateRange.month(cursor.year, cursor.month));
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    return months;
  }

  Future<ReportData> load(DateRange range) async {
    final summary = await _txns.watchSummary(range).first;
    final expenseByCategory = await _txns
        .watchCategoryTotals(range, TransactionType.expense)
        .first;
    final incomeByCategory = await _txns
        .watchCategoryTotals(range, TransactionType.income)
        .first;
    final byMethod = await _txns
        .watchPaymentMethodTotals(range, TransactionType.expense)
        .first;
    final monthly = await _txns.watchMonthly(monthsIn(range)).first;
    final expenses = await _txns
        .watch(TransactionFilter(range: range, type: TransactionType.expense))
        .first;
    final top = [...expenses]
      ..sort((a, b) => b.txn.amountPaise.compareTo(a.txn.amountPaise));

    // ---------------------------------------------------------- ledger
    final entries = await _ledger.watchEntries().first;
    final people = <String, PersonLendingRow>{};
    var loansGiven = 0, loansTaken = 0, received = 0, paid = 0;
    for (final e in entries) {
      final given = e.entry.direction == LedgerDirection.given;
      final principalIn = range.contains(e.entry.entryDate)
          ? e.entry.principalPaise
          : 0;
      final repaidIn = e.repayments
          .where((r) => range.contains(r.settledOn))
          .fold<int>(0, (s, r) => s + r.amountPaise);
      if (given) {
        loansGiven += principalIn;
        received += repaidIn;
      } else {
        loansTaken += principalIn;
        paid += repaidIn;
      }
      final prev = people[e.person.id];
      people[e.person.id] = PersonLendingRow(
        person: e.person,
        givenPaise: (prev?.givenPaise ?? 0) + (given ? principalIn : 0),
        takenPaise: (prev?.takenPaise ?? 0) + (given ? 0 : principalIn),
        receivedBackPaise:
            (prev?.receivedBackPaise ?? 0) + (given ? repaidIn : 0),
        paidBackPaise: (prev?.paidBackPaise ?? 0) + (given ? 0 : repaidIn),
        outstandingReceivablePaise:
            (prev?.outstandingReceivablePaise ?? 0) +
            (given ? e.summary.outstandingPaise : 0),
        outstandingPayablePaise:
            (prev?.outstandingPayablePaise ?? 0) +
            (given ? 0 : e.summary.outstandingPaise),
      );
    }
    final peopleRows =
        people.values
            .where(
              (p) =>
                  p.givenPaise +
                          p.takenPaise +
                          p.receivedBackPaise +
                          p.paidBackPaise >
                      0 ||
                  p.outstandingReceivablePaise + p.outstandingPayablePaise > 0,
            )
            .toList()
          ..sort(
            (a, b) => a.person.name.toLowerCase().compareTo(
              b.person.name.toLowerCase(),
            ),
          );

    // ---------------------------------------------------------- groups
    final groupRows = <GroupReportRow>[];
    var settlementsTotal = 0, settlementsCount = 0;
    final groupList = await _groups.watchGroups(includeArchived: true).first;
    for (final item in groupList) {
      final d = await _groups.watchGroup(item.group.id).first;
      if (d == null) continue;
      final self = d.selfMember?.id;
      final inRange = d.expenses
          .where((e) => range.contains(e.expense.expenseDate))
          .toList();
      final settlements = d.settlements
          .where((s) => range.contains(s.settledOn))
          .toList();
      if (inRange.isEmpty && settlements.isEmpty) continue;
      final settled = settlements.fold<int>(0, (s, x) => s + x.amountPaise);
      settlementsTotal += settled;
      settlementsCount += settlements.length;
      groupRows.add(
        GroupReportRow(
          group: d.group,
          expenseCount: inRange.length,
          spentPaise: inRange.fold(0, (s, e) => s + e.expense.amountPaise),
          mySharePaise: self == null
              ? 0
              : inRange.fold(0, (s, e) => s + (e.splits[self] ?? 0)),
          myPaidPaise: self == null
              ? 0
              : inRange
                    .where((e) => e.expense.paidByMemberId == self)
                    .fold(0, (s, e) => s + e.expense.amountPaise),
          settlementsPaise: settled,
        ),
      );
    }

    return ReportData(
      range: range,
      summary: summary,
      expenseByCategory: expenseByCategory,
      incomeByCategory: incomeByCategory,
      expenseByMethod: byMethod,
      monthly: monthly,
      people: peopleRows,
      groups: groupRows,
      loansGivenPaise: loansGiven,
      loansTakenPaise: loansTaken,
      repaymentsReceivedPaise: received,
      repaymentsPaidPaise: paid,
      groupSettlementsPaise: settlementsTotal,
      groupSettlementsCount: settlementsCount,
      topExpenses: top.take(5).toList(),
    );
  }
}

final reportServiceProvider = Provider<ReportService>(
  (ref) => ReportService(
    ref.watch(transactionRepositoryProvider),
    ref.watch(ledgerRepositoryProvider),
    ref.watch(groupRepositoryProvider),
  ),
);

final reportProvider = FutureProvider.autoDispose.family<ReportData, DateRange>(
  (ref, range) => ref.watch(reportServiceProvider).load(range),
);
