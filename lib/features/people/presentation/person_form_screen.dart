import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../data/contact_picker.dart';
import '../data/people_repository.dart';

class PersonFormScreen extends ConsumerStatefulWidget {
  const PersonFormScreen({super.key, this.personId});

  final String? personId;

  @override
  ConsumerState<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends ConsumerState<PersonFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _description = TextEditingController();
  final _notes = TextEditingController();
  var _loaded = false;
  var _saving = false;
  var _dirty = false;

  @override
  void initState() {
    super.initState();
    if (widget.personId == null) {
      _loaded = true;
    } else {
      _load();
    }
  }

  Future<void> _load() async {
    final p = await ref
        .read(peopleRepositoryProvider)
        .getById(widget.personId!);
    if (!mounted) return;
    if (p == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _name.text = p.name;
      _phone.text = p.phone ?? '';
      _email.text = p.email ?? '';
      _description.text = p.description ?? '';
      _notes.text = p.notes ?? '';
      _loaded = true;
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _email, _description, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickContact() async {
    try {
      final contact = await ref.read(contactPickerProvider).pick();
      if (contact == null) return;
      setState(() {
        _name.text = contact.name;
        _phone.text = contact.phone == null
            ? ''
            : (PhoneNumbers.normalize(contact.phone!) ?? contact.phone!);
        _dirty = true;
      });
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(peopleRepositoryProvider)
          .save(
            PersonDraft(
              id: widget.personId,
              name: _name.text,
              phone: _phone.text,
              email: _email.text,
              description: _description.text,
              notes: _notes.text,
            ),
          );
      if (!mounted) return;
      _dirty = false;
      showAppSnack(context, context.l10n.personSaved);
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
    return UnsavedChangesGuard(
      hasChanges: _dirty && !_saving,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.personId == null ? l.addPerson : l.editPerson),
        ),
        body: !_loaded
            ? const LoadingView()
            : Form(
                key: _form,
                onChanged: () => _dirty = true,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickContact,
                      icon: const Icon(Icons.contacts_rounded),
                      label: Text(l.pickFromContacts),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.contactsHint,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    HmTextField(
                      controller: _name,
                      label: l.personName,
                      prefixIcon: Icons.person_rounded,
                      maxLength: 80,
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9+\s\-()૦-૯]'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: '${l.mobileNumber} (${l.optional})',
                        prefixIcon: const Icon(Icons.phone_rounded),
                      ),
                      validator: (v) =>
                          v == null ||
                              v.trim().isEmpty ||
                              PhoneNumbers.isValid(v)
                          ? null
                          : l.validationPhone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: l.emailOptional,
                        prefixIcon: const Icon(Icons.alternate_email_rounded),
                      ),
                      validator: (v) {
                        final t = v?.trim() ?? '';
                        if (t.isEmpty) return null;
                        return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                            ? null
                            : l.validationEmail;
                      },
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
                  ],
                ),
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(l.save),
            ),
          ),
        ),
      ),
    );
  }
}
