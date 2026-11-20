# Part B — Personal Data in Supabase Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every personal record (people, entries, khata, repayments, reminders, bills) and every group is saved in Supabase under the user's account, with a working copy on the phone that works offline; categories stay phone-only.

**Architecture:** The phone keeps its Drift database as a cache. Every personal write also queues an outbox operation (scope `personal`) in the same SQLite transaction, exactly like shared groups today. `SyncService` pushes queued ops to a new `apply_personal_op` RPC (idempotent, revision-checked) and pulls a per-user change feed (`personal_sync_events`), or a snapshot on a fresh phone. Files go to a private `personal-attachments` bucket (group bills to the existing `group-attachments` bucket).

**Tech Stack:** Flutter 3.47.9 / Dart, Drift (SQLite, schema v3 → v4), Riverpod 3, Supabase (Postgres + RLS + RPC + Storage), `supabase_flutter`.

**Spec:** `docs/superpowers/specs/2026-11-20-personal-data-in-supabase-design.md`

## Global Constraints

- Builds on Part A's uncommitted work on branch `part-a-fixes` (owner's default); B's work stays uncommitted unless the owner approves commits. Never push.
- Money is integer paise; amount checks `> 0 and <= 99999999999` (same as group tables).
- RLS on every new table; clients only SELECT their own rows (`owner_id = auth.uid()`); all writes through SECURITY DEFINER functions with `set search_path = ''`; no direct insert/update/delete grants (match `20261118000200_lock_down_api_surface.sql`).
- Financial records are never resolved by "last write wins": a revision mismatch is a conflict the user resolves (Keep mine / Keep theirs).
- An op is "synced" only after the server answers `applied`.
- Sample (tour) data never reaches Supabase.
- Categories never reach Supabase as their own rows; entries carry a category snapshot (`category_name`, `category_system_key`, `category_icon`, `category_color`). Built-in category ids are `cat_<systemKey>` on every phone.
- Builds without a Supabase configuration keep working fully offline (ops queue, nothing pushes).
- Every visible string in English and Gujarati via `l10n/en|gu/*.json` → `dart run tool/build_l10n.dart && flutter gen-l10n`.
- Drift schema change: bump `currentSchemaVersion`, add the step, `dart run build_runner build --delete-conflicting-outputs`, `dart run drift_dev make-migrations`, `dart run tool/gen_database_schema_doc.dart`.
- SQL tests run with `bash tool/run_supabase_tests.sh` (Docker). Migrations whose file name contains `storage` are skipped there (no Storage schema in plain Postgres).
- Applying migrations to the live project needs the owner's database password or access token at that moment — never written to any file.
- Done = format clean, `flutter analyze` clean, `flutter test` all passing, SQL tests passing.

## Review Focus

1. A pulled entry references a person that arrives later in the same pull (ordering) → it must still apply (retry after the batch), not be dropped. (Task 7 test)
2. The user edits an entry while its first upload is still queued, then goes offline for days → one consistent row in Supabase, no duplicate, no conflict with itself. (Task 7 test)
3. Sign-out while offline with unsent changes, choosing "Sign out anyway" → the phone's copy is wiped and nothing crashes on next sign-in. (Task 11 test)
4. A restore interrupted after the reset was sent but before all uploads → next sync continues the uploads; nothing from before the restore reappears. (Task 12 test)
5. A bill whose file upload keeps failing (e.g. file deleted from disk) → the record still syncs without the file and the queue is not blocked forever. (Task 9 test)

---

### Task 1: Cloud tables, `apply_personal_op`, change feed and snapshot

**Files:**
- Create: `supabase/migrations/20261120000000_personal_data.sql`
- Create: `supabase/tests/20_personal_data_test.sql`
- Modify: `tool/run_supabase_tests.sh` (also run `20_personal_data_test.sql`)

