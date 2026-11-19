import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/hm_colors.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../settings/application/settings_controller.dart';
import '../../transactions/domain/transaction_models.dart';

/// Grouped bars: income vs expense per month. Amounts are converted to
/// doubles only for drawing; all figures shown are formatted from paise.
class IncomeExpenseChart extends ConsumerWidget {
  const IncomeExpenseChart({
    super.key,
    required this.months,
    this.height = 200,
  });

  final List<MonthTotals> months;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formattersProvider);
    var maxPaise = 0;
    for (final m in months) {
      if (m.incomePaise > maxPaise) maxPaise = m.incomePaise;
      if (m.expensePaise > maxPaise) maxPaise = m.expensePaise;
    }
    final maxY = maxPaise == 0 ? 100.0 : maxPaise / 100 * 1.15;

    return Semantics(
      label: [
        l.incomeVsExpense,
        for (final m in months)
          '${fmt.shortMonth(m.month.start)}: ${l.income} ${fmt.money(m.incomePaise)}, '
              '${l.expense} ${fmt.money(m.expensePaise)}',
      ].join('. '),
      child: ExcludeSemantics(
        child: Column(
          children: [
            SizedBox(
              height: height,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: 0.5,
                      ),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        interval: maxY / 4,
                        getTitlesWidget: (value, meta) => Text(
                          Money.compact((value * 100).round()),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= months.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              fmt.shortMonth(months[i].month.start),
                              style: theme.textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => theme.colorScheme.inverseSurface,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final m = months[group.x];
                        final paise = rodIndex == 0
                            ? m.incomePaise
                            : m.expensePaise;
                        return BarTooltipItem(
                          '${rodIndex == 0 ? l.income : l.expense}\n${fmt.money(paise)}',
                          TextStyle(
                            color: theme.colorScheme.onInverseSurface,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < months.length; i++)
                      BarChartGroupData(
                        x: i,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(
                            toY: months[i].incomePaise / 100,
                            color: hm.income,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                          BarChartRodData(
                            toY: months[i].expensePaise / 100,
                            color: hm.expense,
                            width: 10,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: hm.income, label: l.income),
                const SizedBox(width: 16),
                _Legend(color: hm.expense, label: l.expense),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 6),
      Text(label, style: Theme.of(context).textTheme.labelMedium),
    ],
  );
}
