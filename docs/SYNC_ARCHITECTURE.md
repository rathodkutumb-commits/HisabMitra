# Offline-first Synchronisation

Code: `lib/features/synchronization/data/sync_service.dart`,
`supabase_cloud_gateway.dart`; server: `apply_group_op`, `sync_events`.
Tests: `test/features/synchronization/sync_service_test.dart` (in-memory
fake cloud).

## What syncs

| Data | Syncs? |
|---|---|
| Personal transactions, categories, people, personal ledger, reminders, personal bills | **Never** |
| Groups the owner did not share | Never (local groups) |
| Shared groups: group, members, expenses + splits, settlements | Yes, between authorised members |
| Group-expense attachments | Only when a member explicitly shares the file |

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
