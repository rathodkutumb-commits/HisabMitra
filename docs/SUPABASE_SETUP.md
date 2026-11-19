# Supabase Setup

HisabMitra works fully offline without Supabase. Supabase is only used for
**shared groups** (multi-device, multi-member) and for the **email-verified account**.
Personal transactions, people, the personal ledger, reminders and bills are
never uploaded.

## 1. Project

| Item | Value |
|---|---|
| Project name | Hisabmitra |
| Project ref | `zjidwksngkxcsryzgnoe` |
| API URL | `https://zjidwksngkxcsryzgnoe.supabase.co` |
| Client key | Publishable key (`sb_publishable_…`) — safe to ship in the APK |

Never put the **secret / service-role key** or the **database password** in
the app, in `dart_defines.json`, in docs or in Git. The service-role key is
only available to Edge Functions as a server-side secret.

## 2. App configuration

Configuration is supplied at build time with `--dart-define-from-file`:

```bash
cp dart_defines.example.json dart_defines.json   # git-ignored
# fill SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY
flutter run --dart-define-from-file=dart_defines.json
```

When the values are empty the app runs offline and the cloud screens show
"cloud not configured" — nothing is faked.

## 3. Database (status: applied)

Migrations live in `supabase/migrations/` and were applied to the live
project on 2026-11-18 over a direct `psql` connection, then recorded in
`supabase_migrations.schema_migrations`, so `supabase db push` treats them as
applied.

| Migration | Contents |
|---|---|
| `20261118000000_hisabmitra_init.sql` | 11 tables, RLS on every table, membership helpers, `apply_group_op`, snapshot, invitation and account-deletion RPCs |
| `20261118000100_group_attachments_storage.sql` | Private `group-attachments` bucket (10 MB, images + PDF), member-only storage policies, `register_group_attachment` |
| `20261118000200_lock_down_api_surface.sql` | Removes Supabase's default EXECUTE/table grants so only intended RPCs and reads are exposed |
| `20261119000000_profile_phone.sql` | Compulsory `phone` (E.164 check) on `user_profiles`; owner-only via RLS |

2026-11-19: `20261119000000_profile_phone` tested (53/53 SQL checks) and
applied to the live project; 4 migrations recorded, 11 tables with RLS
enabled, 13 functions, private bucket, 0 users.

**Applying a future migration**

1. Add `supabase/migrations/<timestamp>_<name>.sql`.
2. Run `bash tool/run_supabase_tests.sh` (Docker; throw-away PostgreSQL with
   a Supabase shim) — all checks must pass. CI runs the same script.
3. Apply with the Supabase CLI (`supabase link --project-ref
   zjidwksngkxcsryzgnoe && supabase db push`) or `psql` over the direct
   connection, and record the version in
   `supabase_migrations.schema_migrations`.

## 4. Authentication (email verification)

Sign-up is compulsory: name, email and mobile number; the **email** is
verified (AUTHENTICATION_FLOW.md). Phone/SMS sign-in is not used.

### 4.1 Settings (Authentication → Sign In / Providers)

| Setting | Required value |
|---|---|
| Email provider | **Enabled** (status 2026-11-19: enabled) |
| Confirm email | On (default) |
| Phone provider | Not needed (may stay disabled) |
| Anonymous sign-ins | Disabled |
| Email OTP expiry | 3600 s or less (default 1 hour) |

### 4.2 Redirect URL for the email link (Authentication → URL Configuration)

Add **`hisabmitra://login-callback`** to **Redirect URLs**. Without it,
Supabase sends the link to the Site URL and tapping it in the email will not
open the app (the code still works).

### 4.3 Email sender (custom SMTP) — needed for real users

Supabase's built-in mailer is for testing only: it **delivers only to
members of the Supabase project team** (others get "email address not
authorized" — the app shows "email sender not set up"), has a very low
hourly limit, and on new free projects its templates cannot be edited.

Set a custom SMTP sender in **Project Settings → Authentication → SMTP
Settings** (free options):

| Provider | Free allowance (check current terms) | Notes |
|---|---|---|
| Gmail SMTP | daily sending limit of a Gmail account | `smtp.gmail.com`, port 465 or 587, user = your Gmail, password = a Google **App Password** (needs 2-step verification). Emails come from your Gmail address. |
| Brevo | free daily quota | Verify a single sender address; no own domain needed. |
| Resend / others | free tiers | Usually need your own domain verified. |

After SMTP is set, raise the Auth email rate limit if needed (Authentication
→ Rate Limits).

### 4.4 Email templates — send a code, not only a link

With custom SMTP the templates can be edited (Authentication → Emails →
Templates). Edit **Confirm signup** and **Magic Link** so they contain the
code; keeping the link as a second option is fine:

```html
<h2>Your HisabMitra code</h2>
<p>Enter this code in the app:</p>
<p style="font-size:28px;letter-spacing:6px"><b>{{ .Token }}</b></p>
<p>Or open this link on the same phone: <a href="{{ .ConfirmationURL }}">Verify email</a></p>
<p>If you did not request this, ignore this email.</p>
```

The app accepts 6–10 digit codes (Supabase's code length is configurable).

### 4.5 Testing before SMTP is configured

Use an email address of a Supabase team member (for example the project
owner's). The default template sends a **link**: open the email on the
phone where the app is waiting and tap it — the app completes verification
through `hisabmitra://login-callback` (needs §4.2).

## 5. Edge Function: `delete-account`

Status 2026-11-19: **not deployed** (`/functions/v1/delete-account` returns
404). Until it is deployed, in-app account deletion cannot remove the cloud
account.

```bash
supabase login
supabase link --project-ref zjidwksngkxcsryzgnoe
supabase functions deploy delete-account
```

`SUPABASE_URL`, `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` are
injected by the Supabase runtime; nothing else needs configuring. The
function keeps JWT verification on.

## 6. Storage

Bucket `group-attachments` (private, 10 MB, `image/jpeg`, `image/png`,
`image/webp`, `image/heic`, `application/pdf`). Object path:
`<group_id>/<expense_id>/<attachment_id>.<ext>`. Members of the group can
read and upload; nobody can update or delete through the API.

## 7. Checklist for the project owner

- [x] Project created, migrations applied (4), RLS verified
- [x] Publishable key in `dart_defines.json` (local, git-ignored)
- [x] Email provider enabled
- [x] Redirect URL `hisabmitra://login-callback` added (§4.2)
- [x] Custom SMTP sender configured (§4.3) — Gmail, port 587
- [x] Confirm signup template contains `{{ .Token }}` (§4.4) — check Magic Link too
- [ ] `delete-account` Edge Function deployed (§5)
- [ ] Database password reset (it was shared in chat)
- [x] GitHub secrets `SUPABASE_URL` / `SUPABASE_PUBLISHABLE_KEY` for release builds
