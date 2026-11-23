import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/dialogs.dart';
import '../../gujarati_input/presentation/gujarati_text_field.dart';
import '../../people/data/contact_picker.dart';
import '../data/family_repository.dart';

/// Optional mobile number of a person in a Family hisab.
class FamilyPhoneField extends StatelessWidget {
  const FamilyPhoneField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()૦-૯]')),
        LengthLimitingTextInputFormatter(20),
      ],
      decoration: InputDecoration(
        labelText: '${l.mobileNumber} (${l.optional})',
        prefixIcon: const Icon(Icons.phone_rounded),
      ),
      validator: (v) => v == null || v.trim().isEmpty || PhoneNumbers.isValid(v)
          ? null
          : l.validationPhone,
    );
  }
}

/// A contact chosen from the phone, as a Family hisab person (null when the
/// user cancels; failures are shown).
Future<FamilyPersonDraft?> pickFamilyContact(
  BuildContext context,
  WidgetRef ref,
) async {
  try {
    final c = await ref.read(contactPickerProvider).pick();
    if (c == null) return null;
    return FamilyPersonDraft(
      name: c.name,
      phone: c.phone == null
          ? null
          : (PhoneNumbers.normalize(c.phone!) ?? c.phone!),
    );
  } catch (e) {
    if (context.mounted) showFailure(context, e);
    return null;
  }
}

/// Asks for a person's name and number (new or existing person).
Future<FamilyPersonDraft?> showFamilyPersonDialog(
  BuildContext context, {
  required String title,
  FamilyPersonDraft? initial,
}) => showDialog<FamilyPersonDraft>(
  context: context,
  builder: (_) => _PersonDialog(title: title, initial: initial),
);

class _PersonDialog extends ConsumerStatefulWidget {
  const _PersonDialog({required this.title, this.initial});

  final String title;
  final FamilyPersonDraft? initial;

  @override
  ConsumerState<_PersonDialog> createState() => _PersonDialogState();
}

class _PersonDialogState extends ConsumerState<_PersonDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initial?.name);
  late final _phone = TextEditingController(text: widget.initial?.phone);

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Navigator.of(context).pop(
      FamilyPersonDraft(
        id: widget.initial?.id,
        familyId: widget.initial?.familyId,
        name: _name.text.trim(),
        phone: _phone.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(widget.title),
      content: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GujaratiTextField(
                key: const Key('family-person-name'),
                controller: _name,
                autofocus: true,
                maxLength: 80,
                decoration: InputDecoration(
                  labelText: l.familyPersonName,
                  counterText: '',
                ),
                validator: (v) =>
                    (v?.trim().isEmpty ?? true) ? l.validationRequired : null,
              ),
              const SizedBox(height: 12),
              FamilyPhoneField(
                key: const Key('family-person-phone'),
                controller: _phone,
              ),
              const SizedBox(height: 4),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () async {
                    final c = await pickFamilyContact(context, ref);
                    if (c == null || !mounted) return;
                    setState(() {
                      _name.text = c.name;
                      _phone.text = c.phone ?? '';
                    });
                  },
                  icon: const Icon(Icons.contacts_rounded),
                  label: Text(l.pickFromContacts),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l.save)),
      ],
    );
  }
}
