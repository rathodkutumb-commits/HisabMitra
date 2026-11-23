import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/categories/data/category_repository.dart';
import 'package:hisabmitra/features/money_ledger/data/ledger_repository.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_models.dart';
import 'package:hisabmitra/features/people/data/people_repository.dart';
import 'package:hisabmitra/features/reminders/data/reminder_repository.dart';
import 'package:hisabmitra/features/reminders/domain/reminder_schedule.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

class _Clock extends Clock {
  DateTime value = DateTime(2026, 11, 20, 10);
  @override
  DateTime now() => value;
}

class _Scheduler implements ReminderScheduler {
  final scheduled = <int>[];
  final cancelled = <int>[];
  @override
  Future<void> schedule(ReminderRow reminder) async =>
      scheduled.add(reminder.notificationId);
  @override
  Future<void> cancel(int notificationId) async =>
      cancelled.add(notificationId);
}

/// One phone signed in to the shared fake server.
class Phone {
  Phone(FakeCloudServer server, String uid) {
    cloud = FakeCloudClient(server, uid);
    const ids = IdGenerator();
    people = PeopleRepository(db, clock, ids);
    txns = TransactionRepository(db, clock, ids);
    ledger = LedgerRepository(db, clock, ids);
    categories = CategoryRepository(db, clock, ids);
    reminders = ReminderRepository(db, clock, ids, scheduler);
    sync = SyncService(
      db: db,
      cloud: cloud,
      clock: clock,
      ids: ids,
      scheduler: scheduler,
    );
  }

  final db = newTestDatabase();
  final clock = _Clock();
  final scheduler = _Scheduler();
  late final FakeCloudClient cloud;
  late final PeopleRepository people;
  late final TransactionRepository txns;
  late final LedgerRepository ledger;
  late final CategoryRepository categories;
  late final ReminderRepository reminders;
  late final SyncService sync;

