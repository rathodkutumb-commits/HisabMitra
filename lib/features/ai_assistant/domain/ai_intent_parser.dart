import 'package:flutter/foundation.dart';

import '../../../core/domain/enums.dart';
import '../../../core/money/money.dart';
import '../../../core/utils/date_range.dart';

enum AiIntent {
  spend,
  income,
  savings,
  topCategory,
  topExpenses,
  compareMonths,
  reduceTips,
  receivables,
  personBalance,
  groupTotal,
  whoOwesWhom,
  familySpend,
  familyPersonIn,
  familyBalance,
  draft,
  help,
}

enum AiPeriod { today, thisMonth, lastMonth, thisYear }

@immutable
class AiQuery {
  const AiQuery({
    required this.intent,
    required this.period,
    required this.range,
    this.personId,
    this.groupId,
    this.familyId,
    this.familyMemberId,
    this.amountPaise,
    this.categoryId,
    this.draftType,
  });

  final AiIntent intent;
  final AiPeriod period;
  final DateRange range;
  final String? personId;
  final String? groupId;

  /// The Family hisab asked about, and one of its people.
  final String? familyId;
  final String? familyMemberId;
  final int? amountPaise;
  final String? categoryId;
  final TransactionType? draftType;
}

typedef NamedEntity = ({String id, String name});
typedef CategoryNames = ({String id, List<String> names, TransactionType type});
typedef FamilyPersonName = ({String id, String familyId, String name});

/// Deterministic keyword-based understanding of finance questions in
/// English and Gujarati. No model is involved: what the assistant answers
/// is decided here and computed from the database.
class AiIntentParser {
  AiIntentParser({
    required this.now,
    required this.people,
    required this.groups,
    required this.categories,
    this.families = const [],
    this.familyPeople = const [],
  });

  final DateTime now;
  final List<NamedEntity> people;
  final List<NamedEntity> groups;
  final List<NamedEntity> families;
  final List<FamilyPersonName> familyPeople;
  final List<CategoryNames> categories;

  static bool _any(String q, List<String> words) => words.any(q.contains);

  static final _amount = RegExp(
    r'(?:₹|rs\.?|inr)?\s*([0-9૦-૯][0-9૦-૯,]*(?:\.[0-9૦-૯]{1,2})?)',
  );

  AiQuery parse(String question) {
    final q = question.toLowerCase().trim();
    final period = _period(q);
    final range = switch (period) {
      AiPeriod.today => DateRange.custom(now, now),
      _ => DateRange.forPreset(switch (period) {
        AiPeriod.lastMonth => PeriodPreset.lastMonth,
        AiPeriod.thisYear => PeriodPreset.thisYear,
        _ => PeriodPreset.thisMonth,
      }, now),
    };
    AiQuery make(AiIntent intent, {String? person, String? group}) => AiQuery(
      intent: intent,
      period: period,
      range: range,
      personId: person,
      groupId: group,
    );

    // 1. Drafts — the user asks to *record* something.
    if (RegExp(r'^(add|record|note|log)\b').hasMatch(q) ||
        _any(q, ['ઉમેર', 'નોંધ કર', 'લખી લ'])) {
      final income = _any(q, ['income', 'salary', 'received', 'આવક', 'પગાર']);
      final type = income ? TransactionType.income : TransactionType.expense;
      final match = _amount.firstMatch(q);
      final amount = match == null ? null : Money.tryParse(match.group(1)!);
      return AiQuery(
        intent: AiIntent.draft,
        period: period,
        range: range,
        amountPaise: amount != null && amount > 0 ? amount : null,
        categoryId: _category(q, type),
        draftType: type,
      );
    }

    // 2. Family hisab — named (or "family" when there is only one), or one
    // of its people with money-in words. Before groups and Khata people, so
    // "What did Rahul put in?" is about the Family hisab and "How much does
    // Rahul owe me?" stays Khata.
    final family =
        _entity(q, families) ??
        (families.length == 1 && _any(q, ['family', 'પરિવાર'])
            ? families.single.id
            : null);
    final familyPerson = _entity(q, [
      for (final p in familyPeople)
        if (family == null || p.familyId == family) (id: p.id, name: p.name),
    ]);
    final moneyIn = _any(q, [
      'put in',
      'gave',
      'given',
      'contribut',
      'salary',
      'paid in',
      'આપ્યા',
      'આપ્યો',
      'ફાળો',
      'જમા',
      'પગાર',
    ]);
    AiQuery familyQuery(
      AiIntent intent,
      String familyId, {
      String? member,
      String? category,
    }) => AiQuery(
      intent: intent,
      period: period,
      range: range,
      familyId: familyId,
      familyMemberId: member,
      categoryId: category,
    );
    if (family != null) {
      if (_any(q, ['balance', 'left', 'સિલક', 'બાકી'])) {
        return familyQuery(AiIntent.familyBalance, family);
      }
      if (familyPerson != null && moneyIn) {
        return familyQuery(
          AiIntent.familyPersonIn,
          family,
          member: familyPerson,
        );
      }
      final category = _category(q, TransactionType.expense);
      if (category != null ||
          _any(q, ['spend', 'spent', 'expense', 'expenditure', 'ખર્ચ'])) {
        return familyQuery(AiIntent.familySpend, family, category: category);
      }
      return familyQuery(AiIntent.familyBalance, family);
    }
    if (familyPerson != null && moneyIn) {
      final p = familyPeople.firstWhere((x) => x.id == familyPerson);
      return familyQuery(
        AiIntent.familyPersonIn,
        p.familyId,
        member: familyPerson,
      );
    }

    final group = _entity(q, groups);
    final person = _entity(q, people);

    if (group != null &&
        _any(q, [
          'owes',
          'owe whom',
          'who owe',
          'settle',
          'કોણે',
          'કોને',
          'ચૂકતે',
        ])) {
      return make(AiIntent.whoOwesWhom, group: group);
    }
    if (group != null) return make(AiIntent.groupTotal, group: group);
    if (person != null) return make(AiIntent.personBalance, person: person);
    if (_any(q, ['compare', ' vs', 'versus', 'સરખામણી', 'તુલના'])) {
      return make(AiIntent.compareMonths);
    }
    if (_any(q, [
      'top',
      'largest expenses',
      'biggest expenses',
      'સૌથી મોટા',
      'મોટા ખર્ચ',
      'મોટા પાંચ',
    ])) {
      return make(AiIntent.topExpenses);
    }
    if (_any(q, ['category', 'categories', 'શ્રેણી'])) {
      return make(AiIntent.topCategory);
    }
    if (_any(q, [
      'reduce',
      'cut down',
      'save money',
      'tips',
      'spend less',
      'ઘટાડ',
      'ઓછો ખર્ચ',
      'બચાવ',
    ])) {
      return make(AiIntent.reduceTips);
    }
    if (_any(q, [
      'owe me',
      'owes me',
      'receivable',
      'pending',
      'to receive',
      'લેવાના',
      'બાકી',
    ])) {
      return make(AiIntent.receivables);
    }
    if (_any(q, ['saving', 'savings', 'saved', 'બચત', 'બચ્યા'])) {
      return make(AiIntent.savings);
    }
    if (_any(q, ['income', 'earn', 'salary', 'આવક', 'કમાણી', 'પગાર'])) {
      return make(AiIntent.income);
    }
    if (_any(q, ['spend', 'spent', 'expense', 'expenditure', 'ખર્ચ'])) {
      return make(AiIntent.spend);
    }
    return make(AiIntent.help);
  }

