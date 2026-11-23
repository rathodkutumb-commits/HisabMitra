import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/share/share_messages.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../../synchronization/domain/cloud_models.dart';
import '../application/family_sharing.dart';
import '../data/family_repository.dart';

final _invitationsProvider = FutureProvider.autoDispose
    .family<List<InvitationInfo>, String>(
      (ref, familyId) => ref.watch(familySharingProvider).invitations(familyId),
    );

/// Invites a person who has the app into a Family hisab: a code and a
/// "Tap to join" link to share, for a named person (who keeps their
/// entries) or for someone new.
class FamilyInviteScreen extends ConsumerStatefulWidget {
  const FamilyInviteScreen({super.key, required this.familyId, this.memberId});

  final String familyId;

  /// The person to invite (preselected).
  final String? memberId;

  @override
  ConsumerState<FamilyInviteScreen> createState() => _FamilyInviteScreenState();
}

class _FamilyInviteScreenState extends ConsumerState<FamilyInviteScreen> {
  late String? _memberId = widget.memberId;
  CreatedInvitation? _created;
  var _busy = false;

  Future<void> _create() async {
    setState(() => _busy = true);
    try {
      final inv = await ref
          .read(familySharingProvider)
          .createInvitation(familyId: widget.familyId, memberId: _memberId);
      if (!mounted) return;
      setState(() => _created = inv);
      ref.invalidate(_invitationsProvider(widget.familyId));
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
    final detail = ref.watch(familyDetailProvider(widget.familyId)).value;
    if (detail == null) {
      return Scaffold(appBar: AppBar(), body: const LoadingView());
    }
    final notJoined = [
      for (final m in detail.activeMembers)
        if (m.userId == null && !m.isSelf) m,
    ];
    if (!notJoined.any((m) => m.id == _memberId)) _memberId = null;

    String statusLabel(String s) => switch (s) {
      'accepted' => l.inviteStatusAccepted,
      'cancelled' => l.inviteStatusCancelled,
      'expired' => l.inviteStatusExpired,
      _ => l.inviteStatusPending,
    };

    final created = _created;
    return Scaffold(
      appBar: AppBar(title: Text(l.familyInviteTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String?>(
            initialValue: _memberId,
            decoration: InputDecoration(labelText: l.inviteFor),
            items: [
              DropdownMenuItem(value: null, child: Text(l.inviteNewMember)),
              for (final m in notJoined)
                DropdownMenuItem(value: m.id, child: Text(m.name)),
            ],
            onChanged: (v) => setState(() => _memberId = v),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _create,
            icon: const Icon(Icons.vpn_key_rounded),
            label: Text(l.inviteCreate),
          ),
          if (created != null) ...[
            const SizedBox(height: 16),
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    SelectableText(
                      created.code,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            letterSpacing: 4,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(l.inviteExpires(fmt.dateTime(created.expiresAt))),
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
                            ClipboardData(text: created.code),
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => SharePlus.instance.share(
                            ShareParams(
                              text: familyInviteMessage(
                                l,
                                family: detail.family.name,
                                code: created.code,
                                date: fmt.date(created.expiresAt),
                                link: inviteLinkUrl(
                                  created.code,
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
            value: ref.watch(_invitationsProvider(widget.familyId)),
            onRetry: () =>
                ref.invalidate(_invitationsProvider(widget.familyId)),
            data: (list) => list.isEmpty
                ? Text(l.invitesEmpty)
                : Column(
                    children: [
                      for (final inv in list)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.mail_outline_rounded),
                          title: Text(
                            inv.memberId == null
                                ? l.inviteNewMember
                                : detail.memberName(inv.memberId!, l),
                          ),
                          subtitle: Text(
                            '${statusLabel(inv.status)} · '
                            '${l.inviteExpires(fmt.date(inv.expiresAt))}',
                          ),
                          trailing: inv.status == 'pending'
                              ? IconButton(
                                  tooltip: l.inviteCancel,
                                  icon: const Icon(Icons.cancel_outlined),
                                  onPressed: () async {
                                    try {
                                      await ref
                                          .read(familySharingProvider)
                                          .cancel(inv.id);
                                      ref.invalidate(
                                        _invitationsProvider(widget.familyId),
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
