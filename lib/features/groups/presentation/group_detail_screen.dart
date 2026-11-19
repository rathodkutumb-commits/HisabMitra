import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../data/group_repository.dart';
import 'group_cloud_screens.dart';
import '../domain/expense_status.dart';
import '../domain/group_models.dart';
import 'group_expense_views.dart';
import 'group_labels.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({
    super.key,
    required this.groupId,
    this.initialTab = 0,
  });

  final String groupId;
  final int initialTab;

  Future<void> _menu(
    BuildContext context,
    WidgetRef ref,
    String action,
    GroupDetail d,
  ) async {
    final l = context.l10n;
    final repo = ref.read(groupRepositoryProvider);
    try {
      switch (action) {
        case 'edit':
          await context.push(Routes.editGroup(groupId));
        case 'share':
          await shareGroupToCloud(context, ref, groupId);
        case 'remind':
          await context.push(Routes.newReminder(groupId: groupId));
        case 'history':
          await context.push(Routes.groupSettlements(groupId));
        case 'archive':
          final archive = d.group.status == GroupStatus.active;
          final ok = await confirmAction(
            context,
            title: archive ? l.archiveGroup : l.unarchiveGroup,
          );
          if (ok) await repo.setArchived(groupId, archived: archive);
        case 'delete':
          final ok = await confirmDelete(
            context,
            message: l.deleteGroupMessage,
          );
          if (!ok) return;
          await repo.deleteLocalGroup(groupId);
          if (context.mounted) Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncValueView(
      value: ref.watch(groupDetailProvider(groupId)),
      data: (d) {
        if (d == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.groups_rounded,
              title: l.errorNotFound,
            ),
          );
        }
        return DefaultTabController(
          length: 2,
          initialIndex: initialTab,
          child: Scaffold(
            appBar: AppBar(
              title: Text(d.group.name),
              actions: [
                IconButton(
                  tooltip: l.groupMembers,
                  icon: const Icon(Icons.people_alt_rounded),
                  onPressed: () => context.push(Routes.groupMembers(groupId)),
                ),
                if (AppConfig.isCloudConfigured)
                  IconButton(
                    tooltip: l.inviteMembers,
                    icon: const Icon(Icons.person_add_rounded),
                    onPressed: () => context.push(Routes.groupInvite(groupId)),
                  ),
                PopupMenuButton<String>(
                  onSelected: (a) => _menu(context, ref, a, d),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'edit', child: Text(l.editGroup)),
                    if (AppConfig.isCloudConfigured && !d.group.isShared)
                      PopupMenuItem(
                        value: 'share',
                        child: Text(l.shareToCloud),
                      ),
                    PopupMenuItem(value: 'remind', child: Text(l.remindLater)),
                    PopupMenuItem(
                      value: 'history',
                      child: Text(l.settlementHistory),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(
                        d.group.status == GroupStatus.active
                            ? l.archiveGroup
                            : l.unarchiveGroup,
                      ),
                    ),
                    if (!d.group.isShared)
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(l.deleteGroup),
                      ),
                  ],
                ),
              ],
              bottom: TabBar(
                tabs: [
                  Tab(text: l.groupExpenses),
                  Tab(text: l.groupBalances),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              // Unique: the tab shell keeps several FAB screens alive.
              heroTag: 'fab-group-detail',
              onPressed: () => context.push(Routes.newGroupExpense(groupId)),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.addGroupExpense),
            ),
            body: TabBarView(
              children: [
                _ExpensesTab(detail: d),
                GroupBalancesView(detail: d),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.detail});

  final GroupDetail detail;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final theme = Theme.of(context);
    final self = detail.selfMember;
    final net = self == null ? 0 : detail.netBalances[self.id] ?? 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: HeroCard(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.totalSpent,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: hm.onHero.withValues(alpha: 0.8),
                    ),
                  ),
                  AmountText(
                    detail.totalSpentPaise,
                    color: hm.onHero,
                    style: theme.textTheme.titleLarge,
                  ),
                  Text(
                    l.memberCount(detail.members.length),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: hm.onHero.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  net > 0
                      ? l.youAreOwed
                      : net < 0
                      ? l.youOwe
                      : l.settledUp,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: hm.onHero.withValues(alpha: 0.8),
                  ),
                ),
                AmountText(
                  net.abs(),
                  color: hm.highlight,
                  style: theme.textTheme.titleLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpensesTab extends ConsumerStatefulWidget {
  const _ExpensesTab({required this.detail});

  final GroupDetail detail;

  @override
  ConsumerState<_ExpensesTab> createState() => _ExpensesTabState();
}

class _ExpensesTabState extends ConsumerState<_ExpensesTab> {
  GroupView? _view;
  String? _member;
  String? _category;
  ExpenseSettlement? _status;
  DateRange? _range;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final d = widget.detail;
    final view =
        _view ?? ref.watch(settingsControllerProvider).defaultGroupView;
    final expenses = d.expenses.where((e) {
      if (_member != null &&
          e.expense.paidByMemberId != _member &&
          !e.splits.containsKey(_member)) {
        return false;
      }
      if (_category != null && e.expense.categoryKey != _category) return false;
      if (_status != null && statusOf(e, d) != _status) return false;
      if (_range != null && !_range!.contains(e.expense.expenseDate)) {
        return false;
      }
      return true;
    }).toList();
    final settlements = d.settlements.where((s) {
      if (_member != null &&
          s.fromMemberId != _member &&
          s.toMemberId != _member) {
        return false;
      }
      if (_range != null && !_range!.contains(s.settledOn)) return false;
      return _category == null && _status == null;
    }).toList();
    final categories = {for (final e in d.expenses) e.expense.categoryKey}
        .toList();
    final filtered =
        _member != null ||
        _category != null ||
        _status != null ||
        _range != null;

    return Column(
      children: [
        _GroupHeader(detail: d),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SegmentedButton<GroupView>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(
                value: GroupView.spreadsheet,
                icon: const Icon(Icons.table_chart_rounded),
                label: Text(l.viewSpreadsheet),
              ),
              ButtonSegment(
                value: GroupView.cards,
                icon: const Icon(Icons.grid_view_rounded),
                label: Text(l.viewCards),
              ),
              ButtonSegment(
                value: GroupView.timeline,
                icon: const Icon(Icons.timeline_rounded),
                label: Text(l.viewTimeline),
              ),
            ],
            selected: {view},
            onSelectionChanged: (s) => setState(() => _view = s.first),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              _FilterMenu<String>(
                label: _member == null
                    ? l.filterMember
                    : d.memberName(_member!),
                active: _member != null,
                options: [
                  for (final m in d.allMembers.values)
                    (m.id, memberLabel(l, m)),
                ],
                onSelected: (v) => setState(() => _member = v),
              ),
              _FilterMenu<String>(
                label: _category == null
                    ? l.category
                    : groupCategoryLabel(l, _category!),
                active: _category != null,
                options: [
                  for (final c in categories) (c, groupCategoryLabel(l, c)),
                ],
                onSelected: (v) => setState(() => _category = v),
              ),
              _FilterMenu<ExpenseSettlement>(
                label: _status == null ? l.settlementStatus : _status!.label(l),
                active: _status != null,
                options: [
                  for (final s in ExpenseSettlement.values) (s, s.label(l)),
                ],
                onSelected: (v) => setState(() => _status = v),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  avatar: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(
                    _range == null
                        ? l.filterDate
                        : '${fmt.dayMonth(_range!.start)} – ${fmt.dayMonth(_range!.endInclusive)}',
                  ),
                  selected: _range != null,
                  onSelected: (_) async {
                    if (_range != null) {
                      setState(() => _range = null);
                      return;
                    }
                    final picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                    );
                    if (picked != null) {
                      setState(
                        () =>
                            _range = DateRange.custom(picked.start, picked.end),
                      );
                    }
                  },
                ),
              ),
              if (filtered)
                TextButton(
                  onPressed: () => setState(() {
                    _member = null;
                    _category = null;
                    _status = null;
                    _range = null;
                  }),
                  child: Text(l.filterClearAll),
                ),
            ],
          ),
        ),
        Expanded(
          child: d.expenses.isEmpty
              ? EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: l.noGroupExpensesTitle,
                  message: l.noGroupExpensesBody,
                  actionLabel: l.addGroupExpense,
                  onAction: () =>
                      context.push(Routes.newGroupExpense(d.group.id)),
                  compact: true,
                )
              : expenses.isEmpty && settlements.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: l.noResultsTitle,
                  compact: true,
                )
              : switch (view) {
                  GroupView.spreadsheet => GroupSpreadsheetView(
                    detail: d,
                    expenses: expenses,
                  ),
                  GroupView.cards => GroupCardsView(
                    detail: d,
                    expenses: expenses,
                  ),
                  GroupView.timeline => GroupTimelineView(
                    detail: d,
                    expenses: expenses,
                    settlements: settlements,
                  ),
                },
        ),
      ],
    );
  }
}

