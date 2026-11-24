# Family hisab extras (1.3.0, phase 4) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Money out in a Family hisab can carry bill photos or PDFs that every member sees; the AI assistant answers questions about Family hisab; a reminder can be linked to a Family hisab and its notification opens it.

**Architecture:** Bills follow the group-bill pattern: the file goes to a private `family-attachments` bucket at `<family>/<entry>/<file>`, `register_family_attachment` records it and emits an `attachment` event on the family feed, and other phones download on view. The phone's `attachments` table gains `family_entry_id` and `reminders` gains `family_id` (schema v7); `personal_reminders` gains `family_id` (the personal op copies columns by name, so no function change). The assistant's parser learns Family hisab names and people and three new intents answered from the phone's Family hisab data.

**Tech Stack:** Flutter 3.47 / Dart, Riverpod 3, Drift (stepByStep migrations), Supabase (PostgreSQL, Storage), flutter_local_notifications.

**Spec:** `docs/superpowers/specs/2026-11-23-home-budget-design.md` ("Money out … bill photos or PDF (camera, gallery, file)", entries show a bill icon, "AI assistant", "Reminders", Data: private bucket `family-attachments` readable and writable by members); roadmap phase 4.

## Global Constraints

- Every visible text in `l10n/en|gu/*.json` (Family hisab texts in `family.json`, assistant texts in `ai.json`), rebuilt with `dart run tool/build_l10n.dart && flutter gen-l10n`.
- Bills: JPEG, PNG, WebP, HEIC or PDF, at most 10 MB (same as groups); only members read and add them; any member can delete one (it disappears for everyone).
- Bills of a Family hisab never go to the personal bucket; personal bills never go to a Family hisab.
- The assistant computes every number from the phone's data; names are hidden from the optional online model unless the user allowed names (as today).
- A reminder linked to a Family hisab, when its payment is recorded, opens the Family hisab's money-out form (not a personal expense), so nothing is counted twice.
- Server changes only as new migrations, tested with `bash tool/run_supabase_tests.sh`; storage bucket and policies in a migration whose name contains `storage` (the local harness skips those).
- Test/sample names: Hemang, Rahul Patel, Priya Shah; never Asha. Commit the phase locally (no push); then stop and wait for the owner.

## Review Focus

1. A bill added offline to a new money-out entry: it uploads after the entry reaches the account, not before (the server needs the entry). Test in Task 3.
2. A bill another member added arrives on this phone without a file: it opens after downloading, and a deleted one disappears. Test in Task 3.
3. A Family hisab reminder whose Family hisab was later removed from this phone: tapping it does not crash (opens "not found"). Test in Task 4.
4. The assistant asked about a Family hisab person who is also in Khata (same name): a Family hisab question ("put in", "at Home") answers from Family hisab; a Khata question ("owes me") still answers from Khata. Test in Task 5.
5. A Family hisab named like a common word ("Home") must not take over unrelated questions such as "How much did I spend this month?". Test in Task 5.

---

### Task 1: Server — Family hisab bills and reminder link

**Files:**
- Create: `supabase/migrations/20261123000300_family_extras.sql`, `supabase/migrations/20261123000400_family_attachments_storage.sql`, `supabase/tests/60_family_extras_test.sql`
- Modify: `supabase/tests/00_supabase_shim.sql` (a minimal `storage.objects(bucket_id text, name text)` for tests), `tool/run_supabase_tests.sh`

