import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/settlements/domain/group_balance_calculator.dart';

void main() {
  const members = ['A', 'B', 'C', 'D'];

  group('net balances', () {
    test('payer is owed everyone else\'s share', () {
      final net = GroupBalanceCalculator.netBalances(
        memberIds: members,
        expenses: const [
          BalanceExpense(
            paidBy: 'A',
            amountPaise: 100000,
            shares: {'A': 25000, 'B': 25000, 'C': 25000, 'D': 25000},
          ),
        ],
        settlements: const [],
      );
      expect(net, {'A': 75000, 'B': -25000, 'C': -25000, 'D': -25000});
    });

    test('settlements move balances toward zero', () {
      final net = GroupBalanceCalculator.netBalances(
        memberIds: members,
        expenses: const [
          BalanceExpense(
            paidBy: 'A',
            amountPaise: 100000,
            shares: {'A': 25000, 'B': 25000, 'C': 25000, 'D': 25000},
          ),
        ],
        settlements: const [
          BalanceSettlement(from: 'B', to: 'A', amountPaise: 25000),
          BalanceSettlement(from: 'C', to: 'A', amountPaise: 10000),
        ],
      );
      expect(net, {'A': 40000, 'B': 0, 'C': -15000, 'D': -25000});
    });

    test('members without activity have zero balance', () {
      final net = GroupBalanceCalculator.netBalances(
        memberIds: members,
        expenses: const [],
        settlements: const [],
      );
      expect(net, {'A': 0, 'B': 0, 'C': 0, 'D': 0});
    });

    test('totals summary reports paid and owed per member', () {
      final totals = GroupBalanceCalculator.memberTotals(
        memberIds: const ['A', 'B'],
        expenses: const [
          BalanceExpense(
            paidBy: 'A',
            amountPaise: 1000,
            shares: {'A': 500, 'B': 500},
          ),
          BalanceExpense(paidBy: 'B', amountPaise: 300, shares: {'B': 300}),
        ],
      );
      expect(totals['A']!.paidPaise, 1000);
      expect(totals['A']!.owedPaise, 500);
      expect(totals['B']!.paidPaise, 300);
      expect(totals['B']!.owedPaise, 800);
    });
  });

  group('settlement suggestions', () {
    test('single creditor is paid by each debtor', () {
      final suggestions = GroupBalanceCalculator.suggestSettlements({
        'A': 75000,
        'B': -25000,
        'C': -25000,
        'D': -25000,
      });
      expect(suggestions, const [
        SuggestedTransfer(from: 'B', to: 'A', amountPaise: 25000),
        SuggestedTransfer(from: 'C', to: 'A', amountPaise: 25000),
        SuggestedTransfer(from: 'D', to: 'A', amountPaise: 25000),
      ]);
    });

    test('largest debtor pays largest creditor first', () {
      final suggestions = GroupBalanceCalculator.suggestSettlements({
        'A': 5000,
        'B': 3000,
        'C': -6000,
        'D': -2000,
      });
      expect(suggestions, const [
        SuggestedTransfer(from: 'C', to: 'A', amountPaise: 5000),
        SuggestedTransfer(from: 'D', to: 'B', amountPaise: 2000),
        SuggestedTransfer(from: 'C', to: 'B', amountPaise: 1000),
      ]);
    });

    test('settled group needs no transfers', () {
      expect(
        GroupBalanceCalculator.suggestSettlements({'A': 0, 'B': 0}),
        isEmpty,
      );
    });

    test('is independent of map iteration order', () {
      final a = GroupBalanceCalculator.suggestSettlements({
        'A': 1000,
        'B': 1000,
        'C': -1000,
        'D': -1000,
      });
      final b = GroupBalanceCalculator.suggestSettlements({
        'D': -1000,
        'C': -1000,
        'B': 1000,
        'A': 1000,
      });
      expect(a, b);
    });

    test('throws if balances do not sum to zero', () {
      expect(
        () => GroupBalanceCalculator.suggestSettlements({'A': 100, 'B': -50}),
        throwsArgumentError,
      );
    });

    test('property: applying suggestions settles everyone', () {
      final random = Random(7);
      for (var i = 0; i < 1000; i++) {
        final n = 2 + random.nextInt(8);
        final net = <String, int>{};
        var sum = 0;
        for (var k = 0; k < n - 1; k++) {
          final v = random.nextInt(200001) - 100000;
          net['m$k'] = v;
          sum += v;
        }
        net['m${n - 1}'] = -sum;
        final transfers = GroupBalanceCalculator.suggestSettlements(net);
        expect(transfers.length, lessThanOrEqualTo(n - 1));
        final after = Map<String, int>.from(net);
        for (final t in transfers) {
          expect(t.amountPaise, greaterThan(0));
          after[t.from] = after[t.from]! + t.amountPaise;
          after[t.to] = after[t.to]! - t.amountPaise;
        }
        expect(after.values.every((v) => v == 0), isTrue);
      }
    });
  });
}
