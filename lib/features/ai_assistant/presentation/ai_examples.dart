import '../../../core/domain/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/ai_intent_parser.dart';

/// An example question and the answer it must lead to (checked by tests,
/// so every suggestion is one the assistant can really answer).
typedef AiExample = ({
  String text,
  AiIntent intent,
  TransactionType? draftType,
});

typedef AiExampleSection = ({String title, List<AiExample> examples});

AiExample _q(String text, AiIntent intent, [TransactionType? draftType]) =>
    (text: text, intent: intent, draftType: draftType);

/// Example questions grouped by topic. [personName] and [groupName] (the
/// user's most recent person and group) add personal examples; the Groups
/// section appears only when there is a group.
List<AiExampleSection> buildAiExamples(
  AppLocalizations l, {
  String? personName,
  String? groupName,
}) {
  return [
    (
      title: l.aiExamplesSpending,
      examples: [
        _q(l.aiExample1, AiIntent.spend),
        _q(l.aiExample7, AiIntent.spend),
        _q(l.aiExample8, AiIntent.spend),
        _q(l.aiExample2, AiIntent.topCategory),
        _q(l.aiExample4, AiIntent.topExpenses),
        _q(l.aiExample3, AiIntent.compareMonths),
        _q(l.aiExample6, AiIntent.reduceTips),
      ],
    ),
    (
      title: l.aiExamplesIncome,
      examples: [
        _q(l.aiExample9, AiIntent.income),
        _q(l.aiExample10, AiIntent.income),
        _q(l.aiExample11, AiIntent.savings),
        _q(l.aiExample12, AiIntent.savings),
      ],
    ),
    (
      title: l.aiExamplesKhata,
      examples: [
        _q(l.aiExample5, AiIntent.receivables),
        if (personName != null)
          _q(l.aiExamplePerson(personName), AiIntent.personBalance),
      ],
    ),
    if (groupName != null)
      (
        title: l.aiExamplesGroups,
        examples: [
          _q(l.aiExampleGroupTotal(groupName), AiIntent.groupTotal),
          _q(l.aiExampleGroupOwes(groupName), AiIntent.whoOwesWhom),
        ],
      ),
    (
      title: l.aiExamplesAdd,
      examples: [
        _q(l.aiExample13, AiIntent.draft, TransactionType.expense),
        _q(l.aiExample14, AiIntent.draft, TransactionType.income),
        _q(l.aiExample15, AiIntent.draft, TransactionType.expense),
      ],
    ),
  ];
}
