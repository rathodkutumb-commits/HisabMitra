# Progress

Last updated: 2026-11-21.

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

### 2026-11-21 (HisabMitra website)

Design `docs/superpowers/specs/2026-11-21-hisabmitra-website-design.md`;
plan `docs/superpowers/plans/2026-11-21-hisabmitra-website.md`.

- New website **https://hisab-mitra-web.vercel.app** (English at `/`,
  Gujarati at `/gu`): every feature, screenshots, colour themes, download
  page with every release and checksum, guide, privacy, and the invitation
  page (`/join?code=…`). Repo `rathodkutumb-commits/HisabMitra-Web`
  (private, Next.js 16 like the Anuvaad site); Vercel project
  `hisab-mitra-web`. **Published only manually from this PC** with the
  Vercel CLI, on the owner's go-ahead (no CI/CD; the GitHub and Vercel
  accounts use different emails).
- Release data is read from this repo's GitHub Releases (cached 5 min);
  `/download/latest` always gives the newest APK, falling back to the
  fixed-name `hisabmitra.apk` that every release now also carries (with its
  own `.sha256`, so installed apps still pair APK and checksum).
- The app's links (share the app, invite link, invite download line, About
  → "HisabMitra website") use `WEBSITE_URL`; GitHub Pages (`site/`) now only
  redirects to the website, keeping `?code=` for links shared from 1.2.0.
- README download and privacy text updated.

### 2026-11-21 (Part C1 and C2: invite link and live updates; v1.2.0)

Design `docs/superpowers/specs/2026-11-20-invite-link-and-live-updates-design.md`;
plan `docs/superpowers/plans/2026-11-20-invite-link-and-live-updates.md`.

- **Invite link:** the shared invitation now says "👉 Tap to join: <link>"
  (English and Gujarati). The link opens a small page on GitHub Pages
  (`site/join.html`, workflow `.github/workflows/pages.yml`) that opens the
  app (`hisabmitra://join?code=…`), shows the code, and offers the download
  for people without the app. In the app the code is kept as a *pending
  invitation* (`groups.pendingInvite`) until the account is ready, then the
  group is joined without a tap; a failure shows the reason with the code
  filled in and is never retried by itself. The Join screen moved to
  `/groups/join` (back returns to the Groups tab).
- **Live updates:** migration `20261120000200_realtime_feeds.sql` publishes
  `sync_events` and `personal_sync_events` to Supabase Realtime (RLS
  applies). While signed in and in the foreground the app listens
  (`LiveSyncController`) and runs its normal sync 1 s after a change; a sync
  asked for during a sync now runs once more afterwards.
- With the owner's go-ahead: GitHub Pages switched on (Source: GitHub
  Actions; `https://rathodkutumb-commits.github.io/HisabMitra/join?code=…`
  serves the page), the migration applied live (7 migrations recorded;
  only the two feeds are published), and **v1.2.0** (`1.2.0+4`) released.
- Not done: a two-phone check of live updates against the live project.

### 2026-11-20 (v1.1.0 released)

- Released **v1.1.0** (`1.1.0+3`) with parts A and B. CI green on `main`;
  the release workflow published `hisabmitra-1.1.0.apk` and its `.sha256`,
  signed with the same certificate as 1.0.x (`37c8f9fd…f9`), so the in-app
  updater installs it over 1.0.1.
- The two Part B migrations were applied to the live Supabase project
  first and verified (RLS, grants, private bucket, two-account check).
- Not done: a full device run of B against the live project (the owner is
  testing on their own phone after updating).

### 2026-11-20 (Part B: personal data in the account)

Design `docs/superpowers/specs/2026-11-20-personal-data-in-supabase-design.md`;
plan `docs/superpowers/plans/2026-11-20-personal-data-in-supabase.md`.
Owner's choices: Supabase is the main copy with a working copy on the phone
(offline works); categories stay on the phone; manual backup/restore kept,
automatic backups removed.

- **Cloud:** `personal_*` tables (owner-only RLS), `apply_personal_op`
  (idempotent, revision-checked, linked deletes mirror the phone, `reset`
  for restore), `personal_sync_events`, `get_personal_snapshot`; private
  `personal-attachments` bucket; `delete-account` removes personal files.
  SQL tests 91/91 (53 old + 38 new).
- **Phone:** schema v4 (upload state on personal tables; sync tables
  scoped `group`/`personal`; inbox key `(scope, seq)`). Every personal write
  queues an upload in the same SQLite transaction; push/pull for both scopes;
  conflicts for personal records; missing custom categories re-created from
  the entry's copy; reminders get their own notification id per phone.
- **Groups** are always saved to the account ("Share to cloud" removed;
  the tour's sample group stays on the phone). Group bills upload
  automatically; bills download on demand.
- **First sync** screen ("Saving your hisab to your account" / "Getting
  your hisab"), sign-out and account deletion clear the phone's copy (with a
  warning about unsent changes), sync switch removed, restore replaces the
  account's personal data (groups untouched), texts and docs rewritten.
- Found and fixed on the way: a one-off read of open conflicts through a
  watched stream could hang a sync while the Sync screen was open.
- Results: `flutter analyze` clean; `flutter test` **407 passing**; format
  clean. Applied to the live Supabase project the same day (see above).

### 2026-11-20 (Part A: fixes and small features; branch `part-a-fixes`, not released)

Owner's test of v1.0.1 found a crash and rough edges. Design:
`docs/superpowers/specs/2026-11-20-fixes-and-small-features-design.md`; plan:
`docs/superpowers/plans/2026-11-20-fixes-and-small-features.md`.

- **Camera/gallery crash fixed.** Root cause (confirmed on the emulator with a
  release build): the attachment thumbnail's loading placeholder was the
  thumbnail itself, so release builds recursed until "Stack overflow" and
  Android closed the app as not responding. Regression test added. A photo
  taken just before Android closes the app is recovered for the next new
  expense.
- **Back button:** Hisab/Khata/Groups/More tabs go to Home; Home, onboarding
  and sign-in ask "Exit HisabMitra?" (Exit / Stay).
- **Floating AI button** on the tabs and list/detail pages (above the page's
  own button; hidden on forms, chat, onboarding, with the keyboard or keypad
  open, or when AI is off). The on-phone assistant is now on by default
  (new settings key, so existing installs get it on once).
- **Reminders on time:** exact alarms (`USE_EXACT_ALARM`), fallback to inexact
  if refused; battery-saving tip with "Open settings" on the Reminders screen.
- **AI examples:** 15 grouped examples plus up to 3 from the user's own people
  and groups, each tested to reach its answer in English and Gujarati.
- **Shared messages:** group invite and share-app texts redesigned (spacing,
  emojis, WhatsApp bold; owner approved); the non-tappable `hisabmitra://`
  link removed until part C adds an https link; captions on report and backup
  shares.
- Results: `flutter analyze` clean; `flutter test` **346 passing**; format
  clean. Release APK on the `test_device` emulator: photo attaches with no
  freeze; back/exit dialog; AI button positions and chat examples; reminder
  registered as an exact alarm (`window=0`), still registered after a reboot
  and after reinstalling the APK, and the notification posted at 10:00:00.072
  for a 10:00 reminder (clock moved forward for the check). Share sheet
  preview not checked on the device (message text covered by tests).

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
| Push notifications (C3) | A Firebase project: `google-services.json` and a service-account key |
| Website release list (optional) | A read-only GitHub token in Vercel, if GitHub starts rate-limiting the site |

## Parked

"Add normal monthly income and expense into a database for every user" —
meaning to be clarified with the owner (recurring entries, budgets or
templates).
