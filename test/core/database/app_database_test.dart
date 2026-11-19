import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/database/seed.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 1, 1);

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  test('schema version is 3 (v3: verified email on the profile)', () {
    expect(db.schemaVersion, 3);
  });

  test('seeds all default categories exactly once', () async {
    final rows = await db.select(db.categories).get();
    expect(rows.length, defaultCategories.length);
    await seedDefaultCategories(db, now);
    expect(
      (await db.select(db.categories).get()).length,
      defaultCategories.length,
    );
  });

  test('foreign keys are enforced', () async {
    expect(
      () => db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't1',
              ownerId: 'self',
              type: TransactionType.expense,
              amountPaise: 100,
              categoryId: 'missing-category',
              txnDate: now,
              paymentMethod: PaymentMethod.cash,
              createdAt: now,
              updatedAt: now,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('amount must be positive (CHECK constraint)', () async {
    expect(
      () => db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't1',
              ownerId: 'self',
              type: TransactionType.expense,
              amountPaise: 0,
              categoryId: 'cat_food',
              txnDate: now,
              paymentMethod: PaymentMethod.cash,
              createdAt: now,
              updatedAt: now,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('category in use cannot be deleted (RESTRICT)', () async {
    await db
        .into(db.transactions)
        .insert(
          TransactionsCompanion.insert(
            id: 't1',
            ownerId: 'self',
            type: TransactionType.expense,
            amountPaise: 100,
            categoryId: 'cat_food',
            txnDate: now,
            paymentMethod: PaymentMethod.cash,
            createdAt: now,
            updatedAt: now,
          ),
        );
    expect(
      () => (db.delete(
        db.categories,
      )..where((c) => c.id.equals('cat_food'))).go(),
      throwsA(isA<SqliteException>()),
    );
  });

  test('attachment must have exactly one parent', () async {
    expect(
      () => db
          .into(db.attachments)
          .insert(
            AttachmentsCompanion.insert(
              id: 'a1',
              storedName: 'x.jpg',
              originalName: 'x.jpg',
              mimeType: 'image/jpeg',
              sizeBytes: 10,
              sha256: 'abc',
              createdAt: now,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('deleting a person cascades to ledger entries and repayments', () async {
    await db
        .into(db.persons)
        .insert(
          PersonsCompanion.insert(
            id: 'p1',
            name: 'Rahul',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.moneyLedger)
        .insert(
          MoneyLedgerCompanion.insert(
            id: 'l1',
            personId: 'p1',
            direction: LedgerDirection.given,
            principalPaise: 500000,
            entryDate: now,
            paymentMethod: PaymentMethod.upi,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.moneySettlements)
        .insert(
          MoneySettlementsCompanion.insert(
            id: 's1',
            ledgerId: 'l1',
            amountPaise: 100000,
            settledOn: now,
            paymentMethod: PaymentMethod.cash,
            createdAt: now,
            updatedAt: now,
          ),
        );
    await (db.delete(db.persons)..where((p) => p.id.equals('p1'))).go();
    expect(await db.select(db.moneyLedger).get(), isEmpty);
    expect(await db.select(db.moneySettlements).get(), isEmpty);
  });

  test('group settlement cannot be from and to the same member', () async {
    await db
        .into(db.groupsCache)
        .insert(
          GroupsCacheCompanion.insert(
            id: 'g1',
            name: 'Goa',
            groupType: GroupType.trip,
            createdBy: 'm1',
            createdAt: now,
            updatedAt: now,
          ),
        );
    await db
        .into(db.groupMembersCache)
        .insert(
          GroupMembersCacheCompanion.insert(
            id: 'm1',
            groupId: 'g1',
            displayName: 'Me',
            joinedAt: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    expect(
      () => db
          .into(db.groupSettlementsCache)
          .insert(
            GroupSettlementsCacheCompanion.insert(
              id: 's1',
              groupId: 'g1',
              fromMemberId: 'm1',
              toMemberId: 'm1',
              amountPaise: 100,
              settledOn: now,
              paymentMethod: PaymentMethod.cash,
              createdAt: now,
              updatedAt: now,
            ),
          ),
      throwsA(isA<SqliteException>()),
    );
  });

  test('integrity check passes on a fresh database', () async {
    expect(await db.integrityCheck(), isTrue);
  });

  test('stores enums by name', () async {
    final row = await db
        .customSelect("SELECT type FROM categories WHERE id = 'cat_salary'")
        .getSingle();
    expect(row.data['type'], 'income');
    expect(Variable.withString('x').value, 'x');
  });
}
