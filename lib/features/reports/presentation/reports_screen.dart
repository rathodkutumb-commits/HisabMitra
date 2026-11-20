import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../categories/presentation/category_labels.dart';
import '../../dashboard/application/period_controller.dart';
import '../../dashboard/presentation/income_expense_chart.dart';
import '../../groups/presentation/group_labels.dart';
import '../../settings/application/settings_controller.dart';
import '../../transactions/presentation/widgets/transaction_tile.dart';
import '../data/export_service.dart';
import '../data/report_service.dart';
import 'export_actions.dart';
import '../../ai_assistant/presentation/ai_fab.dart';

enum ReportKind {
  overview('overview'),
  categories('categories'),
  paymentMethods('payment-methods'),
  people('people'),
  groups('groups');

  const ReportKind(this.slug);
  final String slug;

  static ReportKind parse(String slug) =>
      values.firstWhere((k) => k.slug == slug, orElse: () => overview);

  String title(AppLocalizations l) => switch (this) {
    overview => l.reportOverview,
    categories => l.reportCategories,
    paymentMethods => l.reportPaymentMethods,
    people => l.reportPeople,
    groups => l.reportGroups,
  };

  String description(AppLocalizations l) => switch (this) {
    overview => l.reportOverviewDesc,
    categories => l.reportCategoriesDesc,
    paymentMethods => l.reportPaymentMethodsDesc,
    people => l.reportPeopleDesc,
    groups => l.reportGroupsDesc,
  };

  IconData get icon => switch (this) {
    overview => Icons.bar_chart_rounded,
    categories => Icons.pie_chart_rounded,
    paymentMethods => Icons.credit_card_rounded,
    people => Icons.menu_book_rounded,
    groups => Icons.groups_rounded,
  };
}

class _ExportButtons extends ConsumerWidget {
  const _ExportButtons();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final range = ref.watch(periodControllerProvider).range;
    Future<void> export(bool pdf) async {
      final data = await ref.read(reportServiceProvider).load(range);
      if (!context.mounted) return;
      final fmt = ref.read(formattersProvider);
      final exporter = ref.read(exportServiceProvider);
      await runExport(
        context,
        () => pdf
            ? exporter.reportPdf(data, l, fmt)
            : exporter.reportCsv(data, l, fmt),
        mime: pdf ? 'application/pdf' : 'text/csv',
        caption: l.shareReportCaption(
          l.reportsTitle,
          l.reportPeriod(fmt.date(range.start), fmt.date(range.endInclusive)),
        ),
      );
    }

    return PopupMenuButton<bool>(
      tooltip: l.export,
      icon: const Icon(Icons.ios_share_rounded),
      onSelected: export,
      itemBuilder: (_) => [
        PopupMenuItem(
          value: false,
          child: ListTile(
            leading: const Icon(Icons.table_view_rounded),
            title: Text(l.exportCsv),
          ),
        ),
        PopupMenuItem(
          value: true,
          child: ListTile(
            leading: const Icon(Icons.picture_as_pdf_rounded),
            title: Text(l.exportPdf),
          ),
        ),
      ],
    );
  }
}

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final theme = Theme.of(context);
    final range = ref.watch(periodControllerProvider).range;
    final report = ref.watch(reportProvider(range));
    return Scaffold(
      floatingActionButton: const AiFabStack(),
      appBar: AppBar(
        title: Text(l.reportsTitle),
        actions: const [_ExportButtons()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(reportProvider(range).future),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const SizedBox(height: 4),
            const PeriodChips(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AsyncValueView(
                value: report,
                data: (r) => HeroCard(
                  child: Row(
                    children: [
                      for (final (label, paise) in [
                        (l.income, r.summary.incomePaise),
                        (l.expense, r.summary.expensePaise),
                        (l.savings, r.summary.balancePaise),
                      ])
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: hm.onHero.withValues(alpha: 0.8),
                                ),
                              ),
                              FittedBox(
                                child: AmountText(
                                  paise,
                                  color: hm.onHero,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final kind in ReportKind.values)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Card(
                  child: ListTile(
                    leading: IconBadge(
                      icon: kind.icon,
                      color: theme.colorScheme.primary,
                    ),
                    title: Text(kind.title(l)),
                    subtitle: Text(kind.description(l)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.report(kind.slug)),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l.reportSeparationNote,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.kind});

  final ReportKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final range = ref.watch(periodControllerProvider).range;
    return Scaffold(
      appBar: AppBar(
        title: Text(kind.title(l)),
        actions: const [_ExportButtons()],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 4),
          const PeriodChips(),
          AsyncValueView(
            value: ref.watch(reportProvider(range)),
            data: (r) => switch (kind) {
              ReportKind.overview => _Overview(r),
              ReportKind.categories => _Categories(r),
              ReportKind.paymentMethods => _Methods(r),
              ReportKind.people => _People(r),
              ReportKind.groups => _Groups(r),
            },
          ),
        ],
      ),
    );
  }
}

class _Overview extends ConsumerWidget {
  const _Overview(this.r);
  final ReportData r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
              child: IncomeExpenseChart(months: r.monthly),
            ),
          ),
        ),
        SectionHeader(title: l.monthlyBreakdown),
        _Table(
          headers: [l.colMonth, l.income, l.expense, l.savings],
          rows: [
            for (final m in r.monthly.reversed)
              [
                fmt.monthYear(m.month.start),
                fmt.money(m.incomePaise),
                fmt.money(m.expensePaise),
                fmt.money(m.incomePaise - m.expensePaise),
              ],
          ],
        ),
        SectionHeader(title: l.topExpenses),
        if (r.topExpenses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.noDataForPeriod),
          )
        else
          for (final t in r.topExpenses)
            TransactionTile(view: t, showDate: true),
      ],
    );
  }
}

