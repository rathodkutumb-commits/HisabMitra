import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../attachments/data/attachment_service.dart';
import '../../money_ledger/data/ledger_repository.dart';
import '../../money_ledger/presentation/ledger_history_screen.dart';
import '../../money_ledger/presentation/widgets/ledger_entry_tile.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_models.dart';
import '../../transactions/presentation/widgets/transaction_tile.dart';
import '../data/people_repository.dart';
import '../../ai_assistant/presentation/ai_fab.dart';

class PersonDetailScreen extends ConsumerWidget {
  const PersonDetailScreen({super.key, required this.personId});

  final String personId;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await confirmDelete(context, message: l.deletePersonMessage);
    if (!ok || !context.mounted) return;
    try {
      final files = await ref.read(peopleRepositoryProvider).delete(personId);
      await ref.read(attachmentServiceProvider).deleteFiles(files);
      if (context.mounted) {
        showAppSnack(context, l.deletedMessage);
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final theme = Theme.of(context);
    final person = ref.watch(personProvider(personId));
    final balance = ref.watch(personBalanceProvider(personId)).value;

    return AsyncValueView(
      value: person,
      data: (p) {
        if (p == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.person_off_rounded,
              title: l.errorNotFound,
            ),
          );
        }
        final net = balance?.netPaise ?? 0;
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            floatingActionButton: const AiFabStack(),
            appBar: AppBar(
              title: Text(p.name),
              actions: [
                if (p.phone != null)
                  IconButton(
                    tooltip: l.callPerson,
                    icon: const Icon(Icons.call_rounded),
                    onPressed: () =>
                        launchUrl(Uri(scheme: 'tel', path: p.phone)),
                  ),
                IconButton(
                  tooltip: l.edit,
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () => context.push(Routes.editPerson(personId)),
                ),
                IconButton(
                  tooltip: l.delete,
                  icon: const Icon(Icons.delete_outline_rounded),
                  onPressed: () => _delete(context, ref),
                ),
              ],
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    InitialsAvatar(name: p.name, radius: 28),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            net > 0
                                                ? l.owesYou(p.name)
                                                : net < 0
                                                ? l.youOweName(p.name)
                                                : l.allSettled,
                                            style: theme.textTheme.labelLarge,
                                          ),
                                          AmountText(
                                            net.abs(),
                                            style:
                                                theme.textTheme.headlineSmall,
                                            color: net > 0
                                                ? hm.receivable
                                                : net < 0
                                                ? hm.payable
                                                : null,
                                          ),
                                          if (p.phone != null)
                                            Text(
                                              PhoneNumbers.display(p.phone!),
                                              style: theme.textTheme.bodySmall,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _Figure(
                                        label: l.totalGiven,
                                        paise: balance?.totalGivenPaise ?? 0,
                                      ),
                                    ),
                                    Expanded(
                                      child: _Figure(
                                        label: l.totalTaken,
                                        paise: balance?.totalTakenPaise ?? 0,
                                      ),
                                    ),
                                    Expanded(
                                      child: _Figure(
                                        label: l.dashboardToReceive,
                                        paise: balance?.receivablePaise ?? 0,
                                        color: hm.receivable,
                                      ),
                                    ),
                                    Expanded(
                                      child: _Figure(
                                        label: l.dashboardToPay,
                                        paise: balance?.payablePaise ?? 0,
                                        color: hm.payable,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () => context.push(
                                  Routes.newLedgerEntry(personId: personId),
                                ),
                                icon: const Icon(Icons.call_made_rounded),
                                label: Text(l.ledgerGivenLabel),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () => context.push(
                                  Routes.newLedgerEntry(
                                    personId: personId,
                                    direction: 'taken',
                                  ),
                                ),
                                icon: const Icon(Icons.call_received_rounded),
                                label: Text(l.ledgerTakenLabel),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filledTonal(
                              tooltip: l.remindLater,
                              onPressed: () => context.push(
                                Routes.newReminder(personId: personId),
                              ),
                              icon: const Icon(Icons.alarm_add_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      tabs: [
                        Tab(text: l.ledgerEntries),
                        Tab(text: l.repaymentHistory),
                        Tab(text: l.personTransactions),
                      ],
                    ),
                    theme.scaffoldBackgroundColor,
                  ),
                ),
              ],
              body: TabBarView(
                children: [
                  _EntriesTab(personId: personId),
                  RepaymentHistoryList(personId: personId),
                  _TransactionsTab(personId: personId),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.paise, this.color});

  final String label;
  final int paise;
  final Color? color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        label,
        style: Theme.of(context).textTheme.labelSmall,
        textAlign: TextAlign.center,
        maxLines: 2,
      ),
      const SizedBox(height: 2),
      FittedBox(
        child: AmountText(
          paise,
          color: color,
          compact: true,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    ],
  );
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar, this.background);

  final TabBar tabBar;
  final Color background;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(color: background, child: tabBar);

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}

class _EntriesTab extends ConsumerWidget {
  const _EntriesTab({required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncValueView(
      value: ref.watch(
        ledgerEntriesProvider((personId: personId, onlyOpen: false)),
      ),
      data: (entries) => entries.isEmpty
          ? EmptyState(
              icon: Icons.menu_book_rounded,
              title: l.noLedgerTitle,
              message: l.noLedgerBody,
              compact: true,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [for (final e in entries) LedgerEntryTile(view: e)],
            ),
    );
  }
}

class _TransactionsTab extends ConsumerWidget {
  const _TransactionsTab({required this.personId});

  final String personId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncValueView(
      value: ref.watch(
        transactionsProvider(TransactionFilter(personId: personId)),
      ),
      data: (items) => items.isEmpty
          ? EmptyState(
              icon: Icons.receipt_long_rounded,
              title: l.noTransactionsTitle,
              compact: true,
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: 32),
              children: [
                for (final v in items) TransactionTile(view: v, showDate: true),
              ],
            ),
    );
  }
}