**Interfaces (SQL):**
- `family_attachments(id uuid pk, family_id → family_hisabs cascade, entry_id → family_entries cascade, storage_path text unique, mime_type text, size_bytes int (1–10485760), sha256 text, uploaded_by uuid → auth.users on delete set null, deleted_at, created_at)`; RLS select for `is_family_member(family_id)`; select granted to `authenticated`.
- `family_sync_events.entity_type` check also allows `attachment`.
- `register_family_attachment(p jsonb) returns jsonb` — `{id, family_id, entry_id, storage_path, mime_type, size_bytes, sha256}`; member only (`forbidden`); live entry of that Family hisab (`invalid_entry`); `storage_path = family/entry/<file>` and present in `storage.objects` of bucket `family-attachments` (`invalid_path`); idempotent on `id`; emits `attachment` upsert with the row as payload.
- `delete_family_attachment(p_id uuid) returns void` — member only; sets `deleted_at`; emits `attachment` delete.
- `get_family_snapshot` replaced: also `attachments` (live, of live entries).
- `personal_reminders.family_id uuid` (no foreign key; it only links the user's own reminder).
- Storage migration: bucket `family-attachments` (private, 10 MB, the five mime types); policies select / insert / delete on `storage.objects` for `is_family_member(first folder)`.

- [ ] **Step 1: Failing SQL test** `60_family_extras_test.sql`: A's "Home" with a money-out entry; a fake object row in `storage.objects`; A registers a bill → `applied`, an `attachment` event; registering again → same result, one row; C (outsider) → `forbidden`; a path of another entry → `invalid_path`; an entry of another Family hisab → `invalid_entry`; a path not uploaded → `invalid_path`; the snapshot lists the bill; B (joined member) deletes it → gone from the snapshot, a delete event; C cannot read `family_attachments`; a personal reminder with `family_id` saves and comes back in the personal snapshot.
- [ ] **Step 2:** `bash tool/run_supabase_tests.sh` → fails (`register_family_attachment` missing).
- [ ] **Step 3:** Write both migrations.
- [ ] **Step 4:** `bash tool/run_supabase_tests.sh` → `ALL FAMILY EXTRAS TESTS PASSED`, all earlier suites pass.

---

### Task 2: Phone schema v7 and applying bills from the feed

**Files:**
- Modify: `lib/core/database/tables.dart` (`Attachments.familyEntryId` — nullable text, no foreign key; the check becomes "exactly one of transaction / ledger entry / group expense / family entry"; `Reminders.familyId` — nullable text, no foreign key), `lib/core/database/app_database.dart` (`currentSchemaVersion = 7`, `from6To7` rebuilds `attachments` with the new column and check, adds `reminders.family_id`), generated schema files (`dart run drift_dev make-migrations`), `lib/features/synchronization/domain/cloud_models.dart` (`FamilySnapshot.attachments`), `lib/features/synchronization/data/family_rows.dart` (`apply('attachment', …)`: insert with `storedName: ''`, `originalName: 'bill_<id8>.<ext>'`, `remotePath: storage_path`; deleted → delete the row and its file name is returned for cleanup), `lib/features/synchronization/data/sync_service.dart` (snapshot applies attachments; `forgetFamily` also removes that Family hisab's bills), `test/helpers/fake_family_cloud.dart` (register/delete + snapshot)
- Test: `test/drift/hisabmitra/migration_test.dart` (v6 → v7 keeps existing bills and reminders), `test/core/database/app_database_test.dart` (version 7), `test/features/synchronization/cloud_models_test.dart`

- [ ] **Step 1: Failing tests** — `'v6 to v7 keeps bills and reminders'`; schema version 7; `FamilySnapshot.fromJson` reads `attachments`.
- [ ] **Step 2:** run them → fail.
- [ ] **Step 3:** Implement; generate the v7 schema and step files.
- [ ] **Step 4:** `flutter test test/drift test/core/database test/features/synchronization` → pass.

---

### Task 3: Bills on money out

**Files:**
- Modify: `lib/features/attachments/data/attachment_service.dart` (`AttachmentParent.familyEntry`; commit without a personal upload; `uploadPendingFiles` uploads a family bill only when its entry has `revision > 0`, at `family/entry/storedName`, via `uploadFamilyAttachment`; `ensureLocal` downloads via `downloadFamilyAttachment`; `delete` of a family bill calls `deleteFamilyAttachment` when it was uploaded, otherwise only removes it locally), `lib/features/attachments/presentation/attachments_editor.dart` (parent enum), `lib/features/synchronization/data/cloud_gateway.dart` + Supabase + not-configured + fakes (`uploadFamilyAttachment({storagePath, bytes, mimeType, metadata})`, `downloadFamilyAttachment(String storagePath)`, `deleteFamilyAttachment(String id)`), `lib/features/family/presentation/family_entry_form_screen.dart` (money out: `AttachmentsEditor`, applied after the entry is saved), `lib/features/family/data/family_repository.dart` (`FamilyDetail.billEntryIds`), `lib/features/family/presentation/family_home_screen.dart` (bill icon on entries with bills)
- Test: `test/features/family/family_bills_test.dart` (two phones), `test/widget/family_entries_test.dart` (bill icon)

- [ ] **Step 1: Failing tests** — `'a bill on money out reaches the other member'` (Hemang adds an expense with a bill offline; one sync uploads the entry, the next the file and record; Rahul's phone shows the bill and `ensureLocal` returns its bytes); `'a deleted bill disappears for everyone'`; `'the passbook shows a bill icon on entries with a bill'`.
- [ ] **Step 2:** run both files → fail.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** `flutter test test/features/family test/features/attachments test/widget/family_entries_test.dart` → pass.

---

### Task 4: Reminders linked to a Family hisab

**Files:**
- Modify: `lib/features/reminders/domain/reminder_schedule.dart` (`ReminderDraft.familyId`), `lib/features/reminders/data/reminder_repository.dart` (save it), `lib/features/synchronization/data/personal_outbox.dart` and `personal_rows.dart` (`family_id`), `lib/app/router/routes.dart` (`newReminder(..., familyId)`; `newFamilyEntry(id, kind, {amountPaise, categoryId, note})`), `lib/app/router/app_router.dart`, `lib/features/reminders/presentation/reminders_screens.dart` (form shows "Family hisab: Home"; tile subtitle; `completeReminder`: a Family hisab reminder's "Record as expense" opens that Family hisab's money-out form prefilled and completes only when it was saved), `lib/features/family/presentation/family_entry_form_screen.dart` (prefill; pops with the saved id), `lib/features/family/presentation/family_home_screen.dart` (menu "Add reminder"), `lib/features/reminders/application/notification_service.dart` (payload and tap), new `lib/features/reminders/domain/notification_route.dart` (`String? notificationPayload(ReminderRow r)` → `family:<id>` / `group:<id>` / null; `String? routeForPayload(String? payload)` → `Routes.familyHome(id)` / `Routes.group(id)` / null)
- Test: `test/features/reminders/notification_route_test.dart`, `test/features/synchronization/personal_sync_test.dart` (add: the link reaches the other phone), `test/widget/family_reminder_test.dart`

- [ ] **Step 1: Failing tests** — payload and route both ways (and a removed Family hisab's route still resolves to its page, which shows "not found"); `'a Family hisab reminder keeps its link on the other phone'`; widget: `'a reminder added from the Family hisab is linked to it'` (menu → Add reminder → title "Rent", monthly → the reminders list shows "Home"); `'recording its payment adds money out to the Family hisab'` (Mark paid → Record as expense → the money-out form has ₹15,000 and Rent → Save → Home shows it, the reminder moved to next month, no personal expense).
- [ ] **Step 2:** run them → fail.
- [ ] **Step 3:** Implement (texts in both languages).
- [ ] **Step 4:** `flutter test test/features/reminders test/features/synchronization test/widget/family_reminder_test.dart` → pass.

---

### Task 5: The assistant answers about Family hisab

**Files:**
- Modify: `lib/features/ai_assistant/domain/ai_intent_parser.dart` (`families: List<NamedEntity>`, `familyPeople: List<({String id, String familyId, String name})>`; `AiQuery.familyId`, `AiQuery.familyMemberId`; intents `familySpend`, `familyPersonIn`, `familyBalance`), `lib/features/ai_assistant/domain/local_ai_engine.dart` (`FamilyRepository` dependency; answers; names redacted as "the Family hisab" / "the person" unless names are shared), `lib/features/ai_assistant/application/ai_chat_controller.dart` (provider wiring), `lib/features/ai_assistant/presentation/ai_examples.dart` (section "Family" when there is a Family hisab: `familyName`, `familyPersonName`), `lib/features/ai_assistant/presentation/ai_screens.dart` (pass the newest Family hisab and one of its other people), `l10n/en|gu/ai.json`
- Test: `test/features/ai_assistant/ai_intent_parser_test.dart` (create or extend), `test/features/ai_assistant/local_ai_engine_test.dart`, `test/features/ai_assistant/ai_examples_test.dart`

**Rules (parser, before groups and Khata people):**
- A Family hisab name in the question, or "family" / "પરિવાર" with exactly one Family hisab: balance words (`balance`, `left`, `સિલક`, `બાકી`) → `familyBalance`; a person of it with money-in words (`put in`, `gave`, `contribut`, `salary`, `paid in`, `આપ્યા`, `ફાળો`, `જમા`, `પગાર`) → `familyPersonIn`; otherwise spend words or a category → `familySpend` (with the category); otherwise `familyBalance`.
- No Family hisab named, a Family hisab person named with money-in words → `familyPersonIn` for that person's Family hisab.
- Otherwise as today.

- [ ] **Step 1: Failing tests** — parser: "How much did we spend on groceries at Home this month?" → `familySpend`, Home, groceries; "What did Rahul put in this month?" → `familyPersonIn` (Rahul of Home) even with a Khata person "Rahul Patel"; "How much does Rahul owe me?" → `personBalance`; "What is the Home balance?" → `familyBalance`; "How much did I spend this month?" → `spend`; Gujarati: "આ મહિને ઘરમાં કરિયાણા પર કેટલો ખર્ચ થયો?" with Family hisab "ઘર" → `familySpend`. Engine (Home: start ₹12,000, salary ₹60,000 You, contribution ₹10,000 Rahul, groceries ₹7,500, this month): spend on groceries → "₹7,500.00"; Rahul put in → "₹10,000.00"; balance → closing "₹74,500.00"; the online-model facts hold no names unless shared. Examples: "Family" section with 4 examples, each parses to its intent; counts 22 with names / 15 without.
- [ ] **Step 2:** `flutter test test/features/ai_assistant` → fail.
- [ ] **Step 3:** Implement (texts in both languages).
- [ ] **Step 4:** same command → pass.

---

### Task 6: Whole-phase checks and local commit

- [ ] **Step 1:** `flutter analyze` → `No issues found!`; `dart format --output=none --set-exit-if-changed lib test` → 0; `flutter test` → all pass; `bash tool/run_supabase_tests.sh` → no `FAILED`.
- [ ] **Step 2:** Commit the phase locally ("Family hisab extras (1.3.0, phase 4)…"), no push; stop and wait for the owner.