class _Categories extends ConsumerWidget {
  const _Categories(this.r);
  final ReportData r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final total = r.summary.expensePaise;
    if (r.expenseByCategory.isEmpty) {
      return EmptyState(
        icon: Icons.pie_chart_rounded,
        title: l.noDataForPeriod,
        compact: true,
      );
    }
    return Column(
      children: [
        Semantics(
          label: [
            for (final c in r.expenseByCategory)
              '${c.category.label(l)} ${ExportService.percentOf(c.totalPaise, total)}%',
          ].join(', '),
          child: ExcludeSemantics(
            child: SizedBox(
              height: 220,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 54,
                  sections: [
                    for (final c in r.expenseByCategory)
                      PieChartSectionData(
                        value: c.totalPaise.toDouble(),
                        color: c.category.color,
                        radius: 46,
                        title: '',
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        for (final c in r.expenseByCategory)
          ListTile(
            leading: IconBadge(icon: c.category.icon, color: c.category.color),
            title: Text(c.category.label(l)),
            subtitle: Text(
              '${ExportService.percentOf(c.totalPaise, total)}% · ${l.itemCount(c.count)}',
            ),
            trailing: AmountText(c.totalPaise),
          ),
        if (r.incomeByCategory.isNotEmpty) ...[
          SectionHeader(title: l.income),
          for (final c in r.incomeByCategory)
            ListTile(
              leading: IconBadge(
                icon: c.category.icon,
                color: c.category.color,
              ),
              title: Text(c.category.label(l)),
              subtitle: Text(l.itemCount(c.count)),
              trailing: AmountText(
                c.totalPaise,
                color: HmColors.of(context).income,
              ),
            ),
        ],
      ],
    );
  }
}

class _Methods extends ConsumerWidget {
  const _Methods(this.r);
  final ReportData r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final palette = HmColors.of(context).chartPalette;
    final total = r.summary.expensePaise;
    if (r.expenseByMethod.isEmpty) {
      return EmptyState(
        icon: Icons.credit_card_rounded,
        title: l.noDataForPeriod,
        compact: true,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Column(
          children: [
            for (final (i, m) in r.expenseByMethod.indexed)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(m.method.label(l))),
                        AmountText(m.totalPaise),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : m.totalPaise / total,
                        minHeight: 8,
                        color: palette[i % palette.length],
                        backgroundColor: palette[i % palette.length].withValues(
                          alpha: 0.15,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${ExportService.percentOf(m.totalPaise, total)}% · ${l.itemCount(m.count)}',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _People extends ConsumerWidget {
  const _People(this.r);
  final ReportData r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Column(
              children: [
                for (final (label, paise) in [
                  (l.loansGiven, r.loansGivenPaise),
                  (l.loansTaken, r.loansTakenPaise),
                  (l.repaymentsReceived, r.repaymentsReceivedPaise),
                  (l.repaymentsPaid, r.repaymentsPaidPaise),
                ])
                  ListTile(title: Text(label), trailing: AmountText(paise)),
              ],
            ),
          ),
        ),
        if (r.people.isEmpty)
          Text(l.noDataForPeriod)
        else
          _Table(
            headers: [
              l.person,
              l.loansGiven,
              l.loansTaken,
              l.dashboardToReceive,
              l.dashboardToPay,
            ],
            rows: [
              for (final p in r.people)
                [
                  p.person.name,
                  fmt.money(p.givenPaise),
                  fmt.money(p.takenPaise),
                  fmt.money(p.outstandingReceivablePaise),
                  fmt.money(p.outstandingPayablePaise),
                ],
            ],
          ),
      ],
    );
  }
}

class _Groups extends ConsumerWidget {
  const _Groups(this.r);
  final ReportData r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    if (r.groups.isEmpty) {
      return EmptyState(
        icon: Icons.groups_rounded,
        title: l.noDataForPeriod,
        compact: true,
      );
    }
    return Column(
      children: [
        for (final g in r.groups)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(g.group.groupType.icon),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            g.group.name,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(l.expensesCount(g.expenseCount)),
                      ],
                    ),
                    const Divider(),
                    for (final (label, paise) in [
                      (l.totalSpent, g.spentPaise),
                      (l.myShare, g.mySharePaise),
                      (l.iPaid, g.myPaidPaise),
                      (l.groupSettlementsLabel, g.settlementsPaise),
                    ])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Text(label)),
                            AmountText(paise),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        SectionHeader(title: l.settlementSummary),
        ListTile(
          title: Text(l.groupSettlementsLabel),
          subtitle: Text(l.itemCount(r.groupSettlementsCount)),
          trailing: AmountText(r.groupSettlementsPaise),
        ),
      ],
    );
  }
}

class _Table extends StatelessWidget {
  const _Table({required this.headers, required this.rows});

  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium
        ?.copyWith(fontWeight: FontWeight.w700);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: WidgetStatePropertyAll(
          Theme.of(context).colorScheme.secondaryContainer
              .withValues(alpha: 0.5),
        ),
        columns: [
          for (var i = 0; i < headers.length; i++)
            DataColumn(
              label: Text(headers[i], style: style),
              numeric: i > 0,
            ),
        ],
        rows: [
          for (final r in rows)
            DataRow(cells: [for (final c in r) DataCell(Text(c))]),
        ],
      ),
    );
  }
}
