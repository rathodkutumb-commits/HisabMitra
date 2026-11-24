import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/providers.dart';
import '../../../core/utils/date_range.dart';
import '../../categories/data/category_repository.dart';
import '../../categories/presentation/category_labels.dart';
import '../../family/data/family_repository.dart';
import '../../groups/data/group_repository.dart';
import '../../money_ledger/data/ledger_repository.dart';
import '../../people/data/people_repository.dart';
import '../../reports/data/export_service.dart';
import '../../settings/application/settings_controller.dart';
import '../../transactions/data/transaction_repository.dart';
import '../../transactions/domain/transaction_models.dart';
import 'ai_intent_parser.dart';

/// A proposed (never saved) income/expense the user can review in the form.
@immutable
class AiDraft {
  const AiDraft({
    required this.type,
    required this.amountPaise,
    this.categoryId,
  });

  final TransactionType type;
  final int amountPaise;
  final String? categoryId;
}

@immutable
class AiAnswer {
  const AiAnswer({
    required this.text,
    this.bullets = const [],
    this.periodLabel,
    this.isSuggestion = false,
    this.draft,
    this.modelFacts = const {},
    this.redactedQuestion = '',
  });

  final String text;
  final List<String> bullets;
  final String? periodLabel;

  /// True for advice; such answers are labelled "suggestion, not data".
  final bool isSuggestion;
  final AiDraft? draft;

  /// Minimal, aggregated facts the optional online model may rephrase.
  final Map<String, Object?> modelFacts;
  final String redactedQuestion;
}

/// The assistant's brain: parses the question, runs deterministic queries
/// and fills localised templates. It only reads data; every number comes
/// from the database and is formatted from integer paise.
class LocalAiEngine {
  LocalAiEngine({
    required this._txns,
    required this._people,
    required this._ledger,
    required this._groups,
    required this._categories,
    this._families,
    required this._clock,
  });

  final TransactionRepository _txns;
  final PeopleRepository _people;
  final LedgerRepository _ledger;
  final GroupRepository _groups;
  final CategoryRepository _categories;
  final FamilyRepository? _families;
  final Clock _clock;

