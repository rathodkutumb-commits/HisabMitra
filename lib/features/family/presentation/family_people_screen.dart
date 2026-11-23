import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../data/family_repository.dart';
import 'family_person_fields.dart';

/// The people of a Family hisab: add, rename or change the number, delete
/// (their entries stay). Removed people are hidden behind "Show removed".
class FamilyPeopleScreen extends ConsumerStatefulWidget {
  const FamilyPeopleScreen({super.key, required this.familyId});

  final String familyId;

  @override
  ConsumerState<FamilyPeopleScreen> createState() => _FamilyPeopleScreenState();
}

class _FamilyPeopleScreenState extends ConsumerState<FamilyPeopleScreen> {
  var _showRemoved = false;

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  Future<void> _add() async {
    final l = context.l10n;
    final p = await showFamilyPersonDialog(context, title: l.familyAddPerson);
    if (p == null) return;
    await _guard(() async {
      await ref
          .read(familyRepositoryProvider)
          .savePerson(
            FamilyPersonDraft(
              familyId: widget.familyId,
              name: p.name,
              phone: p.phone,
            ),
          );
      if (mounted) showAppSnack(context, l.familyPersonSaved);
    });
  }

  Future<void> _edit(FamilyMemberRow m) async {
    final l = context.l10n;
    final p = await showFamilyPersonDialog(
      context,
      title: l.familyEditPerson,
      initial: FamilyPersonDraft(id: m.id, name: m.name, phone: m.phone),
    );
    if (p == null) return;
    await _guard(() => ref.read(familyRepositoryProvider).savePerson(p));
  }

  Future<void> _delete(FamilyMemberRow m) async {
    final l = context.l10n;
    final ok = await confirmAction(
      context,
      title: l.familyDeletePerson,
      message: l.familyDeletePersonMessage(m.name),
      confirmLabel: l.familyDeletePerson,
      destructive: true,
    );
    if (!ok) return;
    await _guard(() async {
      await ref.read(familyRepositoryProvider).deletePerson(m.id);
      if (mounted) showAppSnack(context, l.familyPersonDeleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.familyPeople)),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'fab-family-people',
        onPressed: _add,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l.familyAddPerson),
      ),
      body: AsyncValueView(
        value: ref.watch(familyDetailProvider(widget.familyId)),
        data: (d) {
          if (d == null) {
            return EmptyState(
              icon: Icons.family_restroom_rounded,
              title: l.errorNotFound,
            );
          }
          final removed = d.members.where((m) => m.status == 'removed');
          return ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            children: [
              for (final m in d.activeMembers)
                ListTile(
                  leading: InitialsAvatar(name: m.name),
                  title: Text(m.isSelf ? l.memberYou(m.name) : m.name),
                  subtitle: Text(
                    m.isSelf
                        ? l.roleOwner
                        : [
                            if (m.phone != null) m.phone!,
                            m.userId != null
                                ? l.familyHasApp
                                : l.familyNotJoined,
                          ].join(' · '),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) =>
                        action == 'edit' ? _edit(m) : _delete(m),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(l.familyEditPerson),
                      ),
                      if (m.role != 'owner')
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l.familyDeletePerson),
                        ),
                    ],
                  ),
                ),
              if (removed.isNotEmpty)
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _showRemoved = !_showRemoved),
                      child: Text(
                        _showRemoved
                            ? l.familyHideRemoved
                            : l.familyShowRemoved(removed.length),
                      ),
                    ),
                  ),
                ),
              if (_showRemoved)
                for (final m in removed)
                  ListTile(
                    enabled: false,
                    leading: InitialsAvatar(name: m.name),
                    title: Text(l.familyPersonRemoved(m.name)),
                    subtitle: m.phone == null ? null : Text(m.phone!),
                  ),
            ],
          );
        },
      ),
    );
  }
}
