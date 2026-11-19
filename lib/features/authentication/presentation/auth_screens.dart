import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/hm_logo.dart';
import '../application/auth_controller.dart';

/// Second step of the compulsory account: verify the email with the code
/// it contains, or by tapping its link on this phone (which reopens the app
/// here with [authCode]). On success the router moves on to the dashboard.
class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key, this.authCode, this.linkError = false});

  /// `?code=` from `hisabmitra://login-callback`.
  final String? authCode;

  /// The link came back with an error (expired, already used).
  final bool linkError;

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  final _code = TextEditingController();
  PendingSignUp? _pending;
  var _loaded = false;
  var _busy = false;
  var _secondsLeft = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final pending = await ref.read(authControllerProvider).pendingSignUp();
    if (!mounted) return;
    setState(() {
      _pending = pending;
      _loaded = true;
    });
    _startTimer();
    if (widget.linkError) {
      showFailure(context, const AuthFailure('link_invalid'));
    } else if (widget.authCode != null) {
      await _run(
        () =>
            ref.read(authControllerProvider).completeWithLink(widget.authCode!),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      if (mounted) showAppSnack(context, context.l10n.emailVerified);
      // The router leaves the welcome flow once the account is verified.
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _resend() async {
    final p = _pending;
    if (p == null) return;
    try {
      await ref
          .read(authControllerProvider)
          .requestCode(name: p.name, email: p.email, phone: p.phone);
      if (!mounted) return;
      showAppSnack(context, context.l10n.authCodeSent);
      _startTimer();
    } catch (e) {
      if (mounted) showFailure(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final pending = _pending;
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const Center(child: HmLogo(size: 56)),
                const SizedBox(height: 24),
                Text(l.verifyEmailTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                if (pending != null)
                  Text(l.verifyEmailSubtitle(pending.email))
                else if (widget.authCode == null)
                  Text(l.authNoPending),
                if (_busy && widget.authCode != null) ...[
                  const SizedBox(height: 12),
                  Text(l.verifyingLink, style: theme.textTheme.bodySmall),
                ],
                const SizedBox(height: 24),
                if (pending != null) ...[
                  TextField(
                    controller: _code,
                    autofocus: widget.authCode == null,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    maxLength: 10,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      letterSpacing: 8,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l.verificationCode,
                      counterText: '',
                    ),
                    onSubmitted: (_) => _run(
                      () => ref
                          .read(authControllerProvider)
                          .verifyCode(_code.text),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _busy
                        ? null
                        : () => _run(
                            () => ref
                                .read(authControllerProvider)
                                .verifyCode(_code.text),
                          ),
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l.authVerify),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _secondsLeft > 0 || _busy ? null : _resend,
                    child: Text(
                      _secondsLeft > 0
                          ? l.authResendIn(_secondsLeft)
                          : l.authResend,
                    ),
                  ),
                  Text(
                    l.verifyEmailSpamHint,
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: _busy
                      ? null
                      : () => context.go(Routes.profileSetup),
                  icon: const Icon(Icons.edit_rounded),
                  label: Text(l.changeDetails),
                ),
              ],
            ),
    );
  }
}
