import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/backup/data/restore_sync.dart';
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

/// One phone of `hemang`, signed in to the shared fake server.
class Phone {
  Phone(FakeCloudServer server) {
    cloud = FakeCloudClient(server, 'hemang');
    const ids = IdGenerator();
    family = FamilyRepository(db, clock, ids, currentUserId: () => 'hemang');
    sync = SyncService(db: db, cloud: cloud, clock: clock, ids: ids);
  }

  final db = newTestDatabase();
  final clock = _Clock();
  late final FakeCloudClient cloud;
  late final FamilyRepository family;
  late final SyncService sync;

  Future<FamilyDetail?> detail(String id) => family.watchFamily(id).first;

  Future<List<ConflictRow>> conflicts() => sync.openConflicts().first;

  /// Lets a backed-off upload be retried.
  void later() => clock.value = clock.value.add(const Duration(minutes: 5));
}

void main() {
  late FakeCloudServer server;
  late Phone p1;
  late Phone p2;

  setUp(() {
    server = FakeCloudServer();
    p1 = Phone(server);
    p2 = Phone(server);
  });
  tearDown(() async {
    await p1.db.close();
    await p2.db.close();
  });

  Future<String> home(Phone p) => p.family.createFamily(
    const FamilyDraft(name: 'Home', startingBalancePaise: 1200000),
    selfName: 'Hemang',
    people: const [
      FamilyPersonDraft(name: 'Rahul Patel', phone: '+919800000001'),
    ],
  );

  Future<String> salary(Phone p, String familyId, int paise) async {
    final me = (await p.detail(familyId))!.self!.id;
    return p.family.saveEntry(
      FamilyEntryDraft(
        familyId: familyId,
        memberId: me,
        kind: FamilyEntryKind.salary,
        amountPaise: paise,
        date: DateTime(2026, 11, 1),
      ),
    );
  }

  Future<void> edit(Phone p, String familyId, String id, int paise) async {
    final e = (await p.detail(familyId))!.entries.firstWhere((x) => x.id == id);
    await p.family.saveEntry(
      FamilyEntryDraft(
        id: id,
        familyId: familyId,
        memberId: e.memberId,
        kind: e.kind,
        amountPaise: paise,
        date: e.date,
      ),
    );
  }

  test('a Family hisab made on one phone appears on the other', () async {
    final id = await home(p1);
    final d1 = (await p1.detail(id))!;
    await salary(p1, id, 6000000);
    await p1.family.saveEntry(
      FamilyEntryDraft(
        familyId: id,
        memberId: d1.members.last.id,
        kind: FamilyEntryKind.expense,
        amountPaise: 2650000,
        date: DateTime(2026, 11, 20),
        categoryId: 'cat_groceries',
      ),
    );
    await p1.sync.syncOnce();
    expect(await p1.db.select(p1.db.syncOutbox).get(), isEmpty);

    await p2.sync.syncOnce();
    final d2 = (await p2.detail(id))!;
    expect((d2.family.name, d2.family.openingBalancePaise), ('Home', 1200000));
    expect(
      [for (final m in d2.members) (m.name, m.isSelf, m.role, m.phone)],
      [
        ('Hemang', true, 'owner', null),
        ('Rahul Patel', false, 'member', '+919800000001'),
      ],
    );
    expect(d2.entries, hasLength(2));
    final s1 = (await p1.detail(id))!.month(2026, 11);
    final s2 = d2.month(2026, 11);
    expect(
      (s2.openingPaise, s2.moneyInPaise, s2.moneyOutPaise, s2.closingPaise),
      (s1.openingPaise, s1.moneyInPaise, s1.moneyOutPaise, s1.closingPaise),
    );
    expect(s2.closingPaise, 4550000);
    final groceries = d2.entries.firstWhere(
      (e) => e.kind == FamilyEntryKind.expense,
    );
    expect(groceries.categoryLabel('en'), isNotEmpty);
    expect(
      groceries.categoryLabel('gu'),
      isNot(groceries.categoryLabel('en')),
      reason: 'built-in categories travel in both languages',
    );
    // Everything on the first phone is now marked as saved in the account.
    final self1 = (await p1.detail(id))!.self!;
    expect((self1.revision, self1.syncState), (1, SyncState.synced));
  });

  test('entries added offline upload later', () async {
    final id = await home(p1);
    await p1.sync.syncOnce();
    p1.cloud.online = false;
    final entry = await salary(p1, id, 3500000);
    expect((await p1.sync.syncOnce()).offline, isTrue);
    expect(await p1.db.select(p1.db.syncOutbox).get(), hasLength(1));

    p1.cloud.online = true;
    p1.later();
    await p1.sync.syncOnce();
    expect(server.family.entries[entry]!['amount_paise'], 3500000);
    final row = await (p1.db.select(
      p1.db.familyEntriesCache,
    )..where((e) => e.id.equals(entry))).getSingle();
    expect((row.revision, row.syncState), (1, SyncState.synced));
  });

  test('a deleted entry disappears on the other phone', () async {
    final id = await home(p1);
    final entry = await salary(p1, id, 6000000);
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    expect((await p2.detail(id))!.entries, hasLength(1));

    await p1.family.deleteEntry(entry);
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    expect((await p2.detail(id))!.entries, isEmpty);
    expect((await p2.detail(id))!.month(2026, 11).closingPaise, 1200000);
  });

  test('a person added later reaches the other phone', () async {
    final id = await home(p1);
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    await p1.family.savePerson(
      FamilyPersonDraft(familyId: id, name: 'Priya Shah'),
    );
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    expect(
      [for (final m in (await p2.detail(id))!.members) m.name],
      ['Hemang', 'Rahul Patel', 'Priya Shah'],
    );
  });

  test('a deleted Family hisab disappears on the other phone', () async {
    final id = await home(p1);
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    expect(await p2.family.watchFamilies().first, hasLength(1));

    await p1.family.deleteFamily(id);
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    expect(await p2.family.watchFamilies().first, isEmpty);
    expect(await p2.detail(id), isNull);
  });

  group('the same entry edited on both phones offline', () {
    late String id;
    late String entry;

    setUp(() async {
      id = await home(p1);
      entry = await salary(p1, id, 6000000);
      await p1.sync.syncOnce();
      await p2.sync.syncOnce();
      await edit(p1, id, entry, 6100000);
      await edit(p2, id, entry, 6200000);
      await p2.sync.syncOnce(); // the second phone is first back online
      await p1.sync.syncOnce();
    });

    test('becomes a conflict', () async {
      final c = await p1.conflicts();
      expect(c, hasLength(1));
      expect((c.single.scope, c.single.entityId), ('family', entry));
      expect(server.family.entries[entry]!['amount_paise'], 6200000);
      final row = await (p1.db.select(
        p1.db.familyEntriesCache,
      )..where((e) => e.id.equals(entry))).getSingle();
      expect(row.syncState, SyncState.conflict);
    });

    test("keep theirs shows the other phone's amount", () async {
      final c = (await p1.conflicts()).single;
      await p1.sync.resolveConflict(c.id, keepLocal: false);
      expect(await p1.conflicts(), isEmpty);
      final e = (await p1.detail(id))!.entries.single;
      expect(e.amountPaise, 6200000);
    });

    test('keep mine sends this phone\'s amount on top', () async {
      final c = (await p1.conflicts()).single;
      await p1.sync.resolveConflict(c.id, keepLocal: true);
      await p1.sync.syncOnce();
      expect(server.family.entries[entry]!['amount_paise'], 6100000);
      await p2.sync.syncOnce();
      expect((await p2.detail(id))!.entries.single.amountPaise, 6100000);
    });
  });

  test('restoring a backup leaves Family hisab as it is', () async {
    final id = await home(p1);
    final entry = await salary(p1, id, 6000000);
    await p1.sync.syncOnce();
    // The backup was taken while an edit was still waiting to upload.
    p1.cloud.online = false;
    await edit(p1, id, entry, 1);
    p1.cloud.online = true;
    final before = Map.of(server.family.families[id]!);
    final entryBefore = Map.of(server.family.entries[entry]!);

    await RestoreSync(p1.db, p1.clock, const IdGenerator()).afterRestore();
    final queued = await p1.db.select(p1.db.syncOutbox).get();
    expect(queued.where((o) => o.scope == 'family'), isEmpty);
    await p1.sync.syncOnce();

    expect(server.family.families[id], before);
    expect(server.family.entries[entry], entryBefore);
    final d = (await p1.detail(id))!;
    expect(d.entries.single.amountPaise, 6000000, reason: "the account's copy");
    expect(d.self!.isSelf, isTrue);
  });

  test('a fresh phone skips a Family hisab deleted before it joined', () async {
    final id = await home(p1);
    await p1.sync.syncOnce();
    await p1.family.deleteFamily(id);
    await p1.sync.syncOnce();

    await p2.sync.syncOnce();
    expect(await p2.family.watchFamilies().first, isEmpty);
    final waiting = await (p2.db.select(
      p2.db.syncInbox,
    )..where((i) => i.scope.equals('family') & i.appliedAt.isNull())).get();
    expect(waiting, isEmpty);
  });
}
