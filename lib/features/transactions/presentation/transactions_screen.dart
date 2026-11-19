import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/providers.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/presentation/category_labels.dart';
import '../../reports/presentation/export_actions.dart';
import '../../settings/application/settings_controller.dart';
import '../data/transaction_repository.dart';
import '../../settings/domain/app_preferences.dart';
import '../../tour/application/tour_controller.dart';
import '../domain/transaction_models.dart';
import 'widgets/transaction_sheet_view.dart';
import 'widgets/transaction_tile.dart';

class _FilterController extends Notifier<TransactionFilter> {
  @override
  TransactionFilter build() {
    final now = ref.read(clockProvider).now();
    return TransactionFilter(range: DateRange.month(now.year, now.month));
  }

  void set(TransactionFilter f) => state = f;
}

final transactionFilterProvider =
    NotifierProvider<_FilterController, TransactionFilter>(
      _FilterController.new,
    );

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _search = TextEditingController();
  var _searching = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _shiftMonth(int delta) {
    final f = ref.read(transactionFilterProvider);
    final start = f.range?.start ?? DateTime.now();
    ref
        .read(transactionFilterProvider.notifier)
        .set(
          f.copyWith(
            range: () => DateRange.month(start.year, start.month + delta),
          ),
        );
  }

  Future<void> _openFilters() async {
    final current = ref.read(transactionFilterProvider);
    final result = await showModalBottomSheet<TransactionFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _FilterSheet(initial: current),
    );
    if (result != null) {
      ref.read(transactionFilterProvider.notifier).set(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final filter = ref.watch(transactionFilterProvider);
    final items = ref.watch(transactionsProvider(filter));
    final fmt = ref.watch(formattersProvider);
    final range = filter.range;
    final isMonth = range?.isWholeMonth ?? false;
    final view = ref.watch(
      settingsControllerProvider.select((p) => p.transactionsView),
    );
    final asSheet = view == TransactionsView.sheet;

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _search,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: l.searchTransactionsHint,
                  border: InputBorder.none,
                  filled: false,
                ),
                onChanged: (q) => ref
                    .read(transactionFilterProvider.notifier)
                    .set(filter.copyWith(query: q)),
              )
            : Text(l.transactionsTitle),
        actions: [
          IconButton(
            tooltip: _searching ? l.close : l.search,
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) {
                _search.clear();
                ref
                    .read(transactionFilterProvider.notifier)
                    .set(filter.copyWith(query: ''));
              }
            },
          ),
          IconButton(
            tooltip: l.filter,
            icon: Badge(
              isLabelVisible:
                  filter.type != null ||
                  filter.categoryId != null ||
                  filter.paymentMethod != null,
              child: const Icon(Icons.tune_rounded),
            ),
            onPressed: _openFilters,
          ),
          IconButton(
            key: TourTargets.sheetToggle,
            tooltip: asSheet ? l.transactionsShowList : l.transactionsShowSheet,
            icon: Icon(
              asSheet ? Icons.view_agenda_rounded : Icons.table_chart_rounded,
            ),
            onPressed: () => ref
                .read(settingsControllerProvider.notifier)
                .update(
                  (p) => p.copyWith(
                    transactionsView: asSheet
                        ? TransactionsView.list
                        : TransactionsView.sheet,
                  ),
                ),
          ),
          ExportMenuButton(filter: filter),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        // Unique: the tab shell keeps several FAB screens alive.
        heroTag: 'fab-transactions',
        onPressed: () => showAddTransactionSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: Text(l.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: l.back,
                  onPressed: isMonth ? () => _shiftMonth(-1) : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                      );
                      if (picked != null) {
                        ref
                            .read(transactionFilterProvider.notifier)
                            .set(
                              filter.copyWith(
                                range: () =>
                                    DateRange.custom(picked.start, picked.end),
                              ),
                            );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        range == null
                            ? l.filterAll
                            : isMonth
                            ? fmt.monthYear(range.start)
                            : '${fmt.date(range.start)} – ${fmt.date(range.endInclusive)}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l.next,
                  onPressed: isMonth ? () => _shiftMonth(1) : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          if (range != null) _PeriodStrip(range: range),
          Expanded(
            child: AsyncValueView(
              value: items,
              data: (list) {
                if (list.isEmpty) {
                  final filtered =
                      filter.query.isNotEmpty ||
                      filter.type != null ||
                      filter.categoryId != null ||
                      filter.paymentMethod != null;
                  return EmptyState(
                    icon: filtered
                        ? Icons.search_off_rounded
                        : Icons.receipt_long_rounded,
                    title: filtered ? l.noResultsTitle : l.noTransactionsTitle,
                    message: filtered ? l.noResultsBody : l.noTransactionsBody,
                    actionLabel: filtered
                        ? l.filterClearAll
                        : l.actionAddExpense,
                    onAction: filtered
                        ? () => ref
                              .read(transactionFilterProvider.notifier)
                              .set(TransactionFilter(range: filter.range))
                        : () => context.push(Routes.newTransaction()),
                  );
                }
                return asSheet
                    ? TransactionSheetView(items: list)
                    : _GroupedList(items: list);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodStrip extends ConsumerWidget {
  const _PeriodStrip({required this.range});

  final DateRange range;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final s =
        ref.watch(periodSummaryProvider(range)).value ?? PeriodSummary.zero;
    Widget cell(String label, int paise, Color? color) => Expanded(
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          AmountText(
            paise,
            color: color,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              cell(l.income, s.incomePaise, hm.income),
              cell(l.expense, s.expensePaise, hm.expense),
              cell(l.balance, s.balancePaise, null),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupedList extends ConsumerWidget {
  const _GroupedList({required this.items});

  final List<TransactionView> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final today = DateRange.dateOnly(DateTime.now());
    final rows = <Widget>[];
    DateTime? currentDay;
    var dayIndex = -1;
    final dayNets = <int>[];
    for (final v in items) {
      if (currentDay != v.txn.txnDate) {
        currentDay = v.txn.txnDate;
        dayIndex++;
        dayNets.add(0);
      }
      dayNets[dayIndex] += v.signedPaise;
    }
    currentDay = null;
    dayIndex = -1;
    for (final v in items) {
      if (currentDay != v.txn.txnDate) {
        currentDay = v.txn.txnDate;
        dayIndex++;
        final d = currentDay;
        final label = d == today
            ? l.today
            : d == today.subtract(const Duration(days: 1))
            ? l.yesterday
            : fmt.date(d);
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Text(
                  l.dayNet(fmt.money(dayNets[dayIndex], signed: true)),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        );
      }
      rows.add(TransactionTile(view: v));
    }
    return ListView(padding: const EdgeInsets.only(bottom: 96), children: rows);
  }
}

Future<void> showAddTransactionSheet(BuildContext context) {
  final l = context.l10n;
  final hm = HmColors.of(context);
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: IconBadge(icon: Icons.add_card_rounded, color: hm.income),
            title: Text(l.addIncomeTitle),
            onTap: () {
              Navigator.pop(ctx);
              context.push(Routes.newTransaction(type: 'income'));
            },
          ),
          ListTile(
            leading: IconBadge(
              icon: Icons.shopping_cart_checkout_rounded,
              color: hm.expense,
            ),
            title: Text(l.addExpenseTitle),
            onTap: () {
              Navigator.pop(ctx);
              context.push(Routes.newTransaction());
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.initial});

  final TransactionFilter initial;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late TransactionType? _type = widget.initial.type;
  late String? _category = widget.initial.categoryId;
  late PaymentMethod? _method = widget.initial.paymentMethod;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final categories = ref.watch(categoriesProvider(_type)).value ?? const [];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.filterType, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<TransactionType?>(
              segments: [
                ButtonSegment(value: null, label: Text(l.filterAll)),
                ButtonSegment(
                  value: TransactionType.income,
                  label: Text(l.income),
                ),
                ButtonSegment(
                  value: TransactionType.expense,
                  label: Text(l.expense),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() {
                _type = s.first;
                _category = null;
              }),
            ),
            const SizedBox(height: 16),
            Text(l.category, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in categories)
                  FilterChip(
                    avatar: Icon(c.icon, size: 18, color: c.color),
                    label: Text(c.label(l)),
                    selected: _category == c.id,
                    onSelected: (v) =>
                        setState(() => _category = v ? c.id : null),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l.paymentMethod,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in PaymentMethod.values)
                  FilterChip(
                    label: Text(m.label(l)),
                    selected: _method == m,
                    onSelected: (v) => setState(() => _method = v ? m : null),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      TransactionFilter(
                        range: widget.initial.range,
                        query: widget.initial.query,
                      ),
                    ),
                    child: Text(l.filterClearAll),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(
                      context,
                      widget.initial.copyWith(
                        type: () => _type,
                        categoryId: () => _category,
                        paymentMethod: () => _method,
                      ),
                    ),
                    child: Text(l.apply),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
