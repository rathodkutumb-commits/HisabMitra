import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/family/application/family_sharing.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

class _Clock extends Clock {
  DateTime value = DateTime(2026, 11, 23, 10);
  @override
  DateTime now() => value;
}

/// One person's phone on the shared fake server.
class Phone {
  Phone(FakeCloudServer server, String uid) {
    cloud = FakeCloudClient(server, uid);
    const ids = IdGenerator();
    family = FamilyRepository(db, clock, ids, currentUserId: () => uid);
    sync = SyncService(db: db, cloud: cloud, clock: clock, ids: ids);
    sharing = FamilySharing(cloud, sync);
  }

  final db = newTestDatabase();
  final clock = _Clock();
  late final FakeCloudClient cloud;
  late final FamilyRepository family;
  late final SyncService sync;
  late final FamilySharing sharing;

  Future<FamilyDetail?> detail(String id) => family.watchFamily(id).first;

  Future<List<OutboxRow>> outbox() => db.select(db.syncOutbox).get();

  /// Lets a backed-off upload be retried.
  void later() => clock.value = clock.value.add(const Duration(minutes: 5));
}

void main() {
  late FakeCloudServer server;
  late Phone hemang;
  late Phone rahul;
  late String home;
  late String rahulPerson;

  setUp(() async {
    server = FakeCloudServer();
    hemang = Phone(server, 'hemang');
    rahul = Phone(server, 'rahul');
    home = await hemang.family.createFamily(
      const FamilyDraft(name: 'Home', startingBalancePaise: 1200000),
      selfName: 'Hemang',
      people: const [FamilyPersonDraft(name: 'Rahul Patel')],
    );
    rahulPerson = (await hemang.detail(home))!.members
        .firstWhere((m) => m.name == 'Rahul Patel')
        .id;
    await hemang.family.saveEntry(
      FamilyEntryDraft(
        familyId: home,
        memberId: rahulPerson,
        kind: FamilyEntryKind.contribution,
        amountPaise: 1000000,
        date: DateTime(2026, 11, 12),
      ),
    );
    await hemang.sync.syncOnce();
  });
  tearDown(() async {
    await hemang.db.close();
    await rahul.db.close();
  });

  /// Hemang invites Rahul Patel; Rahul's phone accepts and joins.
  Future<void> rahulJoins() async {
    final inv = await hemang.sharing.createInvitation(
      familyId: home,
      memberId: rahulPerson,
    );
    final accepted = await rahul.cloud.acceptInvitation(
      code: inv.code,
      displayName: 'Rahul',
    );
    expect(await rahul.sharing.join(accepted), home);
  }

  test('Rahul joins as his named person and keeps his entries', () async {
    await rahulJoins();
    final d = (await rahul.detail(home))!;
    expect(d.family.name, 'Home');
    expect((d.self!.id, d.self!.name), (rahulPerson, 'Rahul Patel'));
    expect(d.entries.single.amountPaise, 1000000);
    expect(d.entries.single.memberId, rahulPerson);
    expect((d.canManage, d.isOwner), (false, false));
    final h = (await hemang.detail(home))!;
    expect((h.canManage, h.isOwner), (true, true));
  });

  test('Hemang sees that Rahul has the app', () async {
    await rahulJoins();
    await hemang.sync.syncOnce();
    final person = (await hemang.detail(home))!.members
        .firstWhere((m) => m.id == rahulPerson);
    expect((person.userId, person.isSelf), ('rahul', false));
  });

  test('an entry Rahul adds reaches Hemang', () async {
    await rahulJoins();
    await rahul.family.saveEntry(
      FamilyEntryDraft(
        familyId: home,
        memberId: rahulPerson,
        kind: FamilyEntryKind.salary,
        amountPaise: 3500000,
        date: DateTime(2026, 11, 1),
      ),
    );
    await rahul.sync.syncOnce();
    expect(await rahul.outbox(), isEmpty);
    await hemang.sync.syncOnce();
    expect((await hemang.detail(home))!.month(2026, 11).moneyInPaise, 4500000);
  });

  test('making Rahul an admin lets him add people', () async {
    await rahulJoins();
    await hemang.sharing.setRole(rahulPerson, 'admin');
    await rahul.sync.syncOnce();
    expect((await rahul.detail(home))!.canManage, isTrue);
    await rahul.family.savePerson(
      FamilyPersonDraft(familyId: home, name: 'Priya Shah'),
    );
    await rahul.sync.syncOnce();
    expect(await rahul.outbox(), isEmpty);
    await hemang.sync.syncOnce();
    expect(
      (await hemang.detail(home))!.members.map((m) => m.name),
      contains('Priya Shah'),
    );
  });

  test("a removed person's phone forgets the Family hisab", () async {
    await rahulJoins();
    rahul.cloud.online = false;
    await rahul.family.saveEntry(
      FamilyEntryDraft(
        familyId: home,
        memberId: rahulPerson,
        kind: FamilyEntryKind.salary,
        amountPaise: 3500000,
        date: DateTime(2026, 11, 1),
      ),
    );
    await hemang.sync.syncOnce(); // Hemang's phone knows Rahul joined
    await hemang.family.deletePerson(rahulPerson);
    await hemang.sync.syncOnce();

    rahul.cloud.online = true;
    rahul.later();
    await rahul.sync.syncOnce();
    expect(await rahul.family.watchFamilies().first, isEmpty);
    expect(await rahul.detail(home), isNull);
    expect(await rahul.outbox(), isEmpty, reason: 'no failed uploads left');
    expect(await rahul.db.select(rahul.db.familyEntriesCache).get(), isEmpty);
    expect(
      (await hemang.detail(home))!.entries.single.amountPaise,
      1000000,
      reason: "Rahul's offline entry never reached Home",
    );
  });

  test('a fresh phone of a removed person skips it', () async {
    await rahulJoins();
    await hemang.sync.syncOnce(); // Hemang's phone knows Rahul joined
    await hemang.family.deletePerson(rahulPerson);
    await hemang.sync.syncOnce();
    final fresh = Phone(server, 'rahul');
    addTearDown(fresh.db.close);
    await fresh.sync.syncOnce();
    expect(await fresh.family.watchFamilies().first, isEmpty);
    final waiting = await (fresh.db.select(
      fresh.db.syncInbox,
    )..where((i) => i.scope.equals('family') & i.appliedAt.isNull())).get();
    expect(waiting, isEmpty);
  });

  test('removed by mistake and invited again: his phones keep it', () async {
    await rahulJoins();
    await rahul.sync.syncOnce();
    await hemang.sync.syncOnce();
    await hemang.family.deletePerson(rahulPerson);
    await hemang.sync.syncOnce();
    final again = await hemang.sharing.createInvitation(familyId: home);
    await rahul.cloud.acceptInvitation(code: again.code, displayName: 'Rahul');

    // His phone hears about the removal and the new invitation together.
    await rahul.sync.syncOnce();
    final d = await rahul.detail(home);
    expect(d, isNotNull);
    expect(d!.self!.name, 'Rahul');
    expect(d.entries.single.amountPaise, 1000000);

    final fresh = Phone(server, 'rahul');
    addTearDown(fresh.db.close);
    await fresh.sync.syncOnce();
    expect(await fresh.family.watchFamilies().first, hasLength(1));
  });

  test('an admin made a member while offline: the queued change fails, '
      'nothing else breaks', () async {
    await rahulJoins();
    await hemang.sharing.setRole(rahulPerson, 'admin');
    await rahul.sync.syncOnce();
    rahul.cloud.online = false;
    await rahul.family.savePerson(
      FamilyPersonDraft(familyId: home, name: 'Priya Shah'),
    );
    await hemang.sharing.setRole(rahulPerson, 'member');

    rahul.cloud.online = true;
    rahul.later();
    await rahul.sync.syncOnce();
    final failed = (await rahul.outbox()).where(
      (o) => o.status == OutboxStatus.failed,
    );
    expect(failed.single.lastError, 'forbidden');
    final d = (await rahul.detail(home))!;
    expect(d.canManage, isFalse);
    expect(d.month(2026, 11).closingPaise, 2200000);
  });
}