**Interfaces (Produces — the wire contract every later task uses):**
- Tables `personal_people`, `personal_transactions`, `personal_ledger_entries`, `personal_ledger_repayments`, `personal_reminders`, `personal_attachments`; each with `id uuid pk`, `owner_id uuid not null references auth.users on delete cascade`, `revision bigint not null default 1`, `last_op_id uuid`, `deleted_at timestamptz`, `created_at`, `updated_at`, plus the columns of the matching local table (snake_case; dates `date`, times `timestamptz`). Reminder rows have no `notification_id`. Transactions and reminders carry the category snapshot columns. Attachments: `parent_type text check in ('transaction','ledger_entry')`, `parent_id uuid`, `storage_name text`, `storage_path text` (server-set `owner_id || '/' || storage_name`), `original_name`, `mime_type` (same list as `group_attachments`), `size_bytes` (≤ 10485760), `sha256` (64 chars).
- Entity wire names: `person`, `transaction`, `ledger_entry`, `ledger_repayment`, `reminder`, `attachment`; plus `all` for reset.
- `apply_personal_op(p_op jsonb) returns jsonb` — input `{op_id, entity_type, entity_id, op_type: 'upsert'|'delete'|'reset', base_revision, payload}`; output `{status:'applied', revision}` | `{status:'conflict', revision, current}` | `{status:'rejected', code}` with codes `bad_request`, `not_found`, `invalid_reference`, `invalid_value`. Rules:
  - Idempotent via `processed_ops` (same as groups).
  - Upsert, row absent → insert with `revision = 1`, `owner_id = auth.uid()`.
  - Upsert, row present and owned → if `base_revision = revision` apply and `revision + 1`; if row tombstoned and `base_revision = 0` → resurrect (clear `deleted_at`, `revision + 1`); else conflict with `current`.
  - A row owned by someone else is answered as `not_found` (never reveal it exists).
  - References (`person_id`, `ledger_id`, `parent_id`, `ledger_entry_id`) must be live rows of the same owner, else `invalid_reference`. `group_id` on reminders must be a group the caller belongs to (`is_group_member`).
  - Delete → tombstone + linked deletes: person → its ledger entries (→ their repayments, attachments, reminders) tombstoned; transactions/reminders with that `person_id` get `person_id = null`; transaction or ledger entry → its attachments; ledger entry → reminders with that `ledger_entry_id`. Each touched row gets `revision + 1` and its own event.
  - Reset (`entity_type = 'all'`, `op_type = 'reset'`) → tombstone every live row of the caller, emit **one** event `('all', null, 'reset')`, return `{status:'applied', revision: 0}`.
