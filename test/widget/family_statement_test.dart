import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';

import '../helpers/app_harness.dart';

void main() {
  Future<void> tap(WidgetTester tester, Finder f) async {
    await tester.ensureVisible(f);
    await tester.pumpAndSettle();
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testApp('the statement shows the totals and WhatsApp for people with a '
      'number', (tester) async {
    final db = await pumpHisabMitra(tester);
    final repo = FamilyRepository(db, const Clock(), const IdGenerator());
    final id = await repo.createFamily(
      const FamilyDraft(name: 'Home', startingBalancePaise: 1200000),
      selfName: 'Hemang',
      people: const [
        FamilyPersonDraft(name: 'Rahul Patel', phone: '+919800000001'),
        FamilyPersonDraft(name: 'Priya Shah'),
      ],
    );
    final d = (await repo.watchFamily(id).first)!;
    Future<void> add(int who, FamilyEntryKind kind, int paise) =>
        repo.saveEntry(
          FamilyEntryDraft(
            familyId: id,
            memberId: d.members[who].id,
            kind: kind,
            amountPaise: paise,
            date: DateTime.now(),
            categoryId: kind == FamilyEntryKind.expense ? 'cat_rent' : null,
          ),
        );
    await add(0, FamilyEntryKind.salary, 6000000);
    await add(1, FamilyEntryKind.contribution, 1000000);
    await add(1, FamilyEntryKind.expense, 750000);
    await tester.pumpAndSettle();

    await tap(tester, find.text('More').last);
    await tap(tester, find.byKey(const Key('more-family')));
    await tap(tester, find.byTooltip('Statement'));

    expect(find.text('₹12,000.00'), findsOneWidget);
    expect(find.text('₹70,000.00'), findsWidgets);
    expect(find.text('₹7,500.00'), findsWidgets);
    expect(find.text('₹74,500.00'), findsOneWidget);
    expect(find.text('By person'), findsOneWidget);
    expect(find.byTooltip('Send on WhatsApp to Rahul Patel'), findsOneWidget);
    expect(find.byTooltip('Send on WhatsApp to Hemang'), findsNothing);
    expect(find.byTooltip('Send on WhatsApp to Priya Shah'), findsNothing);
    expect(find.byTooltip('Share'), findsOneWidget);
  });

  testApp('the statement says so when its Family hisab is deleted', (
    tester,
  ) async {
    final db = await pumpHisabMitra(tester);
    final repo = FamilyRepository(db, const Clock(), const IdGenerator());
    final id = await repo.createFamily(
      const FamilyDraft(name: 'Home'),
      selfName: 'Hemang',
    );
    await tester.pumpAndSettle();
    await tap(tester, find.text('More').last);
    await tap(tester, find.byKey(const Key('more-family')));
    await tap(tester, find.byTooltip('Statement'));
    expect(find.text('Home — ${_month(DateTime.now())}'), findsOneWidget);

    await repo.deleteFamily(id); // e.g. from another phone
    await tester.pumpAndSettle();
    expect(find.text('This record no longer exists.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
String _month(DateTime d) => '${_months[d.month - 1]} ${d.year}';
