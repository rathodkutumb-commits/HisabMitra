import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/presentation/category_labels.dart';
import '../../groups/data/group_repository.dart';
import '../../money_ledger/data/ledger_repository.dart';
import '../../people/data/people_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../application/notification_service.dart';
import '../domain/reminder_schedule.dart';
import '../../ai_assistant/presentation/ai_fab.dart';
import '../data/app_details_launcher.dart';

extension ReminderRepeatX on ReminderRepeat {
  String label(AppLocalizations l) => switch (this) {
    ReminderRepeat.none => l.repeatNone,
    ReminderRepeat.daily => l.repeatDaily,
    ReminderRepeat.weekly => l.repeatWeekly,
    ReminderRepeat.monthly => l.repeatMonthly,
    ReminderRepeat.quarterly => l.repeatQuarterly,
    ReminderRepeat.halfYearly => l.repeatHalfYearly,
    ReminderRepeat.yearly => l.repeatYearly,
  };
}

extension ReminderKindX on ReminderKind {
  String label(AppLocalizations l) => switch (this) {
    ReminderKind.repayment => l.kindRepayment,
    ReminderKind.collection => l.kindCollection,
    ReminderKind.groupSettlement => l.kindGroupSettlement,
    ReminderKind.custom => l.kindCustom,
    ReminderKind.emi => l.kindEmi,
    ReminderKind.sip => l.kindSip,
    ReminderKind.installment => l.kindInstallment,
    ReminderKind.maintenance => l.kindMaintenance,
    ReminderKind.insurance => l.kindInsurance,
    ReminderKind.rent => l.kindRent,
    ReminderKind.subscription => l.kindSubscription,
    ReminderKind.bill => l.kindBill,
  };

  IconData get icon => switch (this) {
    ReminderKind.repayment => Icons.call_made_rounded,
    ReminderKind.collection => Icons.call_received_rounded,
    ReminderKind.groupSettlement => Icons.groups_rounded,
    ReminderKind.custom => Icons.alarm_rounded,
    ReminderKind.emi => Icons.account_balance_rounded,
    ReminderKind.sip => Icons.trending_up_rounded,
    ReminderKind.installment => Icons.event_repeat_rounded,
    ReminderKind.maintenance => Icons.apartment_rounded,
    ReminderKind.insurance => Icons.health_and_safety_rounded,
    ReminderKind.rent => Icons.home_rounded,
    ReminderKind.subscription => Icons.subscriptions_rounded,
    ReminderKind.bill => Icons.receipt_long_rounded,
  };
}

/// Fixed payments still due in the current calendar month.
final paymentsDueThisMonthProvider = Provider<int>((ref) {
  final pending = ref.watch(pendingRemindersProvider(null)).value ?? const [];
  final now = ref.watch(clockProvider).now();
  return sumPaymentsDue(
    pending,
    DateTime(now.year, now.month),
    DateTime(now.year, now.month + 1),
  );
});

/// Completes a reminder. For a fixed payment the user can first record it
/// as an expense (pre-filled form); the reminder advances only once that
/// expense is saved, or when they choose to just mark it paid.
Future<void> completeReminder(
  BuildContext context,
  WidgetRef ref,
  ReminderRow r,
) async {
  final repo = ref.read(reminderRepositoryProvider);
  final amount = r.amountPaise;
  if (amount == null) {
    await repo.complete(r.id);
    return;
  }
  final l = context.l10n;
  final fmt = ref.read(formattersProvider);
  final choice = await showModalBottomSheet<bool>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.recordPaymentTitle,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(l.recordPaymentBody(fmt.money(amount), r.title)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(ctx, true),
              icon: const Icon(Icons.add_card_rounded),
              label: Text(l.recordAsExpense),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.justMarkPaid),
            ),
          ],
        ),
      ),
    ),
  );
  if (choice == null || !context.mounted) return;
  if (choice) {
    final saved = await context.push<String>(
      Routes.newTransaction(
        amountPaise: amount,
        categoryId: r.categoryId,
        description: r.title,
      ),
    );
    if (saved == null) return; // form closed without saving
  }
  await repo.complete(r.id);
}

