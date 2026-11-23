import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_cloud.dart';
import '../helpers/test_db.dart';

void main() {
  final ready = AppPreferences.fromMap(const {}).copyWith(
    onboardingComplete: true,
    accountVerified: true,
    initialSyncDone: true,
  );

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  Future<void> openPeople(WidgetTester tester) async {
    await tap(tester, find.text('More').last);
    await tap(tester, find.byKey(const Key('more-family')));
    await tap(tester, find.byTooltip('People'));
  }

  Finder menuOf(String person) => find.descendant(
    of: find.widgetWithText(ListTile, person),
    matching: find.byType(PopupMenuButton<String>),
  );

  testApp('the owner invites a named person and gets a code to share', (
    tester,
  ) async {
    final server = FakeCloudServer();
    final db = await pumpHisabMitra(
      tester,
      prefs: ready,
      overrides: [
        cloudGatewayProvider.overrideWithValue(
          FakeCloudClient(server, 'hemang'),
        ),
      ],
    );
    await FamilyRepository(
      db,
      const Clock(),
      const IdGenerator(),
      currentUserId: () => 'hemang',
    ).createFamily(
      const FamilyDraft(name: 'Home'),
      selfName: 'Hemang',
      people: const [FamilyPersonDraft(name: 'Rahul Patel')],
    );
    await tester.pumpAndSettle();

    await openPeople(tester);
    await tap(tester, menuOf('Rahul Patel'));
    await tap(tester, find.text('Invite'));
    expect(find.text('Rahul Patel'), findsWidgets, reason: 'invite for');
    await tap(tester, find.text('Create invitation code'));

    expect(find.text('FAMCODE000'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.textContaining('Waiting'), findsOneWidget);
  });

  testApp('a member sees no manage actions', (tester) async {
    // Hemang's phone (outside the app) shares Home; Rahul has joined.
    final server = FakeCloudServer();
    final hemangDb = newTestDatabase();
    addTearDown(hemangDb.close);
    final hemang = FamilyRepository(
      hemangDb,
      const Clock(),
      const IdGenerator(),
      currentUserId: () => 'hemang',
    );
    final home = await hemang.createFamily(
      const FamilyDraft(name: 'Home'),
      selfName: 'Hemang',
      people: const [FamilyPersonDraft(name: 'Rahul Patel')],
    );
    await SyncService(
      db: hemangDb,
      cloud: FakeCloudClient(server, 'hemang'),
      clock: const Clock(),
      ids: const IdGenerator(),
    ).syncOnce();
    final rahulPerson = (await hemang.watchFamily(home).first)!.members.last.id;
    server.acceptAny(
      server.family.createInvitation(home, rahulPerson, 'hemang'),
      'rahul',
      'Rahul',
    );

    final rahulCloud = FakeCloudClient(server, 'rahul');
    final db = await pumpHisabMitra(
      tester,
      prefs: ready,
      profileName: 'Rahul',
      overrides: [cloudGatewayProvider.overrideWithValue(rahulCloud)],
    );
    await SyncService(
      db: db,
      cloud: rahulCloud,
      clock: const Clock(),
      ids: const IdGenerator(),
    ).loadFamilySnapshot(home);
    await tester.pumpAndSettle();

    await tap(tester, find.text('More').last);
    await tap(tester, find.byKey(const Key('more-family')));
    await tap(
      tester,
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    expect(find.text('New Family hisab'), findsOneWidget);
    expect(find.text('Edit Family hisab'), findsNothing);
    expect(find.text('Delete Family hisab'), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    await tap(tester, find.byTooltip('People'));
    expect(find.text('Rahul Patel (you)'), findsOneWidget);
    expect(find.text('Add person'), findsNothing);
    expect(find.byType(PopupMenuButton<String>), findsNothing);
  });
}
