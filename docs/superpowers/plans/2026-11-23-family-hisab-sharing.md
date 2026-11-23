# Family hisab sharing (1.3.0, phase 3) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** People who have the app can be invited into a Family hisab, join it (taking over their named person and earlier entries), see it live on their phone, with admins managing and members adding entries; a removed person's phone forgets it, and deleting an account hands the Family hisab over.

**Architecture:** One new migration adds `family_invitations`, `create/cancel_family_invitation`, an `accept_invitation` that finds a code among group **or** Family hisab invitations, an owner-only `set_family_member_role`, a feed rule that lets a removed person read their own removal, and Family hisab hand-over in `prepare_account_deletion`. The app keeps one join flow (link, website and typed code), routes the result by kind, adds an invite screen and role-aware actions, forgets a Family hisab when its own member row is deleted, and listens to the family feed for live updates.

**Tech Stack:** Flutter 3.47 / Dart, Riverpod 3, GoRouter, Drift; Supabase (PostgreSQL functions, RLS, Realtime); SQL tests in Docker.

**Spec:** `docs/superpowers/specs/2026-11-23-home-budget-design.md` (sections "People", "Live", Data: `family_invitations`, "One invite link for both kinds", "Account deletion"); roadmap `docs/superpowers/plans/2026-11-23-family-hisab-roadmap.md` (phase 3).

## Global Constraints

- Every visible text in `l10n/en|gu/family.json`, rebuilt with `dart run tool/build_l10n.dart && flutter gen-l10n`; English and Gujarati both.
- One invite link for both kinds: the website and the app's join flow stay as they are; the old `accept_group_invitation` stays unchanged for app 1.2.x.
- Invitations: single-use, SHA-256 hashed codes from the alphabet `ABCDEFGHJKMNPQRSTUVWXYZ23456789`, 10 characters, 72 h default (1–720 h), optional member to take over; one pending invitation per member.
- Roles: owner and admins manage the Family hisab, its people and invitations; members add, edit and delete entries. Only the owner changes roles (`admin` ↔ `member`); the owner's role never changes except by account deletion.
- Joining a named person links the account to that person (`user_id` is only ever set by the server); their earlier entries stay theirs.
- Account deletion: like groups — ownership passes to another active member who has the app (admins first, then the earliest); with none left, the Family hisab is deleted. The leaving user's people become plain people ("Not joined").
- New server functions are revoked from `public, anon, authenticated` and granted to `authenticated` only where clients call them; `_helpers` are never granted.
- Server changes only as a new migration, tested with `bash tool/run_supabase_tests.sh`; applied live at release with the owner's go-ahead.
- Test/sample names: Hemang, Rahul Patel, Priya Shah; never Asha.
- Commit the phase locally when done (no push); then stop and wait for the owner.

## Review Focus

1. The same code accepted twice (a double tap, or forwarded to two people): the second gets "invalid code"; never two accounts on one person. SQL test in Task 1.
2. A removed person's phone was offline with unsent entries for that Family hisab: after the next sync the Family hisab and those uploads are gone, with no failed uploads left behind. Test in Task 3.
3. An admin made a member again while offline with a queued people change: the change is rejected (shown as a failed upload), the passbook still adds up and the person actions disappear. Test in Task 3.
4. A code for a person who was deleted (removed) after the invitation was made: "invalid code". SQL test in Task 1.
5. The owner deletes their account while the only other account-holder was removed earlier: the Family hisab is deleted, not handed to the removed person. SQL test in Task 1.

---

### Task 1: Server — invitations, unified accept, roles, removal feed, hand-over

**Files:**
- Create: `supabase/migrations/20261123000200_family_sharing.sql`, `supabase/tests/50_family_sharing_test.sql`
- Modify: `tool/run_supabase_tests.sh` (run the new test after 40)

