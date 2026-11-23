import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/utils/stream_combine.dart';
import '../../family/data/family_repository.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_models.dart';

/// Family hisab is a kind of account: the Home screen's income, expense and
/// savings add its money in and out (every Family hisab, every person). The
/// Hisab tab's list and Reports stay personal.
PeriodSummary addSummaries(PeriodSummary a, PeriodSummary b) => PeriodSummary(
  incomePaise: a.incomePaise + b.incomePaise,
  expensePaise: a.expensePaise + b.expensePaise,
);

/// Adds [family] into [personal], month by month (same months).
List<MonthTotals> addMonthly(
  List<MonthTotals> personal,
  List<MonthTotals> family,
) => [
  for (final p in personal)
    () {
      final f = family.where((x) => x.month.start == p.month.start).firstOrNull;
      return MonthTotals(
        month: p.month,
        incomePaise: p.incomePaise + (f?.incomePaise ?? 0),
        expensePaise: p.expensePaise + (f?.expensePaise ?? 0),
      );
    }(),
];

/// (personal + Family hisab, Family hisab alone) within a period.
final combinedSummaryProvider =
    StreamProvider.family<(PeriodSummary, PeriodSummary), DateRange>(
      (ref, range) => combineLatest2(
        ref.watch(transactionRepositoryProvider).watchSummary(range),
        ref.watch(familyRepositoryProvider).watchSummary(range),
        (PeriodSummary personal, PeriodSummary family) =>
            (addSummaries(personal, family), family),
      ),
    );

/// The Home chart's last six months, personal + Family hisab.
final combinedMonthlyProvider = StreamProvider<List<MonthTotals>>((ref) {
  final now = ref.watch(clockProvider).now();
  final months = DateRange.lastMonths(now, 6);
  return combineLatest2(
    ref.watch(transactionRepositoryProvider).watchMonthly(months),
    ref
        .watch(familyRepositoryProvider)
        .watchMonthly(from: months.first.start, months: months.length),
    addMonthly,
  );
});
