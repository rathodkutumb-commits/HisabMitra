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
import 'package:drift/drift.dart' show Value;
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
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

    // Family hisab: Home, kept together by Hemang and Rahul.
    final family = container.read(familyRepositoryProvider);
    final home = await family.createFamily(
      const FamilyDraft(name: 'Home', startingBalancePaise: 1200000),
      selfName: 'Hemang',
      people: const [
        FamilyPersonDraft(name: 'Rahul Patel', phone: '+919800000001'),
        FamilyPersonDraft(name: 'Priya Shah'),
      ],
    );
    final homePeople = (await family.watchFamily(home).first)!.members;
    final you = homePeople[0].id;
    final rahul = homePeople[1].id;
    final today = DateTime.now();
    DateTime day(int d) =>
        DateTime(today.year, today.month, d > today.day ? today.day : d);
    Future<String> entry(
      String who,
      FamilyEntryKind kind,
      int paise,
      int d, {
      String? category,
      String? note,
    }) => family.saveEntry(
      FamilyEntryDraft(
        familyId: home,
        memberId: who,
        kind: kind,
        amountPaise: paise,
        date: day(d),
        categoryId: category,
        note: note,
      ),
    );
    await entry(you, FamilyEntryKind.salary, 6000000, 1);
    await entry(rahul, FamilyEntryKind.salary, 3500000, 1);
    final rent = await entry(
      you,
      FamilyEntryKind.expense,
      2500000,
      3,
      category: 'cat_rent',
    );
    await entry(rahul, FamilyEntryKind.contribution, 1000000, 5);
    await entry(
      rahul,
      FamilyEntryKind.expense,
      780000,
      8,
      category: 'cat_groceries',
      note: 'Monthly ration',
    );
    await entry(
      you,
      FamilyEntryKind.expense,
      230000,
      10,
      category: 'cat_bills',
    );
    await entry(you, FamilyEntryKind.extraIncome, 500000, 12);
    await entry(
      rahul,
      FamilyEntryKind.expense,
      180000,
      15,
      category: 'cat_household',
    );
    // The rent receipt (only its record: the passbook shows the bill icon).
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'rent-receipt',
            familyEntryId: Value(rent),
            storedName: 'rent-receipt.jpg',
            originalName: 'rent.jpg',
            mimeType: 'image/jpeg',
            sizeBytes: 1,
            sha256: 'screenshot',
            createdAt: today,
          ),
        );
    await settings.update((p) => p.copyWith(sampleDataLoaded: false));
    router().go(Routes.home);
    await shot('12_dashboard_family');
    await open(Routes.familyHome(home), '13_family_passbook');
    unawaited(
      router().push(
        Routes.newFamilyEntry(
          home,
          kind: 'out',
          amountPaise: 450000,
          categoryId: 'cat_groceries',
          note: 'Vegetables and fruits',
        ),
      ),
    );
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await shot('14_family_money_out');
    await open(
      Routes.familyStatement(home, year: today.year, month: today.month),
      '15_family_statement',
    );
    await settings.update((p) => p.copyWith(languageCode: 'gu'));
    await open(Routes.familyHome(home), '16_family_passbook_gujarati');
    await settings.update((p) => p.copyWith(languageCode: 'en'));

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

    // Home on the account: Rahul has joined, Priya is invited next.
    final cloudFamily = cloudApp.read(familyRepositoryProvider);
    final cloudHome = await cloudFamily.createFamily(
      const FamilyDraft(name: 'Home', startingBalancePaise: 1200000),
      selfName: 'Hemang',
      people: const [
        FamilyPersonDraft(name: 'Rahul Patel', phone: '+919800000001'),
        FamilyPersonDraft(name: 'Priya Shah', phone: '+919800000002'),
      ],
    );
    await cloudApp.read(syncServiceProvider).syncOnce();
    final cloudPeople =
        (await cloudFamily.watchFamily(cloudHome).first)!.members;
    server.acceptAny(
      server.family.createInvitation(cloudHome, cloudPeople[1].id, 'hemang'),
      'rahul',
      'Rahul',
    );
    await cloudApp.read(syncServiceProvider).syncOnce();
    await open(Routes.familyPeople(cloudHome), '17_family_people');
    router().go(Routes.familyInvite(cloudHome, memberId: cloudPeople[2].id));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create invitation code'));
    await shot('18_family_invite');
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

  @override
  Future<CreatedInvitation> createFamilyInvitation({
    required String familyId,
    String? memberId,
  }) async {
    final made = await super.createFamilyInvitation(
      familyId: familyId,
      memberId: memberId,
    );
    return CreatedInvitation(
      id: made.id,
      code: 'FKQ7M2HWNC',
      expiresAt: DateTime.now().add(const Duration(hours: 72)),
    );
  }

  /// Realistic expiry dates in the invitations list.
  @override
  Future<List<InvitationInfo>> listFamilyInvitations(String familyId) async => [
    for (final i in await super.listFamilyInvitations(familyId))
      InvitationInfo(
        id: i.id,
        status: i.status,
        expiresAt: DateTime.now().add(const Duration(hours: 72)),
        memberId: i.memberId,
        createdAt: i.createdAt,
      ),
  ];
}
