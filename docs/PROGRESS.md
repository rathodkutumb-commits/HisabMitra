# Progress

Last updated: 2026-11-19.

## Status by phase

| Phase | Status | Notes |
|---|---|---|
| 1. Foundation | Done | Riverpod, GoRouter, 5 palettes (light-only), en/gu, fonts, logo, splash, onboarding |
| 2. Local database | Done | Drift schema v2, 18 tables, migrations + migration tests, generated schema doc |
| 3. Personal finance | Done | Dashboard, categories, income/expense CRUD, search, filters, export, calculator, Excel-like sheet view |
| 4. People & ledger | Done | People (manual + system contact picker), given/taken, partial repayments, over-payment guard, person ledger |
| 5. Groups | Done | 5 split methods + participant selection + preview, balances, suggestions, full/partial settlements, sheet / cards / timeline views, filters |
| 6. Reports & attachments | Done | Monthly, category, payment method, person, group, settlement reports; charts; PDF (Gujarati-safe) and CSV; camera/gallery/PDF attachments |
| 7. Reminders, backup, settings | Done | Reminders + recurring payments, notifications, encrypted backup/restore, automatic backups, full settings |
| 8. Supabase cloud + account | Done, partly blocked | Schema, RLS, RPCs, invitations, storage, Edge Function written and tested; live DB migrated (4 migrations). Compulsory email-verified account. Needs custom SMTP + redirect URL; Edge Function not deployed |
| 9. Sync | Done, blocked end-to-end | Outbox/inbox, retries, idempotency, conflicts UI; tested with a fake cloud. Needs sign-in to run live |
| 10. AI & Gujarati input | Done | Local deterministic assistant, optional Claude rephrasing; transliteration; one-page keypad with barakhadi rows |
| 11. Testing & release | Mostly done | CI + release workflows, device tests; release keystore and GitHub repo not created yet |

## Session log

### 2026-11-19 (v1.0.1)

- Released **v1.0.1** (`1.0.1+2`) with the keypad and page-transition fixes.
  Published by the release workflow, signed with the same key as v1.0.0
  (certificate SHA-256 `37c8f9fd…f9`), so it installs over 1.0.0 through
  the in-app updater.

### 2026-11-19 (README and emulator fixes)

- README rewritten for the public repo with nine screenshots of the main
  screens (captured on the emulator by `screenshots/app_screenshots_test.dart`
  with the tour's sample data).
- **Found on the emulator and fixed:** (1) opening a page after visiting
  several tabs raised "multiple heroes share the same tag" — every floating
  button now has its own hero tag (regression test added); (2) with the
  Gujarati keypad open, a field low on the form stayed hidden behind the
  keypad — the field now reserves the keypad's height and scrolls above it
  (test checks the field is visible above the keypad).

### 2026-11-19 (release)

- Code pushed to `rathodkutumb-commits/HisabMitra` (public). CI green on
  GitHub (format, generated code, analyzer, tests, 53 SQL checks).
- Release keystore created (`D:\Hemang\Keys\HisabMitra\`), local
  release builds signed with it, six repository secrets set.
- Tag `v1.0.0` pushed → `Release APK` workflow publishes the signed APK and
  its `.sha256` for in-app updates.
- Supabase: custom SMTP (Gmail), code email template and redirect URL
  configured by the owner.

### 2026-11-19 (afternoon)

- **Compulsory account, verified by email** (owner decision): name, email
  and mobile number required at first launch; email verified by code or
  link (`hisabmitra://login-callback`); phone stored, not SMS-verified.
  Router guard for new installs, existing installs, sign-out and lost
  sessions. Local DB schema v3 (`local_user_profile.email`) with migration
  test; cloud migration `20261119000000_profile_phone` tested (53/53 SQL
  checks) and **applied to the live project**.
- **Guided tour with sample data**: offered after the first sign-up and from
  More → App tour; 7 spotlight steps + finish card; sample data in the app
  language; safe removal (keeps anything the user used). Demo data and test
  fixtures use the owner's name, Hemang.
- **In-app updates** pointed at `rathodkutumb-commits/HisabMitra`
  (local `dart_defines.json`; the release workflow sets it on GitHub).
- Background sync after sign-up no longer blocks the verify screen; the sync
  controller is safe if the app shuts down mid-sync.
- Results: `flutter analyze` clean; `flutter test` **312 passing** (313 after the README fixes); SQL
  53/53. Device tests not re-run after these changes (emulator was closed;
  last device run: 10/10 before the account and tour work).

### 2026-11-19

- Re-inspected the project (moved from `d:\Hemang\Demo\HisabMitra`): analyzer
  clean, 268 tests passing, live Supabase matches the migrations.
- **Themes:** replaced the 7-palette set with the owner's 5 —
  Rann Utsav (new, default), Neel Gagan, Bandhani Lal, Kesariyo, Patola
  Rani; removed palettes migrate to Rann Utsav; launcher icon, splash and
  logos regenerated in Rann Utsav; `accentInk` for readable status labels.
- **Gujarati keypad:** one page; two context rows with the barakhadi after
  a consonant (incl. ક્ and ક્ર) or the vowels otherwise; half letters in
  two taps (પુણ્ય, હર્ષ); vowel key for ગઈ; digits/symbols page; hold
  backspace; field scrolls above the keypad.
- **Excel-like sheet** for personal transactions with running balance and
  totals; list/sheet choice remembered.
- **Device tests** (`integration_test/`) and **GitHub Actions** CI + signed
  release workflow.
- **Docs:** 18 missing documents written; schema doc generated from Drift.
- Removed the unused `Routes.ledgerOverview`; root `.gitignore` now ignores
  keystores.
- **Found on the emulator and fixed:** the empty state on a new group's
  screen overflowed on shorter screens — `EmptyState` now scrolls when space
  is short (regression test added). Test harness now always unmounts the
  app after a failing test (a failure used to hang the remaining device
  tests).
- Results: `flutter analyze` clean; `flutter test` 287 passing; device tests
  10/10 passing on the `test_device` emulator.
- Supabase: publishable key stored locally (git-ignored); verified
  phone provider is off and `delete-account` is not deployed.

### 2026-11-18

Palettes (7, light-only), widget test fixes, live Supabase set-up
(migrations applied), recurring payments (schema v2).

## Blocked by external configuration

| Item | Needed from the owner |
|---|---|
| Email verification | Done by the owner (SMTP, template, redirect URL). Confirm the Magic Link template also contains `{{ .Token }}`. |
| Cloud account deletion | Deploy `delete-account` (`supabase functions deploy delete-account`) or provide an access token |
| Privacy policy / terms links | Public URLs |
| Security | Reset the Supabase database password (shared in chat) |

## Parked

"Add normal monthly income and expense into a database for every user" —
meaning to be clarified with the owner (recurring entries, budgets or
templates).
