import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/presentation/category_labels.dart';
import '../data/family_repository.dart';
import '../domain/family_models.dart';
import 'family_labels.dart';

/// Money in (salary, extra income, contribution by a person) or money out
/// (an expense with its category and who paid). Editing an entry keeps its
/// side; it can be deleted from here.
class FamilyEntryFormScreen extends ConsumerStatefulWidget {
  const FamilyEntryFormScreen({
    super.key,
    required this.familyId,
    this.entryId,
    this.moneyIn = true,
  });

  final String familyId;
  final String? entryId;

  /// For a new entry: money in (true) or money out (false).
  final bool moneyIn;

  @override
  ConsumerState<FamilyEntryFormScreen> createState() =>
      _FamilyEntryFormScreenState();
}

class _FamilyEntryFormScreenState extends ConsumerState<FamilyEntryFormScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  late bool _moneyIn = widget.moneyIn;
  var _kind = FamilyEntryKind.salary;
  String? _memberId;
  String? _categoryId;
  late DateTime _date = ref.read(clockProvider).now();
  var _loaded = false;
  var _dirty = false;
  var _saving = false;
  var _categoryError = false;

  bool get _isEdit => widget.entryId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await ref
        .read(familyRepositoryProvider)
        .watchFamily(widget.familyId)
        .first;
    if (!mounted) return;
    if (d == null) {
      Navigator.of(context).pop();
      return;
    }
    final e = d.entries.where((x) => x.id == widget.entryId).firstOrNull;
    if (_isEdit && e == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      if (e != null) {
        _moneyIn = e.kind.isMoneyIn;
        if (_moneyIn) _kind = e.kind;
        _memberId = e.memberId;
        _categoryId = e.categoryId;
        _date = e.date;
        _amount.text = Money.toEditable(e.amountPaise);
        _note.text = e.note ?? '';
      } else {
        _memberId = d.self?.id ?? d.activeMembers.firstOrNull?.id;
      }
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _markDirty() => _dirty = true;

  Future<void> _save() async {
    if (_saving) return;
    final valid = _form.currentState!.validate();
    setState(() => _categoryError = !_moneyIn && _categoryId == null);
    if (!valid || _categoryError || _memberId == null) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(familyRepositoryProvider)
          .saveEntry(
            FamilyEntryDraft(
              id: widget.entryId,
              familyId: widget.familyId,
              memberId: _memberId!,
              kind: _moneyIn ? _kind : FamilyEntryKind.expense,
              amountPaise: Money.tryParse(_amount.text)!,
              date: _date,
              categoryId: _moneyIn ? null : _categoryId,
              note: _note.text,
            ),
          );
      if (!mounted) return;
      _dirty = false;
      showAppSnack(context, context.l10n.familyEntrySaved);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showFailure(context, e);
      }
    }
  }

  Future<void> _delete() async {
    if (!await confirmDelete(context) || !mounted) return;
    try {
      await ref.read(familyRepositoryProvider).deleteEntry(widget.entryId!);
      if (!mounted) return;
      _dirty = false;
      showAppSnack(context, context.l10n.familyEntryDeleted);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final title = _moneyIn
        ? (_isEdit ? l.familyEditMoneyIn : l.familyAddMoneyIn)
        : (_isEdit ? l.familyEditMoneyOut : l.familyAddMoneyOut);
    final detail = ref.watch(familyDetailProvider(widget.familyId)).value;
    // Active people, plus a removed person this entry already belongs to.
    final people = [
      for (final m in detail?.members ?? const <FamilyMemberRow>[])
        if (m.status == 'active' || m.id == _memberId) m,
    ];

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );

    return UnsavedChangesGuard(
      hasChanges: _dirty && !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: [
            if (_isEdit)
              IconButton(
                tooltip: l.delete,
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: _delete,
              ),
          ],
        ),
        body: !_loaded
            ? const LoadingView()
            : Form(
                key: _form,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_moneyIn)
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.info_outline_rounded),
                            title: Text(
                              l.familyDoubleCountNote,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      MoneyFormField(
                        key: const Key('family-amount'),
                        controller: _amount,
                        autofocus: !_isEdit,
                        large: true,
                        onChanged: (_) => _markDirty(),
                      ),
                      if (_moneyIn) ...[
                        heading(l.familyKind),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final k in FamilyEntryKind.moneyIn)
                              ChoiceChip(
                                label: Text(k.label(l)),
                                selected: _kind == k,
                                onSelected: (_) => setState(() {
                                  _kind = k;
                                  _dirty = true;
                                }),
                              ),
                          ],
                        ),
                      ] else ...[
                        Row(
                          children: [
                            Expanded(child: heading(l.category)),
                            TextButton(
                              onPressed: () => context.push(Routes.categories),
                              child: Text(l.manageCategories),
                            ),
                          ],
                        ),
                        AsyncValueView(
                          value: ref.watch(
                            categoriesProvider(TransactionType.expense),
                          ),
                          data: (list) => Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final c in list)
                                ChoiceChip(
                                  avatar: Icon(
                                    c.icon,
                                    size: 18,
                                    color: c.color,
                                  ),
                                  label: Text(c.label(l)),
                                  selected: _categoryId == c.id,
                                  onSelected: (_) => setState(() {
                                    _categoryId = c.id;
                                    _categoryError = false;
                                    _dirty = true;
                                  }),
                                ),
                            ],
                          ),
                        ),
                        if (_categoryError)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              l.chooseCategory,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                      ],
                      heading(_moneyIn ? l.familyPerson : l.paidBy),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final m in people)
                            ChoiceChip(
                              avatar: InitialsAvatar(name: m.name, radius: 10),
                              label: Text(
                                m.status == 'removed'
                                    ? l.familyPersonRemoved(m.name)
                                    : m.name,
                              ),
                              selected: _memberId == m.id,
                              onSelected: (_) => setState(() {
                                _memberId = m.id;
                                _dirty = true;
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DatePickerField(
                        value: _date,
                        lastDate: DateTime.now().add(const Duration(days: 366)),
                        onChanged: (d) => setState(() {
                          _date = d ?? _date;
                          _dirty = true;
                        }),
                      ),
                      const SizedBox(height: 16),
                      HmTextField(
                        controller: _note,
                        label: l.notes,
                        maxLines: 2,
                        maxLength: 200,
                        onChanged: (_) => _markDirty(),
                      ),
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton.icon(
              onPressed: _saving || !_loaded ? null : _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(l.save),
            ),
          ),
        ),
      ),
    );
  }
}
