# Part A — Fixes and Small Features Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the photo-attachment crash, add the floating AI button, exit confirmation on back, on-time reminders, more AI example questions, and nicer shared messages.

**Architecture:** Flutter app (Riverpod, GoRouter, Drift). Each item is a contained change in its feature folder; shared bits go in `lib/core/widgets` (exit confirmation) and `lib/core/share` (message builders). Platform additions are one MethodChannel method in `MainActivity.kt` and two manifest permissions.

**Tech Stack:** Flutter 3.47.9, Dart, flutter_riverpod 3, go_router 18, flutter_local_notifications 23, image_picker 1.2, share_plus 13.

**Spec:** `docs/superpowers/specs/2026-11-20-fixes-and-small-features-design.md`

## Global Constraints

- Every visible string in English **and** Gujarati: edit `l10n/en/<feature>.json` and `l10n/gu/<feature>.json` (placeholder metadata `@key` in the English file only), then run `dart run tool/build_l10n.dart && flutter gen-l10n`. Never edit `lib/l10n/*.arb` or generated Dart by hand.
- Light theme, existing palette colours via `Theme.of(context).colorScheme`; no new colours.
- Every new `FloatingActionButton` sets `heroTag: null` or a unique tag (multiple heroes broke navigation before).
- Domain code (`features/*/domain`) has no Flutter imports.
- Done = `dart format --output=none --set-exit-if-changed lib test tool integration_test` clean, `flutter analyze` clean, `flutter test` all passing.
- Demo/test data uses the name Hemang (people: Rahul Patel / Rahul Shah, Priya Shah; group: Goa Trip). Never "Asha".
- Commit after each task only if the owner approved committing; never push.

## Review Focus

1. Back pressed while a dialog is open on Home → only the dialog closes; no exit prompt. (Task 3 test)
2. Back pressed twice quickly on Home → exactly one exit dialog. (Task 3 test)
3. Build without a GitHub repository configured → shared messages have no download line, never `https://github.com///releases/latest`. (Task 9 test)
4. A recovered camera photo is added to the first **new** form only, once; edit forms and later forms don't get it. (Task 2 test)
5. On a page with its own floating "+" button, the AI button sits fully above it, no overlap. (Task 5 test)

---

### Task 1: Fix the photo thumbnail that builds itself (camera/gallery crash)

**Files:**
- Modify: `lib/features/attachments/presentation/attachments_editor.dart:185-206` (`_Thumb.build`)
- Test: `test/features/attachments/attachments_editor_test.dart` (create)

**Interfaces:**
- Consumes: `AttachmentsEditor({required AttachmentDraft draft, required AttachmentParent parent, String? parentId})`, `StagedAttachment(...)` (existing).
- Produces: nothing new.

- [ ] **Step 1: Write the failing test** `staged image thumbnail renders without a build loop`

Pump `ProviderScope(overrides: [appDatabaseProvider.overrideWithValue(newTestDatabase())], child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, home: Scaffold(body: AttachmentsEditor(draft: draft, parent: AttachmentParent.transaction))))` where `draft` already holds one `StagedAttachment` pointing at a real 1×1 PNG written to a temp dir (`mimeType: 'image/png'`). Use `tester.runAsync` for file I/O, then `pump()` twice.

```dart
expect(tester.takeException(), isNull);
expect(find.byType(Image), findsOneWidget);
```

- [ ] **Step 2: Run it and see it fail**

Run: `flutter test test/features/attachments/attachments_editor_test.dart`
Expected: FAIL with "A build function returned context.widget".

- [ ] **Step 3: Fix `_Thumb.build`**

Keep the icon in `final placeholder = Icon(...)`, and have the `FutureBuilder` return `placeholder` while loading or when the file is missing. `content` is assigned once and never captured.

- [ ] **Step 4: Run the test and see it pass**

Run: `flutter test test/features/attachments/attachments_editor_test.dart` → PASS.

- [ ] **Step 5: Commit** `fix: photo thumbnail no longer builds itself (camera/gallery crash)`

---

### Task 2: Recover a photo when Android closed the app during the camera

