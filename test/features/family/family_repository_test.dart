import 'dart:convert';

import 'package:drift/drift.dart' show CustomExpression, OrderingTerm, Value;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/core/utils/date_range.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';

class _Clock extends Clock {
  @override
  DateTime now() => DateTime(2026, 11, 23, 10);
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  late AppDatabase db;
  late FamilyRepository repo;

  setUp(() {
    db = newTestDatabase();
    repo = FamilyRepository(
      db,
      _Clock(),
      const IdGenerator(),
      currentUserId: () => 'hemang',
    );
  });
  tearDown(() => db.close());

  Future<String> home() => repo.createFamily(
    const FamilyDraft(name: 'Home', startingBalancePaise: 1200000),
    selfName: 'Hemang',
    people: const [
      FamilyPersonDraft(name: 'Rahul Patel', phone: '+919800000001'),
    ],
  );

  Future<FamilyDetail> detail(String id) async =>
      (await repo.watchFamily(id).first)!;

  test('creating a Family hisab adds You and queues it', () async {
    final id = await home();
    final d = await detail(id);
    expect(d.family.name, 'Home');
    expect(d.family.openingBalancePaise, 1200000);
    expect(
      [for (final m in d.members) (m.name, m.isSelf, m.role, m.phone)],
      [
        ('Hemang', true, 'owner', null),
        ('Rahul Patel', false, 'member', '+919800000001'),
      ],
    );
    final ops =
        await (db.select(db.syncOutbox)..orderBy([
              (o) => OrderingTerm.asc(o.createdAt),
              (_) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
            ]))
            .get();
    expect(
      [for (final o in ops) (o.scope, o.groupId, o.entityType)],
      [('family', id, 'family'), ('family', id, 'member')],
    );
    final payload = jsonDecode(ops.first.payload) as Map<String, Object?>;
    expect(payload['owner_member_id'], d.self!.id);
    expect(payload['owner_display_name'], 'Hemang');
    expect(payload['opening_balance_paise'], 1200000);
  });

  test('an expense keeps its category in both languages', () async {
    final id = await home();
    final now = DateTime(2026, 11, 23);
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'cat_pooja',
            name: 'Pooja',
            nameGu: const Value('પૂજા'),
            type: TransactionType.expense,
            iconKey: 'more',
            colorValue: 0xFF607D8B,
            createdAt: now,
            updatedAt: now,
          ),
        );
    final d = await detail(id);
    await repo.saveEntry(
      FamilyEntryDraft(
        familyId: id,
        memberId: d.self!.id,
        kind: FamilyEntryKind.expense,
        amountPaise: 50000,
        date: DateTime(2026, 11, 20),
        categoryId: 'cat_pooja',
      ),
    );
    await (db.delete(
      db.categories,
    )..where((c) => c.id.equals('cat_pooja'))).go();
    final entry = (await detail(id)).entries.single;
    expect((entry.categoryName, entry.categoryNameGu), ('Pooja', 'પૂજા'));
    expect(entry.categoryLabel('gu'), 'પૂજા');
  });

  test('an expense needs a category and money needs an amount', () async {
    final id = await home();
    final me = (await detail(id)).self!.id;
    await expectLater(
      repo.saveEntry(
        FamilyEntryDraft(
          familyId: id,
          memberId: me,
          kind: FamilyEntryKind.expense,
          amountPaise: 100,
          date: DateTime(2026, 11, 1),
        ),
      ),
      throwsA(isA<ValidationFailure>()),
    );
    await expectLater(
      repo.saveEntry(
        FamilyEntryDraft(
          familyId: id,
          memberId: me,
          kind: FamilyEntryKind.salary,
          amountPaise: 0,
          date: DateTime(2026, 11, 1),
        ),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('deleting a person keeps their entries', () async {
    final id = await home();
    final rahul = (await detail(id)).members.last.id;
    await repo.saveEntry(
      FamilyEntryDraft(
        familyId: id,
        memberId: rahul,
        kind: FamilyEntryKind.contribution,
        amountPaise: 1000000,
        date: DateTime(2026, 11, 12),
      ),
    );
    await repo.deletePerson(rahul);
    final d = await detail(id);
    expect(d.members.last.status, 'removed');
    expect(d.entries.single.memberId, rahul);
    expect(d.memberName(rahul, en), 'Rahul Patel (removed)');
    expect(d.activeMembers.map((m) => m.name), ['Hemang']);
  });

  test('the month view follows edits and deletes', () async {
    final id = await home();
    final me = (await detail(id)).self!.id;
    final salary = await repo.saveEntry(
      FamilyEntryDraft(
        familyId: id,
        memberId: me,
        kind: FamilyEntryKind.salary,
        amountPaise: 6000000,
        date: DateTime(2026, 11, 1),
      ),
    );
    expect((await repo.watchMonth(id, 2026, 11).first).closingPaise, 7200000);
    await repo.saveEntry(
      FamilyEntryDraft(
        id: salary,
        familyId: id,
        memberId: me,
        kind: FamilyEntryKind.salary,
        amountPaise: 6500000,
        date: DateTime(2026, 11, 1),
      ),
    );
    expect((await repo.watchMonth(id, 2026, 11).first).closingPaise, 7700000);
    await repo.deleteEntry(salary);
    expect((await repo.watchMonth(id, 2026, 11).first).closingPaise, 1200000);
    final ops = await db.select(db.syncOutbox).get();
    expect(ops.where((o) => o.entityType == 'entry').map((o) => o.opType), [
      'upsert',
      'upsert',
      'delete',
    ]);
  });

  test('the summary adds every Family hisab', () async {
    final a = await home();
    final b = await repo.createFamily(
      const FamilyDraft(name: 'Village house', startingBalancePaise: 0),
      selfName: 'Hemang',
    );
    for (final (id, paise) in [(a, 6000000), (b, 2000000)]) {
      await repo.saveEntry(
        FamilyEntryDraft(
          familyId: id,
          memberId: (await detail(id)).self!.id,
          kind: FamilyEntryKind.salary,
          amountPaise: paise,
          date: DateTime(2026, 11, 1),
        ),
      );
    }
    final s = await repo.watchSummary(DateRange.month(2026, 11)).first;
    expect((s.incomePaise, s.expensePaise), (8000000, 0));
  });
}
