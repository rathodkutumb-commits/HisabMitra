import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/utils/date_range.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/family/domain/passbook.dart';

void main() {
  const start = 1200000; // ₹12,000 already in the home
  const order = ['you', 'rahul'];

  FamilyEntry e(
    String id,
    String member,
    FamilyEntryKind kind,
    int paise,
    DateTime date,
  ) => FamilyEntry(
    id: id,
    memberId: member,
    kind: kind,
    amountPaise: paise,
    date: date,
    categoryId: kind == FamilyEntryKind.expense ? 'cat_rent' : null,
    categoryName: kind == FamilyEntryKind.expense ? 'Rent' : null,
  );

  final november = [
    e('1', 'you', FamilyEntryKind.salary, 6000000, DateTime(2026, 11, 1)),
    e('2', 'rahul', FamilyEntryKind.salary, 3500000, DateTime(2026, 11, 1)),
    e('3', 'you', FamilyEntryKind.extraIncome, 500000, DateTime(2026, 11, 10)),
    e(
      '4',
      'rahul',
      FamilyEntryKind.contribution,
      1000000,
      DateTime(2026, 11, 12),
    ),
    e('5', 'you', FamilyEntryKind.expense, 5200000, DateTime(2026, 11, 5)),
    e('6', 'rahul', FamilyEntryKind.expense, 2650000, DateTime(2026, 11, 20)),
  ];

  MonthStatement month(List<FamilyEntry> entries, int y, int m) =>
      passbookMonth(
        startingBalancePaise: start,
        entries: entries,
        memberOrder: order,
        year: y,
        month: m,
      );

  test('the first month opens with the starting balance', () {
    final s = month(november, 2026, 11);
    expect(s.openingPaise, 1200000);
    expect(s.moneyInPaise, 11000000);
    expect(s.moneyOutPaise, 7850000);
    expect(s.closingPaise, 4350000);
    expect(
      [for (final p in s.byPerson) (p.memberId, p.moneyInPaise, p.paidPaise)],
      [('you', 6500000, 5200000), ('rahul', 4500000, 2650000)],
    );
    expect(
      s.entries.first.date,
      DateTime(2026, 11, 20),
      reason: 'newest first',
    );
  });

  test("December opens with November's closing", () {
    final s = month(
      [
        ...november,
        e('7', 'you', FamilyEntryKind.expense, 100000, DateTime(2026, 12, 3)),
      ],
      2026,
      12,
    );
    expect(s.openingPaise, 4350000);
    expect(s.closingPaise, 4250000);
  });

  test('an empty month carries the balance', () {
    final s = month(
      [
        ...november,
        e('7', 'you', FamilyEntryKind.expense, 100000, DateTime(2026, 12, 3)),
      ],
      2027,
      1,
    );
    expect(s.openingPaise, 4250000);
    expect(s.closingPaise, 4250000);
    expect(s.entries, isEmpty);
    expect(s.byPerson, isEmpty);
  });

  test(
    'moving an entry to another month changes both and every later month',
    () {
      final moved = [
        for (final x in november)
          x.id == '5' ? x.copyWith(date: DateTime(2026, 10, 15)) : x,
      ];
      final oct = month(moved, 2026, 10);
      expect(
        (oct.openingPaise, oct.moneyInPaise, oct.moneyOutPaise),
        (1200000, 0, 5200000),
      );
      expect(oct.closingPaise, -4000000);
      final nov = month(moved, 2026, 11);
      expect(
        (nov.openingPaise, nov.moneyInPaise, nov.moneyOutPaise),
        (-4000000, 11000000, 2650000),
      );
      expect(nov.closingPaise, 4350000);
      expect(month(moved, 2026, 12).openingPaise, 4350000);
    },
  );

  test('entries before every other entry still add up', () {
    final early = [
      e('0', 'you', FamilyEntryKind.contribution, 300000, DateTime(2025, 1, 1)),
      ...november,
    ];
    expect(month(early, 2026, 11).openingPaise, 1500000);
    expect(month(early, 2026, 11).closingPaise, 4650000);
  });

  test("a removed person's entries still count", () {
    final s = month(
      [
        ...november,
        e(
          '8',
          'priya',
          FamilyEntryKind.contribution,
          200000,
          DateTime(2026, 11, 25),
        ),
      ],
      2026,
      11,
    );
    expect(s.moneyInPaise, 11200000);
    expect(s.byPerson.last.memberId, 'priya');
  });

  test('month totals and period summaries match the statements', () {
    final all = [
      ...november,
      e('7', 'you', FamilyEntryKind.expense, 100000, DateTime(2026, 12, 3)),
    ];
    final totals = familyMonthlyTotals(
      all,
      from: DateTime(2026, 10),
      months: 3,
    );
    expect(
      [
        for (final t in totals)
          (t.month.start.month, t.incomePaise, t.expensePaise),
      ],
      [(10, 0, 0), (11, 11000000, 7850000), (12, 0, 100000)],
    );
    final summary = familyPeriodSummary(
      all,
      DateRange(DateTime(2026, 11), DateTime(2027)),
    );
    expect((summary.incomePaise, summary.expensePaise), (11000000, 7950000));
  });

  test('kinds know whether they are money in', () {
    expect(FamilyEntryKind.salary.isMoneyIn, isTrue);
    expect(FamilyEntryKind.contribution.isMoneyIn, isTrue);
    expect(FamilyEntryKind.expense.isMoneyIn, isFalse);
    expect(
      FamilyEntryKind.fromWire('extra_income'),
      FamilyEntryKind.extraIncome,
    );
    expect(FamilyEntryKind.extraIncome.wire, 'extra_income');
  });
}
