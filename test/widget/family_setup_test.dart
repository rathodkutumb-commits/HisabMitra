import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';

import '../helpers/app_harness.dart';

void main() {
  FamilyRepository repo(AppDatabase db) =>
      FamilyRepository(db, const Clock(), const IdGenerator());

  Finder inAppBar(String text) =>
      find.descendant(of: find.byType(AppBar), matching: find.text(text));

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testApp('the Home quick action opens Family hisab setup and creates one', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    await tap(tester, find.text('Family hisab').first);
    expect(find.text('Create Family hisab'), findsWidgets);
    await tap(tester, find.widgetWithText(FilledButton, 'Create Family hisab'));

    await tester.enterText(find.byKey(const Key('family-name')), 'Home');
    await tester.enterText(find.byKey(const Key('family-start')), '12000');
    await tester.enterText(
      find.byKey(const Key('family-person-name')),
      'Rahul Patel',
    );
    await tester.enterText(
      find.byKey(const Key('family-person-phone')),
      '+919800000001',
    );
    await tap(tester, find.byKey(const Key('family-add-person')));
    expect(find.text('Rahul Patel'), findsOneWidget);
    expect(find.text('Hemang (you)'), findsOneWidget);
    await tap(tester, find.widgetWithText(FilledButton, 'Save'));

    expect(inAppBar('Home'), findsOneWidget);
    final family = await db.select(db.familyHisabsCache).getSingle();
    expect((family.name, family.openingBalancePaise), ('Home', 1200000));
    final people = await db.select(db.familyMembersCache).get();
    expect(
      {for (final m in people) (m.name, m.phone, m.isSelf)},
      {('Hemang', null, true), ('Rahul Patel', '+919800000001', false)},
    );
  });

  testApp('with one Family hisab, the Hisab tab button opens it directly', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    await repo(db)
        .createFamily(const FamilyDraft(name: 'Home'), selfName: 'Hemang');
    await tester.pumpAndSettle();
    await tap(tester, find.text('Hisab').last);
    await tap(tester, find.widgetWithText(TextButton, 'Family'));
    expect(inAppBar('Home'), findsOneWidget);
    expect(find.text('Create Family hisab'), findsNothing);
  });

  testApp('a person can be renamed and deleted, keeping entries', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    final r = repo(db);
    final id = await r.createFamily(
      const FamilyDraft(name: 'Home'),
      selfName: 'Hemang',
      people: const [FamilyPersonDraft(name: 'Rahul Patel')],
    );
    final rahul = (await r.watchFamily(id).first)!.members.last.id;
    await r.saveEntry(
      FamilyEntryDraft(
        familyId: id,
        memberId: rahul,
        kind: FamilyEntryKind.contribution,
        amountPaise: 1000000,
        date: DateTime(2026, 11, 12),
      ),
    );
    await tester.pumpAndSettle();

    await tap(tester, find.text('More').last);
    await tap(tester, find.text('Family hisab').first);
    await tap(tester, find.byTooltip('People'));
    expect(find.text('Hemang (you)'), findsOneWidget);
    expect(find.text('Not joined'), findsOneWidget);

    await tap(
      tester,
      find.descendant(
        of: find.widgetWithText(ListTile, 'Rahul Patel'),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tap(tester, find.text('Edit person'));
    await tester.enterText(
      find.byKey(const Key('family-person-name')),
      'Rahul P.',
    );
    await tap(tester, find.widgetWithText(FilledButton, 'Save'));
    expect(find.text('Rahul P.'), findsOneWidget);

    await tap(
      tester,
      find.descendant(
        of: find.widgetWithText(ListTile, 'Rahul P.'),
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tap(tester, find.text('Delete person'));
    expect(find.textContaining('Their entries stay'), findsOneWidget);
    await tap(tester, find.widgetWithText(FilledButton, 'Delete person'));
    expect(find.text('Rahul P.'), findsNothing);
    await tap(tester, find.text('Show removed (1)'));
    expect(find.text('Rahul P. (removed)'), findsOneWidget);

    final entry = await db.select(db.familyEntriesCache).getSingle();
    expect((entry.memberId, entry.deletedAt), (rahul, null));
  });
}
