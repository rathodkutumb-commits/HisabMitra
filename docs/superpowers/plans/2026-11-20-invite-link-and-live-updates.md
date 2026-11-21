# Invite Link and Live Updates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A tappable https invite link that joins the group in the app, and group/personal changes that appear on other phones within seconds while the app is open.

**Architecture:** Live updates: the two change feeds join Supabase Realtime's publication; the app listens (only while signed in and in the foreground) through `CloudGateway.changeSignals()` and answers each signal with the existing silent sync, debounced. Invite link: a static GitHub Pages page opens `hisabmitra://join?code=…`; the router remembers the code as a pending invitation (saved on the phone) and the Join screen joins automatically once the account is ready.

**Tech Stack:** Flutter/Dart, Riverpod 3, GoRouter 18, Drift, supabase_flutter 2 (realtime_client), PostgreSQL tests in Docker, GitHub Actions Pages.

**Spec:** `docs/superpowers/specs/2026-11-20-invite-link-and-live-updates-design.md`

## Global Constraints

- No commits or pushes during execution: commits on this PC are pushed to GitHub automatically, and the owner has not approved them yet. Outward steps (commit/push, switching Pages on, the live migration, a release) are asked for at the end.
- Never write the database password to a file; ask before reusing it.
- Test and sample data use the name Hemang (and Rahul Patel), never Asha.
- Every user-visible text exists in `l10n/en/*.json` and `l10n/gu/*.json`; rebuild with `dart run tool/build_l10n.dart && flutter gen-l10n`.
- Invite codes: 6–12 letters/digits, compared upper-case (`[A-Z0-9]{6,12}`).
- Link format: `https://<owner lower-case>.github.io/<repo>/join?code=<CODE>`; no link when `AppConfig.githubOwner`/`githubRepo` are empty.
- App id `com.hisabmitra.app`; app link scheme `hisabmitra://join?code=<CODE>` (already in the manifest).
- Live updates: listen only while signed in **and** in the foreground; debounce 1 s; signals never carry data into the app (the normal pull does).
- Only `sync_events` and `personal_sync_events` may be in `supabase_realtime` (the data tables must not be published).

## Review Focus

1. Realtime drops (Wi-Fi ↔ mobile data, phone asleep, token refresh): on every (re)subscribe the app must sync once, or changes made during the gap stay invisible until the next change. Device check in Task 8.
2. A link tapped while the app is open on a half-filled form: the deep link replaces the screen stack (GoRouter `go`), so the draft is lost. Accepted for now; mention to the owner.
3. The page on a phone without the app: the intent fallback reloads the page with `noapp=1`; it must not try to open the app again (no loop) and must show the download button. Manual check in Task 7.
4. The same link tapped again after joining: the server answers `already_member`/`invalid_code`; the user sees the reason, the pending invitation is cleared, nothing loops. Test in Task 6.
5. A phone hears its own pushes back through Realtime: costs one extra (empty) pull per change, never a loop (a pull writes nothing to the feeds). Covered by the two-phone test in Task 2 staying quiet after convergence.

---

### Task 1: Feeds in the Realtime publication (server)

**Files:**
- Modify: `supabase/tests/00_supabase_shim.sql` (end of file)
- Create: `supabase/migrations/20261120000200_realtime_feeds.sql`
- Create: `supabase/tests/30_realtime_test.sql`
- Modify: `tool/run_supabase_tests.sh` (last line)

**Interfaces:** Produces: publication `supabase_realtime` containing exactly `public.sync_events` and `public.personal_sync_events`.

- [ ] **Step 1: Shim creates the publication Supabase provides**

Append to the shim: create `publication supabase_realtime` (empty) only when `pg_publication` has no row with that name (a `do $$ … $$` block).

- [ ] **Step 2: Write the failing SQL test `supabase/tests/30_realtime_test.sql`**

Same `pg_temp.ok` helper as `20_personal_data_test.sql`. Checks:
- `ok((select count(*) from pg_publication_tables where pubname = 'supabase_realtime' and schemaname = 'public' and tablename in ('sync_events', 'personal_sync_events')) = 2, 'both change feeds are published to Realtime')`
- `ok(not exists (select 1 from pg_publication_tables where pubname = 'supabase_realtime' and tablename not in ('sync_events', 'personal_sync_events')), 'no data table is published')`