- `personal_sync_events (seq bigserial pk, owner_id, entity_type, entity_id uuid null, op_type, revision, payload jsonb, op_id, created_at)`, RLS select own; every applied change emits one event whose payload is the full row (deletes: the tombstoned row).
- `get_personal_snapshot() returns jsonb` → `{people:[…], transactions:[…], ledger_entries:[…], ledger_repayments:[…], reminders:[…], attachments:[…], max_seq}` (live rows only, caller's own).
- `prepare_account_deletion()` unchanged (personal rows cascade with `auth.users`).
- Deviation from the spec's wording (ruling): the spec's `reset_personal_data()` is implemented as the `reset` op of `apply_personal_op`, so it is idempotent and travels through the outbox in order ahead of the re-upload (spec §7 "interrupted restore"). It still tombstones every row; it emits one `reset` event instead of one per row.

- [ ] **Step 1: Write the failing SQL tests** in `20_personal_data_test.sql` (same `pg_temp.ok` / `pg_temp.fails` helpers and user ids as `10_rls_and_rpc_test.sql`): user A creates person, transaction (with snapshot), ledger entry, repayment, reminder, attachment → each `applied` revision 1; replaying an op_id returns the identical result; stale `base_revision` → `conflict` with `current.revision = 2`; user B selecting A's tables returns 0 rows; user B upserting A's person id → `not_found`; transaction with B's person id → `invalid_reference`; amount 0 → `invalid_value`; deleting A's person tombstones the ledger entry and repayment and nulls `person_id` on the transaction (events emitted for each); upsert with `base_revision = 0` on a tombstoned row resurrects it; reset tombstones everything and emits exactly one `reset` event; snapshot returns only live rows and `max_seq` = last seq; direct `insert into personal_people` as `authenticated` fails with `permission denied`.
- [ ] **Step 2: Run** `bash tool/run_supabase_tests.sh` → FAIL (function `apply_personal_op` does not exist).
- [ ] **Step 3: Write the migration** to satisfy the contract above.
- [ ] **Step 4: Run** `bash tool/run_supabase_tests.sh` → all existing (53) and new checks print `ok`, exit 0.
- [ ] **Step 5: Commit** `feat(cloud): personal data tables, apply_personal_op, change feed` (only with the owner's approval).

---

### Task 2: Personal files bucket and account-deletion cleanup

**Files:**
- Create: `supabase/migrations/20261120000100_personal_attachments_storage.sql`
- Modify: `supabase/functions/delete-account/index.ts`
- Modify: `docs/RLS_SECURITY.md` (storage policies section)

**Interfaces:**
- Produces: private bucket `personal-attachments`; object names `<owner_id>/<storage_name>`; policies — authenticated users can insert/select/delete only where `(storage.foldername(name))[1] = auth.uid()::text`; same MIME list and 10 MB limit as `group-attachments`.
- `delete-account` removes every object under `personal-attachments/<uid>/` before deleting the auth user.

- [ ] **Step 1:** Write the migration mirroring `20261118000100_group_attachments_storage.sql` (bucket insert with `public = false`, `file_size_limit = 10485760`, `allowed_mime_types`, three policies).
- [ ] **Step 2:** Extend `delete-account/index.ts`: list and remove `personal-attachments/<uid>/*` (paged) with the service-role client, before `auth.admin.deleteUser`.
- [ ] **Step 3: Run** `bash tool/run_supabase_tests.sh` → still passes (this file is skipped by name).
- [ ] **Step 4:** Note in `docs/RLS_SECURITY.md` that storage policies are verified on the live project (Task 14), not in Docker.
- [ ] **Step 5: Commit** `feat(cloud): private bucket for personal bills` (with approval).

---

### Task 3: Local schema v4 — sync columns on personal tables, scope on sync tables

**Files:**
- Modify: `lib/core/database/tables.dart`, `lib/core/database/app_database.dart`
- Generated: `lib/core/database/app_database.g.dart`, `app_database.steps.dart`, `drift_schemas/hisabmitra/drift_schema_v4.json`, `test/drift/hisabmitra/generated/schema_v4.dart`, `docs/DATABASE_SCHEMA.md`
- Test: `test/drift/hisabmitra/migration_test.dart`

**Interfaces:**
- Produces: mixin `PersonalSyncColumns on Table` with `revision` (int, default 0) and `syncState` (`textEnum<SyncState>`, default `'localOnly'`), applied to `Persons`, `Transactions`, `MoneyLedger`, `MoneySettlements`, `Reminders`, `Attachments`.
- `SyncOutbox`, `SyncInbox`, `SyncConflicts` gain `TextColumn scope` (default `'group'`); personal rows use `scope = 'personal'` and `groupId = ''`.
- `AppDatabase.currentSchemaVersion = 4`; step `from3To4` adds those columns (additive only).

- [ ] **Step 1: Write the failing migration test** `v3 → v4 keeps every row and adds sync columns`: open a v3 database with one person, transaction, ledger entry, repayment, reminder, attachment and one outbox op; migrate; assert all rows survive, personal rows have `revision 0` and `sync_state 'localOnly'`, and the outbox op has `scope 'group'`.
- [ ] **Step 2: Run** `flutter test test/drift/hisabmitra/migration_test.dart` → FAIL (no v4 schema).
- [ ] **Step 3:** Add the columns and the step, then regenerate (Global Constraints command list).
- [ ] **Step 4: Run** the migration test, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(db): schema v4 sync columns for personal data` (with approval).

---

### Task 4: Cloud gateway — personal ops, feed, snapshot, files (+ fake cloud)

**Files:**
- Modify: `lib/features/synchronization/domain/cloud_models.dart`, `lib/features/synchronization/data/cloud_gateway.dart`, `lib/features/synchronization/data/supabase_cloud_gateway.dart`
- Modify: `test/helpers/fake_cloud.dart`
- Test: `test/features/synchronization/cloud_models_test.dart` (create)

**Interfaces (Produces):**
- `OutboundOp` gains `final String scope` (`'group'` default, or `'personal'`); `toJson()` omits `group_id` for personal.
- `RemoteEvent` gains `final String scope` (default `'group'`); personal events have `groupId: ''`; `entityId` may be `''` for the reset event.
- `class PersonalSnapshot { final Map<String, List<Map<String, Object?>>> rows; final int maxSeq; }` (keys = the snapshot JSON keys of Task 1).
- `CloudGateway`:
  - `applyOp(op)` calls `apply_personal_op` when `op.scope == 'personal'`.
  - `Future<List<RemoteEvent>> pullPersonalEvents({required int afterSeq, int limit = 500})` (select from `personal_sync_events` ordered by seq).
  - `Future<PersonalSnapshot> fetchPersonalSnapshot()`.
  - `Future<void> uploadPersonalFile({required String storageName, required List<int> bytes, required String mimeType})` (path `<uid>/<storageName>`, upsert false).
  - `Future<List<int>> downloadPersonalFile(String storageName)`.
  - `Future<void> deletePersonalFile(String storageName)`.
  - `NotConfiguredCloudGateway` throws `NotConfiguredFailure` for all of them.
- `FakeCloudServer` implements the Task 1 contract in memory (per-owner rows, revisions, conflicts, tombstones, linked deletes, reset, snapshot, events) plus `Map<String, List<int>> personalFiles` keyed `<uid>/<name>`; `FakeCloudClient` implements the new methods; `FakeCloudClient.offline` (bool) makes every call throw `NetworkFailure`.

- [ ] **Step 1: Write failing tests** `personal op JSON has no group id` (`OutboundOp(scope: 'personal', groupId: '', …).toJson()` lacks `group_id` and carries `entity_type`, `op_type`, `base_revision`, `payload`), and `group op JSON is unchanged`.
- [ ] **Step 2: Run** `flutter test test/features/synchronization/cloud_models_test.dart` → FAIL.
- [ ] **Step 3:** Implement the model, interface, Supabase and not-configured gateways, and the fake (fake is exercised by Tasks 5–12).
- [ ] **Step 4: Run** the test file, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(sync): gateway API for personal data` (with approval).

---

### Task 5: Personal outbox; people and income/expense entries queue their changes

**Files:**
- Create: `lib/features/synchronization/domain/personal_entity.dart`
- Create: `lib/features/synchronization/data/personal_outbox.dart` (queue + payload builders)
- Modify: `lib/features/people/data/people_repository.dart`, `lib/features/transactions/data/transaction_repository.dart`, `lib/features/tour/data/sample_data_service.dart`
- Test: `test/features/synchronization/personal_outbox_test.dart` (create)

**Interfaces (Produces):**
- `enum PersonalEntity { person('person'), transaction('transaction'), ledgerEntry('ledger_entry'), repayment('ledger_repayment'), reminder('reminder'), attachment('attachment'); final String wire; static PersonalEntity? fromWire(String w); }`
- `class PersonalOutbox` (`personalOutboxProvider`), constructed with `AppDatabase`, `Clock`, `IdGenerator`; **must be called inside the caller's `_db.transaction`**:
  - `Future<void> upsert(PersonalEntity type, String id)` — builds the payload from the current local row (wire columns of Task 1; transactions/reminders add the category snapshot from the local category), inserts an outbox row (`scope 'personal'`, `groupId ''`, `opType 'upsert'`, `baseRevision` = row's `revision`, new `opId`) and sets the row's `syncState` to `pending`. No-op when suppressed or when `id` is a sample id (setting `tour.sampleIds`, any list).
  - `Future<void> delete(PersonalEntity type, String id, {Map<String, Object?> extra = const {}})` — queues `opType 'delete'` with payload `{id, ...extra}` and the row's current revision (read before deletion; the caller deletes the row afterwards in the same transaction).
  - `Future<void> reset()` — queues `entity_type 'all'`, `op_type 'reset'`, `entityId ''`, returns nothing; stores its `opId` in setting `sync.ownResetOpId`.
  - `Future<T> withoutUpload<T>(Future<T> Function() body)` — suppresses queuing for writes inside `body`.
- People: `save` → `upsert(person)`; `delete` → `delete(person)` (one op; server mirrors the cascade).
- Transactions: `save` → `upsert(transaction)`; `delete` → `delete(transaction)`.
- `SampleDataService.load` and `remove` run inside `withoutUpload`.

- [ ] **Step 1: Write failing tests** (in-memory DB):
  - `saving a person queues one upsert in the same transaction` — after `people.save`, outbox has 1 row `scope 'personal'`, `entityType 'person'`, payload `name` matches; row `syncState == pending`.
  - `a failing save queues nothing` — save that throws `ValidationFailure` leaves the outbox empty.
  - `transaction payload carries the category snapshot` — payload has `category_id 'cat_groceries'`, `category_system_key 'groceries'`, `category_name`, `category_icon`, `category_color`, `txn_date` as `YYYY-MM-DD`.
  - `editing twice before sync queues two ops in order with the same base revision`.
  - `deleting a person queues one delete` — and no ops for its cascaded ledger rows.
  - `sample data is never queued` — after `SampleDataService.load()` the outbox has 0 personal ops; editing a sample transaction afterwards still queues nothing.
- [ ] **Step 2: Run** `flutter test test/features/synchronization/personal_outbox_test.dart` → FAIL.
- [ ] **Step 3:** Implement and wire.
- [ ] **Step 4: Run** the file, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(sync): queue people and entries for upload` (with approval).

---

### Task 6: Khata, repayments, reminders and category changes queue their changes

**Files:**
- Modify: `lib/features/money_ledger/data/ledger_repository.dart`, `lib/features/reminders/data/reminder_repository.dart`, `lib/features/categories/data/category_repository.dart`
- Test: `test/features/synchronization/personal_outbox_test.dart`

**Interfaces:**
- Consumes: `PersonalOutbox` (Task 5).
- Ledger: `saveEntry` → `upsert(ledgerEntry)`; `addRepayment` → `upsert(repayment)` (and the entry if it changes); `deleteRepayment` → `delete(repayment)`; `deleteEntry` → `delete(ledgerEntry)`.
- Reminders: `save`, `complete`, `cancel` → `upsert(reminder)`; `delete` → `delete(reminder)`. Reminder payload excludes `notification_id`.
- Categories (still local): renaming/re-iconing/re-colouring a category → `upsert` every transaction and reminder using it; `delete(id, reassignTo:)` → `upsert` every reassigned transaction/reminder. Creating a category queues nothing.

- [ ] **Step 1: Write failing tests**: `khata entry and repayment queue upserts`; `deleting a khata entry queues one delete`; `completing a reminder queues an upsert without notification_id`; `renaming a category re-queues the entries that use it` (2 transactions + 1 reminder → 3 ops); `creating a category queues nothing`.
- [ ] **Step 2: Run** → FAIL.
- [ ] **Step 3:** Wire the repositories.
- [ ] **Step 4: Run** the file, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(sync): queue khata, reminders and category-driven changes` (with approval).

---

### Task 7: Push and pull personal data; apply rows on the phone

**Files:**
- Create: `lib/features/synchronization/data/personal_rows.dart`
- Create: `lib/features/reminders/data/notification_ids.dart` (moved from `ReminderRepository._newNotificationId`)
- Modify: `lib/features/synchronization/data/sync_service.dart`, `lib/features/synchronization/application/sync_controller.dart`, `lib/features/reminders/data/reminder_repository.dart`, `lib/features/synchronization/presentation/sync_screen.dart` (titles for personal conflicts)
- Test: `test/features/synchronization/personal_sync_test.dart` (create)

**Interfaces (Produces):**
- `Future<int> newNotificationId(AppDatabase db)` (unique 31-bit, as today).
- `class PersonalRowApplier` (`AppDatabase`, `Clock`, `{ReminderScheduler? scheduler}`):
  - `Future<bool> apply(PersonalEntity type, Map<String, Object?> row, int revision, {bool deleted = false, bool force = false})` — insert/update/delete the local row; skips when local `revision >= revision` unless `force`; before a transaction/reminder whose `category_id` is missing locally, **creates the category** from the snapshot (same id; `systemKey` = `category_system_key`); reminders get `newNotificationId` on insert and are (re)scheduled via `scheduler` when pending and in the future; sets `syncState synced` and `revision`. Returns false (not throws) when a referenced person/entry is not present yet.
  - `Future<void> applyReset()` — deletes all local personal rows that have no pending outbox op (cancelling their notifications).
  - `Future<void> setState(PersonalEntity type, String id, {int? revision, SyncState? state})`.
- `SyncService` constructor gains `ReminderScheduler? scheduler`; new settings keys `sync.personalCursor`, `sync.ownResetOpId`.
  - `push()` sends both scopes in creation order; personal `OpApplied` → `setState(synced/pending)`; personal conflict → `sync_conflicts` row with `scope 'personal'`; reset op `applied` → nothing to mark.
  - Ruling: a fresh phone loads a snapshot instead of replaying the feed from seq 0 (spec §6) — same result, and its size doesn't grow with history.
  - `pull()` = group pull (unchanged) + `pullPersonal()`: cursor 0 → `fetchPersonalSnapshot()` applied with `force` in order people → ledger entries → repayments → transactions → reminders → attachments, cursor = `maxSeq`; else events → inbox (`scope 'personal'`) → applied in seq order, skipping entities with queued ops or open conflicts; reset event with `op_id == sync.ownResetOpId` is skipped, others → `applyReset()`; rows that returned false (missing reference) are retried once after the batch, then left unapplied in the inbox for the next pull.
  - `resolveConflict` handles personal: keepRemote → `apply(force: true)`; keepLocal → re-queue the local payload with `baseRevision` = remote revision.
- `syncServiceProvider` passes `notificationServiceProvider` as the scheduler.

- [ ] **Step 1: Write failing tests** (fake cloud; phones P1 and P2 signed in as the same user):
  - `an entry saved offline uploads when back online` — P1 offline save, sync (offline report, op kept), online sync → server has row revision 1; P1 row `synced`.
  - `the second phone gets the entry` — P2 sync → identical row.
  - `a delete reaches the other phone`.
  - `deleting a person on one phone removes their khata on the other`.
  - `editing on both phones offline creates a conflict, nothing overwritten` — P2's sync gets a `scope 'personal'` conflict; P2's local row unchanged; Keep theirs → P1's version; (separate test) Keep mine → server has P2's version at revision 3.
  - `a custom category missing on this phone is re-created from the entry`.
  - `a pulled reminder gets its own notification id and is scheduled` — fake scheduler records the schedule; id differs from P1's.
  - `pull never overwrites an unsent local change`.
  - `a fresh phone downloads everything from the snapshot`.
  - Review Focus 1: `an entry arriving before its person still applies` (feed order: transaction event, then person event in the same page).
  - Review Focus 2: `editing while the first upload is queued gives one row and no conflict` — save, edit, edit offline; online sync → server revision 3, no conflicts.
- [ ] **Step 2: Run** `flutter test test/features/synchronization/personal_sync_test.dart` → FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4: Run** the file, `test/features/synchronization/sync_service_test.dart` (group behaviour unchanged), then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(sync): push and pull personal data` (with approval).

---

### Task 8: Every group is a cloud group

**Files:**
- Modify: `lib/features/groups/data/group_repository.dart`, `lib/features/groups/presentation/group_cloud_screens.dart`, `lib/features/groups/presentation/group_detail_screen.dart` (remove "Share to cloud"), `lib/features/tour/data/sample_data_service.dart`, `l10n/en|gu/cloud.json`
- Test: `test/features/groups/group_repository_test.dart`, `test/widget/app_flow_test.dart` (adjust if it shares a group)

**Interfaces:**
- `GroupRepository` gains a `String? Function() currentUserId` dependency (from `cloudGatewayProvider.currentSession?.userId`).
- `createGroup(…, {bool cloud = true})` — when `cloud` and a user id exists: create with `isShared: true`, `ownerUserId`, and queue it exactly as `markShared` does today; otherwise phone-only.
- Sample data creates its group with `cloud: false`.
- `shareGroupToCloud` and every "Share to cloud" button/empty state are removed; `GroupInviteScreen` for a phone-only group shows `l.inviteSampleGroup` = "Sample groups can't be shared." (Gujarati too).

- [ ] **Step 1: Write failing tests**: `a new group is shared and queued when signed in`; `a new group stays on the phone when not signed in`; `the sample group stays on the phone`.
- [ ] **Step 2: Run** `flutter test test/features/groups/group_repository_test.dart` → FAIL.
- [ ] **Step 3:** Implement; remove the share UI and unused strings.
- [ ] **Step 4: Run** the file, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(groups): groups are always saved to the account` (with approval).

---

### Task 9: Bills and receipts sync

**Files:**
- Modify: `lib/features/attachments/data/attachment_service.dart`, `lib/features/attachments/presentation/attachments_editor.dart` (`_Thumb`), `lib/features/attachments/presentation/attachment_viewer_screen.dart`, `lib/features/synchronization/data/sync_service.dart`, `l10n/en|gu/attachments.json`
- Test: `test/features/attachments/attachment_sync_test.dart` (create)

**Interfaces:**
- `AttachmentService` gains `PersonalOutbox` and `CloudGateway`:
  - `commit` for a transaction/ledger entry → `upsert(attachment)` with payload `storage_name = storedName`; for a group expense of a shared group nothing is queued (file handled by the uploader below).
  - `delete` → `delete(attachment, extra: {'storage_name': storedName})`.
  - `Future<File?> ensureLocal(AttachmentRow a)` — the local file if present; else downloads (`downloadPersonalFile(storedName)` or `downloadGroupAttachment(remotePath)`), saves it, returns it; returns null on any failure.
- `SyncService.syncOnce()` order: **upload files → push → pull**. The uploader sends every attachment row with `remotePath == null` (personal → `uploadPersonalFile`, then `remotePath = storedName`; group expense of a shared group → `uploadGroupAttachment(storagePath: '<groupId>/<expenseId>/<storedName>', …)`, then `remotePath` = that path). Push skips a personal attachment op while its row has no `remotePath`. After an applied attachment **delete** op, `deletePersonalFile(storage_name)` (best effort).
- A file that is missing on disk or rejected (`AttachmentFailure`) is marked `remotePath = ''` (never retried) and its record syncs without a file; the viewer then shows "missing".
- Thumb and viewer use `ensureLocal`; null → placeholder with `l.attachmentDownloadRetry` ("Couldn't load. Tap to try again.").
- `attachmentPrivateNote` text replaced in Task 13.

- [ ] **Step 1: Write failing tests**: `a bill uploads before its record` (fake server receives the file, then the op; server row `storage_path = '<uid>/<id>.jpg'`); `the other phone downloads the bill when shown`; `deleting a bill removes the stored file`; `a group expense bill uploads to the group bucket`; Review Focus 5: `a bill whose file is gone still lets its record sync` (delete the local file before sync → op applied, `remotePath == ''`, queue empty).
- [ ] **Step 2: Run** `flutter test test/features/attachments/attachment_sync_test.dart` → FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4: Run** the file, `test/features/attachments/attachments_editor_test.dart`, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(sync): bills and receipts saved to the account` (with approval).

---

### Task 10: First upload and new-phone download, with a progress screen

**Files:**
- Create: `lib/features/synchronization/application/account_sync_controller.dart`
- Create: `lib/features/synchronization/presentation/account_sync_screen.dart`
- Modify: `lib/features/synchronization/data/personal_outbox.dart` (bulk queue), `lib/features/settings/domain/app_preferences.dart`, `lib/app/router/routes.dart`, `lib/app/router/app_router.dart`, `l10n/en|gu/cloud.json`
- Test: `test/features/synchronization/account_sync_test.dart`, `test/widget/account_sync_screen_test.dart` (create)

**Interfaces (Produces):**
- `Future<int> PersonalOutbox.queueUnsentLocalData()` — queues an upsert for every personal row with `syncState localOnly` that is not a sample id, in order people → ledger entries → repayments → transactions → reminders → attachments; calls `GroupRepository.markShared` for every phone-only non-sample group; returns the number queued.
- `AppPreferences.initialSyncDone` (key `'sync.initialDone'`, default `false`).
- `Routes.accountSync = '/welcome/sync'`; redirect there when cloud is configured, `accountVerified`, `!initialSyncDone`, and not deferred this run.
- `final accountSyncDeferredProvider = NotifierProvider<AccountSyncDeferred, bool>(AccountSyncDeferred.new)` with `void defer()` (in-memory: "Continue in background" for this run only; no `StateProvider` — it is legacy in Riverpod 3).
- `class AccountSyncController extends Notifier<AccountSyncState>`; `AccountSyncState { phase: AccountSyncPhase (uploading | downloading | offline | done | failed), int done, int total }`; `Future<void> run()` → `queueUnsentLocalData()`, then `syncOnce()` repeatedly until no pending ops (progress = applied ops / queued; downloading phase shows rows applied); on success sets `initialSyncDone = true`.
- Strings: `accountSyncUploadTitle` "Saving your hisab to your account", `accountSyncDownloadTitle` "Getting your hisab", `accountSyncProgress` "{done} of {total}", `accountSyncOffline` "No internet. Your hisab will be saved to your account when you're back online.", `accountSyncContinue` "Continue in background" (+ Gujarati).

- [ ] **Step 1: Write failing tests**: `first upload queues every unsent record once` (fresh phone with 3 people, 5 entries → 8 ops, second call queues 0); `a phone-only group is shared during the first upload`; `sample data is not uploaded`; `the account's existing records and the phone's are merged` (server already has 2 entries from another phone → both phones end with all 7); `offline → phase offline, app usable, completes on next run`; widget: `progress screen shows "3 of 8" and Continue in background leaves to Home`.
- [ ] **Step 2: Run** both test files → FAIL.
- [ ] **Step 3:** Implement; regenerate l10n.
- [ ] **Step 4: Run** the files, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(sync): first upload and new-phone download` (with approval).

---

### Task 11: Sign-out wipes the phone copy (with a warning); sync always on when signed in

**Files:**
- Create: `lib/features/synchronization/data/local_data_wiper.dart`
- Modify: `lib/features/authentication/application/auth_controller.dart`, `lib/features/profile/presentation/profile_screen.dart`, `lib/features/settings/domain/app_preferences.dart` (drop `cloudSyncEnabled`; old key ignored), `lib/features/settings/presentation/settings_screen.dart` (remove the switch), `lib/features/synchronization/application/sync_controller.dart` (`canSync` = configured && signed in), `lib/features/synchronization/presentation/sync_screen.dart`, `lib/features/groups/presentation/group_cloud_screens.dart` (drop `cloudSyncEnabled` writes), `l10n/en|gu/cloud.json`
- Test: `test/features/synchronization/local_data_wiper_test.dart` (create), `test/features/authentication/auth_controller_test.dart`, `test/features/settings/app_preferences_test.dart`

**Interfaces:**
- `class LocalDataWiper { Future<void> wipeAccountData(); }` — cancels reminder notifications, deletes rows of persons, transactions, money_ledger, money_settlements, reminders, attachments, all group cache tables, sync outbox/inbox/conflicts; deletes settings `sync.cursor`, `sync.personalCursor`, `sync.lastSuccess`, `sync.initialDone`, `sync.ownResetOpId`, `tour.sampleIds`; sets `sampleDataLoaded = false`; deletes files in the attachments folder. **Keeps** categories, other app settings and the local profile.
- `AuthController.unsentChanges() → Future<int>` (pending + failed outbox ops); `signOut()` → cloud sign-out then `wipeAccountData()`.
- Profile screen: Sign out with `unsentChanges() > 0` shows `signOutUnsentTitle` "Not saved yet" / `signOutUnsentBody` "{count} changes haven't been saved to your account yet." with **Wait and sync** (runs `syncNow`, stays signed in) and **Sign out anyway**.

- [ ] **Step 1: Write failing tests**: `wipe keeps categories and settings, removes everything else`; `sign out wipes the phone copy`; `unsentChanges counts pending and failed ops`; `canSync no longer depends on a switch` (signed in → true); Review Focus 3: `signing out offline with unsent changes, then signing in again, works` (wipe, fresh sign-in, snapshot download, no exception).
- [ ] **Step 2: Run** the test files → FAIL.
- [ ] **Step 3:** Implement; remove the switch and preference; regenerate l10n.
- [ ] **Step 4: Run** the files, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(account): sign-out clears the phone copy; sync follows sign-in` (with approval).

---

### Task 12: Backups — manual only; restore replaces the account's personal data

**Files:**
- Modify: `lib/features/backup/application/backup_providers.dart` (remove `autoBackupRunnerProvider`), `lib/app/app.dart` (stop calling it), `lib/features/settings/domain/app_preferences.dart` (drop `autoBackup`/`lastAutoBackupAt`; keys ignored), `lib/features/settings/presentation/settings_screen.dart`, `lib/features/backup/presentation/backup_screen.dart`, `lib/features/backup/data/backup_service.dart` (keep `pruneAutomatic` unused → remove), `l10n/en|gu/backup.json`
- Create: `lib/features/backup/data/restore_sync.dart`
- Delete: `test/features/backup/auto_backup_test.dart`
- Test: `test/features/backup/restore_sync_test.dart` (create)

**Interfaces:**
- `class RestoreSync { Future<void> afterRestore(); }` — in one DB transaction: delete group cache rows and the outbox/inbox/conflicts; set settings `sync.cursor = 0` and `sync.personalCursor = 0`; set every personal row to `revision 0`, `syncState localOnly`; `PersonalOutbox.reset()`; `queueUnsentLocalData()`. Called by the backup screen right after a successful `BackupService.restore`.
- Restore needs internet: if `connectivityProvider` is false, the restore button shows `restoreNeedsInternet` ("Connect to the internet to restore.") and does nothing.
- Confirmation text adds `restoreReplacesAccount` "This replaces the hisab saved in your account with this backup. Groups are not changed."
- Automatic-backup settings and runner removed; older automatic backup files still listed until deleted.

- [ ] **Step 1: Write failing tests**: `restore queues the reset first, then every personal record`; `after restore and sync the account holds exactly the backup's records` (server had an extra entry → gone); `groups are not taken from the backup` (backup had an old group copy → after sync the group equals the server's); `the other phone ends up with the backup's records` (P2 applies reset then upserts); Review Focus 4: `an interrupted restore continues in order` (push stops offline after the reset → next online sync uploads the rest; the pre-restore extra entry stays gone); `no automatic backup option in Settings` (widget).
- [ ] **Step 2: Run** `flutter test test/features/backup/` → FAIL.
- [ ] **Step 3:** Implement; regenerate l10n.
- [ ] **Step 4: Run** the folder, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `feat(backup): manual backups; restore replaces account data` (with approval).

---

### Task 13: Honest texts and docs

**Files:**
- Modify (strings): every en/gu string that says data stays on / never leaves the phone or is not uploaded — at least `attachmentPrivateNote`, onboarding intro, profile-setup note, About description, Settings privacy texts (find with `grep -rn -i "phone\|ફોન" l10n/en l10n/gu` and review each).
- Modify (docs): `README.md`, `docs/PRIVACY_AND_SECURITY.md`, `docs/SYNC_ARCHITECTURE.md`, `docs/ARCHITECTURE.md`, `docs/BACKUP_RESTORE.md`, `docs/DATABASE_SCHEMA.md` (regenerated), `docs/RLS_SECURITY.md`, `docs/PROGRESS.md`.

**Copy decisions:**
- Attachment note: "Saved to your HisabMitra account." / "તમારા હિસાબમિત્ર એકાઉન્ટમાં સચવાય છે."
- General wording: data is saved to the user's HisabMitra account; each account sees only its own records; the phone keeps a copy so the app works without internet; signing out removes the phone's copy.
- README/PRIVACY owner note: the app owner's Supabase project stores every user's records; the owner can see them in the Supabase dashboard; anyone installing the public APK stores data there.

- [ ] **Step 1:** Write a test `no visible text promises phone-only storage` that scans `lib/l10n/app_en.arb` for `never leave`, `stays on your phone`, `stay on this phone`, `Not uploaded anywhere` → none found (and the Gujarati equivalents found by the grep above).
- [ ] **Step 2: Run** it → FAIL.
- [ ] **Step 3:** Update strings and docs; regenerate l10n and the schema doc.
- [ ] **Step 4: Run** the test, then `flutter test` → PASS.
- [ ] **Step 5: Commit** `docs: describe account storage honestly` (with approval).

---

### Task 14: Full checks, live migration (owner), device verification

- [ ] **Step 1:** `dart run tool/build_l10n.dart && flutter gen-l10n && dart run build_runner build --delete-conflicting-outputs && git diff --exit-code -- lib l10n` (generated code current), `dart format --output=none --set-exit-if-changed lib test tool integration_test`, `flutter analyze`, `flutter test`, `bash tool/run_supabase_tests.sh` → all clean/passing.
- [ ] **Step 2: STOP and ask the owner** for the database password or an access token; apply `20261120000000_personal_data.sql` and `20261120000100_personal_attachments_storage.sql` to project `zjidwksngkxcsryzgnoe` the same way as earlier migrations (psql over the direct connection, recorded in `supabase_migrations.schema_migrations`). Do not store the credential. If the owner prefers, give them the two files to run in the SQL editor instead.
- [ ] **Step 3: Verify live** (read-only queries): new tables have RLS on; `personal-attachments` bucket is private with three policies; as two test accounts, account B cannot read A's rows or files.
- [ ] **Step 4: Device** (release build with `--dart-define-from-file=dart_defines.json`, `test_device` emulator, a test account the owner provides/approves): add an entry offline → reconnect → row visible in Supabase; add a bill → file in `personal-attachments/<uid>/`; uninstall + reinstall + sign in → "Getting your hisab" → data and bill back; sign out → phone copy gone, categories kept. Two phones: if a second device or emulator is available, sign in on both and check an entry made on one appears on the other after "Sync now"; otherwise report that two-phone sync is covered only by the Task 7 tests.
- [ ] **Step 5:** Update `docs/PROGRESS.md` with results; commit only with approval.
