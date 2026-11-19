# Backend API

All endpoints belong to the Supabase project (`https://<ref>.supabase.co`).
The app calls them through `supabase_flutter` from
`lib/features/synchronization/data/supabase_cloud_gateway.dart`, behind the
`CloudGateway` interface (a fake implementation is used in tests).

Every call sends the publishable key (`apikey`) and, except OTP requests, the
user's JWT (`Authorization: Bearer …`). Errors are mapped to `AppFailure`
types; raw database or HTTP messages are never shown to users.

## Authentication (Supabase Auth)

| Operation | Method | Request | Response / errors |
|---|---|---|---|
| Send email code / link | `auth.signInWithOtp(email, emailRedirectTo: hisabmitra://login-callback, shouldCreateUser: true)` → `POST /auth/v1/otp` | normalised email | 200; 429 rate limit; 400 `email_address_invalid`; 400 `email_address_not_authorized` (built-in mailer, address outside the project team) |
| Verify code | `auth.verifyOTP(email, token, type: email)` → `POST /auth/v1/verify` | email, 6–10 digit code | session; 401/403 invalid or expired code |
| Verify link | `auth.exchangeCodeForSession(code)` (PKCE) | `code` from `hisabmitra://login-callback` | session; `flow_state_not_found` / `bad_code_verifier` when expired or opened on another phone |
| Refresh | handled by `supabase_flutter` | refresh token | new session |
| Sign out | `auth.signOut()` | — | — |

## Tables (read only, RLS-filtered)

| Table | Used for |
|---|---|
| `user_profiles` | upsert own display name and mobile number (`phone`, E.164, required) after email verification |
| `user_devices` | upsert this device (`id`, `platform`, `app_version`, `last_seen_at`) |
| `sync_events` | pull change feed: `select … where seq > :cursor order by seq limit 500` |
| `group_invitations` | admins list invitations of a group |

## RPCs (`POST /rest/v1/rpc/<name>`)

### `apply_group_op(p_op jsonb) → jsonb`

Applies one queued group change. Auth: member of the group (admin for group
and member changes).

Request:

```json
{
  "op_id": "uuid (idempotency key)",
  "group_id": "uuid",
  "entity_type": "group | member | expense | settlement",
  "entity_id": "uuid",
  "op_type": "upsert | delete",
  "base_revision": 3,
  "payload": { "...entity fields; expenses include splits[]" }
}
```

Responses:

| `status` | Meaning | Client action |
|---|---|---|
| `applied` + `revision` | Stored. | Mark local row synced at that revision. |
| `conflict` + `revision` + `current` | Server row changed since `base_revision`. | Create a `sync_conflicts` row with both versions; ask the user. |
| `rejected` + `code` | Invalid. Codes: `bad_request`, `forbidden`, `not_found`, `unsupported`, `member_in_use`, `invalid_member`, `split_mismatch`, `invalid_data`. | Mark op failed; show a localised message. |

Re-sending an `op_id` returns the original result without applying it again.

### `get_group_snapshot(p_group_id uuid) → jsonb`

Full state of a group: `{group, members[], expenses[] (with splits),
settlements[], max_seq}`. Auth: member. Used after joining a group.
Error: `forbidden` (42501).

### `create_group_invitation(p_group_id uuid, p_member_id uuid = null, p_ttl_hours int = 72) → jsonb`

Returns `{invitation_id, code, expires_at}`. The plain code is returned only
once. Auth: admin. Errors: `forbidden`, `invalid_member`,
`invitation_pending`, `not_authenticated`.

### `accept_group_invitation(p_code text, p_display_name text) → jsonb`

Returns `{group_id, member_id}`. Takes over the placeholder member when the
invitation named one, otherwise adds a new member. Errors: `invalid_code`,
`expired`, `already_member`, `not_authenticated`.

### `cancel_group_invitation(p_invitation_id uuid) → void`

Auth: admin of the invitation's group. Error: `forbidden`.

### `register_group_attachment(p jsonb) → jsonb`

Registers an uploaded file (`id`, `group_id`, `expense_id`, `storage_path`,
`mime_type`, `size_bytes`, `sha256`). Auth: member. Upload itself goes to
Storage bucket `group-attachments` at
`<group_id>/<expense_id>/<attachment_id>.<ext>`.

## Edge Function

### `POST /functions/v1/delete-account`

Auth: user JWT. Runs `prepare_account_deletion()` as the user (hands over
owned groups, keeps shared history as plain participants, removes profile
and devices), then deletes the auth user with the service-role key.
Responses: `{ok: true}`; 401 `not_authenticated`; 405; 500
`prepare_failed` / `delete_failed` / `server_misconfigured`. Status
2026-11-19: not deployed yet (see SUPABASE_SETUP.md §5).

## External (non-Supabase)

| Service | When | Data sent |
|---|---|---|
| GitHub Releases API `GET /repos/{owner}/{repo}/releases/latest` | User taps "Check for updates" | none (public endpoint) |
| Anthropic Messages API `POST https://api.anthropic.com/v1/messages` | Only if the user enabled online AI, entered their own key and gave consent | the question plus aggregated figures computed locally; names only if allowed. See AI_ASSISTANT.md |
