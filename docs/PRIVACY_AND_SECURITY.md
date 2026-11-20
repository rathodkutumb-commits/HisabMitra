# Privacy and Security

## Data location

Since Part B (2026-11-20) personal records are saved to the user's account;
the phone keeps a working copy (offline use) that sign-out removes.

| Data | Stored | Who can read it |
|---|---|---|
| Transactions, people, personal ledger and repayments, reminders | Supabase (`personal_*` tables) + a copy in local SQLite | Only the owner (RLS `owner_id = auth.uid()`) |
| Personal bills and receipts | Supabase Storage `personal-attachments/<user id>/` + a local copy | Only the owner |
| Categories | Local SQLite only (entries carry a copy of their category's name/icon) | — |
| Settings | Local SQLite | Only inside a backup the user exports |
| Groups (members, expenses, splits, settlements) | Supabase + local copy; every group is saved to the account (the guided tour's sample group stays on the phone) | Members of that group |
| Group bills | Supabase Storage `group-attachments` + local copy | Members of that group |
| Name, email, mobile number | Device + Supabase (email in Auth, name and phone in `user_profiles`, owner-only) | Yes — required for the compulsory account (since 2026-11-19). Group members see only the display name. |
| Supabase session, AI API key | Android Keystore-backed secure storage | No (session tokens go only to Supabase) |
| AI questions | — | Only with online AI enabled + consent: the question and computed totals go to Anthropic (AI_ASSISTANT.md) |

## Cloud-sharing features and their privacy impact

| Feature | What other people / services can see |
|---|---|
| Groups | Group members see the group's expenses, splits, settlements, bills and member names. Nothing personal outside the group. |
| Invite a member | The invitee sees the group after accepting. Codes expire (default 72 h), are single-use and stored only as hashes. |
| Online AI | Anthropic processes the question and aggregated figures under the user's own API account. |
| Update check | GitHub sees an anonymous request for the latest release. |

## Controls

- RLS on every cloud table, writes only through checked RPCs, `anon` locked
  out, no service-role key in the app (RLS_SECURITY.md).
- Optional backup encryption (AES-256-GCM, PBKDF2 210 000); passwords never
  stored.
- Account deletion (Edge Function) — personal records and bill files are
  deleted with the account; shared group history stays with the group as a
  plain participant; the phone's copy is removed.
- Sign-out removes the phone's copy (records stay in the account); it warns
  first when changes have not been uploaded yet.
- The Supabase project owner can see every user's records in the
  dashboard; anyone installing the public APK stores data in that project.
- Notifications hide amounts by default ("Hide amounts in notifications").
- Reminders use exact alarms (`USE_EXACT_ALARM`, Android 13+; `SCHEDULE_EXACT_ALARM`
  up to Android 12) so they arrive on time. Google Play allows `USE_EXACT_ALARM`
  only for alarm/calendar-type apps; a Play listing would need to ask the user
  for "Alarms & reminders" instead.
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
