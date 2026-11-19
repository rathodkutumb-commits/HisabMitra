import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/hm_colors.dart';
import '../../../../core/l10n/l10n_x.dart';
import '../../../settings/application/settings_controller.dart';
import '../../../categories/presentation/category_labels.dart';
import '../../domain/transaction_models.dart';
import '../../domain/transaction_sheet.dart';

/// Excel-like sheet of personal income and expense: one row per entry,
/// oldest first, separate Income / Expense columns, a running balance and a
/// totals row. Scrolls both ways; tapping a row opens the transaction.
class TransactionSheetView extends ConsumerWidget {
  const TransactionSheetView({super.key, required this.items});

  final List<TransactionView> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    final hm = HmColors.of(context);
    final sheet = TransactionSheet.from(items);

    final headerStyle = theme.textTheme.labelMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final numStyle = theme.textTheme.bodySmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    String money(int p) => p == 0 ? '' : fmt.money(p);

    Text amount(int paise, Color color, {bool bold = false}) => Text(
      money(paise),
      style: numStyle?.copyWith(
        color: color,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      ),
    );

    Text balance(int paise, {bool bold = false}) => Text(
      fmt.money(paise),
      style: numStyle?.copyWith(
        color: paise < 0 ? hm.expense : theme.colorScheme.onSurface,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
      ),
    );

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Text(
            l.sheetTip,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DataTable(
            headingRowColor: WidgetStatePropertyAll(
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.6),
            ),
            border: TableBorder(
              horizontalInside: BorderSide(
                color: theme.colorScheme.outlineVariant,
              ),
              verticalInside: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            columnSpacing: 16,
            horizontalMargin: 10,
            dataRowMinHeight: 40,
            dataRowMaxHeight: 52,
            showCheckboxColumn: false,
            columns: [
              DataColumn(label: Text(l.date, style: headerStyle)),
              DataColumn(label: Text(l.description, style: headerStyle)),
              DataColumn(label: Text(l.category, style: headerStyle)),
              DataColumn(label: Text(l.paymentMethod, style: headerStyle)),
              DataColumn(label: Text(l.person, style: headerStyle)),
              DataColumn(
                label: Text(l.income, style: headerStyle),
                numeric: true,
              ),
              DataColumn(
                label: Text(l.expense, style: headerStyle),
                numeric: true,
              ),
              DataColumn(
                label: Text(l.runningBalance, style: headerStyle),
                numeric: true,
              ),
            ],
            rows: [
              for (final r in sheet.rows)
                DataRow(
                  onSelectChanged: (_) =>
                      context.push(Routes.transaction(r.view.txn.id)),
                  cells: [
                    DataCell(
                      Text(fmt.date(r.view.txn.txnDate), style: numStyle),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 170),
                        child: Text(
                          r.view.txn.description.isEmpty
                              ? '—'
                              : r.view.txn.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(r.view.category.label(l))),
                    DataCell(Text(r.view.txn.paymentMethod.label(l))),
                    DataCell(Text(r.view.person?.name ?? '')),
                    DataCell(amount(r.incomePaise, hm.income)),
                    DataCell(amount(r.expensePaise, hm.expense)),
                    DataCell(balance(r.runningBalancePaise)),
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
                  const DataCell(SizedBox()),
                  const DataCell(SizedBox()),
                  DataCell(
                    amount(sheet.totalIncomePaise, hm.income, bold: true),
                  ),
                  DataCell(
                    amount(sheet.totalExpensePaise, hm.expense, bold: true),
                  ),
                  DataCell(balance(sheet.netPaise, bold: true)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