  Future<TransactionRow?> txn(String id) => (db.select(
    db.transactions,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<ConflictRow>> conflicts() => sync.openConflicts().first;
}

TransactionDraft spend({
  String? id,
  int amount = 25000,
  String category = 'cat_groceries',
  String? person,
}) => TransactionDraft(
  id: id,
  type: TransactionType.expense,
  amountPaise: amount,
  categoryId: category,
  date: DateTime(2026, 11, 20),
  paymentMethod: PaymentMethod.upi,
  personId: person,
  description: 'Vegetables',
);

void main() {
  late FakeCloudServer server;
  late Phone p1;
  late Phone p2;
  const uid = 'hemang';

  setUp(() {
    server = FakeCloudServer();
    p1 = Phone(server, uid);
    p2 = Phone(server, uid);
  });
  tearDown(() async {
    await p1.db.close();
    await p2.db.close();
  });

  test('an entry saved offline uploads when back online', () async {
    p1.cloud.online = false;
    final id = await p1.txns.save(spend());
    final offline = await p1.sync.syncOnce();
    expect(offline.offline, isTrue);
    expect(await p1.db.select(p1.db.syncOutbox).get(), hasLength(1));

    p1.cloud.online = true;
    p1.clock.value = p1.clock.value.add(
      const Duration(minutes: 1),
    ); // retry due
    await p1.sync.syncOnce();
    final row = server.personal.rows['transaction']![id]!;
    expect(row['amount_paise'], 25000);
    expect(row['revision'], 1);
    expect((await p1.txn(id))!.syncState, SyncState.synced);
    expect((await p1.txn(id))!.revision, 1);
    expect(await p1.db.select(p1.db.syncOutbox).get(), isEmpty);
  });

  test('the second phone gets the entry', () async {
    final id = await p1.txns.save(spend());
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    final copy = await p2.txn(id);
    expect(copy, isNotNull);
    expect(copy!.amountPaise, 25000);
    expect(copy.categoryId, 'cat_groceries');
    expect(copy.description, 'Vegetables');
    expect(copy.syncState, SyncState.synced);
  });

  test('a delete reaches the other phone', () async {
    final id = await p1.txns.save(spend());
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    await p1.txns.delete(id);
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    expect(await p2.txn(id), isNull);
  });

  test(
    'deleting a person on one phone removes their khata on the other',
    () async {
      final rahul = await p1.people.save(
        const PersonDraft(name: 'Rahul Patel'),
      );
      final entry = await p1.ledger.saveEntry(
        LedgerDraft(
          personId: rahul,
          direction: LedgerDirection.given,
          principalPaise: 300000,
          date: DateTime(2026, 11, 1),
          paymentMethod: PaymentMethod.cash,
        ),
      );
      await p1.ledger.addRepayment(
        RepaymentDraft(
          ledgerId: entry,
          amountPaise: 300000,
          date: DateTime(2026, 11, 2),
          paymentMethod: PaymentMethod.cash,
        ),
      );
      final t = await p1.txns.save(spend(person: rahul));
      await p1.sync.syncOnce();
      await p2.sync.syncOnce();
      expect(await p2.db.select(p2.db.moneyLedger).get(), hasLength(1));

      await p1.people.delete(rahul);
      await p1.sync.syncOnce();
      await p2.sync.syncOnce();
      expect(await p2.db.select(p2.db.persons).get(), isEmpty);
      expect(await p2.db.select(p2.db.moneyLedger).get(), isEmpty);
      expect(await p2.db.select(p2.db.moneySettlements).get(), isEmpty);
      expect((await p2.txn(t))!.personId, isNull);
    },
  );

  group('both phones edit the same entry offline', () {
    late String id;
    setUp(() async {
      id = await p1.txns.save(spend());
      await p1.sync.syncOnce();
      await p2.sync.syncOnce();
      await p1.txns.save(spend(id: id, amount: 30000));
      await p2.txns.save(spend(id: id, amount: 40000));
      await p1.sync.syncOnce();
      await p2.sync.syncOnce();
    });

    test('creates a conflict and overwrites nothing', () async {
      final conflicts = await p2.conflicts();
      expect(conflicts, hasLength(1));
      expect(conflicts.single.scope, 'personal');
      expect(conflicts.single.entityId, id);
      expect((await p2.txn(id))!.amountPaise, 40000);
      expect(server.personal.rows['transaction']![id]!['amount_paise'], 30000);
    });

    test('keep theirs takes the other phone\'s version', () async {
      final c = (await p2.conflicts()).single;
      await p2.sync.resolveConflict(c.id, keepLocal: false);
      expect((await p2.txn(id))!.amountPaise, 30000);
      expect((await p2.txn(id))!.syncState, SyncState.synced);
    });

    test('keep mine sends this phone\'s version on top', () async {
      final c = (await p2.conflicts()).single;
      await p2.sync.resolveConflict(c.id, keepLocal: true);
      await p2.sync.syncOnce();
      final row = server.personal.rows['transaction']![id]!;
      expect(row['amount_paise'], 40000);
      expect(row['revision'], 3);
      await p1.sync.syncOnce();
      expect((await p1.txn(id))!.amountPaise, 40000);
    });
  });

  test(
    'a custom category missing on this phone is re-created from the entry',
    () async {
      final cat = await p1.categories.save(
        const CategoryDraft(
          name: 'Tiffin',
          nameGu: 'ટિફિન',
          type: TransactionType.expense,
          iconKey: 'food',
          colorValue: 0xFF00AA00,
        ),
      );
      final id = await p1.txns.save(spend(category: cat));
      await p1.sync.syncOnce();
      await p2.sync.syncOnce();
      expect((await p2.txn(id))!.categoryId, cat);
      final made = await (p2.db.select(
        p2.db.categories,
      )..where((c) => c.id.equals(cat))).getSingle();
      expect(made.name, 'Tiffin');
      expect(made.iconKey, 'food');
      expect(made.colorValue, 0xFF00AA00);
      expect(made.type, TransactionType.expense);
    },
  );

  test('a custom category reaches the other phone with both names', () async {
    final cat = await p1.categories.save(
      const CategoryDraft(
        name: 'Pooja',
        nameGu: 'પૂજા',
        type: TransactionType.expense,
        iconKey: 'more',
        colorValue: 0xFF607D8B,
      ),
    );
    await p1.txns.save(spend(category: cat));
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    final made = await (p2.db.select(
      p2.db.categories,
    )..where((c) => c.id.equals(cat))).getSingle();
    expect((made.name, made.nameGu), ('Pooja', 'પૂજા'));
  });

  test(
    'an entry from an older app without the Gujarati name still applies',
    () async {
      // A category made before 1.3.0 has no Gujarati name, so its entries
      // travel without one — exactly what an older app sends.
      final now = DateTime(2026, 11, 23);
      await p1.db
          .into(p1.db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: 'cat_old',
              name: 'Old one',
              type: TransactionType.expense,
              iconKey: 'more',
              colorValue: 0xFF607D8B,
              createdAt: now,
              updatedAt: now,
            ),
          );
      final id = await p1.txns.save(spend(category: 'cat_old'));
      await p1.sync.syncOnce();
      expect(
        server.personal.rows['transaction']![id]!.containsKey(
          'category_name_gu',
        ),
        isFalse,
      );
      await p2.sync.syncOnce();
      final made = await (p2.db.select(
        p2.db.categories,
      )..where((c) => c.id.equals('cat_old'))).getSingle();
      expect((made.name, made.nameGu), ('Old one', null));
    },
  );

  test(
    'a pulled reminder gets its own notification id and is scheduled',
    () async {
      final id = await p1.reminders.save(
        ReminderDraft(
          kind: ReminderKind.custom,
          title: 'Pay society bill',
          dueAt: DateTime(2030, 1, 5, 10),
        ),
      );
      await p1.sync.syncOnce();
      await p2.sync.syncOnce();
      final mine = (await p1.reminders.getById(id))!;
      final theirs = (await p2.reminders.getById(id))!;
      expect(theirs.title, 'Pay society bill');
      expect(theirs.dueAt, DateTime(2030, 1, 5, 10));
      expect(theirs.notificationId, isNot(mine.notificationId));
      expect(p2.scheduler.scheduled, contains(theirs.notificationId));
    },
  );

  test('pull never overwrites an unsent local change', () async {
    final id = await p1.txns.save(spend());
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    await p1.txns.save(spend(id: id, amount: 30000));
    await p1.sync.syncOnce();
    p2.cloud.online = false;
    await p2.txns.save(spend(id: id, amount: 50000));
    p2.cloud.online = true;
    await p2.sync.pull();
    expect((await p2.txn(id))!.amountPaise, 50000);
  });

  test('a fresh phone downloads everything from the snapshot', () async {
    final rahul = await p1.people.save(const PersonDraft(name: 'Rahul Patel'));
    await p1.txns.save(spend(person: rahul));
    await p1.txns.save(spend(amount: 999));
    await p1.sync.syncOnce();
    await p2.sync.syncOnce();
    expect(await p2.db.select(p2.db.persons).get(), hasLength(1));
    expect(await p2.db.select(p2.db.transactions).get(), hasLength(2));
    final rows = await p2.db.select(p2.db.transactions).get();
    expect(rows.every((r) => r.syncState == SyncState.synced), isTrue);
  });

  test('an entry arriving before its person still applies', () async {
    // Feed order: the entry's event comes first, its person afterwards.
    final rahul = await p1.people.save(const PersonDraft(name: 'Rahul Patel'));
    await p1.sync.syncOnce();
    await p2.sync.syncOnce(); // p2 now follows the feed
    await p1.db.delete(p1.db.syncOutbox).go();
    server.personal.events.clear();
    const t = 'tttttttt-0000-0000-0000-000000000001';
    const newPerson = 'pppppppp-0000-0000-0000-000000000002';
    server.personal.apply(
      const OutboundOp(
        opId: 'x1',
        groupId: '',
        scope: 'personal',
        entityType: 'person',
        entityId: newPerson,
        opType: 'upsert',
        baseRevision: 0,
        payload: {'name': 'Priya Shah'},
      ),
      uid,
    );
    server.personal.apply(
      const OutboundOp(
        opId: 'x2',
        groupId: '',
        scope: 'personal',
        entityType: 'transaction',
        entityId: t,
        opType: 'upsert',
        baseRevision: 0,
        payload: {
          'type': 'expense',
          'amount_paise': 500,
          'category_id': 'cat_groceries',
          'category_name': 'Groceries',
          'category_system_key': 'groceries',
          'category_icon': 'grocery',
          'category_color': 1,
          'txn_date': '2026-11-20',
          'payment_method': 'upi',
          'person_id': newPerson,
        },
      ),
      uid,
    );
    // Swap the two events so the entry arrives first.
    final ev = server.personal.events;
    final first = ev[0];
    ev[0] = (owner: ev[1].owner, event: _withSeq(ev[1].event, first.event.seq));
    ev[1] = (owner: first.owner, event: _withSeq(first.event, ev[1].event.seq));
    await p2.sync.pull();
    expect((await p2.txn(t))!.personId, newPerson);
    expect(rahul, isNotEmpty);
  });

  test(
    'editing while the first upload is queued gives one row, no conflict',
    () async {
      p1.cloud.online = false;
      final id = await p1.txns.save(spend());
      await p1.txns.save(spend(id: id, amount: 30000));
      await p1.txns.save(spend(id: id, amount: 35000));
      p1.cloud.online = true;
      await p1.sync.syncOnce();
      expect(await p1.conflicts(), isEmpty);
      final row = server.personal.rows['transaction']![id]!;
      expect(row['amount_paise'], 35000);
      expect(row['revision'], 3);
      expect((await p1.txn(id))!.revision, 3);
    },
  );
}

RemoteEvent _withSeq(RemoteEvent e, int seq) => RemoteEvent(
  seq: seq,
  groupId: e.groupId,
  scope: e.scope,
  entityType: e.entityType,
  entityId: e.entityId,
  opType: e.opType,
  revision: e.revision,
  payload: e.payload,
  opId: e.opId,
);
