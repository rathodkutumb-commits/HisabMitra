# HisabMitra — Implementation Plan

The workspace is empty, so the plan builds bottom-up. Phases follow the master prompt (§34) with one re-ordering, noted below. A phase is "done" only after `dart format .`, `flutter analyze` (no errors/warnings) and `flutter test` pass.

| Phase | Scope | Key outputs |
|---|---|---|
| 1. Foundation | `flutter create`, dependencies, folder structure, theme system (3 modes), brand palette + pattern painters, logo painter + launcher icons + splash, fonts, en/gu localisation, GoRouter shell, onboarding (splash, language, intro), settings controller | Running app shell in both themes and languages |
| 2. Local database | Drift schema v1 (all local tables incl. sync tables), DAOs/repositories, seed default categories, migration strategy + schema-dump tests | `AppDatabase`, repository tests |
| 3. Personal finance | Money parsing/formatting, categories CRUD (icon/colour, safe delete with reassignment), transactions CRUD/search/filter, dashboard (real data, period switch, chart), calculator | Domain tests, widget tests |
| 4. People & ledger | People directory (manual + system contact picker), ledger entries, partial repayments, over-payment guard, person balances & ledger screens | Ledger domain tests |
| 5. Groups | Groups, members, expenses, 5 split methods + participant selection, split preview, balances, settlement suggestions, settlements (full/partial), spreadsheet/card/timeline views, filters | Split + settlement tests |
| 6. Reports & attachments | Reports (monthly, category, payment-method, person, group, settlement), charts, CSV/PDF export + share, attachments (camera, gallery, PDF, preview, delete) | Report service tests |
| 7. Reminders, backup, settings *(moved earlier)* | Local notifications & reminders, backup/restore with checksums + encryption, full settings | Backup round-trip tests |
| 8. Supabase cloud | SQL migrations, RLS, RPCs, invitations, Edge Function, phone OTP auth screens, profile | SQL/RLS tests in PostgreSQL container |
| 9. Sync | Outbox/inbox, `SyncService`, retry/backoff, conflicts UI, sync status screen | Sync tests with in-memory remote |
| 10. AI & Gujarati input | Deterministic AI tools + chat UI, optional provider, transliteration engine + keypad | Transliteration + intent tests |
| 11. Release | Android signing config, GitHub Actions, update checker with SHA-256, integration tests on emulator, release docs, completion report | APK build |

**Re-ordering note:** Reminders/backup/settings (prompt phase 10) are moved before cloud work because they are local-only and have no external dependencies, while cloud phases are blocked on configuration that only the project owner can supply.

## Definition of done per feature

1. Domain rules unit-tested.
2. Repository operations tested against an in-memory Drift DB.
3. Screen wired to real data with loading / empty / error states.
4. All strings localised (en + gu).
5. Docs (`SCREEN_INVENTORY.md`, `DATABASE_SCHEMA.md`, …) updated.

## Status (2026-11-19)

Phases 1–10 are implemented and tested; phase 11 has CI, the release
workflow and device tests, and waits on the release keystore and GitHub
repository. Cloud phases are complete in code and blocked only on
external configuration. Current status and blockers: PROGRESS.md. The
owner's 2026-11-19 requests (5 palettes, one-page Gujarati keypad,
Excel-like sheet) were done in the order themes → keyboard → sheet →
device tests + workflows → docs → emulator check.
