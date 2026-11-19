import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/domain/enums.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';

Map<String, int> _ok(SplitOutcome outcome) {
  expect(outcome, isA<SplitSuccess>(), reason: '$outcome');
  return (outcome as SplitSuccess).shares;
}

SplitError _err(SplitOutcome outcome) {
  expect(outcome, isA<SplitFailure>(), reason: '$outcome');
  return (outcome as SplitFailure).error;
}

List<SplitParticipant> _p(Map<String, int> inputs) => [
  for (final e in inputs.entries) SplitParticipant(e.key, e.value),
];

void main() {
  group('equal split', () {
    test('₹1,000 among 4 gives ₹250 each', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 100000,
          method: SplitMethod.equal,
          participants: _p({'A': 0, 'B': 0, 'C': 0, 'D': 0}),
        ),
      );
      expect(shares, {'A': 25000, 'B': 25000, 'C': 25000, 'D': 25000});
    });

    test('remainder paise go to the first participants in order', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 1000,
          method: SplitMethod.equal,
          participants: _p({'A': 0, 'B': 0, 'C': 0}),
        ),
      );
      expect(shares, {'A': 334, 'B': 333, 'C': 333});
    });

    test('selected participants only: unselected members get nothing', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 90000,
          method: SplitMethod.equal,
          participants: _p({'B': 0, 'D': 0}),
        ),
      );
      expect(shares, {'B': 45000, 'D': 45000});
    });
  });

  group('exact split', () {
    test('accepts amounts that add up to the total', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 1000,
          method: SplitMethod.exact,
          participants: _p({'A': 600, 'B': 400}),
        ),
      );
      expect(shares, {'A': 600, 'B': 400});
    });

    test('rejects amounts that do not reconcile, reporting the difference', () {
      final error = _err(
        SplitCalculator.calculate(
          totalPaise: 1000,
          method: SplitMethod.exact,
          participants: _p({'A': 600, 'B': 300}),
        ),
      );
      expect(error, isA<SplitExactMismatch>());
      expect((error as SplitExactMismatch).differencePaise, -100);
    });
  });

  group('percentage split (basis points)', () {
    test('50/30/20 of ₹1,000', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 100000,
          method: SplitMethod.percentage,
          participants: _p({'A': 5000, 'B': 3000, 'C': 2000}),
        ),
      );
      expect(shares, {'A': 50000, 'B': 30000, 'C': 20000});
    });

    test('33.33/33.33/33.34 of ₹100 reconciles exactly', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 10000,
          method: SplitMethod.percentage,
          participants: _p({'A': 3333, 'B': 3333, 'C': 3334}),
        ),
      );
      expect(shares.values.reduce((a, b) => a + b), 10000);
      expect(shares, {'A': 3333, 'B': 3333, 'C': 3334});
    });

    test('remainder goes to the largest fractional part first', () {
      // ₹0.10 split 33.33/33.33/33.34 → raw 3.333, 3.333, 3.334 paise.
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 10,
          method: SplitMethod.percentage,
          participants: _p({'A': 3333, 'B': 3333, 'C': 3334}),
        ),
      );
      expect(shares, {'A': 3, 'B': 3, 'C': 4});
    });

    test('rejects percentages that do not total 100%', () {
      final error = _err(
        SplitCalculator.calculate(
          totalPaise: 1000,
          method: SplitMethod.percentage,
          participants: _p({'A': 5000, 'B': 4000}),
        ),
      );
      expect(error, isA<SplitPercentageInvalid>());
      expect((error as SplitPercentageInvalid).totalBasisPoints, 9000);
    });
  });

  group('ratio split', () {
    test('2:1:1 of ₹1,000', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 100000,
          method: SplitMethod.ratio,
          participants: _p({'A': 2, 'B': 1, 'C': 1}),
        ),
      );
      expect(shares, {'A': 50000, 'B': 25000, 'C': 25000});
    });

    test('1:1:1 of ₹1.00 reconciles with deterministic remainder', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 100,
          method: SplitMethod.ratio,
          participants: _p({'A': 1, 'B': 1, 'C': 1}),
        ),
      );
      expect(shares, {'A': 34, 'B': 33, 'C': 33});
    });

    test('rejects all-zero weights', () {
      expect(
        _err(
          SplitCalculator.calculate(
            totalPaise: 100,
            method: SplitMethod.ratio,
            participants: _p({'A': 0, 'B': 0}),
          ),
        ),
        isA<SplitZeroWeights>(),
      );
    });
  });

  group('adjustment (unequal) split', () {
    test('equal split of the remainder plus individual adjustments', () {
      // ₹1,000: A had an extra ₹100 item; the rest (₹900) is split equally.
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 100000,
          method: SplitMethod.adjustment,
          participants: _p({'A': 10000, 'B': 0, 'C': 0}),
        ),
      );
      expect(shares, {'A': 40000, 'B': 30000, 'C': 30000});
    });

    test('negative adjustments are allowed when shares stay non-negative', () {
      final shares = _ok(
        SplitCalculator.calculate(
          totalPaise: 30000,
          method: SplitMethod.adjustment,
          participants: _p({'A': -3000, 'B': 0, 'C': 0}),
        ),
      );
      expect(shares, {'A': 8000, 'B': 11000, 'C': 11000});
    });

    test('rejects adjustments larger than the total', () {
      expect(
        _err(
          SplitCalculator.calculate(
            totalPaise: 1000,
            method: SplitMethod.adjustment,
            participants: _p({'A': 2000, 'B': 0}),
          ),
        ),
        isA<SplitAdjustmentsExceedTotal>(),
      );
    });

    test('rejects adjustments that make a share negative', () {
      expect(
        _err(
          SplitCalculator.calculate(
            totalPaise: 1000,
            method: SplitMethod.adjustment,
            participants: _p({'A': -2000, 'B': 0}),
          ),
        ),
        isA<SplitNegativeShare>(),
      );
    });
  });

  group('validation', () {
    test('rejects zero or negative totals', () {
      expect(
        _err(
          SplitCalculator.calculate(
            totalPaise: 0,
            method: SplitMethod.equal,
            participants: _p({'A': 0}),
          ),
        ),
        isA<SplitInvalidTotal>(),
      );
    });

    test('rejects an empty participant list', () {
      expect(
        _err(
          SplitCalculator.calculate(
            totalPaise: 100,
            method: SplitMethod.equal,
            participants: const [],
          ),
        ),
        isA<SplitNoParticipants>(),
      );
    });

    test('rejects duplicate participants', () {
      expect(
        _err(
          SplitCalculator.calculate(
            totalPaise: 100,
            method: SplitMethod.equal,
            participants: const [
              SplitParticipant('A', 0),
              SplitParticipant('A', 0),
            ],
          ),
        ),
        isA<SplitDuplicateParticipant>(),
      );
    });

    test('rejects negative inputs for exact, percentage and ratio', () {
      for (final method in [
        SplitMethod.exact,
        SplitMethod.percentage,
        SplitMethod.ratio,
      ]) {
        expect(
          _err(
            SplitCalculator.calculate(
              totalPaise: 100,
              method: method,
              participants: _p({'A': -1, 'B': 101}),
            ),
          ),
          isA<SplitNegativeInput>(),
          reason: method.name,
        );
      }
    });
  });

  test('property: every successful split reconciles to the total', () {
    final random = Random(42);
    for (var i = 0; i < 2000; i++) {
      final n = 1 + random.nextInt(9);
      final total = 1 + random.nextInt(10000000);
      final method =
          SplitMethod.values[random.nextInt(SplitMethod.values.length)];
      final participants = <SplitParticipant>[];
      if (method == SplitMethod.percentage) {
        var remaining = 10000;
        for (var k = 0; k < n; k++) {
          final bp = k == n - 1 ? remaining : random.nextInt(remaining + 1);
          remaining -= bp;
          participants.add(SplitParticipant('m$k', bp));
        }
      } else if (method == SplitMethod.exact) {
        var remaining = total;
        for (var k = 0; k < n; k++) {
          final v = k == n - 1 ? remaining : random.nextInt(remaining + 1);
          remaining -= v;
          participants.add(SplitParticipant('m$k', v));
        }
      } else {
        for (var k = 0; k < n; k++) {
          participants.add(SplitParticipant('m$k', random.nextInt(5)));
        }
        if (method == SplitMethod.ratio &&
            participants.every((p) => p.input == 0)) {
          participants[0] = const SplitParticipant('m0', 1);
        }
        if (method == SplitMethod.adjustment) {
          participants
            ..clear()
            ..addAll([for (var k = 0; k < n; k++) SplitParticipant('m$k', 0)]);
        }
      }
      final outcome = SplitCalculator.calculate(
        totalPaise: total,
        method: method,
        participants: participants,
      );
      final shares = _ok(outcome);
      expect(shares.values.fold<int>(0, (a, b) => a + b), total);
      expect(shares.values.every((v) => v >= 0), isTrue);
      expect(
        shares.keys.toList(),
        participants.map((p) => p.memberId).toList(),
      );
    }
  });
}
