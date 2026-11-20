# Part A — fixes and small features (design)

Date: 2026-11-20. Approved by the owner the same day.
Part of a three-part request: **A** (this document), **B** move personal
data to Supabase, **C** live groups (invite links, live refresh, push
notifications). B and C get their own designs.

## Intent

The owner tested v1.0.1 on a phone and found a crash and several rough
edges. Part A fixes those and adds small, self-contained features that
don't depend on the data move in B.

## Goals

1. **Camera crash (item 1).** Adding a photo to a form must never freeze or
   close the app.
2. **Floating AI button (item 2).** The AI assistant is one tap away from
   the main pages, like WhatsApp's AI button.
3. **Back button (item 3).** Back never closes the app by surprise. The
   last back asks for confirmation.
4. **Reminders on time (item 7).** Reminder notifications appear at the
   time the user set.
5. **More AI examples (item 9).** More example questions, in English and
   Gujarati.
6. **Nicer shared messages (added 2026-11-20).** Every message the app
   shares looks clean in WhatsApp: spacing, emojis, *bold*.

## Non-goals

- Anything that needs the cloud data move (B) or group sync changes (C).
- New AI capabilities. The examples only cover questions the assistant
  can already answer.
- A release. Publishing a new version is the owner's call.

## Constraints

- Light theme only, existing palettes; no visual identity changes
  (see the theme decisions).
- English and Gujarati for every new text.
- `flutter analyze` clean and all tests passing before handing back.

## Design

### 1. Camera crash

**Root cause (confirmed on the emulator with a release build):**
`_Thumb.build` in `lib/features/attachments/presentation/attachments_editor.dart`
reassigns `content` to a `FutureBuilder` whose builder returns `content`
while the file future is pending. The closure captures the variable, so
the FutureBuilder returns itself. Debug builds stop this with an assertion
("A build function returned context.widget"). Release builds recurse until
"Stack overflow", the UI thread hangs, and Android closes the app as not
responding. Any image attachment triggers it (camera or gallery).

**Fix:** keep the placeholder icon in its own final variable and return
that while loading. Add a widget test that shows a staged image thumbnail
and asserts no exception and a rendered `Image`.

**Safeguard:** on low-memory phones Android may kill the app while the
camera is open. On form start, call `ImagePicker().retrieveLostData()` and,
if a photo is returned, stage it into the open form's attachments so the
photo isn't lost. (Builder's call: where to hook this so it reaches the
right form; if the form itself was lost, show a short notice instead.)

### 2. Floating AI button

- Small round button with the AI icon, bottom-right, stacked **above** the
  page's own floating "+" button. On pages without one, it sits where the
  "+" would be.
- **Shown on:** the five tabs (Home, Hisab, Khata, Groups, More) and
  list/detail pages (person, group, reports, reminders and similar).
- **Hidden on:** add/edit forms, the AI chat itself, onboarding and
  sign-in, the calculator, and whenever the keyboard or the Gujarati keypad
  is open.
- Tapping opens the existing AI chat page.
- **The on-phone assistant becomes on by default** (it sends nothing
  anywhere). Settings are saved as a whole, so a stored "off" can't be told
  apart from the old default: every existing install gets it on once (new
  settings key; the old one is ignored). The online Claude option stays off
  until the user turns it on.
- If the user turns the assistant off in Settings → AI, the button hides.
- Owner's confirmation (2026-11-20): AI on → button at the bottom right,
  above the bottom navigation bar; AI off → no AI button at all; tapping it
  opens the AI assistant chat screen directly.
- Must not cover the guided tour's spotlight targets in a way that breaks
  the tour.

### 3. Back button

- Inner (pushed) page: back goes to the previous page, unchanged.
- Hisab, Khata, Groups or More tab at its root: back switches to Home.
- Home tab at its root, and onboarding/sign-in screens: back shows
  "Exit HisabMitra?" with **Exit** and **Stay**. Exit closes the app;
  Stay dismisses the dialog.
- Works with Android's predictive back (`enableOnBackInvokedCallback` is on).

### 4. Reminders on time