class _FilterMenu<T> extends StatelessWidget {
  const _FilterMenu({
    required this.label,
    required this.active,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final bool active;
  final List<(T, String)> options;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<(T?,)>(
        onSelected: (v) => onSelected(v.$1),
        itemBuilder: (_) => [
          PopupMenuItem(value: (null,), child: Text(context.l10n.filterAll)),
          for (final (value, text) in options)
            PopupMenuItem(value: (value,), child: Text(text)),
        ],
        child: Chip(
          label: Text(label),
          avatar: Icon(
            Icons.arrow_drop_down_rounded,
            size: 18,
            color: active ? Theme.of(context).colorScheme.primary : null,
          ),
          backgroundColor: active
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
        ),
      ),
    );
  }
}

/// Balance summary: per-member paid / share / net and suggested transfers.
class GroupBalancesView extends ConsumerWidget {
  const GroupBalancesView({super.key, required this.detail});

  final GroupDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final theme = Theme.of(context);
    final d = detail;
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        _GroupHeader(detail: d),
        SectionHeader(title: l.groupBalances),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            child: Column(
              children: [
                for (final m in d.allMembers.values.where(
                  (m) =>
                      d.members.contains(m) || (d.netBalances[m.id] ?? 0) != 0,
                ))
                  Builder(
                    builder: (context) {
                      final net = d.netBalances[m.id] ?? 0;
                      final totals = d.memberTotals[m.id];
                      return ListTile(
                        leading: InitialsAvatar(name: m.displayName),
                        title: Text(memberLabel(l, m)),
                        subtitle: Wrap(
                          spacing: 10,
                          children: [
                            Text(
                              '${l.paid}: ${ref.fmt.money(totals?.paidPaise ?? 0, compact: true)}',
                            ),
                            Text(
                              '${l.memberShare}: ${ref.fmt.money(totals?.owedPaise ?? 0, compact: true)}',
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              net > 0
                                  ? l.getsBack
                                  : net < 0
                                  ? l.owes
                                  : l.settledUp,
                              style: theme.textTheme.labelSmall,
                            ),
                            AmountText(
                              net.abs(),
                              color: net > 0
                                  ? hm.receivable
                                  : net < 0
                                  ? hm.payable
                                  : null,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
        SectionHeader(
          title: l.suggestedSettlements,
          actionLabel: l.settlementHistory,
          onAction: () => context.push(Routes.groupSettlements(d.group.id)),
        ),
        if (d.suggestions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: Icon(Icons.verified_rounded, color: hm.income),
                title: Text(l.groupAllSettled),
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Column(
                children: [
                  for (final s in d.suggestions)
                    ListTile(
                      leading: const Icon(Icons.swap_horiz_rounded),
                      title: Text(
                        l.paysTo(d.memberName(s.from), d.memberName(s.to)),
                      ),
                      subtitle: AmountText(s.amountPaise, color: hm.payable),
                      trailing: FilledButton.tonal(
                        onPressed: () => context.push(
                          Routes.groupSettle(
                            d.group.id,
                            from: s.from,
                            to: s.to,
                            amount: s.amountPaise,
                          ),
                        ),
                        child: Text(l.settleUp),
                      ),
                    ),
                ],
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: () => context.push(Routes.groupSettle(d.group.id)),
            icon: const Icon(Icons.handshake_rounded),
            label: Text(l.recordSettlement),
          ),
        ),
      ],
    );
  }
}

class GroupBalancesScreen extends ConsumerWidget {
  const GroupBalancesScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.groupBalances)),
      body: AsyncValueView(
        value: ref.watch(groupDetailProvider(groupId)),
        data: (d) => d == null
            ? EmptyState(icon: Icons.groups_rounded, title: l.errorNotFound)
            : GroupBalancesView(detail: d),
      ),
    );
  }
}
