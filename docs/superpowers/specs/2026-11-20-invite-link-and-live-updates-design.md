# Part C (1 and 2) — Invite link and live updates (design)

Date: 2026-11-20. Approved by the owner ("please do Invite link and Live
updates first, later Notification"). Notifications (C3) come later and need
a Firebase project; the open question there (what a notification says) is
parked.

## Intent

- **Invite link (owner's item 4):** a group invite shared on WhatsApp has a
  tappable link; tapping it opens HisabMitra and the person joins the group
  directly when signed in. WhatsApp does not make `hisabmitra://` links
  tappable (owner's screenshot), so the link must be a normal https page.
- **Live updates (item 5):** when someone adds an expense or a member joins,
  the change shows on the other members' phones within seconds while their
  app is open — and the user's own records on their other phone too.

## Non-goals

- Notifications while the app is closed (C3, later).
- Verified Android App Links (opening the app with no browser step needs a
  separate `rathodkutumb-commits.github.io` repository; possible later).
- Changes to how invitations are created, cancelled or expire.

## Design

### 1. Join page (GitHub Pages)

- New folder `web/` in the repo, deployed by a GitHub Actions workflow to
  GitHub Pages (only this folder is published). Link:
  `https://<owner>.github.io/<repo>/join?code=<CODE>` — with today's
  settings `https://rathodkutumb-commits.github.io/HisabMitra/join?code=…`.
- `web/join.html` (English and Gujarati, Rann Utsav colours, logo):
  - Reads `code`; accepts only 6–12 letters/digits, otherwise shows "This
    invitation link is not valid".
  - On Android it tries to open the app at once
    (`intent://join?code=…#Intent;scheme=hisabmitra;package=com.hisabmitra.app;…`)
    and always shows a big **Open in HisabMitra** button (browsers may need
    a tap), the code itself, and **Download HisabMitra** (latest release)
    for people without the app, plus "then open Groups → Join a group and
    enter the code".
  - No tracking, no external scripts.
- My call: Pages is switched on with the `rathodkutumb-commits` GitHub
  account already logged in here (repository owner); the workflow deploys
  on pushes to `main` that touch `web/`.

### 2. Invite message

- The shared text gains the link line agreed in the A mock-up:
  "👉 Tap to join: {link}" followed by "Or open HisabMitra → Groups → Join a
  group, and enter the code." (Gujarati too). When the build has no GitHub
  repository configured, the link line is left out (as with the download
  line).

### 3. Joining from a link in the app

- `hisabmitra://join?code=…` (what the page opens) is remembered as a
  **pending invitation** (saved on the phone, so it survives the app being
  closed while the user reads their sign-up email).
- When the account is ready (signed in, first sync done or deferred), the
  app joins automatically — no "Join" tap — shows "You joined {group}" and
  opens the group. Not signed in → after sign-up/sign-in it continues
  automatically.
- If joining fails (expired, cancelled, already used, offline) the user sees
  the reason on the Join screen with the code filled in, and the pending
  invitation is cleared (no retry loops).
- The manual "Join a group" screen keeps working as today.

### 4. Live updates (Supabase Realtime)

- Migration: add `sync_events` and `personal_sync_events` to the
  `supabase_realtime` publication. Realtime applies the tables' RLS, so a
  phone only hears about its own records and its own groups.
- App: while signed in and in the foreground, the app listens for new rows
  in both feeds; each signal triggers the existing sync (debounced ~1 s),
  so screens update through the normal pull. Listening stops when the app
  goes to the background and restarts when it returns.
- Behind the `CloudGateway` interface (`changeSignals()`), so tests use the
  fake cloud.

## Testing

- SQL (Docker): both feed tables are in the `supabase_realtime`
  publication (the test shim creates the publication).
- Dart: invite message with link (en/gu, without repo → no link line);
  pending invite saved from a link, joined automatically once the account is
  ready, cleared on failure; live update: a change on phone 1 reaches phone
  2 without a manual sync (fake cloud signal).
- Page: opened in the emulator's Chrome with a code → app opens on the join
  flow.
- Device (live): needs two accounts the owner can sign in to; reported if
  not done.

## Left to the builder

- Page layout details and wording (both languages); Realtime channel names;
  debounce value; where the pending-invite listener lives.
