# Synchronisation (account + offline working copy)

Code: `lib/features/synchronization/data/sync_service.dart`,
`personal_outbox.dart`, `personal_rows.dart`, `supabase_cloud_gateway.dart`;
server: `apply_group_op` + `sync_events` (groups), `apply_personal_op` +
`personal_sync_events` + `get_personal_snapshot` (personal records).
Tests: `test/features/synchronization/` (in-memory fake cloud) and
`supabase/tests/` (PostgreSQL).

## What syncs

| Data | Syncs? |
|---|---|
| Personal transactions, people, khata entries, repayments, reminders | **Yes** — to the user's own account (scope `personal`) |
| Personal bills | Yes — file to `personal-attachments/<uid>/`, then the record |
| Categories | **No** — each entry carries a copy of its category; a missing category is re-created on another phone |
| Groups: group, members, expenses + splits, settlements, bills | Yes, between members (every group is saved to the account; the tour's sample group stays on the phone) |
| Guided-tour sample data | Never |

The outbox, inbox and conflicts carry a **scope** (`group` / `personal`);
the inbox key is `(scope, seq)` because the two feeds number events
separately.

## First sync, new phone, sign-out, restore

- **First sync** (`AccountSyncController`, screen "Saving your hisab to
  your account" / "Getting your hisab"): queues records written before
  v4 (`localOnly`), shares phone-only groups, then syncs until nothing is
  queued. A phone that never pulled loads `get_personal_snapshot`.
- **Sign-out / account deletion** wipe the phone's copy (categories and
  settings stay) after warning about unsent changes.
- **Restore**: the restored database gets a `reset` op first, then every
  personal record, before it is swapped in (`RestoreSync`). The server's
  `reset` tombstones the account's records and emits one `reset` event;
  other phones drop their copy and receive the re-uploaded records. Groups
  are never taken from a backup.

## Write path (push)

1. A change to a shared group is written to the local cache table **and**
   to `sync_outbox` in the same SQLite transaction. The row's `sync_state`
   becomes `pending`.
2. `SyncService.push()` sends outbox ops in creation order to
   `apply_group_op`. Each op carries a unique `op_id` and the
   `base_revision` it was made against.
3. Only on `applied` does the local row become `synced` with the server's
   revision. A change is never marked synced before the server confirms it.
4. Network or 5xx errors: the op stays queued with exponential backoff
   (5 s, 10 s, 20 s … capped at 30 min). Retries reuse the `op_id`, so the
   server applies each op at most once (`processed_ops`).
5. `rejected`: the op is marked failed with its code; the user can retry
   after fixing the cause.

## Read path (pull)

1. `pull()` reads `sync_events` after the stored cursor (`sync.cursor`
   setting), in `seq` order, and stores them in `sync_inbox`.
2. Events are applied when the local row is older than the event revision
   and has no unsent or conflicting local change.
3. Deletes are tombstones (`deleted_at`) so they propagate to every device.
4. After accepting an invitation (or on events for an unknown group), the
   app loads `get_group_snapshot` and continues from its `max_seq`.

## Conflicts

Financial records are **never** resolved with last-write-wins. When the
server answers `conflict`, a `sync_conflicts` row stores the local payload
and the server's current payload. The Sync screen lists open conflicts and
the user chooses:

- **Keep mine** — re-sends the local version on top of the server revision.
- **Keep theirs** — replaces the local copy with the server version.

## Status shown to the user

Sync screen: signed-in state, pending/failed op counts, open conflicts, last
successful sync time, "Sync now" and "Retry failed".

## Triggers

App start and resume (when signed in and cloud sync is enabled), after a
local change to a shared group, and the manual "Sync now".

## Tested scenarios

Offline create then reconnect; duplicate push of the same op; retry with
backoff; server conflict creates a conflict row (no overwrite); keep
mine / keep theirs; delete tombstone propagation; second device pulls the
first device's changes; joining a group via snapshot.