**Files:**
- Modify: `lib/features/attachments/data/attachment_service.dart` (add method + provider)
- Modify: `lib/features/attachments/presentation/attachments_editor.dart` (`AttachmentsEditor` → `ConsumerStatefulWidget`)
- Modify: `lib/app/app.dart` (check once after the first frame)
- Modify: `l10n/en/attachments.json`, `l10n/gu/attachments.json`
- Test: `test/features/attachments/attachments_editor_test.dart`

**Interfaces:**
- Produces:
  - `Future<StagedAttachment?> AttachmentService.recoverLostPhoto()`: calls `ImagePicker().retrieveLostData()`; if it has a file, `stage()` it and return it; returns `null` on empty or any error (logged with `SafeLogger`).
  - `final recoveredPhotoProvider = NotifierProvider<RecoveredPhoto, StagedAttachment?>(RecoveredPhoto.new);` with `void set(StagedAttachment a)` and `StagedAttachment? take()` (returns and clears).
  - l10n: `photoRecovered` = "We saved the photo you took. Add it to a new expense?"; `photoRecoveredAction` = "Add expense".

- [ ] **Step 1: Write the failing tests**
  - `recovered photo is added to a new form once`: set `recoveredPhotoProvider` to a staged PNG, pump `AttachmentsEditor(parentId: null)` → `draft.staged.length == 1` and the provider is `null`. Pump a second new editor with a fresh draft → its `draft.staged` is empty.
  - `recovered photo is not added to an edit form`: provider set, pump `AttachmentsEditor(parentId: 't1')` → `draft.staged` empty and the provider still holds the photo.
- [ ] **Step 2: Run them and see them fail**: `flutter test test/features/attachments/attachments_editor_test.dart`.
- [ ] **Step 3: Implement**
  - `AttachmentsEditor.initState`: when `parentId == null`, call `ref.read(recoveredPhotoProvider.notifier).take()`; if the result is non-null, `draft.add` it.
  - `app.dart`: after the first frame, only when `Platform.isAndroid`, call `recoverLostPhoto()`. If it returns a photo, `set` it in the provider and show a SnackBar via `_messengerKey` with `photoRecovered` and action `photoRecoveredAction` → `router.push(Routes.newTransaction(...expense...))`.
  - Add the strings and regenerate l10n.
- [ ] **Step 4: Run tests**: the file above passes, then `flutter test` passes.
- [ ] **Step 5: Commit** `feat: recover a camera photo after Android closes the app`

---

### Task 3: Back button: tabs go Home, Home asks before exiting

**Files:**
- Create: `lib/core/widgets/exit_confirm_scope.dart`
- Modify: `lib/core/widgets/dialogs.dart` (`confirmAction` gains `String? cancelLabel`)
- Modify: `lib/app/router/home_shell.dart`
- Modify: `lib/features/onboarding/presentation/language_screen.dart`, `intro_screen.dart`, `profile_setup_screen.dart`; `lib/features/authentication/presentation/auth_screens.dart` (`VerifyEmailScreen`)
- Modify: `l10n/en/common.json`, `l10n/gu/common.json`
- Test: `test/widget/back_navigation_test.dart` (create)

