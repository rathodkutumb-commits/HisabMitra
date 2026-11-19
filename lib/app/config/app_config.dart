/// Build-time configuration supplied with `--dart-define` (or
/// `--dart-define-from-file=dart_defines.json`, which is git-ignored).
///
/// Only *public* client values belong here. The Supabase service-role key
/// must never be passed to the app.
abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Public client key (Supabase "publishable" key; the legacy anon key is
  /// accepted too). Never the service-role / secret key.
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  /// GitHub repository that publishes release APKs (e.g. owner `acme`,
  /// repo `hisabmitra`). Update checks are disabled when empty.
  static const githubOwner = String.fromEnvironment('GITHUB_OWNER');
  static const githubRepo = String.fromEnvironment('GITHUB_REPO');

  /// Optional public pages.
  static const privacyPolicyUrl = String.fromEnvironment('PRIVACY_POLICY_URL');
  static const termsUrl = String.fromEnvironment('TERMS_URL');

  static bool get isCloudConfigured =>
      supabaseUrl.startsWith('https://') && supabasePublishableKey.isNotEmpty;

  static bool get isUpdateCheckConfigured =>
      githubOwner.isNotEmpty && githubRepo.isNotEmpty;

  static String get githubReleasesPage =>
      'https://github.com/$githubOwner/$githubRepo/releases';
}
