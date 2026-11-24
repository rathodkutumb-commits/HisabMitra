import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/backup/data/restore_sync.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/people/data/people_repository.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

class _Clock extends Clock {
  DateTime value = DateTime(2026, 11, 20, 10);
  @override
  DateTime now() => value;
}

class Phone {
  Phone(FakeCloudServer server) {
    cloud = FakeCloudClient(server, 'hemang');
    const ids = IdGenerator();
    people = PeopleRepository(db, clock, ids);
    txns = TransactionRepository(db, clock, ids);
    groups = GroupRepository(db, clock, ids, currentUserId: () => 'hemang');
    sync = SyncService(db: db, cloud: cloud, clock: clock, ids: ids);
  }

  final db = newTestDatabase();
  final clock = _Clock();
  late final FakeCloudClient cloud;
  late final PeopleRepository people;
  late final TransactionRepository txns;
  late final GroupRepository groups;
  late final SyncService sync;

  RestoreSync restore() => RestoreSync(db, clock, const IdGenerator());

  Future<String> spend(int amount) => txns.save(
    TransactionDraft(
      type: TransactionType.expense,
      amountPaise: amount,
      categoryId: 'cat_groceries',
      date: DateTime(2026, 11, 20),
      paymentMethod: PaymentMethod.upi,
    ),
  );

  Future<Set<int>> amounts() async => {
    for (final t in await db.select(db.transactions).get()) t.amountPaise,
  };
}

void main() {
  late FakeCloudServer server;
  late Phone p1;

  setUp(() {
    server = FakeCloudServer();
    p1 = Phone(server);
  });
  tearDown(() => p1.db.close());

  Set<int> cloudAmounts() => {
    for (final r in server.personal.live('transaction', 'hemang'))
      r['amount_paise']! as int,
  };

  test('restore queues the reset first, then every personal record', () async {
    await p1.people.save(const PersonDraft(name: 'Rahul Patel'));
    await p1.spend(100);
    await p1.sync.syncOnce(); // rows are now "synced" at revision 1
    await p1.restore().afterRestore();
    final ops = await (p1.db.select(
      p1.db.syncOutbox,
    )..orderBy([(o) => OrderingTerm.asc(o.createdAt)])).get();
    expect(ops.first.opType, 'reset');
    expect(ops.first.entityType, 'all');
    expect(ops.skip(1).map((o) => o.entityType), ['person', 'transaction']);
    expect(ops.skip(1).every((o) => o.baseRevision == 0), isTrue);
  });

  test('after restore and sync the account holds exactly the backup', () async {
    await p1.spend(100);
    await p1.sync.syncOnce();
    // Taken after the backup; the restore must remove it from the account.
    final later = await p1.spend(999);
    await p1.sync.syncOnce();
    await p1.txns.delete(later); // the "backup" doesn't have it
    await p1.db.delete(p1.db.syncOutbox).go();

    await p1.restore().afterRestore();
    await p1.sync.syncOnce();
    expect(cloudAmounts(), {100});
    expect(await p1.amounts(), {100});
  });

  test('groups are not taken from the backup', () async {
    final g = await p1.groups.createGroup(
      const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
      selfName: 'Hemang',
    );
    await p1.sync.syncOnce();
    // The backup holds an old, renamed copy of the group.
    await (p1.db.update(p1.db.groupsCache)..where((x) => x.id.equals(g))).write(
      const GroupsCacheCompanion(name: Value('Old name')),
    );
    await p1.restore().afterRestore();
    await p1.sync.syncOnce();
    final row = await (p1.db.select(
      p1.db.groupsCache,
    )..where((x) => x.id.equals(g))).getSingle();
    expect(row.name, 'Goa Trip');
  });

  test('the other phone ends up with the backup\'s records', () async {
    await p1.spend(100);
    await p1.sync.syncOnce();
    final p2 = Phone(server);
    addTearDown(p2.db.close);
    await p2.spend(555); // added on the other phone after the backup
    await p2.sync.syncOnce();
    expect(await p2.amounts(), {100, 555});

    await p1.restore().afterRestore();
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    expect(await p2.amounts(), {100});
  });

  test('an interrupted restore continues in order', () async {
    await p1.spend(100);
    await p1.sync.syncOnce();
    final later = await p1.spend(999);
    await p1.sync.syncOnce();
    await p1.txns.delete(later);
    await p1.db.delete(p1.db.syncOutbox).go();

    await p1.restore().afterRestore();
    server.dropNextResponse = true; // the reset applies, its answer is lost
    final first = await p1.sync.syncOnce();
    expect(first.offline, isTrue);
    p1.clock.value = p1.clock.value.add(const Duration(minutes: 5));
    await p1.sync.syncOnce();
    expect(cloudAmounts(), {100});
  });

  test('Family hisab bills are dropped, never uploaded as personal', () async {
    await p1.db
        .into(p1.db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'fb1',
            familyEntryId: const Value('e1'),
            storedName: 'fb1.jpg',
            originalName: 'rent.jpg',
            mimeType: 'image/jpeg',
            sizeBytes: 10,
            sha256: 'x',
            remotePath: const Value('f1/e1/fb1.jpg'),
            createdAt: DateTime(2026),
          ),
        );
    await p1.restore().afterRestore();
    expect(await p1.db.select(p1.db.attachments).get(), isEmpty);
    final ops = await p1.db.select(p1.db.syncOutbox).get();
    expect(ops.where((o) => o.entityId == 'fb1'), isEmpty);
  });
}
