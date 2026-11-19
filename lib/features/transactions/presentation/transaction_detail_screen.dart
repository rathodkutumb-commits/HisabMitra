import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../attachments/data/attachment_service.dart';
import '../../attachments/presentation/attachments_editor.dart';
import '../../categories/presentation/category_labels.dart';
import '../../settings/application/settings_controller.dart';
import '../data/transaction_repository.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final String transactionId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await confirmDelete(
      context,
      message: l.deleteTransactionMessage,
    );
    if (!ok || !context.mounted) return;
    try {
      final files = await ref
          .read(transactionRepositoryProvider)
          .delete(transactionId);
      await ref.read(attachmentServiceProvider).deleteFiles(files);
      if (!context.mounted) return;
      showAppSnack(context, l.transactionDeleted);
      Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hm = HmColors.of(context);
    final fmt = ref.watch(formattersProvider);
    final value = ref.watch(transactionProvider(transactionId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l.transactionDetailsTitle),
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () =>
                context.push(Routes.editTransaction(transactionId)),
          ),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: AsyncValueView(
        value: value,
        data: (view) {
          if (view == null) {
            return EmptyState(
              icon: Icons.receipt_long_rounded,
              title: l.errorNotFound,
            );
          }
          final t = view.txn;
          final isIncome = t.type == TransactionType.income;
          Widget row(IconData icon, String label, String value) => ListTile(
            leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
            title: Text(label, style: theme.textTheme.labelMedium),
            subtitle: Text(value, style: theme.textTheme.bodyLarge),
          );
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      IconBadge(
                        icon: view.category.icon,
                        color: view.category.color,
                        size: 56,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        isIncome ? l.income : l.expense,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: isIncome ? hm.income : hm.expense,
                        ),
                      ),
                      AmountText(
                        t.amountPaise,
                        style: theme.textTheme.headlineMedium,
                        color: isIncome ? hm.income : hm.expense,
                      ),
                      if (t.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.description,
                          style: theme.textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    row(
                      Icons.category_rounded,
                      l.category,
                      view.category.label(l),
                    ),
                    row(Icons.event_rounded, l.date, fmt.date(t.txnDate)),
                    row(
                      Icons.payments_rounded,
                      l.paymentMethod,
                      t.paymentMethod.label(l),
                    ),
                    if (view.person != null)
                      ListTile(
                        leading: InitialsAvatar(
                          name: view.person!.name,
                          radius: 14,
                        ),
                        title: Text(
                          l.person,
                          style: theme.textTheme.labelMedium,
                        ),
                        subtitle: Text(
                          view.person!.name,
                          style: theme.textTheme.bodyLarge,
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () =>
                            context.push(Routes.person(view.person!.id)),
                      ),
                    if (t.notes != null)
                      row(Icons.notes_rounded, l.notes, t.notes!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AttachmentStrip(
                parent: AttachmentParent.transaction,
                parentId: t.id,
              ),
              const SizedBox(height: 16),
              Text(
                '${l.createdOn(fmt.dateTime(t.createdAt))}\n${l.updatedOn(fmt.dateTime(t.updatedAt))}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
