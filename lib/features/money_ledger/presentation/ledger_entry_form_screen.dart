import 'package:flutter/material.dart';
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
import '../../people/presentation/person_picker.dart';
import '../data/ledger_repository.dart';
import '../domain/ledger_models.dart';

class LedgerEntryFormScreen extends ConsumerStatefulWidget {
  const LedgerEntryFormScreen({
    super.key,
    this.entryId,
    this.initialPersonId,
    this.initialDirection = LedgerDirection.given,
  });

  final String? entryId;
  final String? initialPersonId;
  final LedgerDirection initialDirection;

  @override
  ConsumerState<LedgerEntryFormScreen> createState() =>
      _LedgerEntryFormScreenState();
}

class _LedgerEntryFormScreenState extends ConsumerState<LedgerEntryFormScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  final _attachments = AttachmentDraft();
  late final AttachmentService _attachmentService = ref.read(
    attachmentServiceProvider,
  );
  late LedgerDirection _direction = widget.initialDirection;
  late String? _personId = widget.initialPersonId;
  DateTime _date = DateTime.now();
  DateTime? _due;
  PaymentMethod _method = PaymentMethod.cash;
  var _loaded = false;
  var _saving = false;
  var _dirty = false;
  var _personError = false;

  @override
  void initState() {
    super.initState();
    _attachmentService;
    if (widget.entryId == null) {
      _loaded = true;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final view = await ref
        .read(ledgerRepositoryProvider)
        .watchEntry(widget.entryId!)
        .first;
    if (!mounted) return;
    if (view == null) {
      Navigator.of(context).pop();
      return;
    }
    final e = view.entry;
    setState(() {
      _direction = e.direction;
      _personId = e.personId;
      _amount.text = Money.toEditable(e.principalPaise);
      _date = e.entryDate;
      _due = e.dueDate;
      _method = e.paymentMethod;
      _description.text = e.description;
      _notes.text = e.notes ?? '';
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    _notes.dispose();
    _attachments.discard(_attachmentService).whenComplete(_attachments.dispose);
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final valid = _form.currentState!.validate();
    setState(() => _personError = _personId == null);
    if (!valid || _personId == null) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(ledgerRepositoryProvider)
          .saveEntry(
            LedgerDraft(
              id: widget.entryId,
              personId: _personId!,
              direction: _direction,
              principalPaise: Money.tryParse(_amount.text)!,
              date: _date,
              dueDate: _due,
              paymentMethod: _method,
              description: _description.text,
              notes: _notes.text,
            ),
          );
      await _attachments.apply(
        _attachmentService,
        parent: AttachmentParent.ledgerEntry,
        parentId: id,
      );
      if (!mounted) return;
      _dirty = false;
      showAppSnack(context, context.l10n.ledgerSaved);
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
    return UnsavedChangesGuard(
      hasChanges: (_dirty || _attachments.hasChanges) && !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.entryId == null
                ? l.ledgerEntryTitleNew
                : l.ledgerEntryTitleEdit,
          ),
        ),
        body: !_loaded
            ? const LoadingView()
            : Form(
                key: _form,
                onChanged: () => _dirty = true,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  children: [
                    SegmentedButton<LedgerDirection>(
                      segments: [
                        ButtonSegment(
                          value: LedgerDirection.given,
                          label: Text(l.ledgerGivenLabel),
                          icon: Icon(
                            Icons.call_made_rounded,
                            color: hm.receivable,
                          ),
                        ),
                        ButtonSegment(
                          value: LedgerDirection.taken,
                          label: Text(l.ledgerTakenLabel),
                          icon: Icon(
                            Icons.call_received_rounded,
                            color: hm.payable,
                          ),
                        ),
                      ],
                      selected: {_direction},
                      onSelectionChanged: (s) => setState(() {
                        _direction = s.first;
                        _dirty = true;
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _direction == LedgerDirection.given
                          ? l.ledgerGivenLong
                          : l.ledgerTakenLong,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    PersonPickerField(
                      value: _personId,
                      required: true,
                      errorText: _personError ? l.validationRequired : null,
                      onChanged: (id) => setState(() {
                        _personId = id;
                        _personError = false;
                        _dirty = true;
                      }),
                    ),
                    const SizedBox(height: 16),
                    MoneyFormField(
                      controller: _amount,
                      large: true,
                      autofocus: widget.entryId == null && _personId != null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DatePickerField(
                            value: _date,
                            onChanged: (d) => setState(() {
                              _date = d ?? _date;
                              _dirty = true;
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DatePickerField(
                            label: l.dueDateOptional,
                            value: _due,
                            clearable: true,
                            onChanged: (d) => setState(() {
                              _due = d;
                              _dirty = true;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    HmTextField(
                      controller: _description,
                      label: l.description,
                      maxLength: 120,
                    ),
                    const SizedBox(height: 16),
                    HmTextField(
                      controller: _notes,
                      label: l.notes,
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 16),
                    AttachmentsEditor(
                      draft: _attachments,
                      parent: AttachmentParent.ledgerEntry,
                      parentId: widget.entryId,
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
      ),
    );
  }
}
