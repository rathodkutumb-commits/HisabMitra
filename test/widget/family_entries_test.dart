import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';

import '../helpers/app_harness.dart';

void main() {
  late AppDatabase db;
  late FamilyRepository repo;
  late String home;

  /// Opens the app with "Home" (₹12,000 to start, You and Rahul Patel).
  Future<void> open(WidgetTester tester, {String language = 'en'}) async {
    db = await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {})
          .copyWith(onboardingComplete: true, languageCode: language),
    );
    repo = FamilyRepository(db, const Clock(), const IdGenerator());
    home = await repo.createFamily(
      const FamilyDraft(name: 'Home', startingBalancePaise: 1200000),
      selfName: 'Hemang',
      people: const [FamilyPersonDraft(name: 'Rahul Patel')],
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  /// A button (of any style, with or without an icon) showing [label].
  Finder button(String label) => find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
  );

  Future<void> openHome(WidgetTester tester, String moreLabel) async {
    await tap(tester, find.text(moreLabel).last);
    await tap(tester, find.byKey(const Key('more-family')));
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<String> member(String name) async =>
      (await repo.watchFamily(home).first)!.members
          .firstWhere((m) => m.name == name)
          .id;

  Future<void> add(String memberName, FamilyEntryKind kind, int paise) async =>
      repo.saveEntry(
        FamilyEntryDraft(
          familyId: home,
          memberId: await member(memberName),
          kind: kind,
          amountPaise: paise,
          date: DateTime.now(),
          categoryId: kind == FamilyEntryKind.expense ? 'cat_rent' : null,
        ),
      );

  testApp('money in and out update the passbook', (tester) async {
    await open(tester);
    await openHome(tester, 'More');
    expect(text(tester, 'passbook-opening'), contains('12,000'));

    await tap(tester, button('Money in'));
    await tester.enterText(find.byKey(const Key('family-amount')), '60000');
    await tap(tester, button('Save'));

    await tap(tester, button('Money out'));
    await tester.enterText(find.byKey(const Key('family-amount')), '7500');
    await tap(tester, find.widgetWithText(ChoiceChip, 'Rent'));
    await tap(tester, find.widgetWithText(ChoiceChip, 'Rahul Patel'));
    await tap(tester, button('Save'));

    expect(text(tester, 'passbook-opening'), contains('12,000'));
    expect(text(tester, 'passbook-in'), contains('60,000'));
    expect(text(tester, 'passbook-out'), contains('7,500'));
    expect(text(tester, 'passbook-closing'), contains('64,500'));
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
    final rent = (await db.select(db.familyEntriesCache).get()).firstWhere(
      (e) => e.kind == 'expense',
    );
    expect(rent.memberId, await member('Rahul Patel'));
  });

  testApp('the month switcher carries the balance', (tester) async {
    await open(tester);
    await add('Hemang', FamilyEntryKind.salary, 6000000);
    await add('Rahul Patel', FamilyEntryKind.expense, 750000);
    await openHome(tester, 'More');
    expect(text(tester, 'passbook-closing'), contains('64,500'));

    await tap(tester, find.byTooltip('Next month'));
    expect(text(tester, 'passbook-opening'), contains('64,500'));
    expect(text(tester, 'passbook-closing'), contains('64,500'));
    expect(find.text('No entries this month yet'), findsOneWidget);

    await tap(tester, find.byTooltip('Previous month'));
    await tap(tester, find.byTooltip('Previous month'));
    expect(text(tester, 'passbook-opening'), contains('12,000'));
    expect(text(tester, 'passbook-closing'), contains('12,000'));
  });

  testApp('the money in form warns about double counting', (tester) async {
    await open(tester);
    await openHome(tester, 'More');
    await tap(tester, button('Money in'));
    expect(
      find.text(
        "Money here already counts on your Home screen — don't add your "
        'salary again in Hisab.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(ChoiceChip, 'Contribution'), findsOneWidget);
  });

  testApp("a removed person's entry shows (removed)", (tester) async {
    await open(tester);
    await add('Rahul Patel', FamilyEntryKind.contribution, 1000000);
    await repo.deletePerson(await member('Rahul Patel'));
    await openHome(tester, 'More');
    expect(find.textContaining('Rahul Patel (removed)'), findsOneWidget);
    expect(text(tester, 'passbook-in'), contains('10,000'));
  });

  testApp('an entry can be edited and deleted from its form', (tester) async {
    await open(tester);
    await add('Hemang', FamilyEntryKind.salary, 6000000);
    await openHome(tester, 'More');
    await tap(tester, find.text('Salary'));
    await tester.enterText(find.byKey(const Key('family-amount')), '65000');
    await tap(tester, button('Save'));
    expect(text(tester, 'passbook-in'), contains('65,000'));

    await tap(tester, find.text('Salary'));
    await tap(tester, find.byTooltip('Delete'));
    await tap(tester, button('Delete'));
    expect(text(tester, 'passbook-in'), isNot(contains('65,000')));
    expect(find.text('No entries this month yet'), findsOneWidget);
  });

  testApp('the passbook shows a bill icon on entries with a bill', (
    tester,
  ) async {
    await open(tester);
    await add('Rahul Patel', FamilyEntryKind.expense, 750000);
    final rent = (await db.select(db.familyEntriesCache).getSingle()).id;
    await add('Hemang', FamilyEntryKind.salary, 6000000);
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'bill1',
            familyEntryId: Value(rent),
            storedName: 'bill1.jpg',
            originalName: 'rent.jpg',
            mimeType: 'image/jpeg',
            sizeBytes: 10,
            sha256: 'x',
            createdAt: DateTime(2026),
          ),
        );
    await openHome(tester, 'More');
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Rent'),
        matching: find.byIcon(Icons.attach_file_rounded),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Salary'),
        matching: find.byIcon(Icons.attach_file_rounded),
      ),
      findsNothing,
    );
  });

  testApp('in Gujarati the card and categories read in Gujarati', (
    tester,
  ) async {
    await open(tester, language: 'gu');
    await add('Rahul Patel', FamilyEntryKind.expense, 750000);
    await openHome(tester, 'વધુ');
    expect(find.text('ઉઘડતી સિલક'), findsOneWidget);
    expect(find.text('બંધ સિલક'), findsOneWidget);
    final entry = await db.select(db.familyEntriesCache).getSingle();
    expect(entry.categoryNameGu, isNot(entry.categoryName));
    expect(find.text(entry.categoryNameGu!), findsOneWidget);
  });
}
