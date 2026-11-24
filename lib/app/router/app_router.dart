import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/app_database.dart';
import '../../core/widgets/exit_confirm_scope.dart';
import '../../features/about/presentation/about_screen.dart';
import '../../features/ai_assistant/presentation/ai_screens.dart';
import '../../features/attachments/presentation/attachment_viewer_screen.dart';
import '../../features/authentication/presentation/auth_screens.dart';
import '../../features/backup/presentation/backup_screen.dart';
import '../../features/calculator/presentation/calculator_panel.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/categories/presentation/category_form_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/family/presentation/family_entry_form_screen.dart';
import '../../features/family/presentation/family_form_screen.dart';
import '../../features/family/presentation/family_home_screen.dart';
import '../../features/family/presentation/family_invite_screen.dart';
import '../../features/family/presentation/family_list_screen.dart';
import '../../features/family/presentation/family_people_screen.dart';
import '../../features/family/presentation/family_statement_screen.dart';
import '../../features/groups/presentation/group_cloud_screens.dart';
import '../../features/groups/presentation/group_detail_screen.dart';
import '../../features/groups/presentation/group_expense_detail_screen.dart';
import '../../features/groups/presentation/group_expense_form_screen.dart';
import '../../features/groups/presentation/group_form_screen.dart';
import '../../features/groups/presentation/group_members_screen.dart';
import '../../features/groups/presentation/group_settle_screen.dart';
import '../../features/groups/presentation/group_settlements_screen.dart';
import '../../features/groups/domain/invite_code.dart';
import '../../features/groups/presentation/groups_screen.dart';
import '../../features/money_ledger/presentation/ledger_entry_detail_screen.dart';
import '../../features/money_ledger/presentation/ledger_entry_form_screen.dart';
import '../../features/money_ledger/presentation/ledger_history_screen.dart';
import '../../features/money_ledger/presentation/repayment_form_screen.dart';
import '../../features/onboarding/presentation/intro_screen.dart';
import '../../features/onboarding/presentation/language_screen.dart';
import '../../features/onboarding/presentation/profile_setup_screen.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/people/presentation/people_screen.dart';
import '../../features/people/presentation/person_detail_screen.dart';
import '../../features/people/presentation/person_form_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reminders/presentation/reminders_screens.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/settings/application/settings_controller.dart';
import '../../features/settings/presentation/more_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/synchronization/application/sync_controller.dart';
import '../../features/synchronization/presentation/sync_screen.dart';
import '../../features/transactions/presentation/transaction_detail_screen.dart';
import '../../features/transactions/presentation/transaction_form_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import 'home_shell.dart';
import 'routes.dart';
import '../../features/synchronization/application/account_sync_controller.dart';
import '../../features/synchronization/presentation/account_sync_screen.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(
    settingsControllerProvider.select(
      (p) => (p.onboardingComplete, p.accountVerified, p.initialSyncDone),
    ),
    (_, _) => refresh.value++,
  );
  ref.listen(accountSyncDeferredProvider, (_, _) => refresh.value++);

  String? q(GoRouterState s, String key) => s.uri.queryParameters[key];

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final uri = state.uri;
      // Email verification link: hisabmitra://login-callback?code=…
      if (uri.host == 'login-callback') {
        final code = uri.queryParameters['code'];
        final failed =
            uri.queryParameters.containsKey('error') ||
            uri.queryParameters.containsKey('error_description');
        return Uri(
          path: Routes.verifyEmail,
          queryParameters: {'authCode': ?code, if (failed) 'linkError': '1'},
        ).toString();
      }
      // Invitation deep link: hisabmitra://join?code=XXXX (opened by the
      // https invitation page).
      if (uri.host == 'join' ||
          (uri.path.isEmpty && uri.queryParameters.containsKey('code'))) {
        final code = normalizeInviteCode(uri.queryParameters['code']);
        if (code == null) return Routes.joinGroup;
        // Remember it in case the account isn't ready yet (sign-up first);
        // outside the redirect, which may run while widgets build.
        scheduleMicrotask(
          () => ref
              .read(settingsControllerProvider.notifier)
              .update((p) => p.copyWith(pendingInviteCode: code)),
        );
        return Routes.joinGroupWithCode(code);
      }
      final prefs = ref.read(settingsControllerProvider);
      // Where the app lands: a pending invitation is joined first.
      final pendingInvite = prefs.pendingInviteCode;
      final landing = pendingInvite.isEmpty
          ? Routes.home
          : Routes.joinGroupWithCode(pendingInvite);
      final path = uri.path;
      final inWelcome = path.startsWith('/welcome');
      if (path == Routes.splash) return null;
      if (!prefs.onboardingComplete) return inWelcome ? null : Routes.language;
      // The account (verified email) is compulsory when the build has a
      // cloud configuration; existing installs and signed-out users are
      // asked for it before anything else. Local data is untouched.
      final needsAccount =
          ref.read(cloudGatewayProvider).isConfigured && !prefs.accountVerified;
      if (needsAccount) {
        return path == Routes.profileSetup || path == Routes.verifyEmail
            ? null
            : Routes.profileSetup;
      }
      // Personal records live in the account: sync this phone with it once
      // (upload old phone data, or download on a new phone).
      final needsFirstSync =
          ref.read(cloudGatewayProvider).isConfigured &&
          prefs.accountVerified &&
          !prefs.initialSyncDone &&
          !ref.read(accountSyncDeferredProvider);
      if (needsFirstSync) {
        return path == Routes.accountSync ? null : Routes.accountSync;
      }
      if (inWelcome) return landing;
      if (path == Routes.home && pendingInvite.isNotEmpty) return landing;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: Routes.language,
        builder: (_, _) => const ExitConfirmScope(child: LanguageScreen()),
      ),
      GoRoute(
        path: Routes.intro,
        builder: (_, _) => const ExitConfirmScope(child: IntroScreen()),
      ),
      GoRoute(
        path: Routes.profileSetup,
        builder: (_, _) => const ExitConfirmScope(child: ProfileSetupScreen()),
      ),
      GoRoute(
        path: Routes.accountSync,
        builder: (_, _) => const ExitConfirmScope(child: AccountSyncScreen()),
      ),
      GoRoute(
        path: Routes.verifyEmail,
        builder: (_, s) => ExitConfirmScope(
          child: VerifyEmailScreen(
            authCode: q(s, 'authCode'),
            linkError: q(s, 'linkError') == '1',
          ),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (_, _) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.transactions,
                builder: (_, _) => const TransactionsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.people,
                builder: (_, _) => const PeopleScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.groups,
                builder: (_, _) => const GroupsScreen(),
                routes: [
                  GoRoute(
                    path: 'join',
                    parentNavigatorKey: _rootKey,
                    builder: (_, s) =>
                        JoinGroupScreen(initialCode: q(s, 'code')),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.more, builder: (_, _) => const MoreScreen()),
            ],
          ),
        ],
      ),
      // ------------------------------------------------------ transactions
      GoRoute(
        path: '/transactions/new',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => TransactionFormScreen(
          initialType: q(s, 'type') == 'income'
              ? TransactionType.income
              : TransactionType.expense,
          initialPersonId: q(s, 'personId'),
          initialAmountPaise: int.tryParse(q(s, 'amount') ?? ''),
          initialCategoryId: q(s, 'category'),
          initialDescription: q(s, 'description'),
        ),
      ),
      GoRoute(
        path: '/transactions/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) =>
            TransactionDetailScreen(transactionId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: _rootKey,
            builder: (_, s) =>
                TransactionFormScreen(transactionId: s.pathParameters['id']),
          ),
        ],
      ),
      // -------------------------------------------------------- categories
      GoRoute(
        path: Routes.categories,
        builder: (_, _) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/categories/new',
        builder: (_, s) => CategoryFormScreen(
          initialType: q(s, 'type') == 'income'
              ? TransactionType.income
              : TransactionType.expense,
        ),
      ),
      GoRoute(
        path: '/categories/:id/edit',
        builder: (_, s) =>
            CategoryFormScreen(categoryId: s.pathParameters['id']),
      ),
      // ------------------------------------------------------------ people
      GoRoute(
        path: Routes.newPerson,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PersonFormScreen(),
      ),
      GoRoute(
        path: '/people/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) =>
            PersonDetailScreen(personId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: _rootKey,
            builder: (_, s) =>
                PersonFormScreen(personId: s.pathParameters['id']),
          ),
        ],
      ),
      // ------------------------------------------------------------ ledger
      GoRoute(
        path: '/ledger/new',
        builder: (_, s) => LedgerEntryFormScreen(
          initialPersonId: q(s, 'personId'),
          initialDirection: q(s, 'direction') == 'taken'
              ? LedgerDirection.taken
              : LedgerDirection.given,
        ),
      ),
      GoRoute(
        path: '/ledger/history',
        builder: (_, s) => LedgerHistoryScreen(personId: q(s, 'personId')),
      ),
      GoRoute(
        path: '/ledger/:id',
        builder: (_, s) =>
            LedgerEntryDetailScreen(entryId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, s) =>
                LedgerEntryFormScreen(entryId: s.pathParameters['id']),
          ),
          GoRoute(
            path: 'repay',
            builder: (_, s) =>
                RepaymentFormScreen(entryId: s.pathParameters['id']!),
          ),
        ],
      ),
      // ------------------------------------------------------------ groups
      GoRoute(
        path: Routes.newGroup,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const GroupFormScreen(),
      ),
      GoRoute(
        path: '/groups/:id',
        parentNavigatorKey: _rootKey,
        builder: (_, s) => GroupDetailScreen(groupId: s.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: _rootKey,
            builder: (_, s) => GroupFormScreen(groupId: s.pathParameters['id']),
          ),
          GoRoute(
            path: 'invite',
            parentNavigatorKey: _rootKey,
            builder: (_, s) =>
                GroupInviteScreen(groupId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'members',
            parentNavigatorKey: _rootKey,
            builder: (_, s) =>
                GroupMembersScreen(groupId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'balances',
            parentNavigatorKey: _rootKey,
            builder: (_, s) =>
                GroupBalancesScreen(groupId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'settlements',
            parentNavigatorKey: _rootKey,
            builder: (_, s) =>
                GroupSettlementsScreen(groupId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'settle',
            parentNavigatorKey: _rootKey,
            builder: (_, s) => GroupSettleScreen(
              groupId: s.pathParameters['id']!,
              from: q(s, 'from'),
              to: q(s, 'to'),
              amount: int.tryParse(q(s, 'amount') ?? ''),
            ),
          ),
          GoRoute(
            path: 'expenses/new',
            parentNavigatorKey: _rootKey,
            builder: (_, s) =>
                GroupExpenseFormScreen(groupId: s.pathParameters['id']!),
          ),
          GoRoute(
            path: 'expenses/:eid',
            parentNavigatorKey: _rootKey,
            builder: (_, s) => GroupExpenseDetailScreen(
              groupId: s.pathParameters['id']!,
              expenseId: s.pathParameters['eid']!,
            ),
            routes: [
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _rootKey,
                builder: (_, s) => GroupExpenseFormScreen(
                  groupId: s.pathParameters['id']!,
                  expenseId: s.pathParameters['eid'],
                ),
              ),
            ],
          ),
        ],
      ),
      // -------------------------------------------------------- Family hisab
      GoRoute(
        path: Routes.family,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const FamilyListScreen(),
        routes: [
          GoRoute(
            path: 'new',
            parentNavigatorKey: _rootKey,
            builder: (_, _) => const FamilyFormScreen(),
          ),
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootKey,
            builder: (_, s) =>
                FamilyHomeScreen(familyId: s.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'edit',
                parentNavigatorKey: _rootKey,
                builder: (_, s) =>
                    FamilyFormScreen(familyId: s.pathParameters['id']),
              ),
              GoRoute(
                path: 'people',
                parentNavigatorKey: _rootKey,
                builder: (_, s) =>
                    FamilyPeopleScreen(familyId: s.pathParameters['id']!),
              ),
              GoRoute(
                path: 'invite',
                parentNavigatorKey: _rootKey,
                builder: (_, s) => FamilyInviteScreen(
                  familyId: s.pathParameters['id']!,
                  memberId: q(s, 'member'),
                ),
              ),
              GoRoute(
                path: 'statement',
                parentNavigatorKey: _rootKey,
                builder: (_, s) {
                  final now = DateTime.now();
                  return FamilyStatementScreen(
                    familyId: s.pathParameters['id']!,
                    year: int.tryParse(q(s, 'year') ?? '') ?? now.year,
                    month: int.tryParse(q(s, 'month') ?? '') ?? now.month,
                  );
                },
              ),
              GoRoute(
                path: 'entries/new',
                parentNavigatorKey: _rootKey,
                builder: (_, s) => FamilyEntryFormScreen(
                  familyId: s.pathParameters['id']!,
                  moneyIn: q(s, 'kind') != 'out',
                  initialAmountPaise: int.tryParse(q(s, 'amount') ?? ''),
                  initialCategoryId: q(s, 'category'),
                  initialNote: q(s, 'note'),
                ),
              ),
              GoRoute(
                path: 'entries/:eid/edit',
                parentNavigatorKey: _rootKey,
                builder: (_, s) => FamilyEntryFormScreen(
                  familyId: s.pathParameters['id']!,
                  entryId: s.pathParameters['eid'],
                ),
              ),
            ],
          ),
        ],
      ),
      // ------------------------------------------------------------- tools
      GoRoute(
        path: Routes.calculator,
        builder: (_, _) => const CalculatorScreen(),
      ),
      GoRoute(path: Routes.reports, builder: (_, _) => const ReportsScreen()),
      GoRoute(
        path: '/reports/:kind',
        builder: (_, s) => ReportDetailScreen(
          kind: ReportKind.parse(s.pathParameters['kind']!),
        ),
      ),
      GoRoute(
        path: Routes.reminders,
        builder: (_, _) => const RemindersScreen(),
      ),
      GoRoute(
        path: '/reminders/new',
        builder: (_, s) => ReminderFormScreen(
          ledgerId: q(s, 'ledgerId'),
          groupId: q(s, 'groupId'),
          familyId: q(s, 'familyId'),
          personId: q(s, 'personId'),
          payment: q(s, 'payment') == '1',
        ),
      ),
      GoRoute(
        path: '/reminders/:id/edit',
        builder: (_, s) =>
            ReminderFormScreen(reminderId: s.pathParameters['id']),
      ),
      GoRoute(
        path: '/attachments/:id',
        builder: (_, s) =>
            AttachmentViewerScreen(attachmentId: s.pathParameters['id']!),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: Routes.backup, builder: (_, _) => const BackupScreen()),
      GoRoute(path: Routes.sync, builder: (_, _) => const SyncScreen()),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(path: Routes.about, builder: (_, _) => const AboutScreen()),
      GoRoute(
        path: Routes.ai,
        builder: (_, _) => const AiChatScreen(),
        routes: [
          GoRoute(
            path: 'settings',
            builder: (_, _) => const AiSettingsScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    refresh.dispose();
    router.dispose();
  });
  return router;
});
