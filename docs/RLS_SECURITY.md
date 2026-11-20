# Row Level Security and Server-side Authorisation

Source of truth: `supabase/migrations/`. Tested by
`supabase/tests/10_rls_and_rpc_test.sql` (run with
`bash tool/run_supabase_tests.sh`; also in CI).

## Principles

1. **RLS is enabled on every table** in `public`. A table without a policy
   is closed to clients (`processed_ops`).
2. **Clients never write group data directly.** `insert/update/delete` on
   group tables is revoked from `anon` and `authenticated`. All group writes
   go through `SECURITY DEFINER` RPCs that check membership, role, revision
   and idempotency.
3. **Membership is the only key to group data.** Knowing a group name, id
   or a member's phone number gives no access. Access is created only by
   creating the group or by accepting a valid invitation.
4. **`anon` has nothing.** All table privileges and function EXECUTE grants
   are revoked from `anon`, and default privileges are revoked so future
   objects are closed until a migration grants them explicitly
   (`20261118000200_lock_down_api_surface.sql`).
5. **No service-role key in the app.** It exists only in the
   `delete-account` Edge Function runtime.
6. **Helper functions are hardened:** `SECURITY DEFINER`,
   `set search_path = ''`, fully qualified names.

## Helpers

| Function | Returns true when |
|---|---|
| `is_group_member(group_id)` | `auth.uid()` has an active, non-deleted `group_members` row in the group |
| `is_group_admin(group_id)` | as above with role `owner` or `admin` |

## Table policies

| Table | Client privileges | Policy |
|---|---|---|
| `user_profiles` | select, insert, update | own row only (`id = auth.uid()`); `phone` required, E.164 check |
| `user_devices` | select, insert, update, delete | own rows only (`user_id = auth.uid()`) |
| `groups` | select | `is_group_member(id)` |
| `group_members` | select | `is_group_member(group_id)` |
| `group_expenses` | select | `is_group_member(group_id)` |
| `group_expense_splits` | select | parent expense's group membership |
| `group_settlements` | select | `is_group_member(group_id)` |
| `group_attachments` | select | `is_group_member(group_id)` |
| `group_invitations` | select | `is_group_admin(group_id)` — members cannot list codes |
| `sync_events` | select | `is_group_member(group_id)` |
| `processed_ops` | none | no policy → no access |
| `personal_people`, `personal_transactions`, `personal_ledger_entries`, `personal_ledger_repayments`, `personal_reminders`, `personal_attachments` | select | `owner_id = auth.uid()` — each user sees only their own records |
| `personal_sync_events` | select | `owner_id = auth.uid()` |

## Storage (`group-attachments`, private)

| Operation | Rule |
|---|---|
| read | member of the group named by the first path segment |
| upload | same; metadata is then registered via `register_group_attachment` |
| update / delete | no policy → denied |

## Storage (`personal-attachments`, private)

| Operation | Rule |
|---|---|
| read / upload / delete | only objects in the caller's own folder (`<auth.uid()>/…`) |
| update | no policy → denied |

These storage policies need the Supabase Storage schema, so the Docker test
harness skips them; they are checked on the live project after the migration
is applied (two test accounts: one cannot read or delete the other's files).

## RPC authorisation summary

| RPC | Caller must be | Notable checks |
|---|---|---|
| `apply_group_op(op)` | authenticated | member (admin for member/group changes), revision match, split sum = amount, payer/members belong to group, op id idempotency |
| `get_group_snapshot(group_id)` | member | — |
| `create_group_invitation(group_id, member_id?, ttl_hours)` | admin | target member has no account, one pending invite per member, TTL 1–720 h |
| `accept_group_invitation(code, display_name)` | authenticated | code hash match, not expired/cancelled/used, not already a member |
| `cancel_group_invitation(invitation_id)` | admin of that group | — |
| `register_group_attachment(p)` | member | path inside the group folder, allowed MIME, ≤ 10 MB |
| `apply_personal_op(op)` | authenticated | own rows only (others answered as `not_found`), every referenced record is the caller's and live, reminder groups must be the caller's groups, revision match, op id idempotency; deletes mirror the phone's links |
| `get_personal_snapshot()` | authenticated | caller's live records only |
| `prepare_account_deletion()` | authenticated (self) | used by the Edge Function before removing the auth user |

Invitation codes are 10 characters from an unambiguous alphabet generated
with `gen_random_bytes`; only their SHA-256 is stored.

## Tests (53 checks, all passing on 2026-11-19)

`10_rls_and_rpc_test.sql` covers: non-members cannot read any group table;
members cannot write tables directly; `anon` cannot call RPCs; revision
conflicts; idempotent replays; split mismatch rejection; invitation expiry,
reuse, cancellation, already-member; admin-only invitation listing; account
deletion hand-over; profile phone required and owner-only.
