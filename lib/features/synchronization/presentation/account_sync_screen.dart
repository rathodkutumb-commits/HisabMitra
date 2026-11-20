import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/hm_logo.dart';
import '../application/account_sync_controller.dart';

/// First sync of this phone with the account: "Saving your hisab to your
/// account" (old phone data) or "Getting your hisab" (new phone). The app
/// moves on by itself when done; the user may continue in the background.
class AccountSyncScreen extends ConsumerStatefulWidget {
  const AccountSyncScreen({super.key});

  @override
  ConsumerState<AccountSyncScreen> createState() => _AccountSyncScreenState();
}

class _AccountSyncScreenState extends ConsumerState<AccountSyncScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(accountSyncControllerProvider.notifier).run();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final s = ref.watch(accountSyncControllerProvider);
    final uploading = s.phase == AccountSyncPhase.uploading && s.total > 0;
    final stuck =
        s.phase == AccountSyncPhase.offline ||
        s.phase == AccountSyncPhase.failed;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const HmLogo(size: 72),
              const SizedBox(height: 24),
              Text(
                uploading || (stuck && s.total > 0)
                    ? l.accountSyncUploadTitle
                    : l.accountSyncDownloadTitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (stuck) ...[
                Text(
                  l.accountSyncOffline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => ref
                      .read(accountSyncControllerProvider.notifier)
                      .run(retryNow: true),
                  child: Text(l.retry),
                ),
              ] else ...[
                LinearProgressIndicator(
                  value: uploading ? s.done / s.total : null,
                ),
                if (uploading) ...[
                  const SizedBox(height: 8),
                  Text(l.accountSyncProgress('${s.done}', '${s.total}')),
                ],
              ],
              const SizedBox(height: 24),
              TextButton(
                onPressed: () =>
                    ref.read(accountSyncDeferredProvider.notifier).defer(),
                child: Text(l.accountSyncContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
