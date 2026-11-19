import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../attachments/data/attachment_service.dart';
import '../../attachments/presentation/attachments_editor.dart';
import '../../settings/application/settings_controller.dart';
import '../data/group_repository.dart';
import '../domain/group_models.dart';
import '../domain/split_calculator.dart';
import 'group_labels.dart';

class GroupExpenseFormScreen extends ConsumerStatefulWidget {
  const GroupExpenseFormScreen({
    super.key,
    required this.groupId,
    this.expenseId,
  });

  final String groupId;
  final String? expenseId;

  @override
  ConsumerState<GroupExpenseFormScreen> createState() =>
      _GroupExpenseFormScreenState();
}

class _GroupExpenseFormScreenState
    extends ConsumerState<GroupExpenseFormScreen> {
  final _form = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  final _attachments = AttachmentDraft();
  late final AttachmentService _attachmentService = ref.read(
    attachmentServiceProvider,
  );
  final Map<String, TextEditingController> _inputs = {};
  final Map<String, bool> _selected = {};
  List<GroupMemberRow> _members = const [];
  String _category = 'food';
  String? _paidBy;
  DateTime _date = DateTime.now();
  SplitMethod _method = SplitMethod.equal;
  var _loaded = false;
  var _saving = false;
  var _dirty = false;

  @override
  void initState() {
    super.initState();
    _attachmentService;
    _load();
  }

  Future<void> _load() async {
    final detail = await ref
        .read(groupRepositoryProvider)
        .watchGroup(widget.groupId)
        .first;
    if (!mounted) return;
    if (detail == null) {
      Navigator.of(context).pop();
      return;
    }
    _members = detail.members;
    for (final m in _members) {
      _inputs[m.id] = TextEditingController()..addListener(_onInput);
      _selected[m.id] = true;
    }
    _paidBy = detail.selfMember?.id ?? _members.first.id;
    if (widget.expenseId != null) {
      final e = detail.expenses
          .where((x) => x.expense.id == widget.expenseId)
          .firstOrNull;
      if (e == null) {
        Navigator.of(context).pop();
        return;
      }
      _description.text = e.expense.description;
      _amount.text = Money.toEditable(e.expense.amountPaise);
      _notes.text = e.expense.notes ?? '';
      _category = e.expense.categoryKey;
      _paidBy = e.expense.paidByMemberId;
      _date = e.expense.expenseDate;
      _method = e.expense.splitMethod;
      for (final m in _members) {
        _selected[m.id] = e.splits.containsKey(m.id);
        final input = e.splitInputs[m.id];
        if (input != null) _inputs[m.id]!.text = Money.toEditable(input);
      }
    }
    setState(() => _loaded = true);
  }

  void _onInput() {
    if (_loaded) setState(() => _dirty = true);
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    _notes.dispose();
    for (final c in _inputs.values) {
      c.dispose();
    }
    _attachments.discard(_attachmentService).whenComplete(_attachments.dispose);
    super.dispose();
  }

  /// Parses a method-specific input to its integer representation.
  /// Percent and ratio use the same two-decimal fixed point as money:
  /// 33.33% → 3333 basis points, ratio 1.5 → 150.
  int? _parse(String text) {
    final t = text.trim();
    if (t.isEmpty) return 0;
    if (_method == SplitMethod.adjustment && t.startsWith('-')) {
      final v = Money.tryParse(t.substring(1));
      return v == null ? null : -v;
    }
    return Money.tryParse(t);
  }

  List<SplitParticipant>? _participants() {
    final list = <SplitParticipant>[];
    for (final m in _members) {
      if (_selected[m.id] != true) continue;
      final value = _method == SplitMethod.equal
          ? 0
          : _parse(_inputs[m.id]!.text);
      if (value == null) return null;
      list.add(SplitParticipant(m.id, value));
    }
    return list;
  }

  SplitOutcome? _preview() {
    final total = Money.tryParse(_amount.text);
    final participants = _participants();
    if (total == null || total <= 0 || participants == null) return null;
    return SplitCalculator.calculate(
      totalPaise: total,
      method: _method,
      participants: participants,
    );
  }

  String _errorText(SplitError e, Formatters fmt) {
    final l = context.l10n;
    return switch (e) {
      SplitNoParticipants() => l.splitNeedsParticipants,
      SplitExactMismatch(:final differencePaise) =>
        differencePaise < 0
            ? l.splitRemaining(fmt.money(-differencePaise))
            : l.splitOver(fmt.money(differencePaise)),
      SplitPercentageInvalid(:final totalBasisPoints) => l.percentTotal(
        Money.toEditable(totalBasisPoints),
      ),
      SplitZeroWeights() => l.splitZeroShares,
      SplitAdjustmentsExceedTotal() => l.splitAdjustmentsTooBig,
      SplitNegativeShare() => l.splitNegativeShare,
      SplitInvalidTotal() => l.validationAmountPositive,
      SplitDuplicateParticipant() ||
      SplitNegativeInput() ||
      SplitInputTooLarge() => l.validationAmount,
    };
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    final outcome = _preview();
    if (outcome is! SplitSuccess) {
      if (outcome is SplitFailure) {
        showAppSnack(
          context,
          _errorText(outcome.error, ref.read(formattersProvider)),
          error: true,
        );
      }
      return;
    }
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(groupRepositoryProvider)
          .saveExpense(
            ExpenseDraft(
              id: widget.expenseId,
              groupId: widget.groupId,
              description: _description.text,
              categoryKey: _category,
              amountPaise: Money.tryParse(_amount.text)!,
              paidByMemberId: _paidBy!,
              date: _date,
              splitMethod: _method,
              participants: _participants()!,
              notes: _notes.text,
            ),
          );
      await _attachments.apply(
        _attachmentService,
        parent: AttachmentParent.groupExpense,
        parentId: id,
      );
      if (!mounted) return;
      _dirty = false;
      showAppSnack(context, context.l10n.groupExpenseSaved);
      Navigator.of(context).pop(id);
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
    final hm = HmColors.of(context);
    final outcome = _loaded ? _preview() : null;

    return UnsavedChangesGuard(
      hasChanges: (_dirty || _attachments.hasChanges) && !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.expenseId == null ? l.addGroupExpense : l.editGroupExpense,
          ),
        ),
        body: !_loaded
            ? const LoadingView()
            : Form(
                key: _form,
                onChanged: () => setState(() => _dirty = true),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    HmTextField(
                      controller: _description,
                      label: l.description,
                      maxLength: 120,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    MoneyFormField(
                      controller: _amount,
                      large: true,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Text(l.category, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final entry in GroupExpenseCategories.all.entries)
                          ChoiceChip(
                            avatar: Icon(entry.value, size: 18),
                            label: Text(groupCategoryLabel(l, entry.key)),
                            selected: _category == entry.key,
                            onSelected: (_) =>
                                setState(() => _category = entry.key),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _paidBy,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: l.paidBy,
                              prefixIcon: const Icon(
                                Icons.account_balance_wallet_rounded,
                              ),
                            ),
                            items: [
                              for (final m in _members)
                                DropdownMenuItem(
                                  value: m.id,
                                  child: Text(
                                    memberLabel(l, m),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (v) => setState(() => _paidBy = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DatePickerField(
                            value: _date,
                            onChanged: (d) =>
                                setState(() => _date = d ?? _date),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(l.splitMethod, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final m in SplitMethod.values)
                          ChoiceChip(
                            label: Text(m.label(l)),
                            selected: _method == m,
                            onSelected: (_) => setState(() {
                              _method = m;
                              for (final c in _inputs.values) {
                                c.clear();
                              }
                              if (m == SplitMethod.ratio) {
                                for (final c in _inputs.values) {
                                  c.text = '1';
                                }
                              }
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(_method.help(l), style: theme.textTheme.bodySmall),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.participants,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            final all = _selected.values.every((v) => v);
                            for (final k in _selected.keys) {
                              _selected[k] = !all;
                            }
                          }),
                          child: Text(l.selectAll),
                        ),
                      ],
                    ),
                    Card(
                      child: Column(
                        children: [
                          for (final m in _members)
                            _ParticipantRow(
                              label: memberLabel(l, m),
                              selected: _selected[m.id] ?? false,
                              method: _method,
                              controller: _inputs[m.id]!,
                              share: outcome is SplitSuccess
                                  ? outcome.shares[m.id]
                                  : null,
                              onSelected: (v) =>
                                  setState(() => _selected[m.id] = v),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (outcome is SplitFailure)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: theme.colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorText(outcome.error, fmt),
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (outcome is SplitSuccess)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: hm.income.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: hm.income),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${l.splitPreview}: ${fmt.money(outcome.shares.values.fold(0, (a, b) => a + b))} = ${fmt.money(Money.tryParse(_amount.text)!)}',
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    HmTextField(
                      controller: _notes,
                      label: l.notes,
                      maxLines: 2,
                      maxLength: 300,
                    ),
                    const SizedBox(height: 16),
                    AttachmentsEditor(
                      draft: _attachments,
                      parent: AttachmentParent.groupExpense,
                      parentId: widget.expenseId,
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: _saving || outcome is! SplitSuccess ? null : _save,
              child: Text(l.save),
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantRow extends ConsumerWidget {
  const _ParticipantRow({
    required this.label,
    required this.selected,
    required this.method,
    required this.controller,
    required this.share,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final SplitMethod method;
  final TextEditingController controller;
  final int? share;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (prefix, suffix) = switch (method) {
      SplitMethod.exact || SplitMethod.adjustment => ('₹ ', null),
      SplitMethod.percentage => (null, '%'),
      SplitMethod.ratio => (null, '×'),
      SplitMethod.equal => (null, null),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Checkbox(value: selected, onChanged: (v) => onSelected(v ?? false)),
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (method != SplitMethod.equal)
            SizedBox(
              width: 96,
              child: TextField(
                controller: controller,
                enabled: selected,
                textAlign: TextAlign.end,
                keyboardType: TextInputType.numberWithOptions(
                  decimal: true,
                  signed: method == SplitMethod.adjustment,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(
                      method == SplitMethod.adjustment
                          ? r'[0-9.\-]'
                          : r'[0-9.]',
                    ),
                  ),
                ],
                decoration: InputDecoration(
                  isDense: true,
                  prefixText: prefix,
                  suffixText: suffix,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          SizedBox(
            width: 92,
            child: Align(
              alignment: Alignment.centerRight,
              child: selected && share != null
                  ? AmountText(
                      share!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : Text('—', style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
