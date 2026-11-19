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
import '../../settings/application/settings_controller.dart';
import '../data/ledger_repository.dart';
import '../domain/ledger_calculator.dart';
import 'widgets/ledger_entry_tile.dart';

class LedgerEntryDetailScreen extends ConsumerWidget {
  const LedgerEntryDetailScreen({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hm = HmColors.of(context);
    final fmt = ref.watch(formattersProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.ledgerEntryDetailTitle),
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push(Routes.editLedgerEntry(entryId)),
          ),
          IconButton(
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () async {
              final ok = await confirmDelete(
                context,
                message: l.deleteLedgerMessage,
              );
              if (!ok || !context.mounted) return;
              try {
                final files = await ref
                    .read(ledgerRepositoryProvider)
                    .deleteEntry(entryId);
                await ref.read(attachmentServiceProvider).deleteFiles(files);
                if (context.mounted) Navigator.of(context).pop();
              } catch (e) {
                if (context.mounted) showFailure(context, e);
              }
            },
          ),
        ],
      ),
      body: AsyncValueView(
        value: ref.watch(ledgerEntryProvider(entryId)),
        data: (view) {
          if (view == null) {
            return EmptyState(
              icon: Icons.menu_book_rounded,
              title: l.errorNotFound,
            );
          }
          final e = view.entry;
          final s = view.summary;
          final given = e.direction == LedgerDirection.given;
          final color = given ? hm.receivable : hm.payable;
          final progress = e.principalPaise == 0
              ? 0.0
              : s.repaidPaise / e.principalPaise;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InitialsAvatar(name: view.person.name),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  view.person.name,
                                  style: theme.textTheme.titleMedium,
                                ),
                                Text(
                                  given ? l.ledgerGivenLong : l.ledgerTakenLong,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          LedgerStatusChip(
                            status: s.status,
                            overdue: view.isOverdue(DateTime.now()),
                          ),
                        ],
                      ),
                      if (e.description.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(e.description, style: theme.textTheme.bodyLarge),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _Stat(
                              label: l.principal,
                              paise: e.principalPaise,
                            ),
                          ),
                          Expanded(
                            child: _Stat(label: l.repaid, paise: s.repaidPaise),
                          ),
                          Expanded(
                            child: _Stat(
                              label: l.outstanding,
                              paise: s.outstandingPaise,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress.clamp(0, 1),
                          minHeight: 8,
                          color: color,
                          backgroundColor: color.withValues(alpha: 0.15),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.repaidProgress(
                          fmt.money(s.repaidPaise),
                          fmt.money(e.principalPaise),
                        ),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Divider(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 4,
                        children: [
                          Text('${l.date}: ${fmt.date(e.entryDate)}'),
                          if (e.dueDate != null)
                            Text(l.dueOn(fmt.date(e.dueDate!))),
                          Text(
                            '${l.paymentMethod}: ${e.paymentMethod.label(l)}',
                          ),
                        ],
                      ),
                      if (e.notes != null) ...[
                        const SizedBox(height: 8),
                        Text(e.notes!, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AttachmentStrip(
                parent: AttachmentParent.ledgerEntry,
                parentId: e.id,
              ),
              SectionHeader(
                title: l.repaymentHistory,
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              ),
              if (view.repayments.isEmpty)
                Text(l.noRepayments, style: theme.textTheme.bodyMedium)
              else
                Card(
                  child: Column(
                    children: [
                      for (final r in view.repayments.reversed)
                        ListTile(
                          leading: Icon(
                            Icons.check_circle_rounded,
                            color: color,
                          ),
                          title: AmountText(r.amountPaise),
                          subtitle: Text(
                            [
                              fmt.date(r.settledOn),
                              r.paymentMethod.label(l),
                              if (r.notes != null) r.notes!,
                            ].join(' · '),
                          ),
                          trailing: IconButton(
                            tooltip: l.delete,
                            icon: const Icon(Icons.delete_outline_rounded),
                            onPressed: () async {
                              final ok = await confirmDelete(
                                context,
                                message: l.deleteRepaymentConfirm,
                              );
                              if (!ok) return;
                              try {
                                await ref
                                    .read(ledgerRepositoryProvider)
                                    .deleteRepayment(r.id);
                              } catch (err) {
                                if (context.mounted) showFailure(context, err);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: Consumer(
        builder: (context, ref, _) {
          final view = ref.watch(ledgerEntryProvider(entryId)).value;
          if (view == null || view.summary.status == LedgerStatus.settled) {
            return const SizedBox.shrink();
          }
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    tooltip: l.remindLater,
                    onPressed: () =>
                        context.push(Routes.newReminder(ledgerId: entryId)),
                    icon: const Icon(Icons.alarm_add_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          context.push(Routes.repayLedgerEntry(entryId)),
                      icon: const Icon(Icons.payments_rounded),
                      label: Text(l.recordRepayment),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.paise, this.color});

  final String label;
  final int paise;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: Theme.of(context).textTheme.labelSmall),
      FittedBox(child: AmountText(paise, color: color)),
    ],
  );
}
