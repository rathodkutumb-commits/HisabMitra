# GitHub Release Guide

Releases are public: anyone can download the APK. That gives no access to
anyone's data — personal data stays on each phone, and shared groups need
phone sign-in plus an invitation (RLS on the server).

## One-time setup

Status 2026-11-19: **done.**

| Item | State |
|---|---|
| Repository | `https://github.com/rathodkutumb-commits/HisabMitra` (public), code pushed |
| Release keystore | `D:\Hemang\Keys\HisabMitra\hisabmitra-release.jks`, alias `hisabmitra`, password in `key.properties` next to it (PKCS12: store password = key password). Back this folder up; never commit it. |
| Local signing | `android/key.properties` (git-ignored) points at that keystore, so local `flutter build apk --release` is release-signed |
| Repository secrets | `HISABMITRA_KEYSTORE_BASE64`, `HISABMITRA_KEYSTORE_PASSWORD`, `HISABMITRA_KEY_ALIAS`, `HISABMITRA_KEY_PASSWORD`, `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` — all set |
| Release certificate SHA-256 | `37c8f9fd01a1e05ce3e2fb47129a181124ece92b95d326545c4d3b0af39deef9` |

To set everything up again from scratch (new keystore = new app identity;
existing installs could not update):

1. `keytool -genkeypair -v -keystore hisabmitra-release.jks -storetype PKCS12 -alias hisabmitra -keyalg RSA -keysize 4096 -validity 10000`
2. Add the six secrets above (Settings → Secrets and variables → Actions),
   `HISABMITRA_KEYSTORE_BASE64` = `base64 -w0 hisabmitra-release.jks`.
   Optional repository variables: `PRIVACY_POLICY_URL`, `TERMS_URL`.

## Publishing a release

```bash
# 1. bump version in pubspec.yaml, e.g. 1.1.0+2 (the +N build number must increase)
# 2. optional notes: docs/release-notes/v1.1.0.md
git commit -am "Release 1.1.0"
git tag v1.1.0
git push origin main v1.1.0
```

`.github/workflows/release.yml` then:

1. checks the tag matches the pubspec version;
2. refuses to continue without the signing secrets (a debug-signed APK is
   never published) and refuses a secret Supabase key;
3. runs the tests, builds `flutter build apk --release`;
4. verifies the signature with `apksigner` and fails on a debug
   certificate;
5. publishes `hisabmitra-<version>.apk` and `hisabmitra-<version>.apk.sha256`
   with release notes showing the APK SHA-256 and the signing-certificate
   SHA-256;
6. deletes the decoded keystore from the runner.

## In-app updates

About → Check for updates calls
`https://api.github.com/repos/{owner}/{repo}/releases/latest`, skips
drafts and pre-releases, compares versions, and offers the update. On
"Download":

1. downloads the APK to the app's private cache;
2. verifies its SHA-256 against the published `.sha256` file (no checksum →
   no install);
3. checks package name, that the version is newer and that the signing
   certificate matches the installed app;
4. explains the steps, then hands the file to Android's package installer —
   the user confirms. Nothing is installed silently.

The first time, Android asks the user to allow HisabMitra to install
unknown apps (`REQUEST_INSTALL_PACKAGES`).

## Local release build (without CI)

```bash
# android/key.properties (git-ignored):
#   storeFile=/absolute/path/hisabmitra-release.jks
#   storePassword=…  keyAlias=hisabmitra  keyPassword=…
flutter build apk --release --dart-define-from-file=dart_defines.json
```

Without `key.properties` the release build falls back to the debug key so
it runs locally; such an APK must not be published.
