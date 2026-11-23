import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/categories/data/category_repository.dart';
import 'package:hisabmitra/features/money_ledger/data/ledger_repository.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_models.dart';
import 'package:hisabmitra/features/reminders/application/notification_service.dart';
import 'package:hisabmitra/features/reminders/domain/reminder_schedule.dart';
import 'package:hisabmitra/features/people/data/people_repository.dart';
import 'package:hisabmitra/features/profile/data/profile_repository.dart';
import 'package:hisabmitra/features/reminders/data/reminder_repository.dart';
import 'package:hisabmitra/features/synchronization/data/personal_outbox.dart';
import 'package:hisabmitra/features/synchronization/domain/personal_entity.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/tour/data/sample_data_service.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer c;

  setUp(() {
    db = newTestDatabase();
    c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialPreferencesProvider.overrideWithValue(
          AppPreferences.fromMap(const {}).copyWith(onboardingComplete: true),
        ),
      ],
    );
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<List<OutboxRow>> ops() => (db.select(
    db.syncOutbox,
  )..orderBy([(o) => OrderingTerm.asc(o.createdAt)])).get();

  Map<String, Object?> payload(OutboxRow o) =>
      (jsonDecode(o.payload) as Map).cast<String, Object?>();

  PeopleRepository people() => c.read(peopleRepositoryProvider);
  TransactionRepository txns() => c.read(transactionRepositoryProvider);

  TransactionDraft groceries({
    String? id,
    int amount = 25000,
    String? person,
  }) => TransactionDraft(
    id: id,
    type: TransactionType.expense,
    amountPaise: amount,
    categoryId: 'cat_groceries',
    date: DateTime(2026, 11, 20),
    paymentMethod: PaymentMethod.upi,
    personId: person,
    description: 'Vegetables',
  );

  test('saving a person queues one upsert in the same transaction', () async {
    final id = await people().save(const PersonDraft(name: 'Rahul Patel'));
    final queued = await ops();
    expect(queued, hasLength(1));
    expect(queued.single.scope, 'personal');
    expect(queued.single.groupId, '');
    expect(queued.single.entityType, 'person');
    expect(queued.single.entityId, id);
    expect(queued.single.opType, 'upsert');
    expect(queued.single.baseRevision, 0);
    expect(payload(queued.single)['name'], 'Rahul Patel');
    final row = await (db.select(
      db.persons,
    )..where((p) => p.id.equals(id))).getSingle();
    expect(row.syncState, SyncState.pending);
  });

  test('a failing save queues nothing', () async {
    await expectLater(
      people().save(const PersonDraft(name: '  ')),
      throwsA(isA<ValidationFailure>()),
    );
    expect(await ops(), isEmpty);
  });

  test('an entry carries its category snapshot', () async {
    await txns().save(groceries());
    final p = payload((await ops()).single);
    expect(p['category_id'], 'cat_groceries');
    expect(p['category_system_key'], 'groceries');
    expect(p['category_name'], isNotEmpty);
    expect(p['category_icon'], isNotEmpty);
    expect(p['category_color'], isA<int>());
    expect(p['txn_date'], '2026-11-20');
    expect(p['type'], 'expense');
    expect(p['payment_method'], 'upi');
    expect(p['amount_paise'], 25000);
  });

  test('editing twice before sync queues two ops in order', () async {
    final id = await txns().save(groceries());
    await txns().save(groceries(id: id, amount: 30000));
    await txns().save(groceries(id: id, amount: 35000));
    final queued = await ops();
    expect(queued.map((o) => o.entityId), [id, id, id]);
    expect(queued.map((o) => o.baseRevision), [0, 0, 0]);
    expect(queued.map((o) => payload(o)['amount_paise']), [
      25000,
      30000,
      35000,
    ]);
  });

  test(
    'deleting a person queues one delete and nothing for their khata',
    () async {
      final id = await people().save(const PersonDraft(name: 'Rahul Patel'));
      await db.delete(db.syncOutbox).go();
      await people().delete(id);
      final queued = await ops();
      expect(queued, hasLength(1));
      expect(queued.single.opType, 'delete');
      expect(queued.single.entityType, 'person');
      expect(payload(queued.single)['id'], id);
    },
  );

  test('sample data is never queued, even after an edit', () async {
    await c.read(profileRepositoryProvider).saveName('Hemang');
    await c.read(sampleDataServiceProvider).load();
    expect(
      (await ops()).where((o) => o.scope == 'personal'),
      isEmpty,
      reason: 'sample people, entries and khata stay on the phone',
    );
    final sample = await db.select(db.transactions).get();
    final t = sample.first;
    await txns().save(
      TransactionDraft(
        id: t.id,
        type: t.type,
        amountPaise: t.amountPaise + 100,
        categoryId: t.categoryId,
        date: t.txnDate,
        paymentMethod: t.paymentMethod,
        description: t.description,
      ),
    );
    expect((await ops()).where((o) => o.scope == 'personal'), isEmpty);
    expect(c.read(settingsControllerProvider).sampleDataLoaded, isTrue);
  });

  group('khata, reminders and categories', () {
    LedgerRepository ledger() => c.read(ledgerRepositoryProvider);

    Future<String> person() =>
        people().save(const PersonDraft(name: 'Rahul Patel'));

    LedgerDraft given(String personId) => LedgerDraft(
      personId: personId,
      direction: LedgerDirection.given,
      principalPaise: 300000,
      date: DateTime(2026, 11, 1),
      paymentMethod: PaymentMethod.cash,
    );

    RepaymentDraft repay(String entry, int amount) => RepaymentDraft(
      ledgerId: entry,
      amountPaise: amount,
      date: DateTime(2026, 11, 10),
      paymentMethod: PaymentMethod.upi,
    );

    test('a khata entry and its repayment queue upserts', () async {
      final p = await person();
      final entry = await ledger().saveEntry(given(p));
      final rep = await ledger().addRepayment(repay(entry, 100000));
      final queued = await ops();
      expect(queued.map((o) => (o.entityType, o.entityId)), [
        ('person', p),
        ('ledger_entry', entry),
        ('ledger_repayment', rep),
      ]);
      expect(payload(queued[1])['entry_date'], '2026-11-01');
      expect(payload(queued[2])['ledger_id'], entry);
    });

    test('an advance created by an over-repayment is queued too', () async {
      final p = await person();
      final entry = await ledger().saveEntry(given(p));
      await db.delete(db.syncOutbox).go();
      await ledger().addRepayment(
        repay(entry, 350000),
        recordExcessAsAdvance: true,
      );
      final types = (await ops()).map((o) => o.entityType).toList();
      expect(types, ['ledger_repayment', 'ledger_entry']);
    });

    test('deleting a khata entry or a repayment queues one delete', () async {
      final p = await person();
      final entry = await ledger().saveEntry(given(p));
      final rep = await ledger().addRepayment(repay(entry, 100000));
      await db.delete(db.syncOutbox).go();
      await ledger().deleteRepayment(rep);
      await ledger().deleteEntry(entry);
      final queued = await ops();
      expect(queued.map((o) => (o.opType, o.entityType, o.entityId)), [
        ('delete', 'ledger_repayment', rep),
        ('delete', 'ledger_entry', entry),
      ]);
    });

    test(
      'completing a reminder queues an upsert without notification_id',
      () async {
        final reminders = c.read(reminderRepositoryProvider);
        final id = await reminders.save(
          ReminderDraft(
            kind: ReminderKind.custom,
            title: 'Pay society bill',
            dueAt: DateTime.utc(2030, 1, 5, 4, 30),
            repeat: ReminderRepeat.monthly,
          ),
        );
        await reminders.complete(id);
        final queued = await ops();
        expect(queued, hasLength(2));
        expect(queued.every((o) => o.entityType == 'reminder'), isTrue);
        final last = payload(queued.last);
        expect(last.containsKey('notification_id'), isFalse);
        expect(last['completed_occurrences'], 1);
        expect(last['status'], 'pending');
      },
    );

    Future<String> tiffin() => c
        .read(categoryRepositoryProvider)
        .save(
          const CategoryDraft(
            name: 'Tiffin',
            nameGu: 'ટિફિન',
            type: TransactionType.expense,
            iconKey: 'food',
            colorValue: 0xFF00AA00,
          ),
        );

    Future<String> spend(String cat) => txns().save(
      TransactionDraft(
        type: TransactionType.expense,
        amountPaise: 8000,
        categoryId: cat,
        date: DateTime(2026, 11, 20),
        paymentMethod: PaymentMethod.cash,
      ),
    );

    Future<String> bill(String cat) => c
        .read(reminderRepositoryProvider)
        .save(
          ReminderDraft(
            kind: ReminderKind.bill,
            title: 'Tiffin service',
            dueAt: DateTime(2030, 1, 5, 10),
            amountPaise: 240000,
            categoryId: cat,
          ),
        );

    test('creating a category queues nothing', () async {
      await tiffin();
      expect(await ops(), isEmpty, reason: 'categories stay on the phone');
    });

    test('renaming a category re-queues the entries that use it', () async {
      final cat = await tiffin();
      await spend(cat);
      await spend(cat);
      await bill(cat);
      await db.delete(db.syncOutbox).go();
      await c
          .read(categoryRepositoryProvider)
          .save(
            CategoryDraft(
              id: cat,
              name: 'Dabba',
              nameGu: 'ડબ્બો',
              type: TransactionType.expense,
              iconKey: 'food',
              colorValue: 0xFF00AA00,
            ),
          );
      final queued = await ops();
      expect(queued, hasLength(3));
      expect(queued.map((o) => payload(o)['category_name']).toSet(), {'Dabba'});
    });

    test(
      'deleting a category re-queues moved entries and its reminders',
      () async {
        final cat = await tiffin();
        await spend(cat);
        final reminder = await bill(cat);
        await db.delete(db.syncOutbox).go();
        await c
            .read(categoryRepositoryProvider)
            .delete(cat, reassignTo: 'cat_food');
        final queued = await ops();
        expect(queued.map((o) => o.entityType).toList()..sort(), [
          'reminder',
          'transaction',
        ]);
        final txnOp = queued.firstWhere((o) => o.entityType == 'transaction');
        expect(payload(txnOp)['category_id'], 'cat_food');
        final remOp = queued.firstWhere((o) => o.entityId == reminder);
        expect(payload(remOp)['category_id'], isNull);
      },
    );
  });

  test(
    'a reminder is never saved without its upload (one transaction)',
    () async {
      final failing = _FailingOutbox(db);
      final reminders = ReminderRepository(
        db,
        const Clock(),
        const IdGenerator(),
        _NoScheduler(),
        outbox: failing,
      );
      await expectLater(
        reminders.save(
          ReminderDraft(
            kind: ReminderKind.custom,
            title: 'Pay society bill',
            dueAt: DateTime(2030, 1, 5, 10),
          ),
        ),
        throwsA(isA<StateError>()),
      );
      expect(await db.select(db.reminders).get(), isEmpty);
    },
  );
}

class _FailingOutbox extends PersonalOutbox {
  _FailingOutbox(AppDatabase db)
    : super(db, const Clock(), const IdGenerator());

  @override
  Future<void> upsert(PersonalEntity type, String id) async =>
      throw StateError('outbox down');
}

class _NoScheduler implements ReminderScheduler {
  @override
  Future<void> schedule(ReminderRow reminder) async {}
  @override
  Future<void> cancel(int notificationId) async {}
}
