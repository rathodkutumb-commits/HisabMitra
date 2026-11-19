import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../people/data/people_repository.dart';
import '../../people/presentation/person_picker.dart';
import '../data/group_repository.dart';
import '../domain/group_models.dart';
import 'group_labels.dart';

class GroupMembersScreen extends ConsumerWidget {
  const GroupMembersScreen({super.key, required this.groupId});

  final String groupId;

  Future<String?> _askName(
    BuildContext context, {
    String? initial,
    required String title,
  }) async {
    final controller = TextEditingController(text: initial);
    final l = context.l10n;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 80,
          decoration: InputDecoration(labelText: l.memberName),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(l.save),
          ),
        ],
      ),
    );
    controller.dispose();
    return result?.trim().isEmpty ?? true ? null : result!.trim();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.read(groupRepositoryProvider);
    Future<void> guard(Future<void> Function() action) async {
      try {
        await action();
      } catch (e) {
        if (context.mounted) showFailure(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.groupMembers)),
      floatingActionButton: FloatingActionButton.extended(
        // Unique: the tab shell keeps several FAB screens alive.
        heroTag: 'fab-group-members',
        onPressed: () async {
          final choice = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit_rounded),
                    title: Text(l.memberName),
                    onTap: () => Navigator.pop(ctx, 'name'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.contacts_rounded),
                    title: Text(l.fromPeople),
                    onTap: () => Navigator.pop(ctx, 'people'),
                  ),
                ],
              ),
            ),
          );
          if (!context.mounted) return;
          if (choice == 'name') {
            final name = await _askName(context, title: l.addMember);
            if (name != null) {
              await guard(
                () => repo.addMember(groupId, MemberDraft(name: name)),
              );
            }
          } else if (choice == 'people') {
            final id = await showPersonPicker(context);
            if (id == null) return;
            final p = await ref.read(peopleRepositoryProvider).getById(id);
            if (p != null) {
              await guard(
                () => repo.addMember(
                  groupId,
                  MemberDraft(name: p.name, phone: p.phone, personId: p.id),
                ),
              );
            }
          }
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l.addMember),
      ),
      body: AsyncValueView(
        value: ref.watch(groupDetailProvider(groupId)),
        data: (d) {
          if (d == null) {
            return EmptyState(
              icon: Icons.groups_rounded,
              title: l.errorNotFound,
            );
          }
          return ListView(
            padding: const EdgeInsets.only(bottom: 96, top: 8),
            children: [
              for (final m in d.members)
                ListTile(
                  leading: InitialsAvatar(name: m.displayName),
                  title: Text(memberLabel(l, m)),
                  subtitle: Text(
                    '${m.role.label(l)} · ${m.userId != null ? l.cloudMember : l.localParticipant}',
                  ),
                  trailing: m.isSelf
                      ? null
                      : PopupMenuButton<String>(
                          onSelected: (action) async {
                            if (action == 'rename') {
                              final name = await _askName(
                                context,
                                initial: m.displayName,
                                title: l.renameMember,
                              );
                              if (name != null) {
                                await guard(
                                  () => repo.renameMember(m.id, name),
                                );
                              }
                            } else if (action == 'remove') {
                              final ok = await confirmAction(
                                context,
                                title: l.removeMember,
                                destructive: true,
                              );
                              if (!ok) return;
                              await guard(() async {
                                await repo.removeMember(m.id);
                                if (context.mounted) {
                                  showAppSnack(context, l.memberRemoved);
                                }
                              });
                            }
                          },
                          itemBuilder: (_) => [
                            PopupMenuItem(
                              value: 'rename',
                              child: Text(l.renameMember),
                            ),
                            PopupMenuItem(
                              value: 'remove',
                              child: Text(l.removeMember),
                            ),
                          ],
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}