- Schedule with exact alarms (`AndroidScheduleMode.exactAllowWhileIdle`).
- Manifest: `USE_EXACT_ALARM` (Android 13+, granted automatically) and
  `SCHEDULE_EXACT_ALARM` with `maxSdkVersion="32"` for Android 12.
  If exact scheduling still fails at runtime, fall back to inexact rather
  than dropping the reminder.
- **Trade-off accepted:** Google Play only allows `USE_EXACT_ALARM` for
  alarm/calendar-type apps. Fine for GitHub releases; a Play listing would
  need to switch to asking the user for "Alarms & reminders".
- Confirm reminders are scheduled again after a phone restart and after an
  app update (the plugin's boot receiver; verify, don't assume).
- Add a short tip on the reminders screen: some phones (Xiaomi, Oppo,
  Vivo) can block reminders in battery saving; link to the app's battery
  setting.

### 5. More AI examples

- About 18 example questions, in English and Gujarati, grouped under:
  Spending, Income & savings, Khata, Groups, Add an entry.
- Only questions the current intent parser answers (spend / income /
  savings for today, this month, last month, this year; top category; top
  expenses; compare months; tips; receivables; person balance; group
  total; who owes whom; add-entry drafts).
- Two or three examples are built from the user's own data: their most
  recent people and groups (e.g. "What is my balance with Rahul?",
  "Who owes whom in Goa trip?"). Shown only when such data exists.
- Each example must be checked against the parser so it lands on the
  intended intent (a test per example).

### 6. Shared messages (approved wording)

The app shares two text messages; reports and backups are shared as files.
WhatsApp formatting (`*bold*`) is used; other apps may show the asterisks.

**Group invite** (English; Gujarati follows the same layout):

```
👋 *Join my group on HisabMitra!*

👥 Group: *{group}*
🔑 Invite code: *{code}*

Open HisabMitra → Groups → Join a group, and enter the code.

⏳ The code is valid till *{date}*.

📲 Don't have the app? Download it free: {downloadUrl}
```

Gujarati (as approved from the mock-up):

```
👋 *હિસાબમિત્રમાં મારા ગ્રુપમાં જોડાઓ!*

👥 ગ્રુપ: *{group}*
🔑 આમંત્રણ કોડ: *{code}*

હિસાબમિત્ર ખોલો → ગ્રુપ → ગ્રુપમાં જોડાઓ, અને કોડ લખો.

⏳ કોડ *{date}* સુધી માન્ય છે.

📲 એપ નથી? મફત ડાઉનલોડ કરો: {downloadUrl}
```

Part C adds a "👉 Tap to join: {link}" line (with "Or open …" before the
code instructions) once the https invite link exists. Until then the
`hisabmitra://` link is dropped: WhatsApp doesn't make it tappable.

**Share the app:**

```
📒 *HisabMitra — Smart Hisab, Happy Family*

I keep my family's hisab in HisabMitra:
✅ Daily income and expenses
🤝 Money given and taken (khata)
👨‍👩‍👧 Family and trip expense splitting
📊 Reports in English and ગુજરાતી

📲 Download free: {downloadUrl}
```

**File captions** (new; sent as the share text with the file):
- Report: `📊 *HisabMitra report* · {title} · {period}`
- Backup: `🔒 *HisabMitra backup* · {date} — keep this file safe; you'll need
  your backup password to restore it.` (Unencrypted backups: same without
  the password clause.)
- Bill photos and PDFs: no caption.

`{downloadUrl}` is `<releases page>/latest`. When the build has no GitHub
repository configured, the download line is left out.

## Approaches considered

| Item | Considered | Chosen |
|---|---|---|
| Reminders | `SCHEDULE_EXACT_ALARM` (user must allow it in settings on Android 14+); `USE_EXACT_ALARM` (automatic); `alarmClock` mode (shows an alarm icon) | `USE_EXACT_ALARM`: works without user action; GitHub distribution has no Play policy issue |
| AI button | Draggable bubble; fixed button above the "+"; item in the app bar | Fixed button above "+", as WhatsApp does |
| Back on other tabs | Exit confirmation on every tab; go to Home first | Go to Home first, confirm only on Home |
| AI default | Keep off; on for the local engine only | On for the local engine; online stays opt-in |

## Left to the builder

- Exact widget structure of the floating button and how pages opt out.
- Test layout and names.
- Gujarati wording (natural, matching existing app texts).
