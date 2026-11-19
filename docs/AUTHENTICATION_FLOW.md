# Authentication Flow

Code: `lib/features/authentication/` (controller, verify screen, secure
session storage), `lib/features/onboarding/presentation/profile_setup_screen.dart`
(account details), gateway in `supabase_cloud_gateway.dart`.

## Decision (TD-05, revised 2026-11-19)

A verified account is **compulsory** (product owner decision of
2026-11-19, replacing the optional phone-OTP sign-in):

- **Name, email address and mobile number are all required.**
- **The email address is verified** by a code (or link) sent by Supabase
  Auth. The mobile number is collected and stored but **not** SMS-verified
  (no SMS provider; see SUPABASE_SETUP.md §4).
- The account is created **at first launch**, during onboarding. The app
  needs internet once for that; afterwards it works fully offline.
- Personal records still stay on the phone; the account identifies the user
  for shared groups.

## Flow

```
Splash → Language → Intro → Account details ───────────► Verify email ──► Dashboard
                            name, email, mobile           code (6–10 digits)
                            validated on device           or tap the link
                            "Send verification code"      in the email on this phone
                                    │                             │
                                    ▼                             ▼
                        signInWithOtp(email,               verifyOTP(email, code, type: email)
                          emailRedirectTo:                 or exchangeCodeForSession(code)
                          hisabmitra://login-callback,             │
                          shouldCreateUser: true)                  ▼
                                                     save profile (name, email, phone,
                                                     Supabase user id) on the device
                                                     upsert cloud user_profiles (name, phone)
                                                     + user_devices; account verified;
                                                     background sync; tour offered
```

- Details entered before verification are saved on the device
  (`app_settings` key `account.pending`), so tapping the email link works
  even if the app was closed in between.
- Resend is allowed after 60 s. Codes are accepted with 6–10 digits
  (Supabase's length is configurable).
- The email link opens `hisabmitra://login-callback?code=…`; the router
  sends it to the verify screen, which completes the PKCE exchange. Group
  invitation links (`hisabmitra://join?code=…`) are handled separately.
- Errors are localised: invalid email/phone, wrong or expired code, link
  expired or opened on another phone, too many requests, offline, and
  "email sender not set up" (Supabase's built-in mailer refuses addresses
  outside the project team until custom SMTP is configured).

## Route guard

When the build has a Supabase configuration and the account is not
verified on this device, every screen redirects to the account step. This
covers new installs, existing installs from before 2026-11-19, sign-out and
a lost cloud session. Local data is never touched.

Builds without a Supabase configuration (development, tests) still require
name, email and phone, keep them on the device, and skip verification.

## Session

Stored with `flutter_secure_storage` (Android Keystore) and refreshed by
`supabase_flutter`. Once verified, the app keeps working offline; if the
server later rejects the session (signed out elsewhere, revoked), cloud
screens mark the account unverified and the guard asks to verify again.

## Sign-out and account deletion

- **Sign out** (Profile): local data stays; the app asks to verify the email
  again before continuing.
- **Delete account** (Profile): Edge Function `delete-account` hands shared
  groups over and removes the cloud account; nothing local is deleted; a
  new verified account is needed to continue. Requires the Edge Function to
  be deployed.

## Tests

`test/features/authentication/auth_controller_test.dart` (validation,
code, link, restart persistence, offline build, sign-out, lost session),
`test/core/utils/email_test.dart`, app flows "sign-up: name, email and
phone, verified by the emailed code" and "an install without a verified
email is asked to verify first", SQL checks for the profile phone.