  static AiPeriod _period(String q) {
    if (_any(q, ['today', 'આજે', 'આજનો'])) return AiPeriod.today;
    if (_any(q, [
      'last month',
      'previous month',
      'ગયા મહિને',
      'ગયા મહિના',
      'ગત મહિને',
    ])) {
      // "compare this month with last month" is about this month.
      if (!_any(q, ['this month', 'આ મહિ'])) return AiPeriod.lastMonth;
    }
    if (_any(q, ['this year', 'આ વર્ષ', 'year'])) return AiPeriod.thisYear;
    return AiPeriod.thisMonth;
  }

  /// Longest matching name wins; also matches on the first name (≥ 3 chars).
  static String? _entity(String q, List<NamedEntity> items) {
    String? best;
    var bestLen = 0;
    for (final e in items) {
      final full = e.name.toLowerCase().trim();
      final first = full.split(RegExp(r'\s+')).first;
      final candidates = [full, if (first.length >= 3) first];
      for (final c in candidates) {
        if (c.isNotEmpty && q.contains(c) && c.length > bestLen) {
          best = e.id;
          bestLen = c.length;
        }
      }
    }
    return best;
  }

  /// A Gujarati word without its ending vowel signs, so "કરિયાણું" also
  /// finds "કરિયાણા" and "કરિયાણામાં" (null when nothing was removed or the
  /// stem would be too short to be safe).
  static String? _stem(String word) {
    var end = word.length;
    bool sign(int c) =>
        (c >= 0x0A81 && c <= 0x0A83) || // candrabindu, anusvara, visarga
        (c >= 0x0ABE && c <= 0x0ACD); // vowel signs and virama
    while (end > 0 && sign(word.codeUnitAt(end - 1))) {
      end--;
    }
    return end < word.length && end >= 3 ? word.substring(0, end) : null;
  }

  String? _category(String q, TransactionType type) {
    String? best;
    var bestLen = 0;
    for (final c in categories.where((c) => c.type == type)) {
      for (final name in c.names) {
        final n = name.toLowerCase();
        final word = n.split(RegExp(r'[\s&]+')).first;
        for (final candidate in [
          n,
          if (word.length >= 4) word,
          ?_stem(n),
          if (word != n) ?_stem(word),
        ]) {
          if (candidate.isNotEmpty &&
              q.contains(candidate) &&
              candidate.length > bestLen) {
            best = c.id;
            bestLen = candidate.length;
          }
        }
      }
    }
    return best;
  }
}
