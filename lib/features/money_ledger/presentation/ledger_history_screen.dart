import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../settings/application/settings_controller.dart';
import '../data/ledger_repository.dart';

class LedgerHistoryScreen extends StatelessWidget {
  const LedgerHistoryScreen({super.key, this.personId});

  final String? personId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.settlementHistoryTitle)),
      body: RepaymentHistoryList(
        personId: personId,
        showPerson: personId == null,
      ),
    );
  }
}

/// Chronological list of all repayments (optionally for one person).
class RepaymentHistoryList extends ConsumerWidget {
  const RepaymentHistoryList({
    super.key,
    this.personId,
    this.showPerson = false,
  });

  final String? personId;
  final bool showPerson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final fmt = ref.watch(formattersProvider);
    return AsyncValueView(
      value: ref.watch(repaymentHistoryProvider(personId)),
      data: (items) => items.isEmpty
          ? EmptyState(
              icon: Icons.history_rounded,
              title: l.noRepayments,
              compact: true,
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 32),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final h = items[i];
                final received = h.entry.direction == LedgerDirection.given;
                return ListTile(
                  onTap: () => context.push(Routes.ledgerEntry(h.entry.id)),
                  leading: showPerson
                      ? InitialsAvatar(name: h.person.name)
                      : IconBadge(
                          icon: received
                              ? Icons.call_received_rounded
                              : Icons.call_made_rounded,
                          color: received ? hm.receivable : hm.payable,
                        ),
                  title: Text(
                    showPerson
                        ? h.person.name
                        : (received
                              ? l.repaymentReceivedTitle
                              : l.repaymentPaidTitle),
                  ),
                  subtitle: Text(
                    [
                      if (showPerson)
                        received
                            ? l.repaymentReceivedTitle
                            : l.repaymentPaidTitle,
                      fmt.date(h.repayment.settledOn),
                      h.repayment.paymentMethod.label(l),
                      if (h.entry.description.isNotEmpty) h.entry.description,
                    ].join(' · '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: AmountText(
                    received
                        ? h.repayment.amountPaise
                        : -h.repayment.amountPaise,
                    signed: true,
                    color: received ? hm.receivable : hm.payable,
                  ),
                );
              },
            ),
    );
  }
}
