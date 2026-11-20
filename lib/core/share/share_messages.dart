import '../../app/config/app_config.dart';
import '../../l10n/app_localizations.dart';

/// The page where the latest APK can be downloaded, or null when this build
/// has no GitHub repository configured (then messages leave the line out).
String? appDownloadUrl() => AppConfig.isUpdateCheckConfigured
    ? '${AppConfig.githubReleasesPage}/latest'
    : null;

String _withDownload(String body, String? line) =>
    line == null ? body : '$body\n\n$line';

/// The group invitation shared to WhatsApp and other apps (spacing, emojis
/// and WhatsApp *bold*).
String inviteMessage(
  AppLocalizations l, {
  required String group,
  required String code,
  required String date,
  String? downloadUrl,
}) => _withDownload(
  l.inviteShareText(group, code, date),
  downloadUrl == null ? null : l.inviteShareDownload(downloadUrl),
);

/// "Share HisabMitra" from About.
String appShareMessage(AppLocalizations l, {String? downloadUrl}) =>
    _withDownload(
      l.shareAppText,
      downloadUrl == null ? null : l.shareAppDownload(downloadUrl),
    );