**Interfaces:**
- Produces:
  - `class ExitConfirmScope extends StatefulWidget { const ExitConfirmScope({super.key, required Widget child, VoidCallback? onBack}); }`. It wraps `PopScope(canPop: !(ModalRoute.of(context)?.isFirst ?? true), onPopInvokedWithResult: ...)`. When a pop is blocked: if `onBack != null`, call it; otherwise show the exit dialog (at most one at a time; a `_asking` flag ignores repeat presses while it's open). On **Exit**, call `SystemNavigator.pop()`.
  - `Future<bool> confirmAction(BuildContext, {required String title, String? message, String? confirmLabel, String? cancelLabel, bool destructive = false})`
  - l10n: `exitAppTitle` "Exit HisabMitra?", `exitAppConfirm` "Exit", `exitAppStay` "Stay".
- `HomeShell`: wrap its `Scaffold` in `ExitConfirmScope(onBack: currentIndex == 0 ? null : () => navigationShell.goBranch(0))`.

- [ ] **Step 1: Write the failing tests** with `pumpHisabMitra`. Mock `SystemChannels.platform` to record `SystemNavigator.pop`, and press back with `await tester.binding.handlePopRoute(); await tester.pumpAndSettle();`.
  - `back on Home asks; Stay keeps the app open`: dialog text `Exit HisabMitra?` is shown; tap `Stay` → dialog gone, pop not recorded.
  - `Exit closes the app`: back, tap `Exit` → `SystemNavigator.pop` recorded.
  - `back on another tab goes to Home`: tap the `Groups` nav item, then back → `DashboardScreen` visible and no dialog.
  - `back on a pushed page returns without asking`: open Reports from Home, back → Home, no dialog.
  - `back with a dialog open closes only the dialog`: open any dialog on Home (e.g. the custom-range picker), back → dialog closed and no exit prompt.
  - `two quick backs on Home show one dialog`: call `handlePopRoute()` twice before `pumpAndSettle` → `find.text('Exit HisabMitra?')` finds one widget.
  - `back on the language screen asks before exiting`: `prefs: AppPreferences.fromMap(const {})`, `profileName: null` → back shows the dialog.
- [ ] **Step 2: Run and see them fail**: `flutter test test/widget/back_navigation_test.dart`.
- [ ] **Step 3: Implement** `ExitConfirmScope`, the `cancelLabel` parameter, the `HomeShell` wrapping, wrap the four onboarding/sign-in screens' scaffolds, add the strings and regenerate l10n.
- [ ] **Step 4: Run** the new test file, then `flutter test` → all pass.
- [ ] **Step 5: Commit** `feat: back goes Home from tabs and asks before exiting`

---

### Task 4: On-phone AI assistant on by default

**Files:**
- Modify: `lib/features/settings/domain/app_preferences.dart` (`_kAiEnabled`)
- Modify: `test/features/settings/app_preferences_test.dart`
- Modify: `docs/AI_ASSISTANT.md` (line 3: "On by default for the on-phone engine; online answers stay off until enabled.")

**Interfaces:**
- Produces: `AppPreferences.aiEnabled` defaults to `true`; stored under the new key `'ai.assistant.enabled'`. The old `'ai.enabled'` key is ignored, like `appearance.theme`.

- [ ] **Step 1: Update/add tests**
  - `AppPreferences.fromMap(const {}).aiEnabled` is `true`.
  - `fromMap({'ai.enabled': 'false'}).aiEnabled` is `true` (old key ignored).
  - `fromMap({'ai.assistant.enabled': 'false'}).aiEnabled` is `false`, and `toMap()` round-trips it.
  - `canUseOnlineAi` stays `false` by default.
- [ ] **Step 2: Run and see them fail**: `flutter test test/features/settings/app_preferences_test.dart`.
- [ ] **Step 3: Change the key constant and the fallback**, then update the doc line.
- [ ] **Step 4: Run** `flutter test`. Fix any existing test that assumed AI off by passing `aiEnabled: false` explicitly.
- [ ] **Step 5: Commit** `feat: on-phone AI assistant on by default`

---

### Task 5: Floating AI button

**Files:**
- Create: `lib/features/ai_assistant/presentation/ai_fab.dart`
- Modify: `lib/features/gujarati_input/presentation/gujarati_text_field.dart` (open-keypad counter)
- Modify (`floatingActionButton:`): `dashboard_screen.dart`, `transactions_screen.dart`, `people_screen.dart`, `groups_screen.dart`, `more_screen.dart`, `person_detail_screen.dart`, `group_detail_screen.dart`, `reports_screen.dart` (`ReportsScreen` only), `reminders_screens.dart` (`RemindersScreen` only), `transaction_detail_screen.dart`, `ledger_history_screen.dart`
- Modify: `test/widget/app_flow_test.dart:438` (`find.byType(FloatingActionButton)` now matches two buttons; find the "+" by its label)
- Modify: `l10n/en/ai.json`, `l10n/gu/ai.json`
- Test: `test/features/ai_assistant/ai_fab_test.dart` (create)

**Interfaces:**
- Produces:
  - `static final ValueNotifier<int> GujaratiTextField.openKeypads`: +1 when a keypad sheet opens, −1 when it closes.
  - `class AiFabStack extends ConsumerWidget { const AiFabStack({super.key, this.child}); final Widget? child; }`. It returns a `Column(mainAxisSize: min, crossAxisAlignment: end)` with the AI button and then, 12 px below it, `child`. The AI button is `FloatingActionButton.small(heroTag: null, tooltip: l.aiOpenAssistant, onPressed: () => context.push(Routes.ai), child: Icon(Icons.auto_awesome_rounded))`. It is omitted when `!prefs.aiEnabled`, when `MediaQuery.viewInsetsOf(context).bottom > 0`, or when `openKeypads.value > 0` (listen to it). If both the button and `child` are absent, return `const SizedBox.shrink()`.
  - l10n: `aiOpenAssistant` "Ask HisabMitra AI" / Gujarati equivalent.
- Wiring: an existing FAB becomes `floatingActionButton: AiFabStack(child: <existing FAB>)`. Pages without one get `floatingActionButton: const AiFabStack()`. Forms, the AI chat, onboarding/sign-in and the calculator are untouched, so they show no button.

- [ ] **Step 1: Write the failing tests** (`pumpHisabMitra`, `aiEnabled: true` prefs):
  - `shows on Home and opens the assistant`: `find.byTooltip('Ask HisabMitra AI')` finds one widget; tap it → AI chat screen (`find.text(l.aiHelp)`), with no AI button there.
  - `sits above the page's + button without overlap` (Groups tab): `tester.getRect(ai).bottom <= tester.getRect(find.widgetWithText(FloatingActionButton, 'Create group')).top`.
  - `hidden on the add-expense form`: tap the "Add expense" quick action → no AI button.
  - `hidden when the assistant is turned off`: prefs `aiEnabled: false` → no AI button on Home.
  - `hidden while the keyboard is open`: `tester.view.viewInsets = const FakeViewPadding(bottom: 900)`, pump → no AI button.
  - `hidden while the Gujarati keypad is open`: `GujaratiTextField.openKeypads.value = 1`, pump → none (reset in `addTearDown`).
- [ ] **Step 2: Run and see them fail**: `flutter test test/features/ai_assistant/ai_fab_test.dart`.
- [ ] **Step 3: Implement** the counter, `AiFabStack`, the wiring on the 11 screens and the string; regenerate l10n.
- [ ] **Step 4: Run** the new tests, then `flutter test`. Fix the `app_flow_test.dart:438` finder and confirm the guided tour tests still pass.
- [ ] **Step 5: Commit** `feat: floating AI button on main pages`

---

### Task 6: Reminders at the exact time

**Files:**
- Modify: `lib/features/reminders/application/notification_service.dart`
- Modify: `android/app/src/main/AndroidManifest.xml`
- Test: `test/features/reminders/notification_schedule_mode_test.dart` (create)

**Interfaces:**
- Produces: `@visibleForTesting Future<void> scheduleWithFallback({required bool canExact, required Future<void> Function(AndroidScheduleMode mode) schedule})`. It uses `exactAllowWhileIdle` when `canExact` and `inexactAllowWhileIdle` otherwise. If the exact attempt throws a `PlatformException`, it retries once with `inexactAllowWhileIdle`. Errors from the inexact attempt propagate.
- `NotificationService.schedule` gets `canExact` from `AndroidFlutterLocalNotificationsPlugin.canScheduleExactNotifications()` (null → false) and calls `scheduleWithFallback`. The existing outer `try/catch` + `SafeLogger` stay. Update the class doc comment, which currently says exact alarms aren't used.
- Manifest (next to the other permissions, each with a one-line comment):
  `<uses-permission android:name="android.permission.USE_EXACT_ALARM" />` and
  `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" android:maxSdkVersion="32" />`

- [ ] **Step 1: Write the failing tests**
  - `exact when allowed`: `canExact: true` → modes recorded `[exactAllowWhileIdle]`.
  - `inexact when not allowed`: `canExact: false` → `[inexactAllowWhileIdle]`.
  - `falls back when exact is refused`: the first call throws `PlatformException(code: 'exact_alarms_not_permitted')` → modes `[exactAllowWhileIdle, inexactAllowWhileIdle]`, no throw.
  - `inexact failure propagates`: `canExact: false` and the schedule throws → `throwsA(isA<PlatformException>())`.
- [ ] **Step 2: Run and see them fail**: `flutter test test/features/reminders/notification_schedule_mode_test.dart`.
- [ ] **Step 3: Implement** the helper, the `schedule` change and the manifest lines.
- [ ] **Step 4: Run** the test file, then `flutter test`.
- [ ] **Step 5: Commit** `fix: reminders use exact alarms so they arrive on time`

---

### Task 7: Battery-saving tip on the reminders screen

**Files:**
- Modify: `android/app/src/main/kotlin/com/hisabmitra/app/MainActivity.kt` (channel `hisabmitra/system`, method `openAppDetails`, which opens `Settings.ACTION_APPLICATION_DETAILS_SETTINGS` for `package:$packageName`)
- Create: `lib/features/reminders/data/app_details_launcher.dart`
- Modify: `lib/features/settings/domain/app_preferences.dart` (new pref)
- Modify: `lib/features/reminders/presentation/reminders_screens.dart` (`RemindersScreen` body)
- Modify: `l10n/en/reminders.json`, `l10n/gu/reminders.json`
- Test: `test/features/reminders/battery_tip_test.dart` (create), `test/features/settings/app_preferences_test.dart`

**Interfaces:**
- Produces:
  - `class AppDetailsLauncher { Future<void> open(); }` invoking `MethodChannel('hisabmitra/system').invokeMethod('openAppDetails')` and ignoring `PlatformException`/`MissingPluginException`; `final appDetailsLauncherProvider = Provider<AppDetailsLauncher>((_) => AppDetailsLauncher());`
  - `AppPreferences.reminderBatteryTipDismissed` (key `'reminders.batteryTipDismissed'`, default `false`, in `copyWith`/`toMap`).
  - l10n: `reminderBatteryTip` "On some phones (Xiaomi, Oppo, Vivo and others) battery saving can stop reminders. Allow HisabMitra to run in the background so they arrive on time."; `reminderBatteryTipOpen` "Open settings"; `reminderBatteryTipDismiss` "Got it".
- UI: `RemindersScreen` body becomes `Column[if (android && !dismissed) _BatteryTipCard(), Expanded(TabBarView(...))]`. The card is a compact `Card` with the text and two `TextButton`s: open settings and dismiss (saves the pref via `settingsControllerProvider.notifier.update`).

- [ ] **Step 1: Write the failing tests**
  - Prefs: default `false`; round-trip `true`.
  - `tip shows, opens settings, and Got it hides it`: `pumpHisabMitra` with `appDetailsLauncherProvider` overridden by a fake that counts calls. `router.push(Routes.reminders)`; the tip text is shown; tap `Open settings` → count 1; tap `Got it` → the tip is gone and stays gone after leaving and reopening the screen.
- [ ] **Step 2: Run and see them fail.**
- [ ] **Step 3: Implement** the Kotlin method, launcher, pref, card and strings; regenerate l10n.
- [ ] **Step 4: Run** the tests, then `flutter test`.
- [ ] **Step 5: Commit** `feat: battery-saving tip for reliable reminders`

---

### Task 8: More AI example questions, grouped, some from the user's own data

**Files:**
- Create: `lib/features/ai_assistant/presentation/ai_examples.dart`
- Modify: `lib/features/ai_assistant/application/ai_chat_controller.dart` (names provider)
- Modify: `lib/features/ai_assistant/presentation/ai_screens.dart` (empty-chat view)
- Modify: `l10n/en/ai.json`, `l10n/gu/ai.json`
- Test: `test/features/ai_assistant/ai_examples_test.dart` (create)

**Interfaces:**
- Produces:
  - `typedef AiExample = ({String text, AiIntent intent, TransactionType? draftType});`
  - `typedef AiExampleSection = ({String title, List<AiExample> examples});`
  - `List<AiExampleSection> buildAiExamples(AppLocalizations l, {String? personName, String? groupName})`
  - `final aiExampleNamesProvider = FutureProvider.autoDispose<({String? person, String? group})>(...)` → the name of the person and of the non-archived group with the latest `updatedAt`, or null when there are none.
- New l10n keys (English shown; write natural Gujarati that hits the same parser keywords):
  - Section titles: `aiExamplesSpending` "Spending", `aiExamplesIncome` "Income & savings", `aiExamplesKhata` "Khata", `aiExamplesGroups` "Groups", `aiExamplesAdd` "Add an entry".
  - `aiExample7` "How much did I spend today?", `aiExample8` "How much did I spend last month?", `aiExample9` "What is my income this month?", `aiExample10` "What was my income last month?", `aiExample11` "What are my savings this month?", `aiExample12` "What are my savings this year?", `aiExample13` "Add 250 for groceries", `aiExample14` "Add salary 25000", `aiExample15` "Add 500 for fuel".
  - `aiExamplePerson` "What is my balance with {name}?", `aiExampleGroupTotal` "How much did {group} cost?", `aiExampleGroupOwes` "Who owes whom in {group}?"
- Sections, in order, with each example's intent:
  - **Spending:** 1 spend, 7 spend, 8 spend, 2 topCategory, 4 topExpenses, 3 compareMonths, 6 reduceTips.
  - **Income & savings:** 9 income, 10 income, 11 savings, 12 savings.
  - **Khata:** 5 receivables, then Person → personBalance when `personName != null`.
  - **Groups** (only when `groupName != null`): GroupTotal → groupTotal, GroupOwes → whoOwesWhom.
  - **Add an entry:** 13 draft (expense), 14 draft (income), 15 draft (expense).
- UI: in the empty-chat view, under `aiHelp`, each section gets a small `titleSmall` heading and a `Wrap` of `ActionChip`s, replacing the flat six-chip list.

- [ ] **Step 1: Write the failing tests.** For each locale `en` and `gu`, build an `AiIntentParser` with `people: [(id: 'p1', name: 'Rahul Shah')]`, `groups: [(id: 'g1', name: 'Goa Trip')]` and categories groceries, fuel and salary (en + gu names):
  - `every example parses to its intent (<locale>)`: for every example from `buildAiExamples(l, personName: 'Rahul Shah', groupName: 'Goa Trip')`, `parser.parse(e.text).intent == e.intent`, and for drafts `draftType == e.draftType`.
  - `18 examples with names, 15 without and no Groups section`.
- [ ] **Step 2: Run and see them fail**: `flutter test test/features/ai_assistant/ai_examples_test.dart`.
- [ ] **Step 3: Implement** the strings (regenerate l10n), `buildAiExamples`, the provider and the UI. Adjust Gujarati wording until the Gujarati test passes; don't change the parser.
- [ ] **Step 4: Run** the tests, then `flutter test`.
- [ ] **Step 5: Commit** `feat: more AI example questions, grouped by topic`

---

### Task 9: Nicer shared messages

**Files:**
- Create: `lib/core/share/share_messages.dart`
- Modify: `lib/features/groups/presentation/group_cloud_screens.dart` (invite share)
- Modify: `lib/features/about/presentation/about_screen.dart` (share app)
- Modify: `lib/features/reports/data/export_service.dart` (`share` gains `String? text`), `lib/features/reports/presentation/export_actions.dart` (`runExport` gains `String? caption`), `lib/features/reports/presentation/reports_screen.dart`
- Modify: `lib/features/backup/presentation/backup_screen.dart` (share caption)
- Modify: `l10n/en|gu/cloud.json`, `about.json`, `reports.json`, `backup.json`
- Test: `test/core/share/share_messages_test.dart` (create)

**Interfaces:**
- Produces:
  - `String? appDownloadUrl()` → `'${AppConfig.githubReleasesPage}/latest'` when `AppConfig.isUpdateCheckConfigured`, else `null`.
  - `String inviteMessage(AppLocalizations l, {required String group, required String code, required String date, String? downloadUrl})` → `l.inviteShareText(group, code, date)`, plus `'\n\n' + l.inviteShareDownload(downloadUrl)` when the URL is non-null.
  - `String appShareMessage(AppLocalizations l, {String? downloadUrl})` → `l.shareAppText`, plus `'\n\n' + l.shareAppDownload(downloadUrl)` when non-null.
- Copy (exact, from the spec §6; Gujarati in the spec too):
  - `inviteShareText` (placeholders `group`, `code`, `date`) = the invite block **without** the 📲 line.
  - `inviteShareDownload(url)` = "📲 Don't have the app? Download it free: {url}".
  - `shareAppText` (no placeholders now) = the app block without the 📲 line; `shareAppDownload(url)` = "📲 Download free: {url}".
  - `shareReportCaption(title, period)` = "📊 *HisabMitra report* · {title} · {period}".
  - `shareBackupCaption(date)` = "🔒 *HisabMitra backup* · {date} — keep this file safe; you'll need your backup password to restore it."; `shareBackupCaptionPlain(date)` = "🔒 *HisabMitra backup* · {date} — keep this file safe."
- Call sites: invite → `inviteMessage(..., date: fmt.date(expiresAt), downloadUrl: appDownloadUrl())`. About → `appShareMessage`. Reports → `caption: l.shareReportCaption(<screen title>, l.reportPeriod(start, end))`. Transactions export → the same with its existing `subtitle` (or `l.filterAll`). Backup → `text:` encrypted/plain caption with `fmt.date(row.createdAt)`. Bill attachments: unchanged.

- [ ] **Step 1: Write the failing tests** (`lookupAppLocalizations` for `en` and `gu`):
  - `invite (en) layout`: with url `https://example.com/latest`, the result starts with `👋 *Join my group on HisabMitra!*`, contains `👥 Group: *Goa Trip*`, `🔑 Invite code: *HSQPP7G9VD*` and `⏳`, has no `hisabmitra://`, `split('\n\n').length == 5`, and ends with `📲 Don't have the app? Download it free: https://example.com/latest`.
  - `invite (gu) layout`: starts with `👋 *હિસાબમિત્રમાં મારા ગ્રુપમાં જોડાઓ!*` and contains `*HSQPP7G9VD*`.
  - `no download line without a repo`: `downloadUrl: null` → no `📲`, 4 blocks. Also `appDownloadUrl()` is `null` in tests (no dart-defines).
  - `share app (en)`: starts with `📒 *HisabMitra — Smart Hisab, Happy Family*`, contains `✅ Daily income and expenses`, and with a URL ends with `📲 Download free: <url>`.
- [ ] **Step 2: Run and see them fail**: `flutter test test/core/share/share_messages_test.dart`.
- [ ] **Step 3: Implement** the strings (regenerate l10n), builders, `text`/`caption` parameters and the call sites.
- [ ] **Step 4: Run** the tests, then `flutter test`.
- [ ] **Step 5: Commit** `feat: clearer shared messages with spacing and emojis`

---

### Task 10: Docs, full checks, device verification

**Files:**
- Modify: `docs/PROGRESS.md` (session log entry for 2026-11-20 Part A), `docs/SCREEN_INVENTORY.md` (AI button), `docs/AI_ASSISTANT.md` (examples list), `docs/PRIVACY_AND_SECURITY.md` (exact-alarm permission line)

- [ ] **Step 1: Full checks.** Run `dart run tool/build_l10n.dart && flutter gen-l10n && dart format --output=none --set-exit-if-changed lib test tool integration_test && flutter analyze && flutter test`. Expected: no format changes, "No issues found!", all tests pass.
- [ ] **Step 2: Release build on the emulator.** Set `ANDROID_USER_HOME`/`ANDROID_EMULATOR_HOME`/`ANDROID_AVD_HOME` to `D:\.android`, run `flutter build apk --release`, install it on `test_device`, then:
  - **Camera:** Add expense → Camera → shutter → ✓ → the thumbnail shows and `adb logcat` has no "Stack overflow".
  - **Gallery:** same, no crash.
  - **Back:** back on Groups → Home; back on Home → dialog; Stay / Exit behave.
  - **AI button:** visible on Home and Groups, hidden on the form, opens chat.
  - **Reminder on time:** create one 2 minutes ahead → `adb shell dumpsys alarm | grep -A6 com.hisabmitra.app` shows it as an exact alarm, and the notification arrives at the set minute.
  - **After a restart:** create one 5 minutes ahead, `adb reboot`, wait for boot → it is listed in `dumpsys alarm` and fires on time.
  - **After an update:** create one 5 minutes ahead, `adb install -r` the same APK → still listed and fires.
  - **Share:** the invite and share-app texts show in the share sheet preview with the new layout.
- [ ] **Step 3: Update the docs** listed above with what changed and the results.
- [ ] **Step 4: Commit** `docs: Part A progress and device checks`
