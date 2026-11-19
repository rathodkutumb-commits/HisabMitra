import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../attachments/data/attachment_service.dart';
import '../../attachments/presentation/attachments_editor.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/presentation/category_labels.dart';
import '../../people/presentation/person_picker.dart';
import '../data/transaction_repository.dart';
import '../domain/transaction_models.dart';

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    super.key,
    this.transactionId,
    this.initialType = TransactionType.expense,
    this.initialPersonId,
    this.initialAmountPaise,
    this.initialCategoryId,
    this.initialDescription,
  });

  final String? transactionId;
  final TransactionType initialType;
  final String? initialPersonId;

  /// Prefill from an assistant draft; the user still reviews and saves.
  final int? initialAmountPaise;
  final String? initialCategoryId;
  final String? initialDescription;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  final _form = GlobalKey<FormState>();
  final _categoryErrorKey = GlobalKey();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  final _attachments = AttachmentDraft();
  late final AttachmentService _attachmentService = ref.read(
    attachmentServiceProvider,
  );
  late TransactionType _type = widget.initialType;
  String? _categoryId;
  late DateTime _date = DateTime.now();
  PaymentMethod _method = PaymentMethod.upi;
  late String? _personId = widget.initialPersonId;
  var _loaded = false;
  var _dirty = false;
  var _saving = false;
  var _categoryError = false;

  bool get _isEdit => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    _attachmentService; // resolve while mounted
    if (_isEdit) {
      _load();
    } else {
      if (widget.initialAmountPaise != null) {
        _amount.text = Money.toEditable(widget.initialAmountPaise!);
      }
      _categoryId = widget.initialCategoryId;
      _description.text = widget.initialDescription ?? '';
      _loaded = true;
    }
  }

  Future<void> _load() async {
    final view = await ref
        .read(transactionRepositoryProvider)
        .getById(widget.transactionId!);
    if (!mounted) return;
    if (view == null) {
      Navigator.of(context).pop();
      return;
    }
    final t = view.txn;
    setState(() {
      _type = t.type;
      _amount.text = Money.toEditable(t.amountPaise);
      _categoryId = t.categoryId;
      _date = t.txnDate;
      _method = t.paymentMethod;
      _personId = t.personId;
      _description.text = t.description;
      _notes.text = t.notes ?? '';
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _notes.dispose();
    // Drop files staged by this form that were never saved.
    _attachments.discard(_attachmentService).whenComplete(_attachments.dispose);
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  Future<void> _save() async {
    if (_saving) return;
    final valid = _form.currentState!.validate();
    setState(() => _categoryError = _categoryId == null);
    if (_categoryId == null && valid) {
      // Save is pinned below the form; bring the message into view so the
      // tap does not look ignored.
      await WidgetsBinding.instance.endOfFrame;
      final target = _categoryErrorKey.currentContext;
      if (target != null && target.mounted) {
        await Scrollable.ensureVisible(
          target,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
    if (!valid || _categoryId == null) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(transactionRepositoryProvider)
          .save(
            TransactionDraft(
              id: widget.transactionId,
              type: _type,
              amountPaise: Money.tryParse(_amount.text)!,
              categoryId: _categoryId!,
              date: _date,
              paymentMethod: _method,
              personId: _personId,
              description: _description.text,
              notes: _notes.text,
            ),
          );
      await _attachments.apply(
        _attachmentService,
        parent: AttachmentParent.transaction,
        parentId: id,
      );
      if (!mounted) return;
      _dirty = false;
      showAppSnack(context, context.l10n.transactionSaved);
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
    final hm = HmColors.of(context);
    final title = _isEdit
        ? l.editTransactionTitle
        : _type == TransactionType.income
        ? l.addIncomeTitle
        : l.addExpenseTitle;
    final categories = ref.watch(categoriesProvider(_type));

    return UnsavedChangesGuard(
      hasChanges: (_dirty || _attachments.hasChanges) && !_saving,
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: !_loaded
            ? const LoadingView()
            : Form(
                key: _form,
                // Not a lazy ListView: every field must be built so Save can
                // scroll to whichever one needs attention.
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SegmentedButton<TransactionType>(
                        segments: [
                          ButtonSegment(
                            value: TransactionType.expense,
                            label: Text(l.expense),
                            icon: Icon(
                              Icons.north_east_rounded,
                              color: hm.expense,
                            ),
                          ),
                          ButtonSegment(
                            value: TransactionType.income,
                            label: Text(l.income),
                            icon: Icon(
                              Icons.south_west_rounded,
                              color: hm.income,
                            ),
                          ),
                        ],
                        selected: {_type},
                        onSelectionChanged: (s) => setState(() {
                          _type = s.first;
                          _categoryId = null;
                          _dirty = true;
                        }),
                      ),
                      const SizedBox(height: 16),
                      MoneyFormField(
                        controller: _amount,
                        autofocus: !_isEdit,
                        large: true,
                        onChanged: (_) => _markDirty(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l.category,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push(Routes.categories),
                            child: Text(l.manageCategories),
                          ),
                        ],
                      ),
                      AsyncValueView(
                        value: categories,
                        data: (list) => Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final c in list)
                              ChoiceChip(
                                avatar: Icon(c.icon, size: 18, color: c.color),
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
                          key: _categoryErrorKey,
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            l.chooseCategory,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
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
                      const SizedBox(height: 20),
                      Text(
                        l.paymentMethod,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      PaymentMethodChips(
                        value: _method,
                        onChanged: (m) => setState(() {
                          _method = m;
                          _dirty = true;
                        }),
                      ),
                      const SizedBox(height: 20),
                      PersonPickerField(
                        label: l.personOptional,
                        value: _personId,
                        onChanged: (id) => setState(() {
                          _personId = id;
                          _dirty = true;
                        }),
                      ),
                      const SizedBox(height: 16),
                      HmTextField(
                        controller: _description,
                        label: l.description,
                        hint: l.descriptionHint,
                        maxLength: 120,
                        onChanged: (_) => _markDirty(),
                      ),
                      const SizedBox(height: 16),
                      HmTextField(
                        controller: _notes,
                        label: l.notes,
                        maxLines: 3,
                        maxLength: 500,
                        onChanged: (_) => _markDirty(),
                      ),
                      const SizedBox(height: 20),
                      AttachmentsEditor(
                        draft: _attachments,
                        parent: AttachmentParent.transaction,
                        parentId: widget.transactionId,
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
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
              label: Text(l.save),
            ),
          ),
        ),
      ),
    );
  }
}
