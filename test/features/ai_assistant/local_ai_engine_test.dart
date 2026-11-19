import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/core/utils/date_range.dart';
import 'package:hisabmitra/features/ai_assistant/domain/ai_intent_parser.dart';
import 'package:hisabmitra/features/ai_assistant/domain/local_ai_engine.dart';
import 'package:hisabmitra/features/categories/data/category_repository.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';
import 'package:hisabmitra/features/money_ledger/data/ledger_repository.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_models.dart';
import 'package:hisabmitra/features/people/data/people_repository.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';

class _Clock extends Clock {
  @override
  DateTime now() => DateTime(2026, 3, 20, 12);
}

void main() {
  final now = DateTime(2026, 3, 20, 12);
  final l = lookupAppLocalizations(const Locale('en'));
  final fmt = Formatters(AppPreferences.fromMap(const {}));

  setUpAll(() => initializeDateFormatting('en'));

  group('intent parser', () {
    final parser = AiIntentParser(
      now: now,
      people: const [(id: 'p1', name: 'Rahul Shah')],
      groups: const [(id: 'g1', name: 'Goa Trip')],
      categories: const [
        (
          id: 'cat_groceries',
          names: ['groceries', 'કરિયાણું'],
          type: TransactionType.expense,
        ),
        (
          id: 'cat_salary',
          names: ['salary', 'પગાર'],
          type: TransactionType.income,
        ),
      ],
    );

    test('spending this month (default period)', () {
      final q = parser.parse('How much did I spend this month?');
      expect(q.intent, AiIntent.spend);
      expect(q.range, DateRange.month(2026, 3));
    });

    test('last month and this year periods', () {
      expect(
        parser.parse('how much did I spend last month').range,
        DateRange.month(2026, 2),
      );
      final q = parser.parse('What was my income this year?');
      expect(q.intent, AiIntent.income);
      expect(q.range, DateRange(DateTime(2026), DateTime(2027)));
    });

    test('Gujarati question', () {
      final q = parser.parse('આ મહિને મેં કેટલો ખર્ચ કર્યો?');
      expect(q.intent, AiIntent.spend);
      expect(q.range, DateRange.month(2026, 3));
    });

    test('biggest category, top expenses, compare, tips, receivables', () {
      expect(
        parser.parse('What is my biggest expense category?').intent,
        AiIntent.topCategory,
      );
      expect(
        parser.parse('Show my top five expenses').intent,
        AiIntent.topExpenses,
      );
      expect(
        parser.parse('Compare this month with last month').intent,
        AiIntent.compareMonths,
      );
      expect(
        parser.parse('How can I reduce unnecessary expenses?').intent,
        AiIntent.reduceTips,
      );
      expect(
        parser.parse('How much do people owe me?').intent,
        AiIntent.receivables,
      );
      expect(parser.parse('મારી બચત કેટલી છે?').intent, AiIntent.savings);
    });

    test('person and group questions resolve the named entity', () {
      final p = parser.parse('How much money is pending from rahul?');
      expect(p.intent, AiIntent.personBalance);
      expect(p.personId, 'p1');
      final g = parser.parse('How much did our Goa trip cost?');
      expect(g.intent, AiIntent.groupTotal);
      expect(g.groupId, 'g1');
      expect(
        parser.parse('Who owes whom in Goa trip?').intent,
        AiIntent.whoOwesWhom,
      );
    });

    test('drafts parse the amount and category but never guess amounts', () {
      final d = parser.parse('add expense 250.50 for groceries');
      expect(d.intent, AiIntent.draft);
      expect(d.draftType, TransactionType.expense);
      expect(d.amountPaise, 25050);
      expect(d.categoryId, 'cat_groceries');
      final noAmount = parser.parse('add expense for groceries');
      expect(noAmount.intent, AiIntent.draft);
      expect(noAmount.amountPaise, isNull);
      expect(
        parser.parse('add income 50000 salary').draftType,
        TransactionType.income,
      );
    });

    test('unknown questions get help', () {
      expect(parser.parse('hello').intent, AiIntent.help);
    });
  });

  group('engine', () {
    late AppDatabase db;
    late LocalAiEngine engine;

    setUp(() async {
      db = newTestDatabase();
      final clock = _Clock();
      const ids = IdGenerator();
      final txns = TransactionRepository(db, clock, ids);
      final people = PeopleRepository(db, clock, ids);
      final ledger = LedgerRepository(db, clock, ids);
      final groups = GroupRepository(db, clock, ids);
      engine = LocalAiEngine(
        txns: txns,
        people: people,
        ledger: ledger,
        groups: groups,
        categories: CategoryRepository(db, clock, ids),
        clock: clock,
      );
      Future<void> spend(int paise, String cat, DateTime d) => txns.save(
        TransactionDraft(
          type: TransactionType.expense,
          amountPaise: paise,
          categoryId: cat,
          date: d,
          paymentMethod: PaymentMethod.upi,
          description: 'Private note $paise',
        ),
      );
      await spend(45000, 'cat_food', DateTime(2026, 3, 2));
      await spend(12000, 'cat_food', DateTime(2026, 3, 3));
      await spend(300000, 'cat_rent', DateTime(2026, 3, 1));
      await spend(9000, 'cat_food', DateTime(2026, 2, 10));
      final rahul = await people.save(const PersonDraft(name: 'Rahul'));
      await ledger.saveEntry(
        LedgerDraft(
          personId: rahul,
          direction: LedgerDirection.given,
          principalPaise: 300000,
          date: DateTime(2026, 3, 1),
          paymentMethod: PaymentMethod.cash,
        ),
      );
      final g = await groups.createGroup(
        const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
        selfName: 'Me',
        members: const [MemberDraft(name: 'Amit')],
      );
      final d = (await groups.watchGroup(g).first)!;
      await groups.saveExpense(
        ExpenseDraft(
          groupId: g,
          description: 'Hotel',
          categoryKey: 'stay',
          amountPaise: 800000,
          paidByMemberId: d.selfMember!.id,
          date: DateTime(2026, 3, 5),
          splitMethod: SplitMethod.equal,
          participants: [for (final m in d.members) SplitParticipant(m.id, 0)],
        ),
      );
    });
    tearDown(() => db.close());

    test('spending answer uses real totals and states the period', () async {
      final a = await engine.ask(
        'How much did I spend this month?',
        l: l,
        fmt: fmt,
      );
      expect(a.text, contains('₹3,570.00'));
      expect(a.text, contains('3 entries'));
      expect(a.periodLabel, 'March 2026');
      expect(a.isSuggestion, isFalse);
    });

    test('top category with share of spending', () async {
      final a = await engine.ask(
        'biggest expense category this month',
        l: l,
        fmt: fmt,
      );
      expect(a.text, contains('Rent'));
      expect(a.text, contains('84.0%'));
    });

    test('person balance and group cost', () async {
      expect(
        (await engine.ask('pending from Rahul?', l: l, fmt: fmt)).text,
        contains('Rahul owes you ₹3,000.00'),
      );
      final g = await engine.ask(
        'How much did the Goa trip cost?',
        l: l,
        fmt: fmt,
      );
      expect(g.text, contains('₹8,000.00'));
      expect(g.text, contains('₹4,000.00'));
    });

    test('comparison with the previous month', () async {
      final a = await engine.ask(
        'compare this month with last month',
        l: l,
        fmt: fmt,
      );
      expect(a.text, contains('₹3,570.00'));
      expect(a.text, contains('₹90.00'));
      expect(a.text, contains('₹3,480.00 more'));
    });

    test('tips are flagged as suggestions', () async {
      final a = await engine.ask('how can I reduce expenses', l: l, fmt: fmt);
      expect(a.isSuggestion, isTrue);
      expect(a.bullets, isNotEmpty);
    });

    test('drafts never write records', () async {
      final before = (await db.select(db.transactions).get()).length;
      final a = await engine.ask(
        'add expense 250 for groceries',
        l: l,
        fmt: fmt,
      );
      expect(a.draft!.amountPaise, 25000);
      expect(a.draft!.categoryId, 'cat_groceries');
      expect((await db.select(db.transactions).get()).length, before);
      final missing = await engine.ask('add expense for food', l: l, fmt: fmt);
      expect(missing.draft, isNull);
      expect(missing.text, l.aiDraftNeedsAmount);
    });

    test(
      'facts for the online model omit descriptions and redact names',
      () async {
        final top = await engine.ask(
          'top 5 expenses this month',
          l: l,
          fmt: fmt,
          shareNames: false,
        );
        expect(top.modelFacts.toString(), isNot(contains('Private note')));
        final person = await engine.ask(
          'pending from Rahul?',
          l: l,
          fmt: fmt,
          shareNames: false,
        );
        expect(person.modelFacts.toString(), isNot(contains('Rahul')));
        expect(person.redactedQuestion, isNot(contains('Rahul')));
        final shared = await engine.ask(
          'pending from Rahul?',
          l: l,
          fmt: fmt,
          shareNames: true,
        );
        expect(shared.modelFacts.toString(), contains('Rahul'));
      },
    );
  });
}
