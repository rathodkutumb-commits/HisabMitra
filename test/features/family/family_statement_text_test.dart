import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/family/data/family_statement_export.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/family/domain/passbook.dart';
import 'package:hisabmitra/features/reports/data/pdf_renderer.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('gu');
  });

  FamilyEntry e(
    String id,
    String member,
    FamilyEntryKind kind,
    int paise,
    int day, {
    String? category,
  }) => FamilyEntry(
    id: id,
    memberId: member,
    kind: kind,
    amountPaise: paise,
    date: DateTime(2026, 11, day),
    categoryId: category == null ? null : 'cat_$category',
    categoryName: category,
    categoryNameGu: category == 'Rent' ? 'ભાડું' : null,
  );

  // The Task 3 fixture: November 2026 at Home.
  final november = passbookMonth(
    startingBalancePaise: 1200000,
    entries: [
      e('1', 'you', FamilyEntryKind.salary, 6000000, 1),
      e('2', 'rahul', FamilyEntryKind.salary, 3500000, 1),
      e('3', 'you', FamilyEntryKind.extraIncome, 500000, 10),
      e('4', 'rahul', FamilyEntryKind.contribution, 1000000, 12),
      e('5', 'you', FamilyEntryKind.expense, 5200000, 5, category: 'Rent'),
      e('6', 'rahul', FamilyEntryKind.expense, 2650000, 20, category: 'Food'),
    ],
    memberOrder: const ['you', 'rahul'],
    year: 2026,
    month: 11,
  );
  String name(String id) => id == 'you' ? 'You' : 'Rahul Patel';

  String text(String language) => familyStatementText(
    lookupAppLocalizations(Locale(language)),
    Formatters(
      AppPreferences.fromMap(const {}).copyWith(languageCode: language),
    ),
    familyName: 'Home',
    s: november,
    name: name,
  );

  test('the WhatsApp text adds up in English', () {
    final lines = text('en').split('\n');
    expect(lines.first, '🏠 *Home — November 2026*');
    expect(
      lines,
      containsAllInOrder([
        'Opening balance: ₹12,000.00',
        'Money in: ₹1,10,000.00',
        'Money out: ₹78,500.00',
        'Closing balance: ₹43,500.00',
        '*By person*',
        'You — in ₹65,000.00 · paid ₹52,000.00',
        'Rahul Patel — in ₹45,000.00 · paid ₹26,500.00',
      ]),
    );
  });

  test('the WhatsApp text in Gujarati', () {
    final lines = text('gu').split('\n');
    expect(lines.first, startsWith('🏠 *Home — '));
    expect(
      lines,
      containsAllInOrder([
        'ઉઘડતી સિલક: ₹12,000.00',
        'જમા: ₹1,10,000.00',
        'ખર્ચ: ₹78,500.00',
        'બંધ સિલક: ₹43,500.00',
        '*વ્યક્તિ મુજબ*',
        'You — જમા ₹65,000.00 · ખર્ચ ₹52,000.00',
      ]),
    );
  });

  test('money in is grouped by person and kind, money out by category', () {
    expect(
      [for (final x in moneyInLines(november)) (x.memberId, x.kind, x.paise)],
      [
        ('you', FamilyEntryKind.salary, 6000000),
        ('you', FamilyEntryKind.extraIncome, 500000),
        ('rahul', FamilyEntryKind.salary, 3500000),
        ('rahul', FamilyEntryKind.contribution, 1000000),
      ],
    );
    expect(moneyOutByCategory(november, 'gu'), [
      ('ભાડું', 5200000),
      ('Food', 2650000),
    ]);
  });

  test('the PDF statement has every part and fits on one page', () {
    final l = lookupAppLocalizations(const Locale('en'));
    final doc = familyStatementDocument(
      l,
      Formatters(AppPreferences.fromMap(const {})),
      familyName: 'Home',
      s: november,
      name: name,
    );
    expect(doc.title, 'Home — November 2026');
    expect(
      [for (final b in doc.blocks.whereType<HeadingBlock>()) b.text],
      ['Money in (credit)', 'Money out (debit)', 'By person'],
    );
    final byPerson = doc.blocks.whereType<TableBlock>().last;
    expect(byPerson.rows.first, ['You', '₹65,000.00', '₹52,000.00']);
    expect(PdfReportRenderer(fontFamily: 'Poppins').pageCount(doc), 1);
  });

  test('WhatsApp links use the number in international form', () {
    expect(
      waMeUrl('+91 98000 00001', 'Hi & bye').toString(),
      'https://wa.me/919800000001?text=Hi%20%26%20bye',
    );
    expect(
      waMeUrl('9800000001', 'x').toString(),
      'https://wa.me/919800000001?text=x',
    );
    expect(
      waMeUrl('+44 20 7946 0958', 'x').toString(),
      'https://wa.me/442079460958?text=x',
    );
  });
}
