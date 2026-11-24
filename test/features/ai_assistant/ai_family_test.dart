import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/ai_assistant/domain/ai_intent_parser.dart';
import 'package:hisabmitra/features/ai_assistant/domain/local_ai_engine.dart';
import 'package:hisabmitra/features/categories/data/category_repository.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/money_ledger/data/ledger_repository.dart';
import 'package:hisabmitra/features/people/data/people_repository.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/test_db.dart';

class _Clock extends Clock {
  @override
  DateTime now() => DateTime(2026, 11, 20, 12);
}

void main() {
  final l = lookupAppLocalizations(const Locale('en'));
  final fmt = Formatters(AppPreferences.fromMap(const {}));
  setUpAll(() => initializeDateFormatting('en'));

  group('understanding Family hisab questions', () {
    AiIntentParser parser({String family = 'Home'}) => AiIntentParser(
      now: DateTime(2026, 11, 20, 12),
      people: const [(id: 'khata-rahul', name: 'Rahul Patel')],
      groups: const [(id: 'g1', name: 'Goa Trip')],
      families: [(id: 'f1', name: family)],
      familyPeople: const [
        (id: 'm-you', familyId: 'f1', name: 'Hemang'),
        (id: 'm-rahul', familyId: 'f1', name: 'Rahul Patel'),
      ],
      categories: const [
        (
          id: 'cat_groceries',
          names: ['Groceries', 'કરિયાણું', 'groceries'],
          type: TransactionType.expense,
        ),
      ],
    );

    test('spending on a category at Home', () {
      final q = parser().parse(
        'How much did we spend on groceries at Home this month?',
      );
      expect(
        (q.intent, q.familyId, q.categoryId),
        (AiIntent.familySpend, 'f1', 'cat_groceries'),
      );
    });

    test('what a person put in, even with a Khata person of that name', () {
      final q = parser().parse('What did Rahul put in this month?');
      expect(
        (q.intent, q.familyId, q.familyMemberId),
        (AiIntent.familyPersonIn, 'f1', 'm-rahul'),
      );
      expect(
        parser().parse('How much does Rahul owe me?').intent,
        AiIntent.personBalance,
        reason: 'Khata questions stay Khata',
      );
    });

    test('the balance', () {
      final q = parser().parse('What is the Home balance?');
      expect((q.intent, q.familyId), (AiIntent.familyBalance, 'f1'));
    });

    test('a name like "Home" does not take over other questions', () {
      expect(
        parser().parse('How much did I spend this month?').intent,
        AiIntent.spend,
      );
      expect(
        parser().parse('What is my income this month?').intent,
        AiIntent.income,
      );
    });

    test('Gujarati', () {
      final q = parser(family: 'ઘર')
          .parse('આ મહિને ઘરમાં કરિયાણું પર કેટલો ખર્ચ થયો?');
      expect((q.intent, q.categoryId), (AiIntent.familySpend, 'cat_groceries'));
    });
  });

  group('answering from the Family hisab', () {
    late AppDatabase db;
    late LocalAiEngine engine;

    setUp(() async {
      db = newTestDatabase();
      final clock = _Clock();
      const ids = IdGenerator();
      final people = PeopleRepository(db, clock, ids);
      await people.save(const PersonDraft(name: 'Rahul Patel')); // Khata
      final family = FamilyRepository(db, clock, ids);
      engine = LocalAiEngine(
        txns: TransactionRepository(db, clock, ids),
        people: people,
        ledger: LedgerRepository(db, clock, ids),
        groups: GroupRepository(db, clock, ids),
        categories: CategoryRepository(db, clock, ids),
        families: family,
        clock: clock,
      );
      final home = await family.createFamily(
        const FamilyDraft(name: 'Home', startingBalancePaise: 1200000),
        selfName: 'Hemang',
        people: const [FamilyPersonDraft(name: 'Rahul Patel')],
      );
      final d = (await family.watchFamily(home).first)!;
      Future<void> add(int who, FamilyEntryKind kind, int paise) =>
          family.saveEntry(
            FamilyEntryDraft(
              familyId: home,
              memberId: d.members[who].id,
              kind: kind,
              amountPaise: paise,
              date: DateTime(2026, 11, 10),
              categoryId: kind == FamilyEntryKind.expense
                  ? 'cat_groceries'
                  : null,
            ),
          );
      await add(0, FamilyEntryKind.salary, 6000000);
      await add(1, FamilyEntryKind.contribution, 1000000);
      await add(1, FamilyEntryKind.expense, 750000);
    });
    tearDown(() => db.close());

    Future<AiAnswer> ask(String q, {bool shareNames = false}) =>
        engine.ask(q, l: l, fmt: fmt, shareNames: shareNames);

    test('groceries at Home', () async {
      final a = await ask(
        'How much did we spend on groceries at Home this month?',
      );
      expect(a.text, contains('₹7,500.00'));
    });

    test('what Rahul put in', () async {
      final a = await ask('What did Rahul put in this month?');
      expect(a.text, contains('₹10,000.00'));
    });

    test('the Home balance', () async {
      final a = await ask('What is the Home balance?');
      expect(a.text, contains('₹74,500.00'));
    });

    test('the online model gets no names unless shared', () async {
      final a = await ask('What did Rahul put in this month?');
      expect(a.modelFacts.toString(), isNot(contains('Rahul')));
      expect(a.modelFacts.toString(), isNot(contains('Home')));
      expect(a.redactedQuestion, isNot(contains('Rahul')));
      final shared = await ask(
        'What did Rahul put in this month?',
        shareNames: true,
      );
      expect(shared.modelFacts.toString(), contains('Rahul'));
    });
  });
}
