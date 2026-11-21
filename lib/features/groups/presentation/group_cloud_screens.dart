import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../profile/data/profile_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../../synchronization/application/sync_controller.dart';
import '../../synchronization/domain/cloud_models.dart';
import '../../authentication/application/auth_controller.dart';
import '../data/group_repository.dart';
import '../domain/invite_code.dart';
import '../../../core/share/share_messages.dart';

final _invitationsProvider = FutureProvider.autoDispose
    .family<List<InvitationInfo>, String>(
      (ref, groupId) =>
          ref.watch(cloudGatewayProvider).listInvitations(groupId),
    );

class GroupInviteScreen extends ConsumerStatefulWidget {
  const GroupInviteScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupInviteScreen> createState() => _GroupInviteScreenState();
}

class _GroupInviteScreenState extends ConsumerState<GroupInviteScreen> {
  String? _memberId;
  CreatedInvitation? _created;
  var _busy = false;

  Future<void> _create(String groupName) async {
    setState(() => _busy = true);
    try {
      final inv = await ref
          .read(cloudGatewayProvider)
          .createInvitation(groupId: widget.groupId, memberId: _memberId);
      setState(() => _created = inv);
      ref.invalidate(_invitationsProvider(widget.groupId));
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final detail = ref.watch(groupDetailProvider(widget.groupId)).value;
    if (detail == null) {
      return Scaffold(appBar: AppBar(), body: const LoadingView());
    }
    final shared = detail.group.isShared && detail.group.revision > 0;
    final localParticipants = detail.members
        .where((m) => m.userId == null && !m.isSelf)
        .toList();

    String statusLabel(String s) => switch (s) {
      'accepted' => l.inviteStatusAccepted,
      'cancelled' => l.inviteStatusCancelled,
      'expired' => l.inviteStatusExpired,
      _ => l.inviteStatusPending,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l.inviteTitle)),
      body: !shared
          ? EmptyState(
              icon: Icons.cloud_off_rounded,
              title: l.inviteSampleGroup,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: _memberId,
                  decoration: InputDecoration(labelText: l.inviteFor),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(l.inviteNewMember),
                    ),
                    for (final m in localParticipants)
                      DropdownMenuItem(value: m.id, child: Text(m.displayName)),
                  ],
                  onChanged: (v) => setState(() => _memberId = v),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _busy ? null : () => _create(detail.group.name),
                  icon: const Icon(Icons.vpn_key_rounded),
                  label: Text(l.inviteCreate),
                ),
                if (_created != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          SelectableText(
                            _created!.code,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  letterSpacing: 4,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            l.inviteExpires(fmt.dateTime(_created!.expiresAt)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l.inviteCodeOnce,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                tooltip: l.calculatorCopy,
                                icon: const Icon(Icons.copy_rounded),
                                onPressed: () => Clipboard.setData(
                                  ClipboardData(text: _created!.code),
                                ),
                              ),
                              FilledButton.icon(
                                onPressed: () => SharePlus.instance.share(
                                  ShareParams(
                                    text: inviteMessage(
                                      l,
                                      group: detail.group.name,
                                      code: _created!.code,
                                      date: fmt.date(_created!.expiresAt),
                                      link: inviteLinkUrl(
                                        _created!.code,
                                        languageCode: l.localeName,
                                      ),
                                      downloadUrl: appDownloadPageUrl(
                                        languageCode: l.localeName,
                                      ),
                                    ),
                                  ),
                                ),
                                icon: const Icon(Icons.share_rounded),
                                label: Text(l.share),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                SectionHeader(
                  title: l.inviteTitle,
                  padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
                ),
                AsyncValueView(
                  value: ref.watch(_invitationsProvider(widget.groupId)),
                  onRetry: () =>
                      ref.invalidate(_invitationsProvider(widget.groupId)),
                  data: (list) => list.isEmpty
                      ? Text(l.invitesEmpty)
                      : Column(
                          children: [
                            for (final inv in list)
                              ListTile(
                                leading: const Icon(Icons.mail_outline_rounded),
                                title: Text(
                                  inv.memberId == null
                                      ? l.inviteNewMember
                                      : detail.memberName(inv.memberId!),
                                ),
                                subtitle: Text(
                                  '${statusLabel(inv.status)} · ${l.inviteExpires(fmt.date(inv.expiresAt))}',
                                ),
                                trailing: inv.status == 'pending'
                                    ? IconButton(
                                        tooltip: l.inviteCancel,
                                        icon: const Icon(Icons.cancel_outlined),
                                        onPressed: () async {
                                          try {
                                            await ref
                                                .read(cloudGatewayProvider)
                                                .cancelInvitation(inv.id);
                                            ref.invalidate(
                                              _invitationsProvider(
                                                widget.groupId,
                                              ),
                                            );
                                          } catch (e) {
                                            if (context.mounted) {
                                              showFailure(context, e);
                                            }
                                          }
                                        },
                                      )
                                    : null,
                              ),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key, this.initialCode});

  final String? initialCode;

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  late final _code = TextEditingController(text: widget.initialCode ?? '');
  var _busy = false;

  @override
  void initState() {
    super.initState();
    // Opened from an invitation link: join without a tap.
    final code = normalizeInviteCode(widget.initialCode);
    if (code != null) {
      _code.text = code;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _join();
      });
    }
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final l = context.l10n;
    final cloud = ref.read(cloudGatewayProvider);
    if (cloud.currentSession == null) {
      showAppSnack(context, l.joinNeedsSignIn);
      await ref.read(authControllerProvider).markSessionLost();
      return;
    }
    final code = normalizeInviteCode(_code.text);
    if (code == null) return;
    final settings = ref.read(settingsControllerProvider.notifier);
    setState(() => _busy = true);
    try {
      final profile = await ref.read(profileRepositoryProvider).get();
      final AcceptedInvitation accepted;
      try {
        accepted = await cloud.acceptInvitation(
          code: code,
          displayName: profile?.displayName ?? 'Member',
        );
      } finally {
        // Tried once: a failure is shown here with the code, never retried
        // by itself. (Not signed in returned above and keeps it.)
        await settings.update(
          (p) => p.pendingInviteCode == code
              ? p.copyWith(pendingInviteCode: '')
              : p,
        );
      }
      await ref.read(syncServiceProvider).joinGroup(accepted.groupId);
      final group = await ref
          .read(groupRepositoryProvider)
          .watchGroup(accepted.groupId)
          .first;
      if (!mounted) return;
      showAppSnack(context, l.joinDone(group?.group.name ?? ''));
      context.pushReplacement(Routes.group(accepted.groupId));
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.joinTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.group_add_rounded, size: 72),
          const SizedBox(height: 24),
          TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            maxLength: 12,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(letterSpacing: 4),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            ],
            decoration: InputDecoration(labelText: l.joinCode, counterText: ''),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _join,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.joinButton),
          ),
        ],
      ),
    );
  }
}
