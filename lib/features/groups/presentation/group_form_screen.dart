import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../people/data/people_repository.dart';
import '../../people/presentation/person_picker.dart';
import '../../profile/data/profile_repository.dart';
import '../data/group_repository.dart';
import '../domain/group_models.dart';
import 'group_labels.dart';

class GroupFormScreen extends ConsumerStatefulWidget {
  const GroupFormScreen({super.key, this.groupId});

  final String? groupId;

  @override
  ConsumerState<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends ConsumerState<GroupFormScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _memberName = TextEditingController();
  GroupType _type = GroupType.trip;
  final List<MemberDraft> _members = [];
  var _loaded = false;
  var _saving = false;

  bool get _isEdit => widget.groupId != null;

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
    final detail = await ref
        .read(groupRepositoryProvider)
        .watchGroup(widget.groupId!)
        .first;
    if (!mounted) return;
    if (detail == null) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _name.text = detail.group.name;
      _description.text = detail.group.description ?? '';
      _type = detail.group.groupType;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _memberName.dispose();
    super.dispose();
  }

  void _addTypedMember() {
    final name = _memberName.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _members.add(MemberDraft(name: name));
      _memberName.clear();
    });
  }

  Future<void> _addFromPeople() async {
    final id = await showPersonPicker(context);
    if (id == null) return;
    final person = await ref.read(peopleRepositoryProvider).getById(id);
    if (person == null || _members.any((m) => m.personId == id)) return;
    setState(
      () => _members.add(
        MemberDraft(
          name: person.name,
          phone: person.phone,
          personId: person.id,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    _addTypedMember();
    setState(() => _saving = true);
    final repo = ref.read(groupRepositoryProvider);
    try {
      final draft = GroupDraft(
        id: widget.groupId,
        name: _name.text,
        description: _description.text,
        groupType: _type,
      );
      if (_isEdit) {
        await repo.updateGroup(draft);
        if (mounted) Navigator.of(context).pop();
      } else {
        final profile = await ref.read(profileRepositoryProvider).get();
        final id = await repo.createGroup(
          draft,
          selfName: profile?.displayName ?? 'Me',
          members: _members,
        );
        if (!mounted) return;
        showAppSnack(context, context.l10n.groupSaved);
        context.pushReplacement(Routes.group(id));
      }
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
    final profile = ref.watch(profileProvider).value;
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l.editGroup : l.createGroup)),
      body: !_loaded
          ? const LoadingView()
          : Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                children: [
                  HmTextField(
                    controller: _name,
                    label: l.groupName,
                    hint: l.groupNameHint,
                    maxLength: 80,
                    required: true,
                  ),
                  const SizedBox(height: 16),
                  HmTextField(
                    controller: _description,
                    label: l.description,
                    maxLength: 200,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l.groupType,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in GroupType.values)
                        ChoiceChip(
                          avatar: Icon(t.icon, size: 18),
                          label: Text(t.label(l)),
                          selected: _type == t,
                          onSelected: (_) => setState(() => _type = t),
                        ),
                    ],
                  ),
                  if (!_isEdit) ...[
                    SectionHeader(
                      title: l.groupMembers,
                      padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: InitialsAvatar(
                        name: profile?.displayName ?? 'Me',
                      ),
                      title: Text(l.memberYou(profile?.displayName ?? 'Me')),
                      subtitle: Text(l.roleOwner),
                    ),
                    for (final m in _members)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: InitialsAvatar(name: m.name),
                        title: Text(m.name),
                        subtitle: m.personId != null
                            ? Text(l.fromPeople)
                            : null,
                        trailing: IconButton(
                          tooltip: l.removeMember,
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          onPressed: () => setState(() => _members.remove(m)),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _memberName,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _addTypedMember(),
                            decoration: InputDecoration(
                              labelText: l.memberName,
                              prefixIcon: const Icon(
                                Icons.person_add_alt_rounded,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          tooltip: l.addMember,
                          onPressed: _addTypedMember,
                          icon: const Icon(Icons.add_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _addFromPeople,
                        icon: const Icon(Icons.contacts_rounded),
                        label: Text(l.fromPeople),
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
