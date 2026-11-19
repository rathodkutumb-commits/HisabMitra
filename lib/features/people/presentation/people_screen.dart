import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../money_ledger/data/ledger_repository.dart';
import '../data/people_repository.dart';

enum _PeopleFilter { all, toReceive, toPay, settled }

/// "Khata" tab: people with their outstanding balances.
class PeopleScreen extends ConsumerStatefulWidget {
  const PeopleScreen({super.key});

  @override
  ConsumerState<PeopleScreen> createState() => _PeopleScreenState();
}

class _PeopleScreenState extends ConsumerState<PeopleScreen> {
  var _filter = _PeopleFilter.all;
  var _query = '';
  var _searching = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final theme = Theme.of(context);
    final totals = ref.watch(ledgerTotalsProvider).value;
    final summaries = ref.watch(peopleSummariesProvider);

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l.searchPeople,
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : Text(l.khataTitle),
        actions: [
          IconButton(
            tooltip: _searching ? l.close : l.search,
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () => setState(() {
              _searching = !_searching;
              _query = '';
            }),
          ),
          IconButton(
            tooltip: l.settlementHistoryTitle,
            icon: const Icon(Icons.history_rounded),
            onPressed: () => context.push(Routes.ledgerHistory()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.addEntry),
      ),
      body: AsyncValueView(
        value: summaries,
        data: (all) {
          final q = _query.trim().toLowerCase();
          final list = all.where((s) {
            if (q.isNotEmpty &&
                !s.person.name.toLowerCase().contains(q) &&
                !(s.person.phone ?? '').contains(q)) {
              return false;
            }
            return switch (_filter) {
              _PeopleFilter.all => true,
              _PeopleFilter.toReceive => s.balance.netPaise > 0,
              _PeopleFilter.toPay => s.balance.netPaise < 0,
              _PeopleFilter.settled => s.balance.netPaise == 0,
            };
          }).toList();
          return ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: HeroCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.netBalance,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: hm.onHero.withValues(alpha: 0.85),
                        ),
                      ),
                      AmountText(
                        totals?.netPaise ?? 0,
                        signed: true,
                        color: hm.onHero,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.dashboardToReceive,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: hm.onHero.withValues(alpha: 0.8),
                                  ),
                                ),
                                AmountText(
                                  totals?.receivablePaise ?? 0,
                                  color: hm.onHero,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l.dashboardToPay,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: hm.onHero.withValues(alpha: 0.8),
                                  ),
                                ),
                                AmountText(
                                  totals?.payablePaise ?? 0,
                                  color: hm.onHero,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    for (final (f, label) in [
                      (_PeopleFilter.all, l.filterAll),
                      (_PeopleFilter.toReceive, l.filterToReceive),
                      (_PeopleFilter.toPay, l.filterToPay),
                      (_PeopleFilter.settled, l.filterSettled),
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(label),
                          selected: _filter == f,
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      ),
                  ],
                ),
              ),
              if (all.isEmpty)
                EmptyState(
                  icon: Icons.menu_book_rounded,
                  title: l.noLedgerTitle,
                  message: l.noLedgerBody,
                  actionLabel: l.addPerson,
                  onAction: () => context.push(Routes.newPerson),
                )
              else if (list.isEmpty)
                EmptyState(
                  icon: Icons.search_off_rounded,
                  title: l.noResultsTitle,
                  compact: true,
                )
              else
                for (final s in list)
                  ListTile(
                    onTap: () => context.push(Routes.person(s.person.id)),
                    leading: InitialsAvatar(name: s.person.name),
                    title: Text(s.person.name),
                    subtitle: Text(
                      s.balance.netPaise > 0
                          ? l.owesYou(s.person.name)
                          : s.balance.netPaise < 0
                          ? l.youOweName(s.person.name)
                          : l.allSettled,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: AmountText(
                      s.balance.netPaise.abs(),
                      color: s.balance.netPaise > 0
                          ? hm.receivable
                          : s.balance.netPaise < 0
                          ? hm.payable
                          : null,
                    ),
                  ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l.ledgerNotIncomeNote,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: IconBadge(
                icon: Icons.call_made_rounded,
                color: hm.receivable,
              ),
              title: Text(l.actionGiveMoney),
              subtitle: Text(l.ledgerGivenLong),
              onTap: () {
                Navigator.pop(ctx);
                context.push(Routes.newLedgerEntry());
              },
            ),
            ListTile(
              leading: IconBadge(
                icon: Icons.call_received_rounded,
                color: hm.payable,
              ),
              title: Text(l.actionReceiveMoney),
              subtitle: Text(l.ledgerTakenLong),
              onTap: () {
                Navigator.pop(ctx);
                context.push(Routes.newLedgerEntry(direction: 'taken'));
              },
            ),
            ListTile(
              leading: IconBadge(
                icon: Icons.person_add_alt_1_rounded,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(l.addPerson),
              onTap: () {
                Navigator.pop(ctx);
                context.push(Routes.newPerson);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
