// Captures README screenshots of the main screens on a device or emulator,
// using the guided tour's sample data in an in-memory database (the
// device's real data is not touched):
//
//   flutter drive -d emulator-5554 \
//     --driver=screenshots/driver.dart \
//     --target=screenshots/app_screenshots_test.dart
//
// PNGs are written to build/screenshots/ (copy the ones you want to
// docs/screenshots/).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/core/database/app_database.dart' show GroupType;
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/gujarati_input/presentation/gujarati_keypad.dart';
import 'package:hisabmitra/features/gujarati_input/presentation/gujarati_text_field.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';
import 'package:hisabmitra/features/tour/application/tour_controller.dart';
import 'package:hisabmitra/features/tour/data/sample_data_service.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/app_harness.dart';
import '../test/helpers/fake_cloud.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('screenshots', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    final db = await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {}).copyWith(
        onboardingComplete: true,
        gujaratiInputMode: GujaratiInputMode.keypad,
      ),
    );
    // The harness fixes a phone size for host tests; use the real screen.
    tester.view.reset();
    await tester.pumpAndSettle();

    Element anyScaffold() => tester.element(find.byType(Scaffold).first);
    final container = ProviderScope.containerOf(anyScaffold());
    GoRouter router() => GoRouter.of(anyScaffold());
    Future<void> shot(String name) async {
      await tester.pumpAndSettle();
      await binding.takeScreenshot(name);
    }

    Future<void> open(String route, String name) async {
      router().go(route);
      await shot(name);
    }

    await container.read(sampleDataServiceProvider).load();
    // Hide the "sample data" banner for clean pictures.
    final settings = container.read(settingsControllerProvider.notifier);
    await settings.update((p) => p.copyWith(sampleDataLoaded: false));
    await shot('01_dashboard');

    router().go(Routes.transactions);
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.table_chart_rounded));
    await shot('02_hisab_sheet');

    await open(Routes.people, '03_khata');

    final group = await db.select(db.groupsCache).getSingle();
    await open(Routes.group(group.id), '04_group');
    await open(Routes.groupBalances(group.id), '05_group_balances');
    await open(Routes.reports, '06_reports');

    // New expense with the Gujarati keypad after typing પ.
    router().go(Routes.home);
    await tester.pumpAndSettle();
    unawaited(router().push(Routes.newTransaction()));
    await tester.pumpAndSettle();
    final description = find.descendant(
      of: find.byType(GujaratiTextField).first,
      matching: find.byType(TextFormField),
    );
    await tester.ensureVisible(description);
    await tester.tap(description);
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(GujaratiKeypad),
        matching: find.text('પ'),
      ),
    );
    await shot('07_gujarati_keypad');

    router().go(Routes.home);
    await tester.pumpAndSettle();
    await settings.update((p) => p.copyWith(languageCode: 'gu'));
    await shot('08_dashboard_gujarati');

    // Samples are already loaded: restore the flag so the tour reuses them.
    await settings.update(
      (p) => p.copyWith(languageCode: 'en', sampleDataLoaded: true),
    );
    await container.read(tourControllerProvider.notifier).start();
    await pumpFor(tester, const Duration(milliseconds: 1600));
    await shot('09_tour');
    await container
        .read(tourControllerProvider.notifier)
        .finish(removeSample: false);
    await tester.pumpAndSettle();

    // The assistant answering one of its example questions.
    router().go(Routes.ai);
    await tester.pumpAndSettle();
    final example = find.text('What is my biggest expense category?');
    if (example.evaluate().isNotEmpty) {
      await tester.ensureVisible(example.first);
      await tester.tap(example.first);
    }
    await pumpFor(tester, const Duration(seconds: 2));
    await shot('10_ai_assistant');

    // A group invitation. Invitations need a group saved to an account, so
    // restart the app on the in-memory test cloud (nothing leaves the phone).
    await tester.pumpWidget(const SizedBox());
    final server = FakeCloudServer();
    await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {}).copyWith(
        onboardingComplete: true,
        accountVerified: true,
        initialSyncDone: true,
      ),
      overrides: [
        cloudGatewayProvider.overrideWithValue(_ScreenshotCloud(server)),
      ],
    );
    tester.view.reset();
    await tester.pumpAndSettle();
    final cloudApp = ProviderScope.containerOf(anyScaffold());
    final groupId = await cloudApp
        .read(groupRepositoryProvider)
        .createGroup(
          const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
          selfName: 'Hemang',
          members: const [
            MemberDraft(name: 'Rahul Patel'),
            MemberDraft(name: 'Priya Shah'),
          ],
        );
    await cloudApp.read(syncServiceProvider).syncOnce();
    router().go(Routes.groupInvite(groupId));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create invitation code'));
    await shot('11_group_invite');
  });
}

/// The test cloud, with a realistic invitation code for the picture.
class _ScreenshotCloud extends FakeCloudClient {
  _ScreenshotCloud(FakeCloudServer server) : super(server, 'hemang');

  @override
  Future<CreatedInvitation> createInvitation({
    required String groupId,
    String? memberId,
  }) async => CreatedInvitation(
    id: 'inv',
    code: 'HSQPP7G9VD',
    expiresAt: DateTime.now().add(const Duration(hours: 72)),
  );
}
