import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/config/app_config.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/decor.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/hm_logo.dart';
import '../../backup/application/backup_providers.dart';
import '../data/update_service.dart';
import '../domain/release_info.dart';
import '../../../core/share/share_messages.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  ReleaseInfo? _release;
  UpdateCheck? _check;
  double? _progress;
  var _busy = false;

  Future<void> _checkNow() async {
    setState(() => _busy = true);
    try {
      final (check, release) = await ref.read(updateServiceProvider).check();
      setState(() {
        _check = check;
        _release = release;
      });
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _rejection(AppLocalizations l, UpdateRejection r) => switch (r) {
    UpdateRejection.noChecksum => l.updateNoChecksum,
    UpdateRejection.checksumMismatch => l.updateChecksumMismatch,
    UpdateRejection.wrongPackage => l.updateWrongPackage,
    UpdateRejection.notNewer => l.updateNotNewer,
    UpdateRejection.signatureMismatch => l.updateSignatureMismatch,
    UpdateRejection.unreadable => l.updateUnreadable,
  };

  Future<void> _install() async {
    final l = context.l10n;
    final service = ref.read(updateServiceProvider);
    if (!await service.canInstall()) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          content: Text(l.updateAllowInstall),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l.ok),
            ),
          ],
        ),
      );
      await service.openInstallPermissionSettings();
      return;
    }
    setState(() => _progress = 0);
    try {
      final file = await service.downloadAndVerify(
        _release!,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      final ok = await confirmAction(
        context,
        title: l.updateDownloadInstall,
        message: l.updateInstallSteps,
      );
      if (ok) await service.install(file);
    } on UpdateRejectedFailure catch (f) {
      if (mounted) showAppSnack(context, _rejection(l, f.reason), error: true);
    } catch (e) {
      if (mounted) showFailure(context, e);
    } finally {
      if (mounted) setState(() => _progress = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const ToranStrip(height: 36),
          const SizedBox(height: 16),
          const Center(child: HmLogo(size: 96)),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'HisabMitra · હિસાબમિત્ર',
              style: theme.textTheme.titleLarge,
            ),
          ),
          Center(child: Text(l.appTagline, style: theme.textTheme.bodyMedium)),
          Center(
            child: Text(
              l.aboutVersion(version),
              style: theme.textTheme.labelMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l.aboutDescription, textAlign: TextAlign.center),
          ),
          SectionHeader(title: l.checkUpdates),
          if (!AppConfig.isUpdateCheckConfigured)
            ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: Text(l.updateNotConfigured),
            )
          else ...[
            ListTile(
              leading: const Icon(Icons.system_update_rounded),
              title: Text(l.checkUpdates),
              subtitle: _check == null
                  ? null
                  : Text(
                      _check == UpdateCheck.available
                          ? l.updateAvailable(_release!.version.toString())
                          : l.updateUpToDate,
                    ),
              trailing: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
              onTap: _busy ? null : _checkNow,
            ),
            if (_check == UpdateCheck.available) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _progress != null
                    ? Column(
                        children: [
                          LinearProgressIndicator(value: _progress),
                          const SizedBox(height: 4),
                          Text(l.updateDownloading((_progress! * 100).round())),
                        ],
                      )
                    : FilledButton.icon(
                        onPressed: _install,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(l.updateDownloadInstall),
                      ),
              ),
              if (_release!.notes.isNotEmpty)
                Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.releaseNotes, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Text(_release!.notes),
                      ],
                    ),
                  ),
                ),
            ],
            ListTile(
              leading: const Icon(Icons.open_in_new_rounded),
              title: Text(l.openReleasePage),
              onTap: () => launchUrl(
                Uri.parse(AppConfig.githubReleasesPage),
                mode: LaunchMode.externalApplication,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: Text(l.shareApp),
              onTap: () => SharePlus.instance.share(
                ShareParams(
                  text: appShareMessage(l, downloadUrl: appDownloadUrl()),
                ),
              ),
            ),
          ],
          SectionHeader(title: l.settingsPrivacyPolicy),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.privacySummary),
          ),
          if (AppConfig.privacyPolicyUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.policy_rounded),
              title: Text(l.settingsPrivacyPolicy),
              onTap: () => launchUrl(
                Uri.parse(AppConfig.privacyPolicyUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
          SectionHeader(title: l.settingsTerms),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l.termsSummary),
          ),
          if (AppConfig.termsUrl.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.gavel_rounded),
              title: Text(l.settingsTerms),
              onTap: () => launchUrl(
                Uri.parse(AppConfig.termsUrl),
                mode: LaunchMode.externalApplication,
              ),
            ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l.licenses),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'HisabMitra',
              applicationVersion: version,
            ),
          ),
        ],
      ),
    );
  }
}
