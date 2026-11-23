import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../tour/application/tour_controller.dart';
import '../../tour/presentation/tour_widgets.dart';
import '../../../core/widgets/hm_logo.dart';
import '../../groups/data/group_repository.dart';
import '../../groups/presentation/group_picker.dart';
import '../../money_ledger/data/ledger_repository.dart';
import '../../money_ledger/domain/ledger_models.dart';
import '../../money_ledger/presentation/widgets/ledger_entry_tile.dart';
import '../../profile/data/profile_repository.dart';
import '../../reminders/presentation/reminders_screens.dart';
import '../../settings/application/settings_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_models.dart';
import '../../transactions/presentation/widgets/transaction_tile.dart';
import '../application/combined_totals.dart';
import '../application/period_controller.dart';
import 'income_expense_chart.dart';
import '../../ai_assistant/presentation/ai_fab.dart';

final _dueSoonProvider = StreamProvider<List<LedgerEntryView>>((ref) {
  final now = ref.watch(clockProvider).now();
  final until = DateTime(now.year, now.month, now.day + 8);
  return ref.watch(ledgerRepositoryProvider).watchDueBefore(until);
});

const _recentFilter = TransactionFilter(limit: 5);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final profile = ref.watch(profileProvider).value;
    final period = ref.watch(periodControllerProvider);
    // Family hisab is a kind of account: its money counts here too.
    final summary = ref.watch(combinedSummaryProvider(period.range)).value;
    final recent = ref.watch(transactionsProvider(_recentFilter));
    final isNewUser = recent.value?.isEmpty ?? false;

    return Scaffold(
      floatingActionButton: const AiFabStack(),
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            const HmLogo(size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                profile == null
                    ? l.greetingNoName
                    : l.greeting(profile.displayName),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l.calculatorTitle,
            icon: const Icon(Icons.calculate_outlined),
            onPressed: () => context.push(Routes.calculator),
          ),
          IconButton(
            tooltip: l.settingsReminders,
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () => context.push(Routes.reminders),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const TourPromptHost(),
          const SampleDataBanner(),
          const SizedBox(height: 4),
          const PeriodChips(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: KeyedSubtree(
              key: TourTargets.hero,
              child: _SummaryHero(
                summary: summary?.$1 ?? PeriodSummary.zero,
                family: summary?.$2 ?? PeriodSummary.zero,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: KeyedSubtree(
              key: TourTargets.khata,
              child: const _KhataRow(),
            ),
          ),
          SectionHeader(title: l.quickActions),
          KeyedSubtree(
            key: TourTargets.quickActions,
            child: const _QuickActions(),
          ),
          if (isNewUser)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                child: EmptyState(
                  icon: Icons.edit_note_rounded,
                  title: l.welcomeEmptyTitle,
                  message: l.welcomeEmptyBody,
                  actionLabel: l.actionAddExpense,
                  onAction: () => context.push(Routes.newTransaction()),
                  compact: true,
                ),
              ),
            ),
          const _DueSoonSection(),
          const UpcomingRemindersSection(),
          const _GroupsSummary(),
          SectionHeader(title: l.incomeVsExpense),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 12),
                child: AsyncValueView(
                  value: ref.watch(combinedMonthlyProvider),
                  data: (months) => IncomeExpenseChart(months: months),
                ),
              ),
            ),
          ),
          SectionHeader(
            title: l.recentTransactions,
            actionLabel: l.viewAll,
            onAction: () => context.go(Routes.transactions),
          ),
          AsyncValueView(
            value: recent,
            data: (items) => items.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l.noTransactionsBody,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : Column(
                    children: [
                      for (final v in items)
                        TransactionTile(view: v, showDate: true),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _SummaryHero extends ConsumerWidget {
  const _SummaryHero({required this.summary, required this.family});

  /// Personal and Family hisab together.
  final PeriodSummary summary;

  /// The Family hisab part, so the totals can be checked.
  final PeriodSummary family;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hm = HmColors.of(context);
    final onHero = hm.onHero;
    return HeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.dashboardBalanceLabel,
            style: theme.textTheme.labelLarge?.copyWith(
              color: onHero.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          AmountText(
            summary.balancePaise,
            style: theme.textTheme.headlineMedium,
            color: onHero,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroFigure(
                  icon: Icons.south_west_rounded,
                  label: l.income,
                  paise: summary.incomePaise,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: onHero.withValues(alpha: 0.25),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _HeroFigure(
                  icon: Icons.north_east_rounded,
                  label: l.expense,
                  paise: summary.expensePaise,
                ),
              ),
            ],
          ),
          if (family.incomePaise != 0 || family.expensePaise != 0) ...[
            const SizedBox(height: 12),
            Text(
              l.familyIncludesLine(
                ref.fmt.money(family.incomePaise),
                ref.fmt.money(family.expensePaise),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: onHero.withValues(alpha: 0.85),
              ),
            ),
          ],
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  const _HeroFigure({
    required this.icon,
    required this.label,
    required this.paise,
  });

  final IconData icon;
  final String label;
  final int paise;

  @override
  Widget build(BuildContext context) {
    final hm = HmColors.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: hm.onHero.withValues(alpha: 0.15),
          child: Icon(icon, size: 18, color: hm.highlight),
        ),
        const SizedBox(width: 8),
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
              AmountText(
                paise,
                color: hm.onHero,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _KhataRow extends ConsumerWidget {
  const _KhataRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final totals = ref.watch(ledgerTotalsProvider).value;
    Widget tile(String label, int paise, Color color, IconData icon) =>
        Expanded(
          child: Card(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => context.go(Routes.people),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    IconBadge(icon: icon, color: color, size: 36),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          AmountText(paise, color: color),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
    return Row(
      children: [
        tile(
          l.dashboardToReceive,
          totals?.receivablePaise ?? 0,
          hm.receivable,
          Icons.call_received_rounded,
        ),
        const SizedBox(width: 12),
        tile(
          l.dashboardToPay,
          totals?.payablePaise ?? 0,
          hm.payable,
          Icons.call_made_rounded,
        ),
      ],
    );
  }
}

class _QuickActions extends ConsumerWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hm = HmColors.of(context);
    final actions = <(IconData, String, Color, VoidCallback)>[
      (
        Icons.family_restroom_rounded,
        l.familyHisab,
        scheme.primary,
        () => context.push(Routes.family),
      ),
      (
        Icons.add_card_rounded,
        l.actionAddIncome,
        hm.income,
        () => context.push(Routes.newTransaction(type: 'income')),
      ),
      (
        Icons.shopping_cart_checkout_rounded,
        l.actionAddExpense,
        hm.expense,
        () => context.push(Routes.newTransaction()),
      ),
      (
        Icons.call_made_rounded,
        l.actionGiveMoney,
        hm.payable,
        () => context.push(Routes.newLedgerEntry()),
      ),
      (
        Icons.call_received_rounded,
        l.actionReceiveMoney,
        hm.receivable,
        () => context.push(Routes.newLedgerEntry(direction: 'taken')),
      ),
      (
        Icons.group_add_rounded,
        l.actionCreateGroup,
        scheme.secondary,
        () => context.push(Routes.newGroup),
      ),
      (
        Icons.call_split_rounded,
        l.actionGroupExpense,
        scheme.tertiary,
        () => pickGroupForExpense(context, ref),
      ),
      (
        Icons.insights_rounded,
        l.actionReports,
        scheme.primary,
        () => context.push(Routes.reports),
      ),
      (
        Icons.calculate_rounded,
        l.calculatorTitle,
        hm.accentInk,
        () => context.push(Routes.calculator),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final perRow = constraints.maxWidth < 340 ? 3 : 4;
          final width = constraints.maxWidth / perRow;
          return Wrap(
            children: [
              for (final (icon, label, color, onTap) in actions)
                SizedBox(
                  width: width,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onTap,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 4,
                      ),
                      child: Column(
                        children: [
                          IconBadge(icon: icon, color: color, size: 48),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DueSoonSection extends ConsumerWidget {
  const _DueSoonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(_dueSoonProvider).value ?? const [];
    if (due.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    return Column(
      children: [
        SectionHeader(
          title: l.pendingRepayments,
          actionLabel: l.viewAll,
          onAction: () => context.go(Routes.people),
        ),
        for (final e in due.take(4)) LedgerEntryTile(view: e, showPerson: true),
      ],
    );
  }
}

class _GroupsSummary extends ConsumerWidget {
  const _GroupsSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(myGroupsSummaryProvider).value;
    if (summary == null || summary.activeGroups == 0) {
      return const SizedBox.shrink();
    }
    final l = context.l10n;
    final hm = HmColors.of(context);
    return Column(
      children: [
        SectionHeader(
          title: l.groupSummaryTitle,
          actionLabel: l.viewAll,
          onAction: () => context.go(Routes.groups),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: ListTile(
              onTap: () => context.go(Routes.groups),
              leading: IconBadge(
                icon: Icons.groups_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(l.groupSummaryLine(summary.activeGroups)),
              subtitle: Wrap(
                spacing: 12,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${l.youAreOwed} '),
                        WidgetSpan(
                          child: AmountText(
                            summary.owedToMePaise,
                            color: hm.receivable,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${l.youOwe} '),
                        WidgetSpan(
                          child: AmountText(
                            summary.iOwePaise,
                            color: hm.payable,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          ),
        ),
      ],
    );
  }
}
