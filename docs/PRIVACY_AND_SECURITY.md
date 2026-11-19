# Privacy and Security

## Data location

| Data | Stored | Leaves the phone? |
|---|---|---|
| Transactions, categories, people, personal ledger, reminders, bills | Local SQLite + app-private files | **No.** Only if the user exports/shares a report or backup file. |
| Settings | Local SQLite | Only inside a backup the user exports |
| Local groups | Local SQLite | No |
| Shared groups (members, expenses, splits, settlements) | Local + Supabase | Yes, to members of that group only, after the owner chose "Share to cloud" |
| Group bills | Local; Supabase Storage only if a member taps "Share with group" | Only for that file |
| Name, email, mobile number | Device + Supabase (email in Auth, name and phone in `user_profiles`, owner-only) | Yes — required for the compulsory account (since 2026-11-19). Group members see only the display name. |
| Supabase session, AI API key | Android Keystore-backed secure storage | No (session tokens go only to Supabase) |
| AI questions | — | Only with online AI enabled + consent: the question and computed totals go to Anthropic (AI_ASSISTANT.md) |

## Cloud-sharing features and their privacy impact

| Feature | What other people / services can see |
|---|---|
| Share a group to cloud | Group members see the group's expenses, splits, settlements and member names. Nothing personal outside the group. |
| Invite a member | The invitee sees the group after accepting. Codes expire (default 72 h), are single-use and stored only as hashes. |
| Share a bill with the group | Group members can view that one file. It cannot be edited or deleted through the API. |
| Online AI | Anthropic processes the question and aggregated figures under the user's own API account. |
| Update check | GitHub sees an anonymous request for the latest release. |

## Controls

- RLS on every cloud table, writes only through checked RPCs, `anon` locked
  out, no service-role key in the app (RLS_SECURITY.md).
- Optional backup encryption (AES-256-GCM, PBKDF2 210 000); passwords never
  stored.
- Account deletion (Edge Function) — shared history stays with the group as
  a plain participant; local data is never deleted by it.
- Sign-out keeps local data.
- Notifications hide amounts by default ("Hide amounts in notifications").
- Input validation on every form and on the server (`CHECK` constraints,
  RPC validation).
- Errors shown to users are localised messages, never raw database or HTTP
  errors.
- `SafeLogger` never logs OTPs, tokens, passwords, amounts, descriptions or
  file contents.
- Release APKs must be signed with the release key (CI enforces it) and
  updates are checksum-verified before install.
- Secrets: `dart_defines*.json`, `key.properties`, `*.jks`, `.env*` are
  git-ignored. The database password and service-role key are never stored
  in the repository or the app.

## Known gaps

- The local database is not encrypted at rest (relies on Android app
  sandboxing and device encryption). SQLCipher could be added later.
- The mobile number is not SMS-verified (no SMS provider); only the email is verified.
- Until custom SMTP is configured, verification emails reach only Supabase project team members.
- The Supabase database password was shared in chat on 2026-11-18 and
  2026-11-19 — **reset it** in Supabase → Settings → Database.