  Future<AiAnswer> ask(
    String question, {
    required AppLocalizations l,
    required Formatters fmt,
    bool shareNames = false,
  }) async {
    final people = await _people.watchAll().first;
    final groups = await _groups.watchGroups(includeArchived: true).first;
    final categories = await _categories.watchAll().first;
    final familyRepo = _families;
    final familyDetails = <FamilyDetail>[
      if (familyRepo != null)
        for (final f in await familyRepo.watchFamilies().first)
          ?(await familyRepo.watchFamily(f.id).first),
    ];
    final parser = AiIntentParser(
      now: _clock.now(),
      people: [for (final p in people) (id: p.id, name: p.name)],
      groups: [for (final g in groups) (id: g.group.id, name: g.group.name)],
      families: [
        for (final d in familyDetails) (id: d.family.id, name: d.family.name),
      ],
      familyPeople: [
        for (final d in familyDetails)
          for (final m in d.members)
            (id: m.id, familyId: d.family.id, name: m.name),
      ],
      categories: [
        for (final c in categories)
          (
            id: c.id,
            names: {
              c.name,
              if (c.nameGu != null) c.nameGu!,
              c.label(l),
              if (c.systemKey != null) c.systemKey!,
            }.toList(),
            type: c.type,
          ),
      ],
    );
    final query = parser.parse(question);

    // Redact personal names before anything could leave the device.
    var redacted = question;
    String personAlias(String name) => shareNames ? name : 'the person';
    String groupAlias(String name) => shareNames ? name : 'the group';
    if (!shareNames) {
      for (final p in people) {
        redacted = redacted.replaceAll(
          RegExp(RegExp.escape(p.name), caseSensitive: false),
          'the person',
        );
        final first = p.name.split(' ').first;
        if (first.length >= 3) {
          redacted = redacted.replaceAll(
            RegExp(RegExp.escape(first), caseSensitive: false),
            'the person',
          );
        }
      }
      for (final g in groups) {
        redacted = redacted.replaceAll(
          RegExp(RegExp.escape(g.group.name), caseSensitive: false),
          'the group',
        );
      }
      for (final d in familyDetails) {
        for (final m in d.members) {
          for (final n in {m.name, m.name.split(' ').first}) {
            if (n.length < 3) continue;
            redacted = redacted.replaceAll(
              RegExp(RegExp.escape(n), caseSensitive: false),
              'the person',
            );
          }
        }
        redacted = redacted.replaceAll(
          RegExp(RegExp.escape(d.family.name), caseSensitive: false),
          'the Family hisab',
        );
      }
    }

    final periodLabel = switch (query.period) {
      AiPeriod.today => l.aiTodayLabel,
      AiPeriod.thisYear => '${query.range.start.year}',
      _ => fmt.monthYear(query.range.start),
    };
    final range = query.range;
    final facts = <String, Object?>{
      'question_period': periodLabel,
      'currency': 'INR',
    };

    AiAnswer done(
      String text, {
      List<String> bullets = const [],
      bool suggestion = false,
      bool withPeriod = true,
      AiDraft? draft,
    }) => AiAnswer(
      text: text,
      bullets: bullets,
      periodLabel: withPeriod ? periodLabel : null,
      isSuggestion: suggestion,
      draft: draft,
      modelFacts: facts,
      redactedQuestion: redacted,
    );

    switch (query.intent) {
      case AiIntent.spend:
        final s = await _txns.watchSummary(range).first;
        final count =
            (await _txns
                    .watch(
                      TransactionFilter(
                        range: range,
                        type: TransactionType.expense,
                      ),
                    )
                    .first)
                .length;
        facts.addAll({
          'expense_total': fmt.money(s.expensePaise),
          'expense_entries': count,
        });
        return done(
          s.expensePaise == 0
              ? l.aiNoExpenses(periodLabel)
              : l.aiSpend(fmt.money(s.expensePaise), periodLabel, count),
        );

      case AiIntent.income:
        final s = await _txns.watchSummary(range).first;
        facts['income_total'] = fmt.money(s.incomePaise);
        return done(l.aiIncome(fmt.money(s.incomePaise), periodLabel));

      case AiIntent.savings:
        final s = await _txns.watchSummary(range).first;
        facts.addAll({
          'income_total': fmt.money(s.incomePaise),
          'expense_total': fmt.money(s.expensePaise),
          'savings': fmt.money(s.balancePaise),
        });
        return done(
          l.aiSavings(
            periodLabel,
            fmt.money(s.incomePaise),
            fmt.money(s.expensePaise),
            fmt.money(s.balancePaise),
          ),
        );

      case AiIntent.topCategory:
        final totals = await _txns
            .watchCategoryTotals(range, TransactionType.expense)
            .first;
        if (totals.isEmpty) return done(l.aiNoExpenses(periodLabel));
        final all = totals.fold<int>(0, (a, t) => a + t.totalPaise);
        final top = totals.first;
        final percent = ExportService.percentOf(top.totalPaise, all);
        facts.addAll({
          'top_category': top.category.label(l),
          'top_category_total': fmt.money(top.totalPaise),
          'share_percent': percent,
          'other_categories': [
            for (final t in totals.skip(1).take(4))
              {
                'category': t.category.label(l),
                'total': fmt.money(t.totalPaise),
              },
          ],
        });
        return done(
          l.aiTopCategory(
            periodLabel,
            top.category.label(l),
            fmt.money(top.totalPaise),
            percent,
          ),
        );

      case AiIntent.topExpenses:
        final items = await _txns
            .watch(
              TransactionFilter(range: range, type: TransactionType.expense),
            )
            .first;
        final top =
            ([...items]..sort(
                  (a, b) => b.txn.amountPaise.compareTo(a.txn.amountPaise),
                ))
                .take(5)
                .toList();
        if (top.isEmpty) return done(l.aiNoExpenses(periodLabel));
        // Descriptions and notes stay on the phone; the model sees amounts only.
        facts['top_expenses'] = [
          for (final t in top)
            {
              'category': t.category.label(l),
              'amount': fmt.money(t.txn.amountPaise),
              'date': fmt.date(t.txn.txnDate),
            },
        ];
        return done(
          l.aiTopExpensesIntro(periodLabel),
          bullets: [
            for (final t in top)
              '${fmt.money(t.txn.amountPaise)} · ${t.txn.description.isEmpty ? t.category.label(l) : t.txn.description} · ${fmt.date(t.txn.txnDate)}',
          ],
        );

      case AiIntent.compareMonths:
        final current = DateRange.forPreset(
          PeriodPreset.thisMonth,
          _clock.now(),
        );
        final previous = current.previous();
        final a = await _txns.watchSummary(current).first;
        final b = await _txns.watchSummary(previous).first;
        final diff = a.expensePaise - b.expensePaise;
        final change = diff == 0
            ? l.aiSame
            : diff > 0
            ? l.aiMore(fmt.money(diff))
            : l.aiLess(fmt.money(-diff));
        facts.addAll({
          'current_month': fmt.monthYear(current.start),
          'current_expense': fmt.money(a.expensePaise),
          'previous_month': fmt.monthYear(previous.start),
          'previous_expense': fmt.money(b.expensePaise),
          'difference': change,
        });
        return done(
          l.aiCompare(
            fmt.monthYear(current.start),
            fmt.money(a.expensePaise),
            fmt.monthYear(previous.start),
            fmt.money(b.expensePaise),
            change,
          ),
          withPeriod: false,
        );

      case AiIntent.reduceTips:
        final totals = await _txns
            .watchCategoryTotals(range, TransactionType.expense)
            .first;
        final s = await _txns.watchSummary(range).first;
        final items = await _txns
            .watch(
              TransactionFilter(range: range, type: TransactionType.expense),
            )
            .first;
        final small = items.where((t) => t.txn.amountPaise < 20000).toList();
        final bullets = <String>[];
        if (totals.isNotEmpty) {
          final all = totals.fold<int>(0, (a, t) => a + t.totalPaise);
          final top = totals.first;
          bullets.add(
            l.aiTipCategory(
              top.category.label(l),
              ExportService.percentOf(top.totalPaise, all),
              fmt.money(top.totalPaise),
            ),
          );
        }
        if (small.length >= 5) {
          bullets.add(
            l.aiTipFrequent(
              small.length,
              fmt.money(small.fold(0, (a, t) => a + t.txn.amountPaise)),
            ),
          );
        }
        if (s.expensePaise > s.incomePaise && s.incomePaise > 0) {
          bullets.add(l.aiTipSavings);
        }
        bullets.add(l.aiTipGeneral);
        facts.addAll({
          'expense_total': fmt.money(s.expensePaise),
          'income_total': fmt.money(s.incomePaise),
          'categories': [
            for (final t in totals.take(5))
              {
                'category': t.category.label(l),
                'total': fmt.money(t.totalPaise),
              },
          ],
          'small_expenses_count': small.length,
        });
        return done(
          l.aiTipsIntro(periodLabel),
          bullets: bullets,
          suggestion: true,
        );

      case AiIntent.receivables:
        final t = await _ledger.watchTotals().first;
        facts.addAll({
          'receivable': fmt.money(t.receivablePaise),
          'payable': fmt.money(t.payablePaise),
        });
        return done(
          l.aiReceivables(
            fmt.money(t.receivablePaise),
            fmt.money(t.payablePaise),
          ),
          withPeriod: false,
        );

      case AiIntent.personBalance:
        final person = people.firstWhere((p) => p.id == query.personId);
        final b = await _people.watchBalance(person.id).first;
        final name = person.name;
        facts.addAll({
          'person': personAlias(name),
          'they_owe_you': fmt.money(b.receivablePaise),
          'you_owe_them': fmt.money(b.payablePaise),
        });
        final text = b.netPaise > 0
            ? l.aiPersonOwesYou(name, fmt.money(b.netPaise))
            : b.netPaise < 0
            ? l.aiYouOwePerson(name, fmt.money(-b.netPaise))
            : l.aiPersonSettled(name);
        return done(text, withPeriod: false);

      case AiIntent.groupTotal:
      case AiIntent.whoOwesWhom:
        final d = await _groups.watchGroup(query.groupId!).first;
        if (d == null) return done(l.aiNoGroup, withPeriod: false);
        final name = d.group.name;
        if (query.intent == AiIntent.groupTotal) {
          final self = d.selfMember;
          final share = self == null
              ? 0
              : d.expenses.fold<int>(0, (a, e) => a + (e.splits[self.id] ?? 0));
          facts.addAll({
            'group': groupAlias(name),
            'total_spent': fmt.money(d.totalSpentPaise),
            'expense_count': d.expenses.length,
            'my_share': fmt.money(share),
          });
          return done(
            l.aiGroupTotal(
              name,
              fmt.money(d.totalSpentPaise),
              d.expenses.length,
              fmt.money(share),
            ),
            withPeriod: false,
          );
        }
        if (d.suggestions.isEmpty) {
          facts['group'] = groupAlias(name);
          return done(l.aiWhoOwesNone(name), withPeriod: false);
        }
        final bullets = [
          for (final s in d.suggestions)
            '${l.paysTo(d.memberName(s.from), d.memberName(s.to))}: ${fmt.money(s.amountPaise)}',
        ];
        facts.addAll({
          'group': groupAlias(name),
          'transfers': [
            for (final (i, s) in d.suggestions.indexed)
              {
                'from': shareNames
                    ? d.memberName(s.from)
                    : 'member ${i * 2 + 1}',
                'to': shareNames ? d.memberName(s.to) : 'member ${i * 2 + 2}',
                'amount': fmt.money(s.amountPaise),
              },
          ],
        });
        return done(
          l.aiWhoOwesIntro(name),
          bullets: bullets,
          withPeriod: false,
        );

      case AiIntent.familySpend:
      case AiIntent.familyPersonIn:
      case AiIntent.familyBalance:
        final d = familyDetails
            .where((x) => x.family.id == query.familyId)
            .firstOrNull;
        if (d == null) return done(l.aiHelp, withPeriod: false);
        final name = d.family.name;
        facts['family'] = shareNames ? name : 'the Family hisab';
        final inRange = [
          for (final e in d.entries)
            if (range.contains(e.date)) e,
        ];
        switch (query.intent) {
          case AiIntent.familySpend:
            final out = [
              for (final e in inRange)
                if (!e.kind.isMoneyIn &&
                    (query.categoryId == null ||
                        e.categoryId == query.categoryId))
                  e,
            ];
            final total = out.fold<int>(0, (a, e) => a + e.amountPaise);
            facts.addAll({
              'expense_total': fmt.money(total),
              'expense_entries': out.length,
            });
            if (query.categoryId == null) {
              return done(
                l.aiFamilySpend(
                  name,
                  fmt.money(total),
                  periodLabel,
                  out.length,
                ),
              );
            }
            final category =
                categories
                    .where((c) => c.id == query.categoryId)
                    .firstOrNull
                    ?.label(l) ??
                out.firstOrNull?.categoryLabel(l.localeName) ??
                '';
            facts['category'] = category;
            return done(
              l.aiFamilySpendCategory(
                name,
                fmt.money(total),
                category,
                periodLabel,
              ),
            );
          case AiIntent.familyPersonIn:
            final person = d.memberName(query.familyMemberId!, l);
            final total = inRange
                .where(
                  (e) => e.kind.isMoneyIn && e.memberId == query.familyMemberId,
                )
                .fold<int>(0, (a, e) => a + e.amountPaise);
            facts.addAll({
              'person': shareNames ? person : 'the person',
              'money_in': fmt.money(total),
            });
            return done(
              l.aiFamilyPersonIn(person, fmt.money(total), name, periodLabel),
            );
          default:
            var opening = d.family.openingBalancePaise;
            var moneyIn = 0;
            var moneyOut = 0;
            for (final e in d.entries) {
              if (e.date.isBefore(range.start)) {
                opening += e.signedPaise;
              } else if (range.contains(e.date)) {
                if (e.kind.isMoneyIn) {
                  moneyIn += e.amountPaise;
                } else {
                  moneyOut += e.amountPaise;
                }
              }
            }
            final closing = opening + moneyIn - moneyOut;
            facts.addAll({
              'opening_balance': fmt.money(opening),
              'money_in': fmt.money(moneyIn),
              'money_out': fmt.money(moneyOut),
              'closing_balance': fmt.money(closing),
            });
            return done(
              l.aiFamilyBalance(
                name,
                periodLabel,
                fmt.money(opening),
                fmt.money(moneyIn),
                fmt.money(moneyOut),
                fmt.money(closing),
              ),
            );
        }

      case AiIntent.draft:
        if (query.amountPaise == null) {
          return done(l.aiDraftNeedsAmount, withPeriod: false);
        }
        final category = query.categoryId == null
            ? null
            : categories.where((c) => c.id == query.categoryId).firstOrNull;
        final categoryText = category == null ? '' : ' (${category.label(l)})';
        final amount = fmt.money(query.amountPaise!);
        return done(
          query.draftType == TransactionType.income
              ? l.aiDraftIncome(amount, categoryText)
              : l.aiDraftExpense(amount, categoryText),
          withPeriod: false,
          draft: AiDraft(
            type: query.draftType!,
            amountPaise: query.amountPaise!,
            categoryId: query.categoryId,
          ),
        );

      case AiIntent.help:
        return done(l.aiHelp, withPeriod: false);
    }
  }
}
