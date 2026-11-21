import '../../app/config/app_config.dart';
import '../../l10n/app_localizations.dart';

/// A page of the HisabMitra website in the app's language (English at the
/// root, Gujarati under `/gu`), or null when this build has no website
/// configured (then messages leave the line out).
String? websitePage(
  String page, {
  required String languageCode,
  String base = AppConfig.websiteUrl,
}) {
  if (base.isEmpty) return null;
  final root = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
  final prefix = languageCode == 'gu' ? '/gu' : '';
  return '$root$prefix$page';
}

/// The website's home page: what HisabMitra is, and the download.
String? appDownloadUrl({required String languageCode}) =>
    websitePage('', languageCode: languageCode);

/// The website's download page (newest version, install steps).
String? appDownloadPageUrl({required String languageCode}) =>
    websitePage('/download', languageCode: languageCode);

/// The invitation page that opens the app on the join screen.
String? inviteLinkUrl(String code, {required String languageCode}) =>
    websitePage(
      '/join?code=${Uri.encodeQueryComponent(code)}',
      languageCode: languageCode,
    );

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