class ReminderTile extends ConsumerWidget {
  const ReminderTile({super.key, required this.reminder});

  final ReminderRow reminder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final scheme = Theme.of(context).colorScheme;
    final hm = HmColors.of(context);
    final r = reminder;
    final pending = r.status == ReminderStatus.pending;
    final overdue = pending && r.dueAt.isBefore(DateTime.now());
    final repo = ref.read(reminderRepositoryProvider);
    final total = r.totalOccurrences;
    return ListTile(
      onTap: pending ? () => context.push(Routes.editReminder(r.id)) : null,
      leading: IconBadge(
        icon: r.kind.icon,
        color: overdue ? scheme.error : scheme.tertiary,
      ),
      title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          fmt.dateTime(r.dueAt),
          if (r.repeat != ReminderRepeat.none) r.repeat.label(l),
          if (total != null) l.paymentProgress(r.completedOccurrences, total),
          if (r.status == ReminderStatus.done) l.statusDone,
          if (r.status == ReminderStatus.cancelled) l.statusCancelled,
        ].join(' · '),
        style: overdue ? TextStyle(color: scheme.error) : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (r.amountPaise != null)
            AmountText(
              r.amountPaise!,
              color: pending ? hm.expense : scheme.onSurfaceVariant,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          if (!pending)
            IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => repo.delete(r.id),
            )
          else
            PopupMenuButton<String>(
              onSelected: (a) async {
                if (a == 'done') await completeReminder(context, ref, r);
                if (a == 'cancel') await repo.cancel(r.id);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'done',
                  child: Text(
                    r.amountPaise != null ? l.markPaid : l.reminderDone,
                  ),
                ),
                PopupMenuItem(value: 'cancel', child: Text(l.reminderCancel)),
              ],
            ),
        ],
      ),
    );
  }
}

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.remindersTitle),
          actions: [
            IconButton(
              tooltip: l.addRecurringPayment,
              icon: const Icon(Icons.event_repeat_rounded),
              onPressed: () => context.push(Routes.newReminder(payment: true)),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l.reminderUpcoming),
              Tab(text: l.reminderHistory),
            ],
          ),
        ),
        floatingActionButton: AiFabStack(
          child: FloatingActionButton.extended(
            // Unique: the tab shell keeps several FAB screens alive.
            heroTag: 'fab-reminders',
            onPressed: () => context.push(Routes.newReminder()),
            icon: const Icon(Icons.alarm_add_rounded),
            label: Text(l.addReminder),
          ),
        ),
        body: Column(
          children: [
            const _BatteryTipCard(),
            Expanded(
              child: TabBarView(
                children: [
                  AsyncValueView(
                    value: ref.watch(pendingRemindersProvider(null)),
                    data: (list) => list.isEmpty
                        ? EmptyState(
                            icon: Icons.alarm_rounded,
                            title: l.noRemindersTitle,
                            message: l.noRemindersBody,
                          )
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 96),
                            children: [
                              const _PaymentsDueCard(),
                              for (final r in list) ReminderTile(reminder: r),
                            ],
                          ),
                  ),
                  AsyncValueView(
                    value: ref.watch(closedRemindersProvider),
                    data: (list) => list.isEmpty
                        ? EmptyState(
                            icon: Icons.history_rounded,
                            title: l.noRemindersTitle,
                            compact: true,
                          )
                        : ListView(
                            children: [
                              for (final r in list) ReminderTile(reminder: r),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Some phones stop reminders in battery saving; explains how to allow
/// HisabMitra to run, until the user taps "Got it".
class _BatteryTipCard extends ConsumerWidget {
  const _BatteryTipCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissed = ref.watch(
      settingsControllerProvider.select((p) => p.reminderBatteryTipDismissed),
    );
    if (dismissed || defaultTargetPlatform != TargetPlatform.android) {
      return const SizedBox.shrink();
    }
    final l = context.l10n;
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.battery_alert_rounded,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l.reminderBatteryTip,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                children: [
                  TextButton(
                    onPressed: () => ref
                        .read(settingsControllerProvider.notifier)
                        .update(
                          (p) => p.copyWith(reminderBatteryTipDismissed: true),
                        ),
                    child: Text(l.reminderBatteryTipDismiss),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(appDetailsLauncherProvider).open(),
                    child: Text(l.reminderBatteryTipOpen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentsDueCard extends ConsumerWidget {
  const _PaymentsDueCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(paymentsDueThisMonthProvider);
    if (due == 0) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        color: scheme.primaryContainer,
        child: ListTile(
          leading: Icon(
            Icons.event_repeat_rounded,
            color: scheme.onPrimaryContainer,
          ),
          title: Text(
            context.l10n.paymentsDueThisMonth,
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
          trailing: AmountText(
            due,
            color: scheme.onPrimaryContainer,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}

/// Dashboard section: next three pending reminders.
class UpcomingRemindersSection extends ConsumerWidget {
  const UpcomingRemindersSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(pendingRemindersProvider(3)).value ?? const [];
    if (list.isEmpty) return const SizedBox.shrink();
    final l = context.l10n;
    return Column(
      children: [
        SectionHeader(
          title: l.upcomingReminders,
          actionLabel: l.viewAll,
          onAction: () => context.push(Routes.reminders),
        ),
        for (final r in list) ReminderTile(reminder: r),
      ],
    );
  }
}

class ReminderFormScreen extends ConsumerStatefulWidget {
  const ReminderFormScreen({
    super.key,
    this.reminderId,
    this.ledgerId,
    this.personId,
    this.groupId,
    this.payment = false,
  });

  final String? reminderId;
  final String? ledgerId;
  final String? personId;
  final String? groupId;

  /// Start as a recurring payment (EMI, SIP, …) instead of a plain reminder.
  final bool payment;

  @override
  ConsumerState<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends ConsumerState<ReminderFormScreen> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _note = TextEditingController();
  final _amount = TextEditingController();
  final _count = TextEditingController();
  late bool _isPayment = widget.payment;
  late ReminderKind _kind = widget.payment
      ? ReminderKind.emi
      : ReminderKind.custom;
  late ReminderRepeat _repeat = widget.payment
      ? ReminderRepeat.monthly
      : ReminderRepeat.none;
  String? _categoryId;
  var _hasEnd = false;
  var _completed = 0;
  late DateTime _due;
  DateTime? _originalDue;

  /// Title last filled in from the type, so it can follow type changes
  /// until the user types their own.
  String? _autoTitle;
  var _loaded = false;
  var _saving = false;

  bool get _linked =>
      widget.ledgerId != null ||
      widget.personId != null ||
      widget.groupId != null;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _due = DateTime(now.year, now.month, now.day + 1, 10);
    WidgetsBinding.instance.addPostFrameCallback((_) => _prefill());
  }

  Future<void> _prefill() async {
    final l = context.l10n;
    final fmt = ref.read(formattersProvider);
    if (widget.reminderId != null) {
      final r = await ref
          .read(reminderRepositoryProvider)
          .getById(widget.reminderId!);
      if (r != null) {
        _title.text = r.title;
        _note.text = r.note ?? '';
        _kind = r.kind;
        _repeat = r.repeat;
        _due = r.dueAt;
        _originalDue = r.dueAt;
        _isPayment = r.kind.isPayment || r.amountPaise != null;
        if (r.amountPaise != null) {
          _amount.text = Money.toEditable(r.amountPaise!);
        }
        _categoryId = r.categoryId;
        _hasEnd = r.totalOccurrences != null;
        if (_hasEnd) _count.text = '${r.totalOccurrences}';
        _completed = r.completedOccurrences;
      }
    } else if (widget.ledgerId != null) {
      final v = await ref
          .read(ledgerRepositoryProvider)
          .watchEntry(widget.ledgerId!)
          .first;
      if (v != null) {
        final given = v.entry.direction == LedgerDirection.given;
        _kind = given ? ReminderKind.collection : ReminderKind.repayment;
        final amount = fmt.money(v.summary.outstandingPaise);
        _title.text = given
            ? l.reminderCollectTitle(amount, v.person.name)
            : l.reminderRepayTitle(amount, v.person.name);
        if (v.entry.dueDate != null &&
            v.entry.dueDate!.isAfter(DateTime.now())) {
          final d = v.entry.dueDate!;
          _due = DateTime(d.year, d.month, d.day, 10);
        }
      }
    } else if (widget.personId != null) {
      final p = await ref
          .read(peopleRepositoryProvider)
          .getById(widget.personId!);
      final b = await ref
          .read(peopleRepositoryProvider)
          .watchBalance(widget.personId!)
          .first;
      if (p != null) {
        _kind = b.netPaise >= 0
            ? ReminderKind.collection
            : ReminderKind.repayment;
        final amount = fmt.money(b.netPaise.abs());
        _title.text = b.netPaise >= 0
            ? l.reminderCollectTitle(amount, p.name)
            : l.reminderRepayTitle(amount, p.name);
      }
    } else if (widget.groupId != null) {
      final g = await ref
          .read(groupRepositoryProvider)
          .watchGroup(widget.groupId!)
          .first;
      if (g != null) {
        _kind = ReminderKind.groupSettlement;
        _title.text = l.reminderSettleTitle(g.group.name);
      }
    } else if (_isPayment) {
      _applyAutoTitle(l);
    }
    if (mounted) setState(() => _loaded = true);
  }

  void _applyAutoTitle(AppLocalizations l) {
    final current = _title.text.trim();
    if (current.isEmpty || current == _autoTitle) {
      _autoTitle = _kind.label(l);
      _title.text = _autoTitle!;
    }
  }

  void _setPayment(bool payment, AppLocalizations l) {
    setState(() {
      _isPayment = payment;
      if (payment && !_kind.isPayment) _kind = ReminderKind.emi;
      if (!payment && _kind.isPayment) _kind = ReminderKind.custom;
      if (payment && _repeat == ReminderRepeat.none) {
        _repeat = ReminderRepeat.monthly;
      }
      _applyAutoTitle(l);
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    _amount.dispose();
    _count.dispose();
    super.dispose();
  }

  bool get _showEnds => _isPayment && _repeat != ReminderRepeat.none;

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    final l = context.l10n;
    final dateChanged = _originalDue == null || _due != _originalDue;
    if (dateChanged && !_due.isAfter(DateTime.now())) {
      showAppSnack(context, l.reminderPast, error: true);
      return;
    }
    setState(() => _saving = true);
    final notifications = ref.read(notificationServiceProvider)
      ..texts = NotificationTexts(
        genericTitle: l.notificationGenericTitle,
        genericBody: l.notificationGenericBody,
        paymentBody: l.notificationPaymentBody,
      );
    final granted = await notifications.requestPermission();
    try {
      await ref
          .read(reminderRepositoryProvider)
          .save(
            ReminderDraft(
              id: widget.reminderId,
              kind: _kind,
              title: _title.text,
              note: _note.text,
              dueAt: _due,
              repeat: _repeat,
              personId: widget.personId,
              ledgerEntryId: widget.ledgerId,
              groupId: widget.groupId,
              amountPaise: _isPayment ? Money.tryParse(_amount.text) : null,
              categoryId: _isPayment ? _categoryId : null,
              totalOccurrences: _showEnds && _hasEnd
                  ? int.tryParse(_count.text.trim())
                  : null,
            ),
          );
      if (!mounted) return;
      showAppSnack(
        context,
        granted ? l.reminderSaved : l.notificationsDenied,
        error: !granted,
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showFailure(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final theme = Theme.of(context);
    final today = DateTime.now();
    final kinds = _isPayment
        ? ReminderKind.payments
        : ReminderKind.values.where((k) => !k.isPayment).toList();
    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reminderId != null
              ? l.editReminder
              : _isPayment
              ? l.addRecurringPayment
              : l.addReminder,
        ),
      ),
      body: !_loaded
          ? const LoadingView()
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (!_linked) ...[
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: true,
                          icon: const Icon(Icons.event_repeat_rounded),
                          label: Text(l.reminderTypePayment),
                        ),
                        ButtonSegment(
                          value: false,
                          icon: const Icon(Icons.alarm_rounded),
                          label: Text(l.reminderTypeReminder),
                        ),
                      ],
                      selected: {_isPayment},
                      onSelectionChanged: (v) => _setPayment(v.first, l),
                    ),
                  ],
                  label(_isPayment ? l.paymentType : l.reminderKind),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final k in kinds)
                        ChoiceChip(
                          avatar: Icon(k.icon, size: 18),
                          label: Text(k.label(l)),
                          selected: _kind == k,
                          onSelected: (_) => setState(() {
                            _kind = k;
                            _applyAutoTitle(l);
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HmTextField(
                    controller: _title,
                    label: l.reminderTitle,
                    maxLength: 120,
                    required: true,
                  ),
                  if (_isPayment) ...[
                    const SizedBox(height: 8),
                    MoneyFormField(controller: _amount, label: l.paymentAmount),
                    const SizedBox(height: 16),
                    AsyncValueView(
                      value: ref.watch(
                        categoriesProvider(TransactionType.expense),
                      ),
                      data: (cats) => DropdownButtonFormField<String?>(
                        initialValue: cats.any((c) => c.id == _categoryId)
                            ? _categoryId
                            : null,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l.paymentCategory,
                          helperText: l.paymentCategoryHint,
                          prefixIcon: const Icon(Icons.category_rounded),
                        ),
                        items: [
                          DropdownMenuItem(value: null, child: Text(l.none)),
                          for (final c in cats)
                            DropdownMenuItem(
                              value: c.id,
                              child: Row(
                                children: [
                                  Icon(c.icon, size: 18, color: c.color),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      c.label(l),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DatePickerField(
                          value: _due,
                          firstDate: _due.isBefore(today) ? _due : today,
                          onChanged: (d) => setState(() {
                            if (d != null) {
                              _due = DateTime(
                                d.year,
                                d.month,
                                d.day,
                                _due.hour,
                                _due.minute,
                              );
                            }
                          }),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_due),
                            );
                            if (t != null) {
                              setState(
                                () => _due = DateTime(
                                  _due.year,
                                  _due.month,
                                  _due.day,
                                  t.hour,
                                  t.minute,
                                ),
                              );
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l.reminderTime,
                              prefixIcon: const Icon(Icons.schedule_rounded),
                            ),
                            child: Text(fmt.time(_due)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  label(l.reminderRepeat),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in ReminderRepeat.values)
                        ChoiceChip(
                          label: Text(r.label(l)),
                          selected: _repeat == r,
                          onSelected: (_) => setState(() => _repeat = r),
                        ),
                    ],
                  ),
                  if (_showEnds) ...[
                    label(l.paymentEnds),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(l.paymentEndsNever),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(l.paymentEndsAfter),
                        ),
                      ],
                      selected: {_hasEnd},
                      onSelectionChanged: (v) =>
                          setState(() => _hasEnd = v.first),
                    ),
                    if (_hasEnd) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _count,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l.paymentCount,
                          prefixIcon: const Icon(Icons.tag_rounded),
                          helperText: _completed > 0
                              ? l.paymentsPaidSoFar(_completed)
                              : null,
                        ),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n < 1) return l.validationRequired;
                          if (_completed > 0 && n <= _completed) {
                            return l.errorPaymentCount;
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  HmTextField(
                    controller: _note,
                    label: l.notes,
                    maxLines: 2,
                    maxLength: 300,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving || !_loaded ? null : _save,
            child: Text(l.save),
          ),
        ),
      ),
    );
  }
}
