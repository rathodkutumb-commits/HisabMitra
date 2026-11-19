import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/expense_status.dart';
import '../domain/group_models.dart';
import 'group_labels.dart';

ExpenseSettlement statusOf(ExpenseView e, GroupDetail d) => expenseStatus(
  paidBy: e.expense.paidByMemberId,
  shares: e.splits,
  netBalances: d.netBalances,
);

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.status);

  final ExpenseSettlement status;

  @override
  Widget build(BuildContext context) {
    final hm = HmColors.of(context);
    final color = switch (status) {
      ExpenseSettlement.settled => hm.income,
      ExpenseSettlement.partlySettled => hm.accentInk,
      ExpenseSettlement.pending => hm.payable,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label(context.l10n),
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// A. Excel-like date-wise table with one column per member share.
class GroupSpreadsheetView extends ConsumerWidget {
  const GroupSpreadsheetView({
    super.key,
    required this.detail,
    required this.expenses,
  });

  final GroupDetail detail;
  final List<ExpenseView> expenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    final members =
        detail.allMembers.values
            .where(
              (m) =>
                  detail.members.contains(m) ||
                  expenses.any((e) => e.splits.containsKey(m.id)),
            )
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final numStyle = theme.textTheme.bodySmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    String money(int p) => fmt.money(p);

    final totals = {for (final m in members) m.id: 0};
    var grand = 0;
    for (final e in expenses) {
      grand += e.expense.amountPaise;
      e.splits.forEach((id, share) => totals[id] = (totals[id] ?? 0) + share);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 96),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DataTable(
          headingRowColor: WidgetStatePropertyAll(
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
          ),
          columnSpacing: 18,
          horizontalMargin: 10,
          dataRowMinHeight: 44,
          dataRowMaxHeight: 56,
          showCheckboxColumn: false,
          columns: [
            DataColumn(label: Text(l.date, style: headerStyle)),
            DataColumn(label: Text(l.description, style: headerStyle)),
            DataColumn(label: Text(l.paidBy, style: headerStyle)),
            DataColumn(
              label: Text(l.amount, style: headerStyle),
              numeric: true,
            ),
            DataColumn(label: Text(l.category, style: headerStyle)),
            for (final m in members)
              DataColumn(
                label: Text(m.displayName, style: headerStyle),
                numeric: true,
              ),
            DataColumn(label: Text(l.settlementStatus, style: headerStyle)),
          ],
          rows: [
            for (final e in expenses)
              DataRow(
                onSelectChanged: (_) => context.push(
                  Routes.groupExpense(detail.group.id, e.expense.id),
                ),
                cells: [
                  DataCell(
                    Text(fmt.date(e.expense.expenseDate), style: numStyle),
                  ),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 160),
                      child: Text(
                        e.expense.description,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  DataCell(Text(detail.memberName(e.expense.paidByMemberId))),
                  DataCell(
                    Text(
                      money(e.expense.amountPaise),
                      style: numStyle?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  DataCell(Text(groupCategoryLabel(l, e.expense.categoryKey))),
                  for (final m in members)
                    DataCell(
                      Text(
                        e.splits.containsKey(m.id)
                            ? money(e.splits[m.id]!)
                            : '—',
                        style: numStyle,
                      ),
                    ),
                  DataCell(_StatusPill(statusOf(e, detail))),
                ],
              ),
            DataRow(
              color: WidgetStatePropertyAll(
                theme.colorScheme.surfaceContainerHigh,
              ),
              cells: [
                DataCell(Text(l.total, style: headerStyle)),
                const DataCell(SizedBox()),
                const DataCell(SizedBox()),
                DataCell(Text(money(grand), style: headerStyle)),
                const DataCell(SizedBox()),
                for (final m in members)
                  DataCell(Text(money(totals[m.id] ?? 0), style: headerStyle)),
                const DataCell(SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// B. Card grid.
class GroupCardsView extends ConsumerWidget {
  const GroupCardsView({
    super.key,
    required this.detail,
    required this.expenses,
  });

  final GroupDetail detail;
  final List<ExpenseView> expenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth > 600
            ? 3
            : (constraints.maxWidth > 360 ? 2 : 1);
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            mainAxisExtent: 168,
          ),
          itemCount: expenses.length,
          itemBuilder: (context, i) {
            final e = expenses[i];
            return Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push(
                  Routes.groupExpense(detail.group.id, e.expense.id),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconBadge(
                            icon: GroupExpenseCategories.icon(
                              e.expense.categoryKey,
                            ),
                            color: theme.colorScheme.tertiary,
                            size: 32,
                          ),
                          const Spacer(),
                          _StatusPill(statusOf(e, detail)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        e.expense.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall,
                      ),
                      AmountText(
                        e.expense.amountPaise,
                        style: theme.textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Text(
                        l.paidByName(
                          detail.memberName(e.expense.paidByMemberId),
                        ),
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${fmt.date(e.expense.expenseDate)} · ${e.expense.splitMethod.label(l)} · ${e.splits.length}',
                        style: theme.textTheme.labelSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// C. Chronological timeline of expenses and settlements.
class GroupTimelineView extends ConsumerWidget {
  const GroupTimelineView({
    super.key,
    required this.detail,
    required this.expenses,
    required this.settlements,
  });

  final GroupDetail detail;
  final List<ExpenseView> expenses;
  final List<GroupSettlementRow> settlements;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    final hm = HmColors.of(context);
    final events =
        <(DateTime, DateTime, Widget)>[
          for (final e in expenses)
            (
              e.expense.expenseDate,
              e.expense.createdAt,
              ListTile(
                onTap: () => context.push(
                  Routes.groupExpense(detail.group.id, e.expense.id),
                ),
                title: Text(e.expense.description),
                subtitle: Text(
                  l.paidByName(detail.memberName(e.expense.paidByMemberId)),
                ),
                trailing: AmountText(e.expense.amountPaise),
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiaryContainer,
                  child: Icon(
                    GroupExpenseCategories.icon(e.expense.categoryKey),
                    color: theme.colorScheme.onTertiaryContainer,
                    size: 20,
                  ),
                ),
              ),
            ),
          for (final s in settlements)
            (
              s.settledOn,
              s.createdAt,
              ListTile(
                title: Text(
                  l.timelineSettlement(
                    detail.memberName(s.fromMemberId),
                    detail.memberName(s.toMemberId),
                  ),
                ),
                subtitle: Text(s.paymentMethod.label(l)),
                trailing: AmountText(s.amountPaise, color: hm.income),
                leading: CircleAvatar(
                  backgroundColor: hm.income.withValues(alpha: 0.15),
                  child: Icon(
                    Icons.handshake_rounded,
                    color: hm.income,
                    size: 20,
                  ),
                ),
              ),
            ),
        ]..sort((a, b) {
          final c = b.$1.compareTo(a.$1);
          return c != 0 ? c : b.$2.compareTo(a.$2);
        });

    final children = <Widget>[];
    DateTime? day;
    for (final (date, _, tile) in events) {
      if (day != date) {
        day = date;
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Icon(Icons.circle, size: 10, color: hm.highlight),
                const SizedBox(width: 8),
                Text(fmt.date(date), style: theme.textTheme.labelLarge),
              ],
            ),
          ),
        );
      }
      children.add(
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 2,
                ),
              ),
            ),
            child: tile,
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: children,
    );
  }
}
