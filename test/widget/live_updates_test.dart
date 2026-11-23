import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/app.dart';
import 'package:hisabmitra/app/router/app_router.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/live_sync.dart';
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

  late FakeCloudServer server;
  late AppDatabase hemangDb;
  late GroupRepository hemangGroups;
  late SyncService hemangSync;
  late String groupId;

  /// Hemang's phone (outside the app) creates "Goa Trip"; Rahul accepts.
  Future<void> hemangSharesGoaTrip() async {
    server = FakeCloudServer();
    hemangDb = newTestDatabase();
    addTearDown(hemangDb.close);
    const ids = IdGenerator();
    hemangGroups = GroupRepository(
      hemangDb,
      const Clock(),
      ids,
      currentUserId: () => 'hemang',
    );
    hemangSync = SyncService(
      db: hemangDb,
      cloud: FakeCloudClient(server, 'hemang'),
      clock: const Clock(),
      ids: ids,
    );
    groupId = await hemangGroups.createGroup(
      const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
      selfName: 'Hemang',
      members: const [MemberDraft(name: 'Rahul Patel')],
    );
    final d = (await hemangGroups.watchGroup(groupId).first)!;
    await hemangSync.syncOnce();
    final rahul = d.members.firstWhere((m) => !m.isSelf).id;
    server.accept(server.createInvitation(groupId, rahul), 'rahul', 'Rahul');
  }

  Future<ProviderContainer> openAppAsRahul(WidgetTester tester) async {
    await pumpHisabMitra(
      tester,
      prefs: ready,
      profileName: 'Rahul Patel',
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

  testApp('a group expense from another phone appears on the open group', (
    tester,
  ) async {
    await hemangSharesGoaTrip();
    final container = await openAppAsRahul(tester);
    await container.read(syncServiceProvider).joinGroup(groupId);
    container.read(routerProvider).go(Routes.group(groupId));
    await tester.pumpAndSettle();
    expect(find.text('Goa Trip'), findsWidgets);
    expect(find.text('Hotel'), findsNothing);

    final d = (await hemangGroups.watchGroup(groupId).first)!;
    await hemangGroups.saveExpense(
      ExpenseDraft(
        groupId: groupId,
        description: 'Hotel',
        categoryKey: 'stay',
        amountPaise: 100000,
        paidByMemberId: d.selfMember!.id,
        date: DateTime(2026, 11, 20),
        splitMethod: SplitMethod.equal,
        participants: [for (final m in d.members) SplitParticipant(m.id, 0)],
      ),
    );
    await hemangSync.syncOnce();

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Hotel'), findsWidgets);
  });

  testApp('an entry from another phone appears on the open Family hisab', (
    tester,
  ) async {
    await hemangSharesGoaTrip();
    final hemangFamily = FamilyRepository(
      hemangDb,
      const Clock(),
      const IdGenerator(),
      currentUserId: () => 'hemang',
    );
    final home = await hemangFamily.createFamily(
      const FamilyDraft(name: 'Home'),
      selfName: 'Hemang',
      people: const [FamilyPersonDraft(name: 'Rahul Patel')],
    );
    final members = (await hemangFamily.watchFamily(home).first)!.members;
    await hemangSync.syncOnce();
    server.acceptAny(
      server.family.createInvitation(home, members.last.id, 'hemang'),
      'rahul',
      'Rahul',
    );

    final container = await openAppAsRahul(tester);
    await container.read(syncServiceProvider).loadFamilySnapshot(home);
    container.read(routerProvider).go(Routes.familyHome(home));
    await tester.pumpAndSettle();
    expect(find.text('Salary'), findsNothing);

    await hemangFamily.saveEntry(
      FamilyEntryDraft(
        familyId: home,
        memberId: members.first.id,
        kind: FamilyEntryKind.salary,
        amountPaise: 6000000,
        date: DateTime.now(),
      ),
    );
    await hemangSync.syncOnce();

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Salary'), findsOneWidget);
  });

  testApp('the app stops listening in the background', (tester) async {
    await hemangSharesGoaTrip();
    final container = await openAppAsRahul(tester);
    expect(container.read(liveSyncControllerProvider), isTrue);

    for (final s in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pump();
    expect(container.read(liveSyncControllerProvider), isFalse);

    for (final s in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(s);
    }
    await tester.pumpAndSettle();
    expect(container.read(liveSyncControllerProvider), isTrue);
  });
}
