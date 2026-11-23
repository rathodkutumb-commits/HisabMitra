# Family Hisab Core Implementation Plan (phase 2 of 5)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A user can create a Family hisab, add people by name and number, record money in (salary / extra income / contribution) and money out, see a month-by-month passbook and statement (PDF + WhatsApp), and see it combined into the Home screen — saved to their account and working offline.

**Architecture:** New member-based server tables (`family_*`, owner = first member) written only through `apply_family_op`, with a change feed `family_sync_events`; the phone keeps cache tables (schema v6) and syncs them as a third scope `family` beside `group` and `personal`, using the existing outbox/inbox/conflict machinery. Passbook maths is a pure function over entries, so balances are never stored. Sharing with other members (invitations, joining, live updates) is phase 3; bills, AI and reminders are phase 4.

**Tech Stack:** Flutter/Dart, Drift (v6), Riverpod 3, GoRouter, Supabase Postgres (SQL tests in Docker), `pdf` (existing `PdfReportRenderer`), `share_plus`, `url_launcher`.

**Spec:** `docs/superpowers/specs/2026-11-23-home-budget-design.md`; roadmap `docs/superpowers/plans/2026-11-23-family-hisab-roadmap.md`.

## Global Constraints

- Feature name: **Family hisab** / **પરિવારનો હિસાબ**; every visible text in `l10n/en|gu/*.json` (new file `family.json` in both), rebuilt with `dart run tool/build_l10n.dart && flutter gen-l10n`.
- Money in kinds: `salary`, `extra_income`, `contribution`; money out kind `expense`. Amounts are integer paise > 0. Dates are calendar days (`yyyy-MM-dd` on the wire).
- Nothing is split: no shares, no balances between people.
- Passbook: a month's opening = the Family hisab's starting balance + all money in − all money out dated **before** the month; closing = opening + month's in − month's out. Balances are computed, never stored.
- People: name 1–80 characters, mobile number optional (stored as typed, trimmed). The creator is "You" (`isSelf`). Deleting a person keeps their entries; they show as "Name (removed)".
- Money out uses the user's expense categories; each entry stores a snapshot (category id, English name, Gujarati name, icon, colour).
- Home screen: income, expense, savings and the month-by-month chart **add** Family hisab money in/out (all Family hisabs, all people); one line under the figures "Includes Family hisab: in ₹X · out ₹Y" (only when not zero); no separate card. Hisab tab list and Reports stay personal.
- Money in form note: "Money here already counts on your Home screen — don't add your salary again in Hisab."
- Server changes only as new migrations, tested with `bash tool/run_supabase_tests.sh`; applied live at release with the owner's go-ahead.
- Test/sample names: Hemang, Rahul Patel, Priya Shah; never Asha.
- Commit the phase locally when done (no push).

## Review Focus

1. An entry dated in a later month, or before any other entry: every month's opening and closing still add up from the starting balance. Test in Task 3.
2. Changing an entry's date from November to October changes both months and every later opening. Test in Task 3.
3. A removed person's entries still count in totals and statements and show "Name (removed)". Tests in Tasks 3 and 7.
4. A category deleted after use: the entry still shows its snapshot name in both languages. Test in Task 4.
5. The same entry edited on two phones of the same user while offline: a conflict to resolve (keep mine / keep theirs), never a silent overwrite. Test in Task 5.

---

### Task 1: Server — Family hisab tables, writes, snapshot and feed

**Files:**
- Create: `supabase/migrations/20261123000100_family_hisab.sql`, `supabase/tests/40_family_hisab_test.sql`
- Modify: `tool/run_supabase_tests.sh` (run the new test), `supabase/tests/30_realtime_test.sql` (the published feeds become three)

