# HisabMitra — Project Analysis

_Original analysis: 2026-11-18 (green-field). Re-inspection: 2026-11-19._

## 0. Re-inspection 2026-11-19

The project moved to `d:\Hemang\Work\Mine\HisabMitra`. State found:
all 45 screens routed and working on real data, analyzer clean, 268 tests
passing, live Supabase project migrated (11 tables, RLS on all). Gaps
found: owner's new 5-palette theme set (Rann Utsav default) not
implemented; Gujarati keypad needed page switching for matras; no
personal Excel-like view; no `integration_test/`, no CI/release workflows;
18 of 22 required docs missing; Supabase publishable key empty locally,
phone provider off, `delete-account` not deployed. All code gaps were
closed the same day — see PROGRESS.md.

The sections below are the original green-field analysis.

## 1. Workspace inspection result

| Item | Finding |
|---|---|
| Existing Flutter project | **None.** `d:\Hemang\Demo\HisabMitra` was an empty directory. |
| Existing source code | None |
| Project documentation | None (no HTML, Markdown, diagrams) |
| Functional requirements | Only the master development prompt supplied in the conversation |
| UI reference images | **Not supplied.** The prompt refers to "Gujarati cultural UI reference images", but none exist in the workspace. |
| Architecture / database / API diagrams | None |
| Brand assets / logos | None |
| Configuration files | None |
| Tests | None |
| Git repository | Not initialised |

**Conclusion:** this is a green-field build. The master prompt is the single source of functional and architectural requirements. All design direction is derived from its written description (palette, theme names, cultural motifs).

## 2. Development environment

| Tool | Version | Use |
|---|---|---|
| Flutter | 3.47.9 (stable) | App framework |
| Dart | 3.13.7 | Language |
| JDK | Temurin 21.0.12 | Android/Gradle builds |
| Android SDK | platforms 35, 36, 37; build-tools 34–37 | Android target |
| Android emulator | AVDs `test_device`, `gallop_tablet` | Integration tests |
| Docker | 29.4.3 | Disposable PostgreSQL to execute Supabase schema + RLS tests |
| PostgreSQL client | 18 (`psql`) | Running SQL test scripts |
| Node.js | present | Not required by the app |
| Supabase CLI / Deno | **Not installed** | Edge Functions cannot be executed locally; they are written and type-reviewed only |

## 3. Current technology stack

Nothing exists yet; the approved stack from the prompt is adopted unchanged:
Flutter + Dart, Riverpod, GoRouter, Material 3, Drift/SQLite, Supabase (Auth, Postgres, RLS, Storage, Edge Functions).

## 4. Existing functionality

None.

## 5. Missing functionality

Everything in the prompt (sections 3–28). See `IMPLEMENTATION_PLAN.md` for the phase breakdown and `SCREEN_INVENTORY.md` for per-screen status (kept up to date as work proceeds).

## 6. Database status

No local or cloud database exists. To be created:
- Local: Drift/SQLite schema v1 (see `DATABASE_SCHEMA.md` once written).
- Cloud: Supabase SQL migrations under `supabase/migrations/`.

## 7. Backend integration status

- No Supabase project, URL, anon key, or SMS provider is available. **Cloud features will be built against an isolated interface and configured through `--dart-define` values.** When the values are absent the app runs fully offline and the cloud features show a "cloud not configured" state; they are never faked.
- Phone OTP requires an SMS provider (Twilio / MessageBird / Vonage / TextLocal) configured in the Supabase dashboard. This has per-SMS cost — documented in `SUPABASE_SETUP.md`.

## 8. UI implementation status

None. Design system to be built from the textual brief (Theme A light "Gujarati Modern Heritage", Theme B dark "Traditional Gujarati Heritage", Theme C system).

## 9. Security gaps (to be addressed by design)

| Risk | Mitigation planned |
|---|---|
| Service-role key leakage | Only the anon key is ever read by the app; service-role used only inside Edge Functions (server env). |
| Private financial data leaking to cloud | Personal tables have **no cloud counterpart**; only group tables sync, and only for groups the user explicitly shares. |
| Unauthorised group access | RLS on every exposed table; membership via SECURITY DEFINER helper; invitations validated server-side by RPC. |
| Session token theft | Supabase session persisted in `flutter_secure_storage` (Android Keystore-backed). |
| AI data exposure | AI is opt-in; online provider receives only aggregated, minimised figures after explicit consent. |
| Backup exposure | Backups in app-private storage; optional AES-256-GCM encryption with PBKDF2 key derivation; password never stored. |
| Logging sensitive data | Central logger that never logs OTPs, tokens, amounts, or attachment contents. |
| Keystore in VCS | `.gitignore` for `key.properties`, `*.jks`; CI uses GitHub secrets. |

## 10. Testing gaps

No tests exist. Planned: unit (money, splits, balances, ledger, settlements, transliteration, formatting), Drift database + migration tests, widget tests (themes, localisation, forms), integration tests on emulator, SQL RLS tests against a PostgreSQL container.

## 11. Technical risks & unresolved decisions

| # | Risk / decision | Handling |
|---|---|---|
| R1 | No UI reference images | Design derived from the written brief; documented in `UI_DESIGN_SYSTEM.md`. |
| R2 | No Supabase credentials / SMS provider | Isolated `CloudGateway` interface; documented setup; features honestly marked "blocked by external configuration". |
| R3 | Gujarati glyph shaping in PDF (the `pdf` package does not perform Indic OpenType shaping) | Render report pages with Flutter's own text engine (HarfBuzz) to raster images, then embed in PDF. See `TECHNICAL_DECISIONS.md` TD-09. |
| R4 | Gujarati typing without a system IME | In-app phonetic transliteration engine (syllable-based, not char replacement) + on-screen Gujarati keypad; the system keyboard always remains available. |
| R5 | AI provider requires a paid API key | Optional, opt-in, user-supplied key; local deterministic assistant works without any network. |
| R6 | Edge Functions cannot be run locally (no Deno/Supabase CLI) | Prefer Postgres RPC (tested in container); only account deletion needs an Edge Function. |
| R7 | Background scheduled backups on Android (Doze/WorkManager complexity) | Due-check on app launch/resume; documented limitation. |
| R8 | GitHub owner/repo for releases unknown | Configurable via `--dart-define`; update checker disabled when not configured. |
| R9 | Login vs offline-first conflict (prompt flow says OTP → dashboard, but core features must work offline) | **Assumption:** sign-in is optional. Users can start locally; phone OTP is required only for cloud group sharing. Documented in `AUTHENTICATION_FLOW.md`. |
