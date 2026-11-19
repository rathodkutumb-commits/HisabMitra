# Testing Strategy

No test uses production credentials or real user data. Databases are
in-memory or throw-away files; the cloud is a fake `CloudGateway` or a
throw-away PostgreSQL container.

## Commands

```bash
dart format --output=none --set-exit-if-changed lib test tool integration_test
flutter analyze
flutter test                                    # unit, database, widget, app flows
flutter test integration_test -d <device-id> --concurrency=1 # same app flows + device-only tests on Android
bash tool/run_supabase_tests.sh                 # cloud schema, RLS and RPCs (Docker)
```

CI (`.github/workflows/ci.yml`) runs the format check, generated-code
check, analyzer, `flutter test` and the Supabase SQL tests on every push and
pull request.

## Layers

| Layer | Where | Covers |
|---|---|---|
| Unit — money & domain | `test/core/money`, `test/features/*/domain`-style tests | paise parsing/formatting, Indian grouping, split methods + remainder distribution, percentages, ratios, group net balances, settlement suggestions, ledger balances, partial repayments, over-repayment guard, calculator precision, date ranges, phone validation, transliteration, keypad suggestions, recurring schedules, transactions sheet running balance |
| Database | `test/core/database`, repository tests, `test/drift/hisabmitra/migration_test.dart` | insert/update/delete, FK behaviour (restrict / cascade / set null), transactions, category reassignment, v1 → v2 migration keeps data, schema matches the exported snapshots |
| Services | backup, reports, CSV, PDF renderer, update checker, reminders, sync | backup round trip / tamper / password; report figures; CSV quoting + BOM; PDF pages; SHA-256 parsing; reminder scheduling; outbox/inbox, retries, idempotency, conflicts, tombstones, multi-device |
| Widget | `test/features/gujarati_input/gujarati_keypad_test.dart` | keypad barakhadi, vowels, half letters, backspace, symbols, cursor |
| App flows | `test/widget/app_flow_test.dart` (real router, theme, l10n, in-memory DB) | onboarding in Gujarati, add expense updates dashboard, validation, create group + equal split + balances, Gujarati settings, palette applied and light, Excel-like sheet, keypad typing પુણ્ય into an expense |
| On device | `integration_test/app_flows_test.dart`, `integration_test/device_backup_test.dart` | all app flows on Android with real rendering and Gujarati shaping; encrypted backup + restore in app-private storage at full PBKDF2 strength |
| Cloud security | `supabase/tests/10_rls_and_rpc_test.sql` | RLS isolation, no direct writes, anon locked out, revisions, idempotency, invitations, account deletion (48 checks) |

## Results (2026-11-19)

| Suite | Result |
|---|---|
| `flutter analyze` | no issues |
| `flutter test` | see PROGRESS.md for the latest count |
| Integration tests on emulator (`test_device`, Android, `--concurrency=1`) | 10/10 passing — 8 app flows + 2 backup tests (encrypted backup ≈ 2.0 s, inspect + restore ≈ 1.6 s at 210 000 PBKDF2 iterations) |
| Supabase SQL tests | 48/48 passing (last run 2026-11-18; migrations unchanged since) |

Run device tests with `--concurrency=1`: with several files Flutter
installs the next file's app while the previous one is still running on
the same device, which kills it mid-test.

Screenshots of key screens: `flutter drive -d <device>
--driver=screenshots/driver.dart --target=screenshots/app_screenshots_test.dart`
(PNG files in `build/screenshots/`).

## Not automated (manual checks)

- Phone OTP against the live project — blocked until the phone provider or
  test numbers are configured.
- Camera, gallery and PDF pickers, Android contact picker, notifications
  firing at the scheduled time, APK install from the update checker.
- Edge Function `delete-account` (Deno runtime not available locally).
