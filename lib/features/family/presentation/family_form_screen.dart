import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../gujarati_input/presentation/gujarati_text_field.dart';
import '../../profile/data/profile_repository.dart';
import '../data/family_repository.dart';
import 'family_person_fields.dart';

/// Creates a Family hisab (name, starting balance, people) or edits its
/// name and starting balance.
class FamilyFormScreen extends ConsumerStatefulWidget {
  const FamilyFormScreen({super.key, this.familyId});

  final String? familyId;

  @override
  ConsumerState<FamilyFormScreen> createState() => _FamilyFormScreenState();
}

class _FamilyFormScreenState extends ConsumerState<FamilyFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _start = TextEditingController();
  final _personName = TextEditingController();
  final _personPhone = TextEditingController();
  final List<FamilyPersonDraft> _people = [];
  var _loaded = false;
  var _saving = false;

  bool get _isEdit => widget.familyId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _load();
    } else {
      _loaded = true;
    }
  }

  Future<void> _load() async {
    final d = await ref
        .read(familyRepositoryProvider)
        .watchFamily(widget.familyId!)
        .first;
    if (!mounted) return;
    if (d == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _name.text = d.family.name;
      if (d.family.openingBalancePaise != 0) {
        _start.text = Money.toEditable(d.family.openingBalancePaise);
      }
      _loaded = true;
    });
  }

  @override
  void dispose() {
    for (final c in [_name, _start, _personName, _personPhone]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Adds the typed person; false when the typed number is not valid.
  bool _addTypedPerson() {
    final name = _personName.text.trim();
    if (name.isEmpty) return true;
    final phone = _personPhone.text.trim();
    if (phone.isNotEmpty && !PhoneNumbers.isValid(phone)) {
      showAppSnack(context, context.l10n.validationPhone, error: true);
      return false;
    }
    setState(() {
      _people.add(FamilyPersonDraft(name: name, phone: phone));
      _personName.clear();
      _personPhone.clear();
    });
    return true;
  }

  Future<void> _addFromContacts() async {
    final c = await pickFamilyContact(context, ref);
    if (c != null && mounted) setState(() => _people.add(c));
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    if (!_isEdit && !_addTypedPerson()) return;
    setState(() => _saving = true);
    final repo = ref.read(familyRepositoryProvider);
    final draft = FamilyDraft(
      id: widget.familyId,
      name: _name.text,
      startingBalancePaise: Money.tryParse(_start.text) ?? 0,
    );
    try {
      if (_isEdit) {
        await repo.updateFamily(draft);
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final profile = await ref.read(profileRepositoryProvider).get();
      final id = await repo.createFamily(
        draft,
        selfName: profile?.displayName ?? 'Me',
        people: _people,
      );
      if (!mounted) return;
      showAppSnack(context, context.l10n.familySaved);
      context.pushReplacement(Routes.familyHome(id));
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
    final me = ref.watch(profileProvider).value?.displayName ?? 'Me';
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l.familyEdit : l.familyCreate)),
      body: !_loaded
          ? const LoadingView()
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  HmTextField(
                    key: const Key('family-name'),
                    controller: _name,
                    label: l.familyName,
                    hint: l.familyNameHint,
                    prefixIcon: Icons.family_restroom_rounded,
                    maxLength: 80,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  MoneyFormField(
                    key: const Key('family-start'),
                    controller: _start,
                    label: l.familyStartingBalance,
                    allowZero: true,
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 12,
                      top: 4,
                    ),
                    child: Text(
                      l.familyStartingBalanceHelp,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (!_isEdit) ...[
                    SectionHeader(
                      title: l.familyPeople,
                      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: InitialsAvatar(name: me),
                      title: Text(l.memberYou(me)),
                      subtitle: Text(l.roleOwner),
                    ),
                    for (final p in _people)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: InitialsAvatar(name: p.name),
                        title: Text(p.name),
                        subtitle: (p.phone?.isEmpty ?? true)
                            ? null
                            : Text(p.phone!),
                        trailing: IconButton(
                          tooltip: l.removeMember,
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          onPressed: () => setState(() => _people.remove(p)),
                        ),
                      ),
                    const SizedBox(height: 8),
                    GujaratiTextField(
                      key: const Key('family-person-name'),
                      controller: _personName,
                      maxLength: 80,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l.familyPersonName,
                        prefixIcon: const Icon(Icons.person_add_alt_rounded),
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FamilyPhoneField(
                            key: const Key('family-person-phone'),
                            controller: _personPhone,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          key: const Key('family-add-person'),
                          tooltip: l.familyAddPerson,
                          onPressed: _addTypedPerson,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton.icon(
                        onPressed: _addFromContacts,
                        icon: const Icon(Icons.contacts_rounded),
                        label: Text(l.pickFromContacts),
                      ),
                    ),
                  ],
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
