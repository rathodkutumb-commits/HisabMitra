import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../attachments/presentation/attachments_editor.dart';
import '../../settings/application/settings_controller.dart';
import '../data/group_repository.dart';
import '../domain/group_models.dart';
import 'group_expense_views.dart';
import 'group_labels.dart';

class GroupExpenseDetailScreen extends ConsumerWidget {
  const GroupExpenseDetailScreen({
    super.key,
    required this.groupId,
    required this.expenseId,
  });

  final String groupId;
  final String expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.groupExpenseDetail),
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () =>
                context.push(Routes.editGroupExpense(groupId, expenseId)),
          ),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final ok = await confirmDelete(
                context,
                message: l.deleteGroupExpenseMessage,
              );
              if (!ok || !context.mounted) return;
              try {
                await ref
                    .read(groupRepositoryProvider)
                    .deleteExpense(expenseId);
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) showFailure(context, e);
              }
            },
          ),
        ],
      ),
      body: AsyncValueView(
        value: ref.watch(groupDetailProvider(groupId)),
        data: (d) {
          final e = d?.expenses
              .where((x) => x.expense.id == expenseId)
              .firstOrNull;
          if (d == null || e == null) {
            return EmptyState(
              icon: Icons.receipt_long_rounded,
              title: l.errorNotFound,
            );
          }
          final x = e.expense;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      IconBadge(
                        icon: GroupExpenseCategories.icon(x.categoryKey),
                        color: theme.colorScheme.tertiary,
                        size: 56,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        x.description,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      AmountText(
                        x.amountPaise,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${l.paidByName(d.memberName(x.paidByMemberId))} · ${fmt.date(x.expenseDate)}',
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          Chip(
                            label: Text(groupCategoryLabel(l, x.categoryKey)),
                          ),
                          Chip(label: Text(x.splitMethod.label(l))),
                          Chip(label: Text(statusOf(e, d).label(l))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SectionHeader(
                title: l.splitPreview,
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              ),
              Card(
                child: Column(
                  children: [
                    for (final entry in e.splits.entries)
                      ListTile(
                        leading: InitialsAvatar(name: d.memberName(entry.key)),
                        title: Text(
                          d.allMembers[entry.key] == null
                              ? '—'
                              : memberLabel(l, d.allMembers[entry.key]!),
                        ),
                        subtitle: _inputLabel(
                          context,
                          x.splitMethod,
                          e.splitInputs[entry.key],
                          fmt,
                        ),
                        trailing: AmountText(entry.value),
                      ),
                    const Divider(),
                    ListTile(
                      title: Text(l.total, style: theme.textTheme.titleSmall),
                      trailing: AmountText(
                        e.splits.values.fold(0, (a, b) => a + b),
                      ),
                    ),
                  ],
                ),
              ),
              if (x.notes != null) ...[
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.notes_rounded),
                    title: Text(x.notes!),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              AttachmentStrip(
                parent: AttachmentParent.groupExpense,
                parentId: x.id,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget? _inputLabel(
    BuildContext context,
    SplitMethod method,
    int? input,
    Formatters fmt,
  ) {
    if (input == null) return null;
    final text = switch (method) {
      SplitMethod.percentage =>
        '${(input ~/ 100)}.${(input % 100).toString().padLeft(2, '0')}%',
      SplitMethod.ratio =>
        '× ${(input ~/ 100)}${input % 100 == 0 ? '' : '.${(input % 100).toString().padLeft(2, '0')}'}',
      SplitMethod.adjustment => fmt.money(input, signed: true),
      SplitMethod.exact || SplitMethod.equal => null,
    };
    return text == null ? null : Text(text);
  }
}
