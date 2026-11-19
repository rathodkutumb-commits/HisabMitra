# Build and Deployment Guide

## Prerequisites

| Tool | Version used |
|---|---|
| Flutter | 3.47.9 stable (Dart 3.13.7) |
| JDK | 21 (Temurin) |
| Android SDK | compileSdk 37, minSdk 24 |
| Docker | for the Supabase SQL tests |

On this development PC the Android user folder is `D:\.android`
(`ANDROID_USER_HOME`, `ANDROID_EMULATOR_HOME`, `ANDROID_AVD_HOME`).

## First run

```bash
flutter pub get
cp dart_defines.example.json dart_defines.json   # git-ignored; fill Supabase values
flutter run --dart-define-from-file=dart_defines.json
```

Without Supabase values the app runs fully offline.

## After changing…

| Change | Run |
|---|---|
| strings in `l10n/*/*.json` | `dart run tool/build_l10n.dart && flutter gen-l10n` |
| Drift tables | bump `currentSchemaVersion`, add a migration step, `dart run build_runner build`, `dart run drift_dev make-migrations`, `dart run tool/gen_database_schema_doc.dart` |
| logo / default palette | `flutter test tool/generate_brand_assets_test.dart` (rewrites launcher, splash and logo PNGs) and `android/app/src/main/res/values/colors.xml` |
| Supabase schema | new file in `supabase/migrations/`, `bash tool/run_supabase_tests.sh`, then apply (SUPABASE_SETUP.md §3) |

## Quality gate (before every release)

```bash
dart format --output=none --set-exit-if-changed lib test tool integration_test
flutter analyze
flutter test
flutter test integration_test -d <device> --concurrency=1
bash tool/run_supabase_tests.sh
```

## Builds

```bash
flutter build apk --debug   --dart-define-from-file=dart_defines.json
flutter build apk --release --dart-define-from-file=dart_defines.json   # needs key.properties
```

Release publishing: GITHUB_RELEASE_GUIDE.md. Backend: SUPABASE_SETUP.md.

## Android permissions

| Permission | Why | When asked |
|---|---|---|
| `INTERNET`, `ACCESS_NETWORK_STATE` | cloud groups, update check, optional AI | never (install-time) |
| `POST_NOTIFICATIONS` (Android 13+) | reminders | when the first reminder is created |
| `RECEIVE_BOOT_COMPLETED` | re-schedule reminders after a restart | install-time |
| `REQUEST_INSTALL_PACKAGES` | install a verified update the user chose | Android asks on first update |
| Camera / photos | attach a bill | by the system picker when used |

Contacts use the system contact picker, so **no contacts permission** is
needed (TD-11).