**Interfaces (produces):**
- Tables (RLS on, `select` for active members only via `public.is_family_member(family_id)`; no client writes):
  - `family_hisabs(id uuid pk, name text 1–80, opening_balance_paise bigint not null default 0, owner_id uuid → auth.users on delete set null, revision bigint, last_op_id uuid, deleted_at, created_at, updated_at)`
  - `family_members(id uuid pk, family_id → family_hisabs on delete cascade, user_id uuid null (server-set), name text 1–80, phone text ≤ 20, role text owner/admin/member default member, status text active/removed default active, sort_order int, revision, last_op_id, deleted_at, created_at, updated_at)`
  - `family_entries(id uuid pk, family_id → family_hisabs cascade, member_id → family_members, kind text salary/extra_income/contribution/expense, amount_paise bigint > 0, entry_date date, category_id text ≤ 60, category_name text 1–60, category_name_gu text 1–60, category_icon text ≤ 40, category_color bigint, note text ≤ 200, revision, last_op_id, deleted_at, created_by uuid, created_at, updated_at)`; check: `kind = 'expense'` ⇔ `category_id` and `category_name` not null.
  - `family_sync_events(seq bigserial pk, family_id → cascade, entity_type family/member/entry, entity_id uuid, op_type upsert/delete, revision bigint, payload jsonb, op_id uuid, actor_id uuid, created_at)`; added to `supabase_realtime`.
- `public.is_family_member(uuid)`, `public.is_family_admin(uuid)` (security definer, like the group ones).
- `public.apply_family_op(p_op jsonb) returns jsonb` — op `{op_id, family_id, entity_type, entity_id, op_type, base_revision, payload}`; results as `apply_group_op`: `{"status":"applied","revision":n}`, `{"status":"conflict","revision":n,"current":{…}}`, `{"status":"rejected","code":…}`; idempotent through `processed_ops`; every applied change emits one `family_sync_events` row with the full row as payload. Rules:
  - `family` upsert, base 0: creates the Family hisab and its owner member (payload `owner_member_id`, `owner_display_name`; `user_id = auth.uid()`, role `owner`). Later upserts and `delete`: admins only (`forbidden`).
  - `member` upsert/delete: admins only; cannot delete the owner member (`forbidden`); delete sets `status='removed'`, `deleted_at` and keeps entries.
  - `entry` upsert/delete: any active member; `member_id` must belong to the same Family hisab (`invalid_reference`); invalid fields → `invalid_data`.
  - Not a member → `forbidden`; signed out → `not_authenticated`.
- `public.get_family_snapshot(p_family_id uuid) returns jsonb` `{family, members[], entries[], max_seq}` (live rows; removed members included so old entries keep their names); not a member → error `forbidden`.
- Grants: execute on the two functions to `authenticated` only.

