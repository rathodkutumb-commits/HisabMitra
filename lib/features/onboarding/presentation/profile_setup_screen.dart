import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/utils/email.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../core/widgets/hm_logo.dart';
import '../../authentication/application/auth_controller.dart';
import '../../profile/data/profile_repository.dart';
import '../../synchronization/application/sync_controller.dart';

/// Compulsory account step of onboarding (and after sign-out): name, email
/// and mobile number. With a cloud configuration the email is verified on
/// the next screen; otherwise the details are kept on the device.
class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  var _busy = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  /// Existing installs and a returning user see what they entered before.
  Future<void> _prefill() async {
    final pending = await ref.read(authControllerProvider).pendingSignUp();
    final profile = await ref.read(profileRepositoryProvider).get();
    if (!mounted) return;
    void fill(TextEditingController c, String? v) {
      if (c.text.isEmpty && v != null) c.text = v;
    }

    fill(_name, pending?.name ?? profile?.displayName);
    fill(_email, pending?.email ?? profile?.email);
    final phone = pending?.phone ?? profile?.phone;
    fill(_phone, phone == null ? null : PhoneNumbers.display(phone));
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_busy || !_form.currentState!.validate()) return;
    setState(() => _busy = true);
    final auth = ref.read(authControllerProvider);
    try {
      if (ref.read(cloudGatewayProvider).isConfigured) {
        await auth.requestCode(
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
        );
        if (!mounted) return;
        showAppSnack(context, context.l10n.authCodeSent);
        context.go(Routes.verifyEmail);
      } else {
        await auth.saveWithoutCloud(
          name: _name.text,
          email: _email.text,
          phone: _phone.text,
        );
        if (mounted) context.go(Routes.home);
      }
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cloud = ref.watch(cloudGatewayProvider).isConfigured;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Center(child: HmLogo(size: 64)),
              const SizedBox(height: 24),
              Text(l.profileSetupTitle, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                l.profileSetupSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              HmTextField(
                controller: _name,
                label: l.yourName,
                prefixIcon: Icons.person_rounded,
                maxLength: 80,
                required: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l.emailAddress,
                  hintText: l.emailHint,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                ),
                validator: (v) =>
                    EmailAddresses.isValid(v ?? '') ? null : l.validationEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-૦-૯]')),
                ],
                decoration: InputDecoration(
                  labelText: l.mobileNumber,
                  hintText: '98765 43210',
                  helperText: '+91',
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                ),
                validator: (v) =>
                    PhoneNumbers.isValid(v ?? '') ? null : l.validationPhone,
                onFieldSubmitted: (_) => _continue(),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(l.privacyPromise)),
                    ],
                  ),
                ),
              ),
              if (!cloud) ...[
                const SizedBox(height: 12),
                Text(l.accountOfflineNote, style: theme.textTheme.bodySmall),
              ],
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _busy ? null : _continue,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(cloud ? l.authSendOtp : l.startUsing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
