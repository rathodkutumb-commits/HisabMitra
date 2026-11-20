# Part B — Personal data in Supabase (design)

Date: 2026-11-20. Part B of the owner's three-part request (A fixes — done
on branch `part-a-fixes`; **B this document**; C live groups: invite links,
live refresh, push notifications — later, on the owner's command).

## Intent and why

The owner's items 8 and 10: "create new tables for the user expense also;
from now all data should store into the Supabase database instead of local",
and "only the income and expense category types should store locally … rest
all dynamic data comes from Supabase".

The owner chose (2026-11-20) **Supabase as the main copy with a working copy
on the phone** (option 2), over a cloud-only app, so the app keeps working
without internet and stays fast. The phone's copy is a cache, not the record:
a new or reset phone gets everything back after sign-in.

The owner did not state the underlying reason (asked twice). Reasonable
reading: data survives a lost/changed phone, and one account can be used on
more than one phone. The design delivers both.

## Goals

1. Every personal record is stored in Supabase under the user's account:
   income/expense entries, people, khata entries (given/taken) and their
   repayments, reminders and recurring payments, and bill/receipt files.
2. All groups live in Supabase (no more phone-only groups).
3. The app works offline: changes made without internet upload when the
   connection returns; nothing is lost.
4. A new or reset phone, after sign-in, downloads all of the user's data.
5. Two phones on one account stay in sync (on app start, return to the app,
   after each change, and on "Sync now").
6. Existing installs (1.0.0, 1.0.1) upload their phone data once after the
   update.
7. Income/expense **categories stay on the phone only**; adding, editing and
   deleting them is local. Entries still show the right category on a new
   phone.
8. Manual backup and restore stays; automatic backups are removed (owner's
   choice, 2026-11-20).

## Non-goals

- Live push of changes between the user's own phones (Supabase Realtime) —
  that is part C's "live refresh"; B syncs on start/resume/change/"Sync now".
- Push notifications, invite links (part C).
- Categories in the cloud.
- A web dashboard or any non-app access to the data.
- End-to-end encryption of personal data (see Privacy).

## Anti-goals (would make this a failure even if it works)

- Losing an entry: a change marked "saved" that never reaches Supabase, or a
  download that overwrites a newer unsent change.
- Silently resolving a money conflict by "last write wins".
- One user able to read or change another user's records.
- Sample (tour) data appearing in a user's Supabase data.
- The app becoming unusable offline.

## Constraints

- Supabase project `zjidwksngkxcsryzgnoe`. New migrations are tested with
  `tool/run_supabase_tests.sh` (Docker) before being applied; applying them to
  the live database needs the owner's database password or an access token
  each time (never stored).
- Free plan limits to keep in mind: 500 MB database, 1 GB file storage. Bill
  photos are compressed (≤ 2400 px, quality 85, ≤ 10 MB each).
- Money stays integer paise; domain rules unchanged.
- English and Gujarati for every new text; light theme; existing palettes.
- `flutter analyze` clean, all tests passing, SQL tests passing.
- Builds without a Supabase configuration (tests, CI) keep working fully on
  the phone, with nothing syncing.

## Approaches considered

| Approach | Trade-offs | Decision |
|---|---|---|
| Cloud only (no data on the phone) | Literal reading of "remove local storage"; no offline use, spinners everywhere, rewrite of all 14 data services and 28 live screens | Rejected by the owner |
| **Supabase main copy + phone working copy** | Works offline, fast, reuses the existing sync engine, screens/reports/AI unchanged | **Chosen by the owner** |

Within the chosen approach, how personal records reach Supabase (my call):

| Option | Trade-offs | Decision |
|---|---|---|
| Direct table writes (PostgREST upsert) with RLS, newest edit wins | Simple server; but "last write wins" on money, and phone clocks decide | Rejected (anti-goal) |
| **Same contract as groups: an operation RPC with idempotency + revisions, plus a per-user change feed** | Reuses the proven push/pull/conflict engine and its tests; conflicts shown to the user | **Chosen** |