- [ ] **Step 1: Failing SQL test** `40_family_hisab_test.sql` (users A and B from `10_rls_and_rpc_test.sql`): A creates "Home" with owner member and starting balance 1200000 → applied, revision 1, two events (family, member); A adds member "Rahul Patel" (phone `+919800000001`) → applied; A adds a `salary` entry for A's member (6000000, 2026-11-01) and an `expense` entry (750000, category snapshot `Rent`/`ભાડું`) → applied; B reads `family_hisabs` / `family_entries` → 0 rows; B's `apply_family_op` on A's family → `forbidden`; B's `get_family_snapshot` → raises `forbidden`; A's snapshot has 1 family, 2 members, 2 entries and `max_seq` = latest event; an `expense` without a category → `invalid_data`; amount 0 → `invalid_data`; an entry for a member of another Family hisab → `invalid_reference`; a replayed `op_id` returns the first result and emits nothing; an upsert with a stale `base_revision` → `conflict` with `current`; deleting member Rahul keeps his entries (`deleted_at is null` on entries) and his row has `status='removed'`; deleting the owner member → `forbidden`; `30_realtime_test`: three feeds published, no data tables.
- [ ] **Step 2:** `bash tool/run_supabase_tests.sh` → fails (`relation "public.family_hisabs" does not exist`).
- [ ] **Step 3:** Write the migration (follow `apply_group_op`'s structure; header comment).
- [ ] **Step 4:** `bash tool/run_supabase_tests.sh` → no `FAILED`.

---

### Task 2: Phone tables (schema v6) and cloud gateway

**Files:**
- Modify: `lib/core/database/tables.dart`, `lib/core/database/app_database.dart` (v6, `from5To6`, add tables to `@DriftDatabase`), generated files (`build_runner`, `drift_dev make-migrations`), `test/drift/hisabmitra/migration_test.dart`, `test/core/database/app_database_test.dart` (version 6)
- Modify: `lib/features/synchronization/domain/cloud_models.dart` (`OutboundOp` JSON for scope `family`: `family_id` instead of `group_id`; `RemoteEvent.fromJson(…, scope: 'family')` reads `family_id` into `groupId`; `FamilySnapshot`), `lib/features/synchronization/data/cloud_gateway.dart` (+`NotConfigured`), `supabase_cloud_gateway.dart`, `test/helpers/fake_cloud.dart` (+ new `test/helpers/fake_family_cloud.dart`)
- Test: `test/features/synchronization/cloud_models_test.dart` (add)

**Interfaces (produces):**
- Drift tables (with `SyncColumns`: revision, syncState, deletedAt): `FamilyHisabsCache` (`family_hisabs_cache`: id, name, openingBalancePaise int, ownerUserId text?, createdAt, updatedAt), `FamilyMembersCache` (`family_members_cache`: id, familyId, userId?, name, phone?, role text, status text default 'active', isSelf bool, sortOrder int, createdAt, updatedAt), `FamilyEntriesCache` (`family_entries_cache`: id, familyId, memberId, kind text, amountPaise int, entryDate DateTime, categoryId?, categoryName?, categoryNameGu?, categoryIcon?, categoryColor int?, note?, createdAt, updatedAt). Row classes `FamilyRow`, `FamilyMemberRow`, `FamilyEntryRow`.
- `CloudGateway`: `Future<List<RemoteEvent>> pullFamilyEvents({required int afterSeq, int limit = 500})` (from `family_sync_events`), `Future<FamilySnapshot> fetchFamilySnapshot(String familyId)`; `applyOp` routes `scope == 'family'` to `apply_family_op`.
- `FamilySnapshot.fromJson` → `family` (map), `members`, `entries` (lists of maps), `maxSeq`.
- Fake: `FakeFamilyStore` mirroring Task 1's rules (owner creation, admin-only family/member edits, member check, removed members keep entries, revision conflicts, events per change); `FakeCloudServer.family`; `FakeCloudClient` implements the two new methods.

- [ ] **Step 1: Failing tests** — migration `'v5 → v6 adds the Family hisab tables and keeps everything'` (a v5 category and transaction survive; the three new tables exist and are empty); `app_database_test` expects version 6; `cloud_models_test`: a family op's JSON has `family_id` and no `group_id`; a family event JSON with `family_id` gives `groupId == family id` and `scope == 'family'`; `FamilySnapshot.fromJson` reads rows and `max_seq`.
- [ ] **Step 2:** run `flutter test test/drift test/core/database test/features/synchronization/cloud_models_test.dart` → fail.
- [ ] **Step 3:** Implement tables, migration, models, gateway (Supabase: `.from('family_sync_events').select('seq, family_id, entity_type, entity_id, op_type, revision, payload').gt('seq', afterSeq).order('seq').limit(limit)`; `rpc('get_family_snapshot', params: {'p_family_id': id})`), fake store.
- [ ] **Step 4:** same command → pass; `flutter analyze` clean.

---

### Task 3: Passbook maths

**Files:**
- Create: `lib/features/family/domain/family_models.dart`, `lib/features/family/domain/passbook.dart`
- Test: `test/features/family/passbook_test.dart`

**Interfaces (produces):**
- `enum FamilyEntryKind { salary, extraIncome, contribution, expense }` with `wire` (`salary`, `extra_income`, `contribution`, `expense`) and `bool get isMoneyIn`.
- `class FamilyEntry { id, memberId, kind, amountPaise, date, categoryId?, categoryName?, categoryNameGu?, categoryIcon?, categoryColor?, note? }` (from `FamilyEntryRow`).
- `class PersonLine { final String memberId; final int moneyInPaise; final int paidPaise; }`
- `class MonthStatement { final int year, month; final int openingPaise, moneyInPaise, moneyOutPaise; int get closingPaise; final List<FamilyEntry> entries (newest first); final List<PersonLine> byPerson (members with any entry in the month, in member order); }`
- `MonthStatement passbookMonth({required int startingBalancePaise, required List<FamilyEntry> entries, required List<String> memberOrder, required int year, required int month})`
- `List<MonthTotals> familyMonthlyTotals(List<FamilyEntry> entries, {required DateTime from, required int months})` (reuses `MonthTotals` from transactions: money in → income, money out → expense) and `PeriodSummary familyPeriodSummary(List<FamilyEntry> entries, DateRange range)`.

- [ ] **Step 1: Failing tests** (starting balance ₹12,000 = 1200000):
  - `'the first month opens with the starting balance'`: November: salary You 6000000, salary Rahul 3500000, extra You 500000, contribution Rahul 1000000, expenses You 5200000 and Rahul 2650000 → opening 1200000, in 11000000, out 7850000, closing 4350000; byPerson You (6500000, 5200000), Rahul (4500000, 2650000).
  - `'December opens with November's closing'`: one December expense 100000 → opening 4350000, closing 4250000.
  - `'an empty month carries the balance'`: January with no entries → opening = closing = 4250000.
  - `'moving an entry to another month changes both and every later month'`: change You's 5200000 expense to 2026-10-15 → October opening 1200000, in 0, out 5200000, closing −4000000; November opening −4000000, in 11000000, out 2650000, closing 4350000; December opening 4350000 (unchanged).
  - `'entries before every other entry still add up'`: an entry dated 2025-01-01 changes every later opening by its amount.
  - `'a removed person's entries still count'`: byPerson includes a member id not in `memberOrder` (appended last).
  - `familyMonthlyTotals` for Oct–Dec and `familyPeriodSummary` for a range give the same in/out sums as the statements.
- [ ] **Step 2:** `flutter test test/features/family/passbook_test.dart` → fail.
- [ ] **Step 3:** Implement (pure Dart; one pass summing entries before the month, then the month's entries).
- [ ] **Step 4:** same command → pass.

---

### Task 4: Family repository (local writes + outbox)

**Files:**
- Create: `lib/features/family/data/family_repository.dart`
- Test: `test/features/family/family_repository_test.dart`

**Interfaces:**
- Consumes: Task 2 tables, Task 3 models.
- Produces:
  - `class FamilyDraft { String? id; String name; int startingBalancePaise; }`, `class FamilyPersonDraft { String? id; String familyId; String name; String? phone; }`, `class FamilyEntryDraft { String? id; String familyId; String memberId; FamilyEntryKind kind; int amountPaise; DateTime date; String? categoryId; String? note; }`
  - `class FamilyDetail { FamilyRow family; List<FamilyMemberRow> members (removed included, active first by sortOrder); List<FamilyEntry> entries; FamilyMemberRow? get self; String memberName(String id, AppLocalizations l) }` — removed members' names get `l.familyPersonRemoved(name)` ("{name} (removed)").
  - `FamilyRepository(AppDatabase db, Clock clock, IdGenerator ids, {required String? Function() currentUserId})` with: `Future<String> createFamily(FamilyDraft d, {required String selfName, List<FamilyPersonDraft> people = const []})`, `Future<void> updateFamily(FamilyDraft d)`, `Future<void> deleteFamily(String id)`, `Future<String> savePerson(FamilyPersonDraft d)`, `Future<void> deletePerson(String id)`, `Future<String> saveEntry(FamilyEntryDraft d)`, `Future<void> deleteEntry(String id)`, `Stream<List<FamilyRow>> watchFamilies()`, `Stream<FamilyDetail?> watchFamily(String id)`, `Stream<MonthStatement> watchMonth(String id, int year, int month)`, `Stream<PeriodSummary> watchSummary(DateRange range)` (all Family hisabs), `Stream<List<MonthTotals>> watchMonthly({required DateTime from, required int months})`.
  - Every write runs in one Drift transaction with its outbox op (scope `family`, `groupId` = family id, entity types `family` / `member` / `entry`, base revision from the row); `createFamily` queues the family op (payload with `owner_member_id`, `owner_display_name`, `name`, `opening_balance_paise`) then one op per person. Validation failures throw `ValidationFailure` (`required`, `amount`, `category`).
  - Providers: `familyRepositoryProvider`, `familiesProvider`, `familyDetailProvider(id)`, `familyMonthProvider((id, year, month))`, `familySummaryProvider(range)`, `familyMonthlyProvider`.

- [ ] **Step 1: Failing tests** — `'creating a Family hisab adds You and queues it'` (members: You (isSelf, role owner) + Rahul Patel with phone; outbox has family op then member op, scope `family`); `'an expense keeps its category in both languages'` (category Pooja/પૂજા; after deleting the category the entry still has the names); `'an expense needs a category and money needs an amount'` (ValidationFailure); `'deleting a person keeps their entries'` (person status removed, entry still listed, `memberName` = "Rahul Patel (removed)"); `'watchMonth follows edits'` (stream emits new closing after saveEntry/deleteEntry); `'the summary adds every Family hisab'` (two Family hisabs in one range).
- [ ] **Step 2:** `flutter test test/features/family/family_repository_test.dart` → fail.
- [ ] **Step 3:** Implement (pattern: `GroupRepository._enqueue`).
- [ ] **Step 4:** same command → pass.

---

### Task 5: Sync for scope `family`

**Files:**
- Create: `lib/features/synchronization/data/family_rows.dart` (applies remote rows to the cache tables)
- Modify: `lib/features/synchronization/data/sync_service.dart` (push routing/applied/conflict for `family`, `pullFamily()` with cursor key `sync.familyCursor`, called from `syncOnce` after `pullPersonal`; `loadFamilySnapshot(String id)`), `lib/features/synchronization/data/local_data_wiper.dart` (sign-out clears the three tables and the family cursor), `lib/features/backup/...restore_sync.dart` (restore leaves Family hisab tables and their outbox ops untouched), conflict screen labels for family entities
- Test: `test/features/family/family_sync_test.dart`, `test/features/synchronization/local_data_wiper_test.dart` (add)

**Interfaces:**
- Consumes: Task 2 gateway, Task 4 repository.
- Produces: `SyncService.pullFamily()`, `SyncService.loadFamilySnapshot(String familyId)` (phase 3 uses it after joining).

- [ ] **Step 1: Failing tests** (two phones of `hemang`, fake cloud) — `'a Family hisab made on one phone appears on the other'` (family, members, entries, statement totals equal); `'entries added offline upload later'`; `'a deleted entry disappears on the other phone'`; `'the same entry edited on both phones offline becomes a conflict'` (conflict row scope `family`; keep theirs → phone 1 shows phone 2's amount); `'signing out removes Family hisab from the phone'` (wiper test); `'restoring a backup leaves Family hisab as it is'`.
- [ ] **Step 2:** `flutter test test/features/family/family_sync_test.dart test/features/synchronization` → fail.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** same command → pass.

---

### Task 6: Screens — list, create, people, entry points

**Files:**
- Create: `lib/features/family/presentation/family_list_screen.dart`, `family_form_screen.dart`, `family_people_screen.dart`, `l10n/en/family.json`, `l10n/gu/family.json`
- Modify: `lib/app/router/routes.dart` (`family = '/family'`, `newFamily = '/family/new'`, `familyHome(id)`, `familyPeople(id)`, `newFamilyEntry(id, {required String kind})`, `editFamilyEntry(id, entryId)`, `familyStatement(id, {required int year, required int month})`), `lib/app/router/app_router.dart`, `lib/features/dashboard/presentation/dashboard_screen.dart` (first quick action "Family hisab"), `lib/features/transactions/presentation/transactions_screen.dart` (app-bar button "Family"), `lib/features/settings/presentation/more_screen.dart` (top item)
- Test: `test/widget/family_setup_test.dart`

**Behaviour:** `/family` lists Family hisabs; with exactly one it opens it directly (replace); with none it shows an empty state with "Create Family hisab". Create form: name (required), starting balance (optional amount), people (add rows: name + optional number; "From contacts" uses the existing contact picker). People screen: list (You first, removed people hidden behind "Show removed"), add, rename/number edit, delete (confirm: "Their entries stay").

- [ ] **Step 1: Failing widget tests** — `'the Home quick action opens Family hisab setup and creates one'` (tap "Family hisab" on Home → empty state → create "Home" with Rahul Patel +919800000001 → the Family hisab screen shows "Home"); `'with one Family hisab, the Hisab tab button opens it directly'`; `'a person can be renamed and deleted, keeping entries'`.
- [ ] **Step 2:** `flutter test test/widget/family_setup_test.dart` → fail.
- [ ] **Step 3:** Implement screens, routes, entry points, texts (both languages).
- [ ] **Step 4:** same command → pass; `flutter test test/widget` → pass.

---

### Task 7: Family hisab screen and money forms

**Files:**
- Create: `lib/features/family/presentation/family_home_screen.dart`, `family_entry_form_screen.dart`
- Test: `test/widget/family_entries_test.dart`

**Behaviour:** month switcher (‹ November 2026 ›, starts at the current month); passbook card (opening, money in, money out, closing); the month's entries newest first (person, kind or category name in the app's language, amount; removed people "(removed)"); buttons "Money in" and "Money out"; tap an entry to edit, delete from the form. Money in form: person, kind (Salary / Extra income / Contribution), amount, date, note, and the double-counting note. Money out form: amount, category (expense categories picker), paid by, date, note. App bar: "Statement", "People".

- [ ] **Step 1: Failing widget tests** — `'money in and out update the passbook'` (starting ₹12,000; add salary ₹60,000 for You, expense Rent ₹7,500 paid by Rahul → card shows opening ₹12,000, in ₹60,000, out ₹7,500, closing ₹64,500); `'the month switcher carries the balance'` (next month opening ₹64,500); `'the money in form warns about double counting'`; `'a removed person's entry shows (removed)'`; Gujarati: the card labels and a category name in Gujarati.
- [ ] **Step 2:** `flutter test test/widget/family_entries_test.dart` → fail.
- [ ] **Step 3:** Implement (reuse `AmountField`, date and category pickers, `GujaratiTextField` for notes).
- [ ] **Step 4:** same command → pass.

---

### Task 8: Statement, PDF and WhatsApp

**Files:**
- Create: `lib/features/family/presentation/family_statement_screen.dart`, `lib/features/family/data/family_statement_export.dart`
- Test: `test/features/family/family_statement_text_test.dart`, `test/widget/family_statement_test.dart`

**Interfaces:**
- `String familyStatementText(AppLocalizations l, Formatters fmt, {required String familyName, required MonthStatement s, required String Function(String memberId) name})` — WhatsApp text with *bold* headers: title "🏠 *Home — November 2026*", opening, money in total, money out total, closing, then "By person" lines.
- `Future<File> familyStatementPdf(...)` using `PdfReportRenderer` (Gujarati-safe), with the full statement (money in lines by person and kind, money out by category, by-person table).
- WhatsApp per person: `https://wa.me/<digits>?text=<encoded text>` via `launchUrl` (external), digits = the number without spaces/`+`; Indian 10-digit numbers get `91` prepended.

- [ ] **Step 1: Failing tests** — text in English and Gujarati (exact lines for the Task 3 fixture: "Opening balance: ₹12,000.00", "Money in: ₹1,10,000.00", "Money out: ₹78,500.00", "Closing balance: ₹43,500.00", "You — in ₹65,000.00 · paid ₹52,000.00"); `waMeUrl('+91 98000 00001', text)` → `https://wa.me/919800000001?text=…`, `waMeUrl('9800000001', …)` → `…/919800000001?…`; widget: the statement screen shows the same totals and a WhatsApp button only for people with a number.
- [ ] **Step 2:** run both files → fail.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** run both files → pass.

---

### Task 9: Home screen combined

**Files:**
- Modify: `lib/features/dashboard/presentation/dashboard_screen.dart` (summary hero and monthly chart use combined providers; "includes" line), `lib/features/family/data/family_repository.dart` (providers if not yet), new `lib/features/dashboard/application/combined_totals.dart`
- Test: `test/widget/dashboard_family_test.dart`, `test/features/dashboard/combined_totals_test.dart`

**Interfaces:**
- `final combinedSummaryProvider = StreamProvider.family<(PeriodSummary total, PeriodSummary family), DateRange>(…)` — total = personal + family.
- `final combinedMonthlyProvider = StreamProvider<List<MonthTotals>>(…)` — same months as today's chart, income/expense summed.

- [ ] **Step 1: Failing tests** — unit: personal (income ₹50,000, expense ₹20,000) + family (in ₹1,10,000, out ₹78,500) → total income ₹1,60,000, expense ₹98,500, savings ₹61,500; widget: the Home screen shows those figures and "Includes Family hisab: in ₹1,10,000.00 · out ₹78,500.00"; with no Family hisab the line is absent; the chart's bars for the month use the combined numbers (check the chart's data via its widget).
- [ ] **Step 2:** run → fail.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** run → pass.

---

### Task 10: Whole-phase checks and local commit

- [ ] **Step 1:** `flutter analyze` → `No issues found!`; `dart format --output=none --set-exit-if-changed lib test` → 0; `flutter test` → all pass; `bash tool/run_supabase_tests.sh` → no `FAILED`.
- [ ] **Step 2:** Commit the phase locally ("Family hisab (1.3.0, phase 2)…"), no push.
