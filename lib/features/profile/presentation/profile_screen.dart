import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/config/app_config.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../authentication/application/auth_controller.dart';
import '../../synchronization/application/sync_controller.dart';
import '../data/profile_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  var _loaded = false;
  var _busy = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action, String doneMessage) async {
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) showAppSnack(context, doneMessage);
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final profile = ref.watch(profileProvider).value;
    final session = ref.watch(cloudSessionProvider).value;
    if (!_loaded && profile != null) {
      _name.text = profile.displayName;
      _loaded = true;
    }
    final signedIn = session != null;

    return Scaffold(
      appBar: AppBar(title: Text(l.profileTitle)),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: InitialsAvatar(
                name: profile?.displayName ?? '?',
                radius: 40,
              ),
            ),
            const SizedBox(height: 24),
            HmTextField(
              controller: _name,
              label: l.profileName,
              maxLength: 80,
              required: true,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy
                  ? null
                  : () {
                      if (!_form.currentState!.validate()) return;
                      _run(
                        () => ref
                            .read(profileRepositoryProvider)
                            .saveName(_name.text),
                        l.profileSaved,
                      );
                    },
              child: Text(l.save),
            ),
            SectionHeader(
              title: l.settingsAccount,
              padding: const EdgeInsets.fromLTRB(0, 24, 0, 8),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      signedIn
                          ? Icons.verified_user_rounded
                          : Icons.mark_email_unread_rounded,
                    ),
                    title: Text(
                      signedIn
                          ? l.accountVerifiedAs(
                              session.email ?? profile?.email ?? '',
                            )
                          : (profile?.email ?? l.emailAddress),
                    ),
                    subtitle: Text(l.emailAddress),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone_android_rounded),
                    title: Text(PhoneNumbers.display(profile?.phone ?? '')),
                    subtitle: Text(l.mobileNumber),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (!AppConfig.isCloudConfigured)
              Text(
                l.accountOfflineNote,
                style: Theme.of(context).textTheme.bodySmall,
              )
            else if (!signedIn)
              OutlinedButton.icon(
                onPressed: () =>
                    ref.read(authControllerProvider).markSessionLost(),
                icon: const Icon(Icons.mark_email_read_rounded),
                label: Text(l.verifyEmailAction),
              )
            else ...[
              OutlinedButton.icon(
                onPressed: _busy
                    ? null
                    : () async {
                        final ok = await confirmAction(
                          context,
                          title: l.settingsLogout,
                          message: l.settingsLogoutConfirm,
                        );
                        if (ok) {
                          await _run(
                            () => ref.read(authControllerProvider).signOut(),
                            l.signedOut,
                          );
                        }
                      },
                icon: const Icon(Icons.logout_rounded),
                label: Text(l.settingsLogout),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: _busy
                    ? null
                    : () async {
                        final ok = await confirmAction(
                          context,
                          title: l.settingsDeleteAccount,
                          message: l.deleteAccountConfirm,
                          confirmLabel: l.delete,
                          destructive: true,
                        );
                        if (ok) {
                          await _run(
                            () => ref
                                .read(authControllerProvider)
                                .deleteAccount(),
                            l.accountDeleted,
                          );
                        }
                      },
                icon: const Icon(Icons.delete_forever_rounded),
                label: Text(l.settingsDeleteAccount),
              ),
              Text(
                l.settingsDeleteAccountDesc,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
