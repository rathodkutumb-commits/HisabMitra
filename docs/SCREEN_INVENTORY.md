# Screen Inventory

Status legend: **Done** = implemented on real data with loading, empty and
error states, localised in English and Gujarati, actions working.
**Blocked** = implemented, needs external configuration to work end to end.
"Test" names the automated test that drives the screen (W = widget/app flow
test in `test/widget/app_flow_test.dart`, also run on device through
`integration_test/app_flows_test.dart`; U = unit/repository tests behind it).

| # | Screen | Route | Widget | Status | Test |
|---|---|---|---|---|---|
| 1 | Splash | `/splash` | `SplashScreen` | Done | W |
| 2 | Onboarding intro | `/welcome/intro` | `IntroScreen` | Done | W (onboarding) |
| 3 | Language selection | `/welcome/language` | `LanguageScreen` | Done | W (onboarding) |
| 4–6 | Account details (name, email, mobile — compulsory) | `/welcome/profile` | `ProfileSetupScreen` | Done | W (onboarding, sign-up, existing install) |
| 5 | Verify email (code or link) | `/welcome/verify` | `VerifyEmailScreen` | Done; real users need custom SMTP (SUPABASE_SETUP §4.3) | W (sign-up), U |
| 7 | Dashboard | `/home` | `DashboardScreen` | Done | W (add expense updates totals) |
| 8 | Transaction list (list + Excel-like sheet) | `/transactions` | `TransactionsScreen`, `TransactionSheetView` | Done | W (sheet view), U |
| 9 | Add income | `/transactions/new?type=income` | `TransactionFormScreen` | Done | U |
| 10 | Add expense | `/transactions/new` | `TransactionFormScreen` | Done | W |
| 11 | Transaction details | `/transactions/:id` | `TransactionDetailScreen` | Done | W (opened from sheet) |
| 12 | Edit transaction | `/transactions/:id/edit` | `TransactionFormScreen` | Done | U |
| 13 | Categories | `/categories` | `CategoriesScreen` | Done | U |
| 14 | Add/edit category | `/categories/new`, `/categories/:id/edit` | `CategoryFormScreen` | Done | U |
| 15 | People list (person-wise balances) | `/people` | `PeopleScreen` | Done | U |
| 16 | Add/edit person (manual or Android contact picker) | `/people/new`, `/people/:id/edit` | `PersonFormScreen` | Done | U |
| 17 | Person details + person ledger | `/people/:id` | `PersonDetailScreen` | Done | U |
| 18 | Personal money ledger | People tab + person detail | `PeopleScreen`, `PersonDetailScreen` | Done | U (ledger repository) |
| 19 | Add money given/taken | `/ledger/new` | `LedgerEntryFormScreen` | Done | U |
| 20 | Repayment entry | `/ledger/:id/repay` | `RepaymentFormScreen` | Done | U (over-repayment guard) |
| 21 | Repayment / settlement history | `/ledger/history`, `/ledger/:id` | `LedgerHistoryScreen`, `LedgerEntryDetailScreen` | Done | U |
| 22 | Group list | `/groups` | `GroupsScreen` | Done | W |
| 23 | Create/edit group | `/groups/new`, `/groups/:id/edit` | `GroupFormScreen` | Done | W |
| 24 | Group details | `/groups/:id` | `GroupDetailScreen` | Done | W |
| 25 | Group members | `/groups/:id/members` | `GroupMembersScreen` | Done | U |
| 26 | Add group expense | `/groups/:id/expenses/new` | `GroupExpenseFormScreen` | Done | W |
| 27 | Expense split configuration + preview | inside 26 | `GroupExpenseFormScreen` | Done | W, U (split calculator) |
| 28 | Expense details | `/groups/:id/expenses/:eid` | `GroupExpenseDetailScreen` | Done | U |
| 29 | Date-wise spreadsheet view | inside 24 | `GroupSpreadsheetView` | Done | U |
| 30 | Grid/card view | inside 24 | `GroupCardsView` | Done | U |
| 31 | Timeline view | inside 24 | `GroupTimelineView` | Done | U |
| 32 | Group balance summary | `/groups/:id/balances` | `GroupBalancesScreen` | Done | W |
| 33 | Group settlement | `/groups/:id/settle` | `GroupSettleScreen` | Done | U |
| 34 | Group settlement history | `/groups/:id/settlements` | `GroupSettlementsScreen` | Done | U |
| 35 | Calculator | `/calculator` (+ panel in forms) | `CalculatorScreen` | Done | U (calculator engine) |
| 36 | Reports | `/reports` | `ReportsScreen` | Done | U (report service) |
| 37 | Report details + PDF/CSV export | `/reports/:kind` | `ReportDetailScreen` | Done | U (CSV, PDF renderer) |
| 38 | AI assistant (+ AI settings) | `/ai`, `/ai/settings` | `AiChatScreen`, `AiSettingsScreen` | Done (local); online AI needs the user's own key | U |
| 39 | Reminders (+ form, recurring payments) | `/reminders`, `/reminders/new`, `/reminders/:id/edit` | `RemindersScreen`, `ReminderFormScreen` | Done | U |
| 40 | Attachment viewer | `/attachments/:id` | `AttachmentViewerScreen` | Done | — (manual) |
| 41 | Backup and restore | `/backup` | `BackupScreen` | Done | U, device test |
| 42 | Synchronisation status + conflicts | `/sync` | `SyncScreen` | Blocked — needs sign-in | U (fake cloud) |
| 43 | Settings | `/settings` | `SettingsScreen` | Done | W (Gujarati sections) |
| 44 | Profile / account | `/profile` | `ProfileScreen` | Done; delete account blocked on Edge Function | — |
| 45 | About, release info, update check | `/about` | `AboutScreen` | Blocked — GitHub owner/repo not configured | U (update checker) |
| + | Group invitation | `/groups/:id/invite` | `GroupInviteScreen` | Blocked — needs sign-in | U |
| + | Join group with code | `/join` | `JoinGroupScreen` | Blocked — needs sign-in | U |
| + | More (menu tab) | `/more` | `MoreScreen` | Done | W |
| + | Family hisab list (opens the only one directly) | `/family` | `FamilyListScreen` | Done | W (`family_setup_test`) |
| + | Create/edit Family hisab | `/family/new`, `/family/:id/edit` | `FamilyFormScreen` | Done | W (`family_setup_test`) |
| + | Family hisab (month passbook) | `/family/:id` | `FamilyHomeScreen` | Done | W (`family_entries_test`), U (passbook) |
| + | Family hisab people | `/family/:id/people` | `FamilyPeopleScreen` | Done | W (`family_setup_test`) |
| + | Money in / money out | `/family/:id/entries/new?kind=in\|out`, `/family/:id/entries/:eid/edit` | `FamilyEntryFormScreen` | Done | W (`family_entries_test`) |
| + | Family hisab statement (PDF, WhatsApp) | `/family/:id/statement?year=&month=` | `FamilyStatementScreen` | Done | W (`family_statement_test`), U (text, PDF) |
| + | Guided tour + sample data (overlay, prompt, banner) | overlay on any route | `TourOverlay`, `TourPromptHost`, `SampleDataBanner` | Done | W (tour, banner)
| + | Floating AI button (above the page's own button; hidden on forms, chat, onboarding, with keyboard/keypad, or when AI is off) | tabs + list/detail pages | `AiFabStack` | Done | W (`ai_fab_test`) |
| + | Exit confirmation on back (tabs go Home first) | Home tab, onboarding, sign-in | `ExitConfirmScope` | Done | W (`back_navigation_test`) |, U (sample data) |

## Shared components

`HmTextField` / `GujaratiTextField` (Gujarati input modes), `GujaratiKeypad`,
`AmountText`, `IconBadge`, `SectionHeader`, `EmptyState`, `AsyncValueView`,
confirmation dialogs (`dialogs.dart`), Patola band / toran / Bandhani
painters (`decor.dart`, `patterns.dart`), `HmLogo`.
