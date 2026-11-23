import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/app.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/family/presentation/family_home_screen.dart';
import 'package:hisabmitra/features/groups/presentation/group_cloud_screens.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_cloud.dart';
import '../helpers/test_db.dart';

/// Delivers [uri] the way Android hands a link to the app.
Future<void> openLink(WidgetTester tester, String uri) async {
  await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
    SystemChannels.navigation.name,
    SystemChannels.navigation.codec.encodeMethodCall(
      MethodCall('pushRouteInformation', {'location': uri, 'state': null}),
    ),
    (_) {},
  );
  await tester.pumpAndSettle();
}

void main() {
  final ready = AppPreferences.fromMap(const {}).copyWith(
    onboardingComplete: true,
    accountVerified: true,
    initialSyncDone: true,
  );

  late FakeCloudServer server;
  late String code;

  /// Hemang's phone (outside the app) shares Home and invites Rahul Patel.
  Future<void> hemangInvitesRahul() async {
    server = FakeCloudServer();
    final db = newTestDatabase();
    addTearDown(db.close);
    final repo = FamilyRepository(
      db,
      const Clock(),
      const IdGenerator(),
      currentUserId: () => 'hemang',
    );
    final home = await repo.createFamily(
      const FamilyDraft(name: 'Home'),
      selfName: 'Hemang',
      people: const [FamilyPersonDraft(name: 'Rahul Patel')],
    );
    final rahul = (await repo.watchFamily(home).first)!.members.last.id;
    await repo.saveEntry(
      FamilyEntryDraft(
        familyId: home,
        memberId: rahul,
        kind: FamilyEntryKind.contribution,
        amountPaise: 1000000,
        date: DateTime.now(),
      ),
    );
    await SyncService(
      db: db,
      cloud: FakeCloudClient(server, 'hemang'),
      clock: const Clock(),
      ids: const IdGenerator(),
    ).syncOnce();
    code = server.family.createInvitation(home, rahul, 'hemang');
  }

  Future<ProviderContainer> openRahulsApp(WidgetTester tester) async {
    await pumpHisabMitra(
      tester,
      prefs: ready,
      profileName: 'Rahul',
      overrides: [
        cloudGatewayProvider.overrideWithValue(
          FakeCloudClient(server, 'rahul'),
        ),
      ],
    );
    return ProviderScope.containerOf(
      tester.element(find.byType(HisabMitraApp)),
    );
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testApp('a Family hisab link opens the Family hisab after joining', (
    tester,
  ) async {
    await hemangInvitesRahul();
    final c = await openRahulsApp(tester);

    await openLink(tester, 'hisabmitra://join?code=${code.toLowerCase()}');

    expect(find.byType(FamilyHomeScreen), findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('Home')),
      findsOneWidget,
    );
    expect(find.text('You joined Home'), findsOneWidget);
    expect(find.text('Contribution'), findsOneWidget);
    expect(c.read(settingsControllerProvider).pendingInviteCode, '');
  });

  testApp('a typed Family hisab code joins too', (tester) async {
    await hemangInvitesRahul();
    await openRahulsApp(tester);
    await tap(tester, find.text('More').last);
    await tap(tester, find.byKey(const Key('more-family')));
    await tap(tester, find.text('Join with a code'));
    expect(find.byType(JoinGroupScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), code);
    await tap(
      tester,
      find.ancestor(of: find.text('Join'), matching: find.byType(FilledButton)),
    );
    expect(find.byType(FamilyHomeScreen), findsOneWidget);
    expect(find.text('Contribution'), findsOneWidget);
  });

  testApp('a used code shows the invalid-code message', (tester) async {
    await hemangInvitesRahul();
    server.acceptAny(code, 'priya', 'Priya Shah');
    await openRahulsApp(tester);

    await openLink(tester, 'hisabmitra://join?code=$code');

    expect(find.byType(JoinGroupScreen), findsOneWidget);
    expect(find.text('This invitation code is not valid.'), findsOneWidget);
    expect(find.byType(FamilyHomeScreen), findsNothing);
  });
}