**Interfaces (SQL, all `security definer set search_path = ''`):**
- Table `family_invitations(id uuid pk, family_id → family_hisabs on delete cascade, code_hash text unique, created_by uuid → auth.users on delete cascade, member_id uuid null → family_members on delete cascade, status pending/accepted/cancelled/expired, expires_at, accepted_by → auth.users on delete set null, accepted_at, created_at)`; unique pending per member; RLS select for `is_family_admin(family_id)`; select granted to `authenticated`.
- `create_family_invitation(p_family_id uuid, p_member_id uuid default null, p_ttl_hours integer default 72) returns jsonb` `{invitation_id, code, expires_at}`; errors `not_authenticated`, `forbidden` (not admin), `invalid_member` (not this Family hisab's active person without an account), `invitation_pending`.
- `cancel_family_invitation(p_invitation_id uuid) returns void` — admins only (`forbidden`).
- `accept_invitation(p_code text, p_display_name text) returns jsonb` — a group code returns `accept_group_invitation(...) || {"kind":"group"}`; a Family hisab code returns `{"kind":"family","family_id","member_id"}`. Errors as groups: `invalid_code` (unknown, used, cancelled, deleted Family hisab, the named person no longer active or already linked), `expired`, `already_member`. Linking sets `user_id` on the named person (revision + 1); without a person, adds one (`name` = display name, role `member`, last `sort_order` + 1). Emits a `member` upsert on the family feed.
- `set_family_member_role(p_member_id uuid, p_role text) returns jsonb` `{revision}` — caller must be the Family hisab's owner (`forbidden`); target must be active, have an account and not be the owner (`forbidden`); `p_role` in (`admin`, `member`) else `invalid_data`. Emits a `member` upsert.
- `public.can_read_family_event(p_family_id uuid, p_entity_type text, p_entity_id uuid) returns boolean` — `is_family_reader(family_id)` **or** (`entity_type = 'member'` and that member row's `user_id = auth.uid()`). `family_sync_events` select policy uses it (drop and recreate `family_events_member_select`).
- `prepare_account_deletion()` replaced: the group part unchanged, plus for every live Family hisab owned by the user: next owner = active, not-deleted member with `user_id` not null and ≠ the user, `role = 'admin'` first, then earliest `created_at`; none → `deleted_at = now()`, revision + 1, emit `family` delete; else `owner_id` = next, that member `role = 'owner'` (emit). Then every `family_members` row of the user → `user_id = null`, `role = 'member'`, revision + 1 (emit each); pending `family_invitations` created by the user → `cancelled`.
- Grants: execute on `create_family_invitation`, `cancel_family_invitation`, `accept_invitation`, `set_family_member_role`, `can_read_family_event`, `prepare_account_deletion` to `authenticated` after revoking from `public, anon, authenticated`.

- [ ] **Step 1: Failing SQL test** `50_family_sharing_test.sql` (users A, B, C from `10_rls_and_rpc_test.sql`; A creates "Home" with person "Rahul Patel" and a contribution entry for Rahul through `apply_family_op`):
  - B and C cannot create an invitation (`forbidden`); A's invitation for a person of another Family hisab → `invalid_member`; a second pending invitation for Rahul → `invitation_pending`.
  - B accepts A's code for Rahul → `kind = 'family'`, `member_id = Rahul`; Rahul's row has `user_id = B`; B now reads the Family hisab and the contribution (`created_by` unchanged); the same code again (C) → `invalid_code`; B with a second code for "someone new" → `already_member`.
  - An expired invitation (`expires_at` in the past) → `expired`; a cancelled one → `invalid_code`; a code for a person removed after it was made → `invalid_code`; C cannot cancel A's invitation (`forbidden`).
  - `accept_invitation` with a group code (A's group from test 10, invitation made here) → `kind = 'group'` and the group id.
  - B (member) renaming the Family hisab or adding a person → `forbidden`; B adding an entry → `applied`.
  - `set_family_member_role`: B → `forbidden`; A makes B `admin` → B can add a person; A on the owner → `forbidden`; role `boss` → `invalid_data`; A makes B `member` again.
  - A removes B's person; B reads the `delete` event of their own member row; an entry A adds afterwards is not visible to B.
  - Hand-over (as superuser, then `as_user(A)`): a second Family hisab "Village" with C joined as admin and B joined then removed; `prepare_account_deletion()` as A → "Village" owner is C with role `owner`; A's people have `user_id is null`; "Home" (B removed, nobody else with an account) is deleted.
- [ ] **Step 2:** `bash tool/run_supabase_tests.sh` → fails (`function public.create_family_invitation(...) does not exist`).
- [ ] **Step 3:** Write the migration (header comment; follow `create_group_invitation` / `accept_group_invitation` for codes and errors; `_family_emit` for events).
- [ ] **Step 4:** `bash tool/run_supabase_tests.sh` → `ALL FAMILY SHARING TESTS PASSED`, every earlier suite still passes (incl. "anon cannot execute any public function").

---

### Task 2: App gateway, models and fakes

**Files:**
- Modify: `lib/features/synchronization/domain/cloud_models.dart`, `lib/features/synchronization/data/cloud_gateway.dart` (+ `NotConfiguredCloudGateway`), `lib/features/synchronization/data/supabase_cloud_gateway.dart`, `test/helpers/fake_family_cloud.dart`, `test/helpers/fake_cloud.dart`, `test/helpers/fake_auth_gateway.dart` (only if a sync path calls a new method)
- Test: `test/features/synchronization/cloud_models_test.dart`, `test/features/synchronization/supabase_feed_topic_test.dart`

**Interfaces:**
- `AcceptedInvitation({String? groupId, String? familyId, required String memberId})`, `bool get isFamily`, `factory AcceptedInvitation.fromJson(Map<String, Object?> j)` (`kind` missing → group).
- `CloudGateway`: `acceptInvitation` now calls `accept_invitation`; new `Future<CreatedInvitation> createFamilyInvitation({required String familyId, String? memberId})`, `Future<List<InvitationInfo>> listFamilyInvitations(String familyId)`, `Future<void> cancelFamilyInvitation(String invitationId)`, `Future<void> setFamilyRole({required String memberId, required String role})`.
- `SupabaseCloudGateway.liveFeeds` — `static const ['sync_events', 'personal_sync_events', 'family_sync_events']`; `changeSignals` subscribes to each (personal filtered by `owner_id`, the others by RLS).
- Fakes: `FakeFamilyStore.createInvitation(familyId, memberId, uid) → String code`, `accept(code, uid, name) → AcceptedInvitation`, `setRole(memberId, role, uid)`, `pull` delivers a removed person's own member events (mirrors `can_read_family_event`); `FakeCloudServer.acceptAny(code, uid, name)` tries group codes, then Family hisab codes.

- [ ] **Step 1: Failing tests** — `'an accepted Family hisab code says so'` (`fromJson({'kind':'family','family_id':'f','member_id':'m'})` → `isFamily`, ids; `{'group_id':'g','member_id':'m'}` → group); `'live updates listen to all three feeds'` (`liveFeeds` contains `family_sync_events`).
- [ ] **Step 2:** `flutter test test/features/synchronization/cloud_models_test.dart test/features/synchronization/supabase_feed_topic_test.dart` → fail.
- [ ] **Step 3:** Implement; update every caller of `AcceptedInvitation.groupId` (null-aware).
- [ ] **Step 4:** same command → pass; `flutter analyze` → no issues.

---

### Task 3: Joining, roles and removal on the phone

**Files:**
- Modify: `lib/features/synchronization/data/family_rows.dart` (`Future<void> forgetFamily(String familyId)` — deletes its entries, people, the Family hisab, its outbox and inbox rows and open conflicts), `lib/features/synchronization/data/sync_service.dart` (`_applyFamilyInbox`: a `member` event for a row whose `user_id` is this user with `deleted_at` set → `forgetFamily`, mark that Family hisab's events done; an unknown Family hisab whose pending events contain such a removal → done without a snapshot), `lib/features/family/data/family_repository.dart` (`FamilyDetail.canManage` = self is owner or admin; `FamilyDetail.isOwner`), `lib/features/family/application/family_sharing.dart` (new: `FamilySharing(cloud, sync)` with `Future<String> join(AcceptedInvitation a)` → `loadFamilySnapshot`, returns the family id; `setRole`, invitations pass-through), provider `familySharingProvider`
- Test: `test/features/family/family_sharing_test.dart` (Hemang's and Rahul's phones on one fake server)

**Interfaces:**
- Consumes: Task 2 gateway; phase 2 `SyncService.loadFamilySnapshot`.
- Produces: `FamilyDetail.canManage`, `FamilyDetail.isOwner`, `familySharingProvider`, `FamilySharing.join`, `FamilySharing.createInvitation({familyId, memberId})`, `FamilySharing.invitations(familyId)`, `FamilySharing.cancel(id)`, `FamilySharing.setRole(memberId, role)` (then `syncOnce`).

- [ ] **Step 1: Failing tests** — `'Rahul joins as his named person and keeps his entries'` (Hemang: Home, Rahul Patel, contribution ₹10,000 for Rahul; invite for Rahul; Rahul accepts + `join` → his phone shows Home, `self` = "Rahul Patel", the contribution, `canManage` false); `'Hemang sees that Rahul has the app'` (after sync, Rahul's `userId` = 'rahul'); `'an entry Rahul adds reaches Hemang'`; `'making Rahul an admin lets him add people'`; `'a removed person's phone forgets the Family hisab'` (Rahul has an unsent entry offline; Hemang removes him; Rahul syncs → no Family hisab, no outbox rows, no failed uploads); `'a fresh phone of a removed person skips it'`; `'an admin made a member while offline: the queued change fails, nothing else breaks'`.
- [ ] **Step 2:** `flutter test test/features/family/family_sharing_test.dart` → fail.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** `flutter test test/features/family test/features/synchronization` → pass.

---

### Task 4: Invite screen and role-aware actions

**Files:**
- Create: `lib/features/family/presentation/family_invite_screen.dart` (like `GroupInviteScreen`: "Invite for" = a person without an account (preselected from the route) or "Someone new"; create code; code card with copy and Share; list of invitations with cancel)
- Modify: `lib/app/router/routes.dart` (`familyInvite(String id, {String? memberId})` → `/family/$id/invite[?member=…]`), `lib/app/router/app_router.dart`, `lib/core/share/share_messages.dart` (`String familyInviteMessage(AppLocalizations l, {required String family, required String code, required String date, String? link, String? downloadUrl})`), `lib/features/family/presentation/family_people_screen.dart` (managers: "Invite" on people without an account, "Make admin" / "Remove admin" for the owner on people with an account; members: no add button, no edit/delete/invite; role shown "Owner" / "Admin" / "Member"), `lib/features/family/presentation/family_home_screen.dart` (Edit and Delete only for managers), `l10n/en|gu/family.json`
- Test: `test/widget/family_invite_test.dart`, `test/core/share_messages_test.dart` (add)

- [ ] **Step 1: Failing tests** — widget: `'the owner invites a named person and gets a code to share'` (People → Rahul Patel ⋮ → Invite → Invite for shows "Rahul Patel" → Create invitation code → a 10-character code and a Share button; the invitations list shows Rahul Patel · Pending); `'a member sees no manage actions'` (Rahul's phone: no "Add person", no ⋮ on people, the Family hisab menu has "New Family hisab" only); unit: `familyInviteMessage` in English contains "*Home*", the code, "Tap to join: <link>" and "valid till", and in Gujarati "પરિવારનો હિસાબ".
- [ ] **Step 2:** run both files → fail.
- [ ] **Step 3:** Implement (texts in both languages).
- [ ] **Step 4:** run both files → pass.

---

### Task 5: One join flow for both kinds

**Files:**
- Modify: `lib/features/groups/presentation/group_cloud_screens.dart` (`JoinGroupScreen`: after accept, a Family hisab code → `familySharingProvider.join`, snack "You joined Home", `pushReplacement(Routes.familyHome(id))`; a group code as today), `lib/features/family/presentation/family_list_screen.dart` (empty state and app bar: "Join with a code" → `Routes.joinGroup`), `l10n` (`joinTitle` "Join with a code" / "કોડથી જોડાઓ", `joinButton` "Join" / "જોડાઓ"; the group invite messages' "Groups → Join a group" wording unchanged)
- Test: `test/widget/family_join_test.dart`, existing `test/widget/invite_link_test.dart` still passes

- [ ] **Step 1: Failing tests** — `'a Family hisab link opens the Family hisab after joining'` (Rahul's signed-in app receives `/join?code=<family code>` → lands on "Home" with his contribution, the pending code is cleared); `'a typed Family hisab code joins too'` (Family hisab list → Join with a code → type → Join → "Home"); `'a used code shows the invalid-code message'`.
- [ ] **Step 2:** `flutter test test/widget/family_join_test.dart` → fail.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** `flutter test test/widget` → pass.

---

### Task 6: Live updates

**Files:**
- Modify: nothing new beyond Task 2's channel; `test/widget/live_updates_test.dart` gains a Family hisab case.

- [ ] **Step 1: Failing test** — `'an entry from another phone appears on the open Family hisab'` (Rahul's app open on Home; Hemang's phone adds Salary ₹60,000 and syncs; Rahul's screen shows it without a tap — live sync answers the fake's change signal).
- [ ] **Step 2:** run → fail (only if Task 2 left a gap; if it passes at once, record that the fake signal path from phase 2 already covers it and keep the test).
- [ ] **Step 3:** Implement whatever is missing.
- [ ] **Step 4:** `flutter test test/widget/live_updates_test.dart` → pass.

---

### Task 7: Whole-phase checks and local commit

- [ ] **Step 1:** `flutter analyze` → `No issues found!`; `dart format --output=none --set-exit-if-changed lib test` → 0; `flutter test` → all pass; `bash tool/run_supabase_tests.sh` → no `FAILED`; `docs/SCREEN_INVENTORY.md` lists the invite screen.
- [ ] **Step 2:** Commit the phase locally ("Family hisab sharing (1.3.0, phase 3)…"), no push; stop and wait for the owner.
