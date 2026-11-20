import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/domain/enums.dart';
import 'package:hisabmitra/features/ai_assistant/domain/ai_intent_parser.dart';
import 'package:hisabmitra/features/ai_assistant/presentation/ai_examples.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';

void main() {
  final parser = AiIntentParser(
    now: DateTime(2026, 11, 20, 12),
    people: const [(id: 'p1', name: 'Rahul Shah')],
    groups: const [(id: 'g1', name: 'Goa Trip')],
    categories: const [
      (
        id: 'cat_groceries',
        names: ['Groceries', 'કરિયાણું', 'groceries'],
        type: TransactionType.expense,
      ),
      (
        id: 'cat_fuel',
        names: ['Fuel', 'પેટ્રોલ-ડીઝલ', 'fuel'],
        type: TransactionType.expense,
      ),
      (
        id: 'cat_salary',
        names: ['Salary', 'પગાર', 'salary'],
        type: TransactionType.income,
      ),
    ],
  );

  for (final code in ['en', 'gu']) {
    final l = lookupAppLocalizations(Locale(code));

    test('every example parses to its intended answer ($code)', () {
      final sections = buildAiExamples(
        l,
        personName: 'Rahul Shah',
        groupName: 'Goa Trip',
      );
      for (final s in sections) {
        for (final e in s.examples) {
          final q = parser.parse(e.text);
          expect(q.intent, e.intent, reason: e.text);
          if (e.intent == AiIntent.draft) {
            expect(q.draftType, e.draftType, reason: e.text);
            expect(q.categoryId, isNotNull, reason: 'category: ${e.text}');
          }
        }
      }
    });

    test(
      '18 examples with names, 15 without and no Groups section ($code)',
      () {
        int count(List<AiExampleSection> s) =>
            s.fold(0, (n, section) => n + section.examples.length);

        final withNames = buildAiExamples(
          l,
          personName: 'Rahul Shah',
          groupName: 'Goa Trip',
        );
        expect(count(withNames), 18);
        expect(withNames.map((s) => s.title), contains(l.aiExamplesGroups));

        final without = buildAiExamples(l);
        expect(count(without), 15);
        expect(
          without.map((s) => s.title),
          isNot(contains(l.aiExamplesGroups)),
        );
      },
    );
  }
}
