import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/hm_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../settings/application/settings_controller.dart';
import '../../domain/ledger_calculator.dart';
import '../../domain/ledger_models.dart';

class LedgerStatusChip extends StatelessWidget {
  const LedgerStatusChip({
    super.key,
    required this.status,
    this.overdue = false,
  });

  final LedgerStatus status;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final hm = HmColors.of(context);
    final (label, color) = overdue
        ? (l.overdue, scheme.error)
        : switch (status) {
            LedgerStatus.open => (l.statusOpen, hm.payable),
            LedgerStatus.partial => (l.statusPartial, hm.accentInk),
            LedgerStatus.settled => (l.statusSettled, hm.income),
          };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class LedgerEntryTile extends ConsumerWidget {
  const LedgerEntryTile({
    super.key,
    required this.view,
    this.showPerson = false,
  });

  final LedgerEntryView view;
  final bool showPerson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final fmt = ref.watch(formattersProvider);
    final e = view.entry;
    final given = e.direction == LedgerDirection.given;
    final color = given ? hm.receivable : hm.payable;
    final overdue = view.isOverdue(DateTime.now());
    final title = showPerson
        ? view.person.name
        : (e.description.isNotEmpty
              ? e.description
              : (given ? l.ledgerGivenLabel : l.ledgerTakenLabel));
    final subtitle = [
      if (showPerson && e.description.isNotEmpty) e.description,
      given ? l.ledgerGivenLabel : l.ledgerTakenLabel,
      fmt.date(e.entryDate),
      if (e.dueDate != null && view.summary.status != LedgerStatus.settled)
        l.dueOn(fmt.date(e.dueDate!)),
    ].join(' · ');

    return ListTile(
      onTap: () => context.push(Routes.ledgerEntry(e.id)),
      leading: showPerson
          ? InitialsAvatar(name: view.person.name)
          : IconBadge(
              icon: given
                  ? Icons.call_made_rounded
                  : Icons.call_received_rounded,
              color: color,
            ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AmountText(
            view.summary.status == LedgerStatus.settled
                ? e.principalPaise
                : view.summary.outstandingPaise,
            color: view.summary.status == LedgerStatus.settled ? null : color,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 2),
          LedgerStatusChip(status: view.summary.status, overdue: overdue),
        ],
      ),
    );
  }
}
