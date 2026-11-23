import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../data/family_repository.dart';
import '../domain/family_models.dart';
import 'family_labels.dart';

/// One Family hisab, a month at a time, like a passbook: opening balance,
/// money in, money out, closing balance and the month's entries.
class FamilyHomeScreen extends ConsumerStatefulWidget {
  const FamilyHomeScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<FamilyHomeScreen> createState() => _FamilyHomeScreenState();
}

class _FamilyHomeScreenState extends ConsumerState<FamilyHomeScreen> {
  late DateTime _month = () {
    final now = ref.read(clockProvider).now();
    return DateTime(now.year, now.month);
  }();

  String get _id => widget.familyId;

  void _shift(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await confirmAction(
      context,
      title: l.familyDelete,
      message: l.familyDeleteMessage,
      confirmLabel: l.delete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(familyRepositoryProvider).deleteFamily(_id);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final hm = HmColors.of(context);
    final detail = ref.watch(familyDetailProvider(_id));

    return Scaffold(
      appBar: AppBar(
        title: Text(detail.value?.family.name ?? l.familyHisab),
        actions: [
          IconButton(
            tooltip: l.familyStatement,
            icon: const Icon(Icons.summarize_rounded),
            onPressed: () => context.push(
              Routes.familyStatement(
                _id,
                year: _month.year,
                month: _month.month,
              ),
            ),
          ),
          IconButton(
            tooltip: l.familyPeople,
            icon: const Icon(Icons.people_alt_rounded),
            onPressed: () => context.push(Routes.familyPeople(_id)),
          ),
          PopupMenuButton<String>(
            onSelected: (action) => switch (action) {
              'edit' => context.push(Routes.editFamily(_id)),
              'new' => context.push(Routes.newFamily),
              _ => _delete(),
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'edit', child: Text(l.familyEdit)),
              PopupMenuItem(value: 'new', child: Text(l.familyNew)),
              PopupMenuItem(value: 'delete', child: Text(l.familyDelete)),
            ],
          ),
        ],
      ),
      body: AsyncValueView(
        value: detail,
        data: (d) {
          if (d == null) {
            return EmptyState(
              icon: Icons.family_restroom_rounded,
              title: l.errorNotFound,
            );
          }
          final s = d.month(_month.year, _month.month);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: l.familyPreviousMonth,
                    onPressed: () => _shift(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Expanded(
                    child: Text(
                      fmt.monthYear(_month),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: l.familyNextMonth,
                    onPressed: () => _shift(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                  ),
                ],
              ),
              HeroCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _line(
                      l.familyOpening,
                      fmt.money(s.openingPaise),
                      'passbook-opening',
                    ),
                    const SizedBox(height: 8),
                    _line(
                      l.familyMoneyIn,
                      '+ ${fmt.money(s.moneyInPaise)}',
                      'passbook-in',
                    ),
                    const SizedBox(height: 8),
                    _line(
                      l.familyMoneyOut,
                      '− ${fmt.money(s.moneyOutPaise)}',
                      'passbook-out',
                    ),
                    Divider(
                      height: 24,
                      color: hm.onHero.withValues(alpha: 0.3),
                    ),
                    _line(
                      l.familyClosing,
                      fmt.money(s.closingPaise),
                      'passbook-closing',
                      big: true,
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          context.push(Routes.newFamilyEntry(_id, kind: 'in')),
                      icon: Icon(Icons.south_west_rounded, color: hm.income),
                      label: Text(l.familyMoneyIn),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () =>
                          context.push(Routes.newFamilyEntry(_id, kind: 'out')),
                      icon: Icon(Icons.north_east_rounded, color: hm.expense),
                      label: Text(l.familyMoneyOut),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (s.entries.isEmpty)
                EmptyState(
                  compact: true,
                  icon: Icons.receipt_long_rounded,
                  title: l.familyNoEntriesYet,
                )
              else
                for (final e in s.entries)
                  _EntryTile(
                    entry: e,
                    person: d.memberName(e.memberId, l),
                    onTap: () =>
                        context.push(Routes.editFamilyEntry(_id, e.id)),
                  ),
            ],
          );
        },
      ),
    );
  }

  Widget _line(String label, String value, String key, {bool big = false}) {
    final t = Theme.of(context).textTheme;
    final style = (big ? t.titleLarge : t.bodyLarge)?.copyWith(
      color: HmColors.of(context).onHero,
      fontWeight: big ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, key: Key(key), style: style),
      ],
    );
  }
}

class _EntryTile extends ConsumerWidget {
  const _EntryTile({
    required this.entry,
    required this.person,
    required this.onTap,
  });

  final FamilyEntry entry;
  final String person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final hm = HmColors.of(context);
    final color = entry.kind.isMoneyIn
        ? hm.income
        : (entry.categoryColor == null
              ? hm.expense
              : Color(entry.categoryColor!));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: IconBadge(icon: entry.icon, color: color),
      title: Text(entry.title(l)),
      subtitle: Text(
        [
          person,
          fmt.dayMonth(entry.date),
          if (entry.note != null) entry.note!,
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${entry.kind.isMoneyIn ? '+' : '−'} ${fmt.money(entry.amountPaise)}',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: entry.kind.isMoneyIn ? hm.income : hm.expense,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
