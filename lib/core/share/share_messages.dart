import '../../app/config/app_config.dart';
import '../../l10n/app_localizations.dart';

/// The page where the latest APK can be downloaded, or null when this build
/// has no GitHub repository configured (then messages leave the line out).
String? appDownloadUrl() => AppConfig.isUpdateCheckConfigured
    ? '${AppConfig.githubReleasesPage}/latest'
    : null;

/// The invitation page (GitHub Pages of the release repository) that opens
/// the app on the join screen, or null when this build has no GitHub
/// repository configured (then the message has no link line).
String? inviteLinkUrl(String code) => AppConfig.isUpdateCheckConfigured
    ? 'https://${AppConfig.githubOwner.toLowerCase()}.github.io/'
          '${AppConfig.githubRepo}/join?code=${Uri.encodeQueryComponent(code)}'
    : null;

String _withDownload(String body, String? line) =>
    line == null ? body : '$body\n\n$line';

/// The group invitation shared to WhatsApp and other apps (spacing, emojis
/// and WhatsApp *bold*). With [link] it starts with "Tap to join".
String inviteMessage(
  AppLocalizations l, {
  required String group,
  required String code,
  required String date,
  String? link,
  String? downloadUrl,
}) => _withDownload(
  link == null
      ? l.inviteShareText(group, code, date)
      : l.inviteShareTextLink(group, code, link, date),
  downloadUrl == null ? null : l.inviteShareDownload(downloadUrl),
);

/// "Share HisabMitra" from About.
String appShareMessage(AppLocalizations l, {String? downloadUrl}) =>
    _withDownload(
      l.shareAppText,
      downloadUrl == null ? null : l.shareAppDownload(downloadUrl),
    );