Backups (owner's choice): keep manual backup and restore, drop automatic
backups. Rejected: removing backups entirely (no safety net on the free plan).

## Design

### 1. Cloud schema (new migration)

New tables, all with RLS enabled and **select-only for the owner**
(`owner_id = auth.uid()`); all writes go through `apply_personal_op`:

| Table | Mirrors local table | Notes |
|---|---|---|
| `personal_people` | `persons` | name, phone, email, description, notes |
| `personal_transactions` | `transactions` | type, amount_paise, category_id, **category snapshot** (`category_name`, `category_system_key`, `category_icon`, `category_color`), txn_date, payment_method, person_id, description, notes |
| `personal_ledger_entries` | `money_ledger` | person_id, direction, principal_paise, entry_date, due_date, payment_method, description, notes |
| `personal_ledger_repayments` | `money_settlements` | ledger_id, amount_paise, settled_on, payment_method, notes |
| `personal_reminders` | `reminders` | all reminder fields **except** `notification_id` (per-phone); category snapshot for recurring payments |
| `personal_attachments` | `attachments` (personal parents) | parent type + id, storage_path, original_name, mime_type, size_bytes, sha256 |

Each table: `id uuid pk`, `owner_id uuid not null references auth.users on
delete cascade`, `revision bigint`, `last_op_id uuid`, `deleted_at
timestamptz` (tombstone), `created_at`, `updated_at`, and the same value
checks as the local schema and the group tables (lengths, amount > 0 and
≤ 99 999 999 999, enum values).

- **`apply_personal_op(op jsonb)`** — SECURITY DEFINER, `search_path` pinned,
  same contract as `apply_group_op`: `op_id` idempotency via
  `processed_ops`, `base_revision` optimistic concurrency (`applied` /
  `conflict` with the current row / `rejected` with a code), owner checks
  (a row can only be created for, and changed by, `auth.uid()`; referenced
  people/entries must belong to the same owner). Deletes set `deleted_at`.
- **Linked deletes mirror the phone (my call):** the server applies the same
  rules as the local foreign keys when a row is tombstoned — person →
  their ledger entries (→ repayments, attachments, linked reminders) are
  tombstoned, and transactions/reminders pointing at the person get
  `person_id = null` (revision bumped); transaction or ledger entry →
  its attachments; ledger entry → linked reminders. Each change emits its
  own event, so other phones end up identical. The phone still only sends
  the one delete op.
- **`personal_sync_events`** — append-only feed `(seq, owner_id, entity_type,
  entity_id, op_type, revision, payload, op_id, created_at)`; RLS: owner reads
  own events only.
- **`reset_personal_data()`** — tombstones all of the caller's personal rows
  (used by restore, §7); emits delete events.
- Storage: private bucket **`personal-attachments`**, path
  `<owner_id>/<attachment_id>.<ext>`; policies: owner can upload/read/delete
  only under their own folder; same type and 10 MB limits as group files.
- `prepare_account_deletion` / the `delete-account` function: personal rows
  go with the user (cascade); personal files must be removed too.
- Lock-down consistent with `20261118000200_lock_down_api_surface.sql` (no
  direct insert/update/delete grants).
- SQL tests (`supabase/tests`) for: owner isolation (user B cannot read or
  change user A's rows or files), idempotency, conflicts, tombstones, value
  checks, reset.

### 2. Phone side: sync engine

- The outbox/inbox/conflict tables gain a **scope** (`group` or
  `personal`); personal ops have no group id. Cursor for the personal feed is
  stored separately from the group cursor.
- Every write in the transaction, people, ledger, repayment, reminder and
  attachment repositories writes the row **and** an outbox op in the same
  SQLite transaction (as groups do today). Local rows get the sync columns
  the group cache tables already have (revision, sync state).
- `SyncService.syncOnce()` pushes both scopes in creation order, then pulls
  both feeds. Pull never overwrites a row that has unsent or conflicting
  local changes. Conflicts use the existing Sync screen (Keep mine / Keep
  theirs), with titles for personal record types.
- Triggers unchanged: app start, return to the app, shortly after a local
  change, "Sync now". Sync runs whenever the user is signed in (the "cloud
  sync" switch in Settings is removed; signing out is the way to stop).
- Applying a pulled entry whose category id is missing on this phone first
  **re-creates the category** from the entry's snapshot (same id, name,
  type, icon, colour). Built-in categories have the same ids everywhere
  (`cat_<key>`), so this only matters for custom or renamed ones.
- Renaming or recolouring a category re-uploads the snapshot of the entries
  that use it (so a new phone shows the current name).
- Reminders pulled from the cloud get a new per-phone notification id and are
  scheduled on that phone; reminders therefore notify on every signed-in
  phone.

### 3. Groups

- Every group is a cloud group from creation; the "Share to cloud" step and
  its confirmation are removed. Creating a group needs a signed-in account
  (the account is already compulsory).
- At upgrade, existing phone-only groups are shared automatically (the
  existing `markShared` path) as part of the first upload (§5).
- Bill files on group expenses upload to the existing `group-attachments`
  bucket automatically (today only after "Share with group").

### 4. Bills and receipts (attachments)

- Saving an attachment stores the file on the phone (as today) and queues an
  upload to `personal-attachments` (or `group-attachments` for group
  expenses); the metadata row syncs through the outbox after the file is
  uploaded.
- On another phone, the file is downloaded when first shown (thumbnail or
  viewer) and kept as a cached copy; a missing download shows a "tap to
  retry" placeholder, never an error crash.
- Deleting an attachment deletes the file in storage.

### 5. First upload for existing installs

- On the first start of the new version with a signed-in account, if local
  personal data exists that was never uploaded, a full-screen
  **"Saving your hisab to your account"** step queues every record (people
  → transactions → ledger → repayments → reminders → attachments; groups via
  `markShared`) and shows progress ("120 of 450"). It can run in the
  background if the user leaves; it continues on the next start until done.
- If the account already has cloud data (e.g. the user's second phone), the
  phone's records are uploaded and the cloud records downloaded: the result
  is the union (ids are UUIDs, so nothing collides).
- Offline at that moment: the screen says so and the upload starts when the
  connection returns; the app stays usable.

### 6. Sign-in, sign-out, new phone

- New phone / reinstall: after the (compulsory) email sign-in, a
  **"Getting your hisab"** step downloads everything (personal feed from
  `seq 0`, groups via snapshots), with progress, before showing Home.
- **Sign out** wipes the phone's copy of personal records, groups, files and
  sync tables; **categories and app settings stay** (they belong to the
  phone). If there are changes not yet uploaded, sign-out warns ("3 changes
  haven't been saved to your account yet") and offers *Wait and sync* or
  *Sign out anyway*.
- Account deletion removes cloud data and files (when the `delete-account`
  function is deployed — still pending from before).

### 7. Backup and restore

- **Automatic backups are removed** (Settings option and the background
  runner); existing automatic backup files stay listed until deleted.
- Manual **"Back up now"** stays (encrypted option unchanged): a file the
  user can keep elsewhere.
- **Restore** a backup = replace the user's personal data with the backup's:
  the existing validation + safety backup + database swap runs, then
  `reset_personal_data()` tombstones the cloud copy and every personal record
  of the restored database is queued for upload. **Groups are not restored
  from a backup** (other members rely on the cloud copy); after restore,
  groups are re-downloaded from the cloud. The confirmation dialog says this
  in plain words and restore needs internet.
- **Interrupted restore (my call):** the reset is queued as the first
  outbox operation, ahead of the re-upload, in the same SQLite transaction
  that finishes the restore — so if the app closes or the network drops, the
  next sync continues in the right order (reset, then uploads).

### 8. Guided tour sample data

- Sample records stay on the phone and are never queued for upload (their ids
  are already tracked in `tour.sampleIds`; repositories skip the outbox for
  those ids, including when the user edits one). Removing sample data stays
  as today. The sample group is phone-only and is the one exception to §3.

### 9. Texts and privacy

- Replace "stays on your phone / never leaves your phone / not uploaded
  anywhere" wording everywhere (onboarding, sign-up, attachments note,
  About, Settings, README, PRIVACY_AND_SECURITY.md, SYNC_ARCHITECTURE.md,
  ARCHITECTURE.md, BACKUP_RESTORE.md, DATABASE_SCHEMA.md, RLS_SECURITY.md)
  with accurate text: data is saved to the user's HisabMitra account (in the
  app owner's Supabase project), each account sees only its own data,
  the phone keeps a copy for offline use.
- Privacy note for the owner (README/PRIVACY doc): as the project owner you
  can see every user's records in the Supabase dashboard; anyone installing
  the public APK stores their data in your project.

### 10. Status the user sees

- Sync screen: pending / failed / conflicts now include personal records.
- A small "not yet saved to your account" indicator is **not** added in B
  (the Sync screen covers it) — builder must not add new indicators.

## Testing

- SQL (Docker): owner isolation, idempotency, conflicts, tombstones, checks,
  reset, storage policies.
- Dart unit (fake cloud): every repository write queues exactly one op in the
  same transaction; push/pull for each personal entity; conflict on each;
  missing-category re-creation; reminder notification id per phone; sample
  rows never queued; first upload (fresh, partial, resumed, union with
  existing cloud data); sign-out wipe keeps categories/settings; sign-out
  warning with pending ops; restore → reset + re-upload, groups untouched.
- Drift migration test for the new schema version (sync columns, scope).
- Widget: first-upload and download progress screens; sign-out warning.
- Device (emulator, live Supabase test account): add offline → reconnect →
  row in Supabase; reinstall → sign in → data back; two-device sync.

## What is left to the builder

- Exact column names of sync metadata on the phone, op payload shapes,
  migration file names and order (one migration file is fine).
- How progress is computed and displayed (wording in both languages).
- Batch sizes for upload/download.

## Open items needing the owner (not blocking the plan)

- Database password or access token when applying the migration live.
- Deploying `delete-account` (pending since before B).