Add `run < supabase/tests/30_realtime_test.sql` to `tool/run_supabase_tests.sh`.

- [ ] **Step 3: Run it to make sure it fails**

Run: `bash tool/run_supabase_tests.sh 2>&1 | tail -5`
Expected: `ASSERTION FAILED: both change feeds are published to Realtime`

- [ ] **Step 4: Write the migration**

Header comment (why: live updates; Realtime applies each table's RLS, so a phone hears only its groups and its own records), then `alter publication supabase_realtime add table public.sync_events, public.personal_sync_events;`.

- [ ] **Step 5: Run the SQL tests**

Run: `bash tool/run_supabase_tests.sh 2>&1 | grep -c "ok -"; bash tool/run_supabase_tests.sh 2>&1 | grep -i "failed\|error" || echo CLEAN`
Expected: count grows by 2 over the previous run; `CLEAN`.

---

### Task 2: Change signals and the `LiveSync` listener

**Files:**
- Modify: `lib/features/synchronization/data/cloud_gateway.dart` (interface + `NotConfiguredCloudGateway`)
- Modify: `lib/features/synchronization/data/supabase_cloud_gateway.dart`
- Create: `lib/features/synchronization/application/live_sync.dart`
- Modify: `test/helpers/fake_cloud.dart`, `test/helpers/fake_personal_cloud.dart`, `test/helpers/fake_auth_gateway.dart`
- Test: `test/features/synchronization/live_sync_test.dart`

**Interfaces:**
- Produces: `Stream<void> changeSignals()` on `CloudGateway` — every call opens its own subscription; cancelling the subscription closes it. Emits once when (re)subscribed and once per new feed row the user may read.
- Produces: `class LiveSync { LiveSync({required Stream<void> Function() signals, required Future<void> Function() sync, Duration debounce = const Duration(seconds: 1)}); bool get isListening; void start(); Future<void> stop(); }` — `start` is idempotent; signals within `debounce` collapse to one `sync()`; `stop` cancels the subscription and any pending timer; an error thrown by `sync()` is swallowed (listening continues).
- Produces (tests): `FakeCloudClient.changeSignals()` emits for group events where `server.isMember(groupId, userId)` (checked on delivery) and personal events whose owner is `userId`; `FakeAuthGateway` gets `void setSession(CloudSession? s)` (sets and emits on `sessionChanges`) and `final signals = StreamController<void>.broadcast()` returned by `changeSignals()`.

- [ ] **Step 1: Write the failing tests** in `live_sync_test.dart`

Unit (a `StreamController<void>.broadcast()` and a counting `sync`, `debounce: Duration(milliseconds: 20)`, waits of 100 ms):
- `'signals close together sync once'`: 3 signals → `syncs == 1`.
- `'nothing syncs after stop'`: signal, `await stop()`, wait → `syncs == 0`, `isListening == false`.
- `'start twice listens once'`: `start(); start();` one signal → `syncs == 1`.
- `'a failing sync keeps listening'`: sync throws `NetworkFailure` once; second signal → second call happens.

Two phones on one `FakeCloudServer` (local `Phone` helper like `attachment_sync_test.dart`: db, `FakeCloudClient`, `GroupRepository`, `TransactionRepository`, `SyncService`), `debounce: Duration.zero`, polling helper `eventually(Future<bool> Function())` (10 ms steps, fails after 3 s):
- `'a group expense reaches the other member without a manual sync'`: Hemang creates "Goa Trip" with member Rahul Patel and syncs; Rahul accepts `server.createInvitation(groupId, null)` and `sync.joinGroup`; Rahul's `LiveSync(signals: rahul.cloud.changeSignals, sync: rahul.sync.syncOnce)` starts; Hemang saves expense "Hotel" ₹1,000 and `syncOnce()` → eventually Rahul's db has an expense with description `'Hotel'`.
- `'a new member shows on the other phone'`: Hemang's LiveSync running before Rahul joins → eventually Hemang's group has a member with `userId == 'rahul'`.
- `'own records reach the same user's other phone'`: two `Phone`s for `'hemang'`; phone 2 listening; phone 1 saves an expense transaction and syncs → eventually phone 2's `transactions` has it.
- `'a phone does not hear groups it is not in'`: a third user's LiveSync counts zero syncs after Hemang's expense.

- [ ] **Step 2: Run to make sure they fail**

Run: `flutter test test/features/synchronization/live_sync_test.dart`
Expected: compile errors — `LiveSync` and `changeSignals` not defined.

- [ ] **Step 3: Implement**

- Interface method with doc comment; `NotConfiguredCloudGateway` → `const Stream.empty()`.
- Supabase: a `StreamController<void>` whose `onListen` opens `_client.channel('feeds:<uid>')` with two `onPostgresChanges(event: PostgresChangeEvent.insert, schema: 'public', …)` — table `sync_events` (RLS filters), table `personal_sync_events` with `PostgresChangeFilter(type: PostgresChangeFilterType.eq, column: 'owner_id', value: uid)` — each callback adds a signal; `subscribe((status, error) {…})` adds a signal on `RealtimeSubscribeStatus.subscribed` and logs other statuses with `SafeLogger.info('realtime', {'status': status.name})`; `onCancel` → `_client.removeChannel(channel)`. No uid → an empty stream.
- Fakes: `FakeCloudServer` gets a broadcast `StreamController<({String? groupId, String? owner})>`, fed from its `_emit`, from `accept`, and (through a callback set by the server) from every event `FakePersonalStore` records, resets included.

- [ ] **Step 4: Run the tests**

Run: `flutter test test/features/synchronization/live_sync_test.dart`
Expected: all pass.

---

### Task 3: A sync asked for during a sync runs afterwards

**Files:**
- Modify: `lib/features/synchronization/application/sync_controller.dart` (`SyncController.syncNow`)
- Test: `test/features/synchronization/sync_controller_test.dart`

**Interfaces:** Produces: `syncNow(silent: true)` while a sync runs still returns `null` at once, but exactly one more silent sync starts when the running one ends (requests during a run coalesce). Non-silent calls during a run are unchanged.

- [ ] **Step 1: Write the failing tests** (ProviderContainer overriding `appDatabaseProvider`, `cloudGatewayProvider`, `syncServiceProvider` with a `SyncService` on a `_GatedCloud extends FakeCloudClient` that counts `pullEvents` and can hold the first one on a `Completer`, and `connectivityProvider.overrideWith((ref) => Stream.value(true))`)
- `'a silent request during a sync runs once more afterwards'`: start a held sync; two more `syncNow(silent: true)` return `null`; release → after the queue drains `pulls == 2`.
- `'no request, no extra run'`: one sync → `pulls == 1`.

- [ ] **Step 2: Run to make sure the first fails**

Run: `flutter test test/features/synchronization/sync_controller_test.dart`
Expected: first test FAILS (`pulls` is 1), second passes.

- [ ] **Step 3: Implement** a `_again` flag set by silent calls while `state.running`; after the run (success or error, still mounted) clear it and `unawaited(syncNow(silent: true))`.

- [ ] **Step 4: Run** the same command. Expected: both pass.

---

### Task 4: Listening while signed in and in the foreground (app wiring)

**Files:**
- Modify: `lib/features/synchronization/application/live_sync.dart` (add controller + provider)
- Modify: `lib/app/app.dart` (lifecycle)
- Test: `test/features/synchronization/live_sync_controller_test.dart`, `test/widget/live_updates_test.dart`

**Interfaces:**
- Consumes: `LiveSync`, `CloudGateway.changeSignals()` (Task 2), coalescing `syncNow(silent: true)` (Task 3).
- Produces: `final liveSyncControllerProvider = NotifierProvider<LiveSyncController, bool>(…)`; `LiveSyncController.setForeground(bool foreground)`; state `true` while listening. Listens when `foreground && cloud.isConfigured && cloud.currentSession != null`; follows `cloudSessionProvider` (stops on sign-out, restarts for a different user id); `ref.onDispose` stops.

- [ ] **Step 1: Write the failing tests**

`live_sync_controller_test.dart` (ProviderContainer, `FakeAuthGateway`, `container.listen` to keep it alive):
- `'listens only in the foreground while signed in'`: session set; `setForeground(true)` → `true`, `signals.hasListener`; `setForeground(false)` → `false`, no listener.
- `'stops on sign-out and starts again on sign-in'`: foreground, `setSession(null)` → `false`; `setSession(CloudSession(userId: 'user-1', …))` → `true`.
- `'never listens without a cloud configuration'`: `FakeAuthGateway(configured: false)` → stays `false`.

`live_updates_test.dart` (`testApp` + `pumpHisabMitra`, prefs onboarded/verified/initial sync done, cloud = `FakeCloudClient(server, 'rahul')`):
- `'a group expense from another phone appears on the open group'`: Hemang's test phone creates "Goa Trip" and invites; Rahul accepts on the server and the app joins (`syncServiceProvider.joinGroup`); app shows the group (`router.go(Routes.group(id))`); Hemang adds "Hotel" and syncs; `pump(2 s)` + `pumpAndSettle` → `find.text('Hotel')` found, with no sync button tapped.
- `'the app stops listening in the background'`: `tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused)` → controller state `false`; `resumed` → `true`.

- [ ] **Step 2: Run to make sure they fail**

Run: `flutter test test/features/synchronization/live_sync_controller_test.dart test/widget/live_updates_test.dart`
Expected: compile error — `liveSyncControllerProvider` not defined.

- [ ] **Step 3: Implement** the controller and wire `app.dart`: first frame and `resumed` → `setForeground(true)`; `paused`, `hidden`, `detached` → `setForeground(false)`; `inactive` leaves it as is.

- [ ] **Step 4: Run** the same command. Expected: all pass.

---

### Task 5: Invite code check, invite link and the shared message

**Files:**
- Create: `lib/features/groups/domain/invite_code.dart`
- Modify: `lib/core/share/share_messages.dart`, `lib/features/groups/presentation/group_cloud_screens.dart` (share button)
- Modify: `l10n/en/cloud.json`, `l10n/gu/cloud.json`
- Test: `test/core/share/share_messages_test.dart`, `test/features/groups/invite_code_test.dart`

**Interfaces:**
- Produces: `String? normalizeInviteCode(String? raw)` — trims, upper-cases, returns null unless `^[A-Z0-9]{6,12}$`.
- Produces: `String? inviteLinkUrl(String code)` in `share_messages.dart` — null when `!AppConfig.isUpdateCheckConfigured`, else `https://${githubOwner.toLowerCase()}.github.io/$githubRepo/join?code=$code`.
- Produces: `inviteMessage(l, {group, code, date, String? link, String? downloadUrl})` — with `link` uses `l.inviteShareTextLink(group, code, link, date)`, else the current `inviteShareText`.

Exact copy (new key `inviteShareTextLink`, placeholders group, code, link, date):
- en: `"👋 *Join my group on HisabMitra!*\n\n👥 Group: *{group}*\n🔑 Invite code: *{code}*\n\n👉 Tap to join: {link}\nOr open HisabMitra → Groups → Join a group, and enter the code.\n\n⏳ The code is valid till *{date}*."`
- gu: `"👋 *હિસાબમિત્રમાં મારા ગ્રુપમાં જોડાઓ!*\n\n👥 ગ્રુપ: *{group}*\n🔑 આમંત્રણ કોડ: *{code}*\n\n👉 જોડાવા માટે ટેપ કરો: {link}\nઅથવા હિસાબમિત્ર ખોલો → ગ્રુપ → ગ્રુપમાં જોડાઓ, અને કોડ લખો.\n\n⏳ કોડ *{date}* સુધી માન્ય છે."`

- [ ] **Step 1: Write the failing tests**
- `invite_code_test.dart`: `normalizeInviteCode(' hsqpp7g9vd ') == 'HSQPP7G9VD'`; `null`, `''`, `'AB12'`, `'ABCDEFGHIJKLM'` (13), `'AB-123'`, `'ABC 123'` → null; `'CODE01'` (6) and 12 characters accepted.
- share test, new cases: `'English layout with the tap-to-join link'` — contains `'👉 Tap to join: https://hemang.github.io/HisabMitra/join?code=HSQPP7G9VD'` followed on the next line by `'Or open HisabMitra → Groups → Join a group, and enter the code.'`, 5 paragraphs with the download line; `'Gujarati layout with the link'` — contains `'👉 જોડાવા માટે ટેપ કરો: '` and `'અથવા હિસાબમિત્ર ખોલો'`; `'no link line without a repository'` — `inviteLinkUrl('HSQPP7G9VD')` is null and the message without `link` has no `👉`. Existing cases stay.

- [ ] **Step 2: Run to make sure they fail**

Run: `flutter test test/core/share/share_messages_test.dart test/features/groups/invite_code_test.dart`
Expected: compile errors (`normalizeInviteCode`, `link:` not defined).

- [ ] **Step 3: Implement**, add the strings, rebuild l10n, and pass `link: inviteLinkUrl(code)` from the invite screen's share button.

- [ ] **Step 4: Run** the same command. Expected: all pass.

---

### Task 6: Pending invitation and automatic join

**Files:**
- Modify: `lib/features/settings/domain/app_preferences.dart` (field, key, map, copyWith)
- Modify: `lib/app/router/routes.dart`, `lib/app/router/app_router.dart`
- Modify: `lib/features/groups/presentation/group_cloud_screens.dart` (`JoinGroupScreen`)
- Test: `test/features/settings/app_preferences_test.dart`, `test/widget/invite_link_test.dart`

**Interfaces:**
- Consumes: `normalizeInviteCode` (Task 5).
- Produces: `AppPreferences.pendingInviteCode` (`String`, `''` = none; key `'groups.pendingInvite'`; `copyWith(pendingInviteCode: '')` clears).
- Produces: `Routes.joinGroup = '/groups/join'` (a child of the Groups tab route with `parentNavigatorKey: _rootKey`, so back returns to the Groups tab) and `static String joinGroupWithCode(String code)`.

Router redirect (decisions the tests pin):
1. Join link (`uri.host == 'join'`): `code = normalizeInviteCode(...)`. Invalid → `Routes.joinGroup` (manual screen, nothing saved). Valid → save it as pending with `scheduleMicrotask(() => settings.update(...))` (the redirect may run while widgets build) and return `joinGroupWithCode(code)`.
2. The existing welcome/account/first-sync rules apply unchanged to `/groups/join` (an unready account is sent through them; the code waits as pending).
3. Where the flow lands (`inWelcome` → today `Routes.home`, and `Routes.home` itself): `joinGroupWithCode(pending)` when `pendingInviteCode` is not empty, else unchanged.

`JoinGroupScreen`: a valid `initialCode` joins automatically after the first frame (spinner shown, no tap). After any attempt that reached the cloud call — success or failure — clear the pending code. Not signed in → keep it (existing `markSessionLost` path; joining continues after sign-in via rule 3). On failure the field keeps the code and `showFailure` shows the reason.

- [ ] **Step 1: Write the failing tests**
- `app_preferences_test.dart`: `'pending invite survives a save and clears'` — `fromMap({'groups.pendingInvite': 'CODE01'}).pendingInviteCode == 'CODE01'`; round-trip through `toMap`; `copyWith(pendingInviteCode: '')` → `''`; default `''`.
- `invite_link_test.dart` (`testApp`, `pumpHisabMitra`, `FakeCloudClient(server, 'rahul')`; Hemang's test phone creates "Goa Trip" and `server.createInvitation` gives `CODE0`; helper `openLink(tester, uri)` sends `pushRouteInformation` on `SystemChannels.navigation` then `pumpAndSettle`):
  - `'a link joins the group for a signed-in user'`: `hisabmitra://join?code=code0` (lower-case) → group screen shows "Goa Trip", snack `'You joined Goa Trip'`, `pendingInviteCode == ''`; back → Groups tab (`find.byType(GroupsScreen)`).
  - `'a link waits for sign-up, then joins'`: prefs onboarded but not verified → after the link the profile screen shows, `pendingInviteCode == 'CODE0'` and `SettingsRepository(db).readRaw('groups.pendingInvite') == 'CODE0'`; then update prefs `accountVerified: true, initialSyncDone: true` → "Goa Trip" opens.
  - `'a failed join shows the reason with the code filled in'`: `code=NOPE1234` → Join screen, field text `'NOPE1234'`, the `invalid_code` failure text visible, `pendingInviteCode == ''`.
  - `'the same link twice does not loop'`: join with `CODE0`, go home, open the same link again → failure text shown once, still on the Join screen after `pump(5 s)`.
  - `'an invalid link opens the empty join screen'`: `code=ab` → Join screen, empty field, `server.invitations['CODE0']!.used == false`.
- Existing push from the Groups tab still opens the manual Join screen (existing app tests stay green).

- [ ] **Step 2: Run to make sure they fail**

Run: `flutter test test/features/settings/app_preferences_test.dart test/widget/invite_link_test.dart`
Expected: compile error (`pendingInviteCode` not defined).

- [ ] **Step 3: Implement** as above.

- [ ] **Step 4: Run** the same command, then `flutter test test/widget`. Expected: all pass.

---

### Task 7: The join page and its Pages workflow

**Files:**
- Create: `site/index.html`, `site/join.html`, `site/join.js`, `site/logo.png` (copy of `assets/images/logo_tile.png`), `site/.nojekyll`
- Create: `.github/workflows/pages.yml`

Ruling carried from the spec: the folder is `site/`, not `web/` — `web/` is Flutter's web-platform folder and would make Flutter treat the app as a web app.

**Interfaces:** Consumes the link format from Global Constraints. Produces `https://<owner>.github.io/<repo>/join?code=…` once Pages is switched on (Task 8 asks).

Page behaviour (`join.js`, no external scripts, CSP meta `default-src 'none'; img-src 'self'; style-src 'unsafe-inline'; script-src 'self'`):
- Reads `code`, trims and upper-cases; invalid → shows "This invitation link is not valid / આ આમંત્રણ લિંક માન્ય નથી", no app launch.
- Valid → shows the code (via `textContent`), a big "Open in HisabMitra / હિસાબમિત્રમાં ખોલો" button linking to `intent://join?code=<CODE>#Intent;scheme=hisabmitra;package=com.hisabmitra.app;S.browser_fallback_url=<this page + &noapp=1, encoded>;end` (plain `hisabmitra://join?code=` on non-Android), "Copy code", "Download HisabMitra" → `https://github.com/<owner>/<repo>/releases/latest` (owner from the host name, repo from the first path segment) and the manual steps line.
- Tries the intent once on load on Android unless `noapp=1` is present; with `noapp=1` the download button is shown first.
- English and Gujarati on the page, Rann Utsav colours (`#B5452B` primary, `#FFF8EE` background), works at 360 px wide.
- `index.html`: name, one line, download button.

`pages.yml`: on push to `main` touching `site/**` or the workflow, plus `workflow_dispatch`; permissions `contents: read, pages: write, id-token: write`; `actions/checkout@v4` → `actions/configure-pages@v5` → `actions/upload-pages-artifact@v3` (path `site`) → `actions/deploy-pages@v4` in environment `github-pages`.

- [ ] **Step 1: Write the page and workflow.**
- [ ] **Step 2: Check on the emulator**

Run: serve `site/` with `python -m http.server 8765` from the scratchpad copy, install a debug APK, then `adb shell am start -a android.intent.action.VIEW -d "http://10.0.2.2:8765/join.html?code=CODE01"` and tap "Open in HisabMitra".
Expected: HisabMitra opens on the Join screen with `CODE01` (joining fails on the empty test server with "invalid code" — that proves the hand-over). Also `?code=ab` → "not valid", and `&noapp=1` → no launch attempt.

---

### Task 8: Whole-change checks and hand-over

**Files:** Modify `docs/PROGRESS.md` (Part C1/C2 status, what the owner must switch on).

- [ ] **Step 1:** `flutter analyze` → `No issues found!`; `dart format --output=none --set-exit-if-changed lib test` → exit 0; `flutter test` → all pass; `bash tool/run_supabase_tests.sh` → no `FAILED`.
- [ ] **Step 2:** Device: two emulators are not available, so the live Realtime check (Review Focus 1) is reported as pending until the migration is live; run the app once on the emulator against the live project only after the owner approves the migration.
- [ ] **Step 3:** Ask the owner for: commit + push; switching on GitHub Pages (`gh api -X POST repos/<owner>/<repo>/pages -f build_type=workflow` as `rathodkutumb-commits`, then `gh auth switch -u Hemang67`) and checking `/join?code=…` serves the page; applying `20261120000200_realtime_feeds.sql` live (password or access token); a v1.2.0 release.
