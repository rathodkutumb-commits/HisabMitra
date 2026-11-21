import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/app.dart';
import 'package:hisabmitra/app/router/app_router.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/presentation/group_cloud_screens.dart';
import 'package:hisabmitra/features/groups/presentation/group_detail_screen.dart';
import 'package:hisabmitra/features/groups/presentation/groups_screen.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/onboarding/presentation/profile_setup_screen.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/data/settings_repository.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_cloud.dart';
import '../helpers/test_db.dart';

/// Rahul's phone; counts join attempts.
class _RahulCloud extends FakeCloudClient {
  _RahulCloud(FakeCloudServer server) : super(server, 'rahul');

  var accepts = 0;

  @override
  Future<AcceptedInvitation> acceptInvitation({
    required String code,
    required String displayName,
  }) {
    accepts++;
    return super.acceptInvitation(code: code, displayName: displayName);
  }
}

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
  late _RahulCloud cloud;
  late String code;

  /// Hemang's phone (outside the app) shares "Goa Trip" and invites.
  Future<void> hemangInvites() async {
    server = FakeCloudServer();
    cloud = _RahulCloud(server);
    final db = newTestDatabase();
    addTearDown(db.close);
    const ids = IdGenerator();
    final groups = GroupRepository(
      db,
      const Clock(),
      ids,
      currentUserId: () => 'hemang',
    );
    final groupId = await groups.createGroup(
      const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
      selfName: 'Hemang',
      members: const [],
    );
    await SyncService(
      db: db,
      cloud: FakeCloudClient(server, 'hemang'),
      clock: const Clock(),
      ids: ids,
    ).syncOnce();
    code = server.createInvitation(groupId, null);
  }

  Future<(ProviderContainer, AppDatabase)> openApp(
    WidgetTester tester, {
    AppPreferences? prefs,
  }) async {
    final db = await pumpHisabMitra(
      tester,
      prefs: prefs ?? ready,
      profileName: 'Rahul Patel',
      overrides: [cloudGatewayProvider.overrideWithValue(cloud)],
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(HisabMitraApp)),
    );
    return (container, db);
  }

  String pending(ProviderContainer c) =>
      c.read(settingsControllerProvider).pendingInviteCode;

  String fieldText(WidgetTester tester) =>
      tester.widget<TextField>(find.byType(TextField)).controller!.text;

  testApp('a link joins the group for a signed-in user', (tester) async {
    await hemangInvites();
    final (container, _) = await openApp(tester);

    await openLink(tester, 'hisabmitra://join?code=${code.toLowerCase()}');

    expect(find.byType(GroupDetailScreen), findsOneWidget);
    expect(find.text('Goa Trip'), findsWidgets);
    expect(find.text('You joined Goa Trip'), findsOneWidget);
    expect(cloud.accepts, 1);
    expect(pending(container), '');

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(GroupsScreen), findsOneWidget);
  });

  testApp('a link waits for sign-up, then joins', (tester) async {
    await hemangInvites();
    final (container, db) = await openApp(
      tester,
      prefs: AppPreferences.fromMap(const {})
          .copyWith(onboardingComplete: true),
    );

    await openLink(tester, 'hisabmitra://join?code=$code');

    expect(find.byType(ProfileSetupScreen), findsOneWidget);
    expect(cloud.accepts, 0);
    expect(pending(container), code);
    expect(await SettingsRepository(db).readRaw('groups.pendingInvite'), code);

    await container
        .read(settingsControllerProvider.notifier)
        .update(
          (p) => p.copyWith(accountVerified: true, initialSyncDone: true),
        );
    await tester.pumpAndSettle();

    expect(find.byType(GroupDetailScreen), findsOneWidget);
    expect(find.text('Goa Trip'), findsWidgets);
    expect(cloud.accepts, 1);
    expect(pending(container), '');
  });

  testApp('a failed join shows the reason with the code filled in', (
    tester,
  ) async {
    await hemangInvites();
    final (container, _) = await openApp(tester);

    await openLink(tester, 'hisabmitra://join?code=NOPE1234');

    expect(find.byType(JoinGroupScreen), findsOneWidget);
    expect(fieldText(tester), 'NOPE1234');
    expect(find.text('This invitation code is not valid.'), findsOneWidget);
    expect(pending(container), '');
  });

  testApp('the same link twice does not loop', (tester) async {
    await hemangInvites();
    final (container, _) = await openApp(tester);
    await openLink(tester, 'hisabmitra://join?code=$code');
    expect(find.byType(GroupDetailScreen), findsOneWidget);
    container.read(routerProvider).go(Routes.home);
    await tester.pumpAndSettle();

    await openLink(tester, 'hisabmitra://join?code=$code');
    expect(find.byType(JoinGroupScreen), findsOneWidget);
    expect(find.text('This invitation code is not valid.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(JoinGroupScreen), findsOneWidget);
    expect(cloud.accepts, 2);
    expect(pending(container), '');
  });

  testApp('an invalid link opens the empty join screen', (tester) async {
    await hemangInvites();
    final (container, _) = await openApp(tester);

    await openLink(tester, 'hisabmitra://join?code=ab');

    expect(find.byType(JoinGroupScreen), findsOneWidget);
    expect(fieldText(tester), '');
    expect(cloud.accepts, 0);
    expect(server.invitations[code]!.used, isFalse);
    expect(pending(container), '');
  });

  testApp('the Groups tab still opens the empty join screen', (tester) async {
    await hemangInvites();
    final (container, _) = await openApp(tester);
    container.read(routerProvider).go(Routes.groups);
    await tester.pumpAndSettle();

    // What the Groups tab's "Join a group" button does (shown only in
    // builds with a cloud configuration).
    unawaited(container.read(routerProvider).push(Routes.joinGroup));
    await tester.pumpAndSettle();

    expect(find.byType(JoinGroupScreen), findsOneWidget);
    expect(fieldText(tester), '');
    expect(cloud.accepts, 0);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(GroupsScreen), findsOneWidget);
  });
}
