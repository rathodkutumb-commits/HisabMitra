import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/calculator/domain/calculator_engine.dart';

int? eval(String expr) => CalculatorEngine.evaluateToPaise(expr);

void main() {
  group('evaluateToPaise', () {
    test('basic arithmetic', () {
      expect(eval('2+3'), 500);
      expect(eval('10-4.5'), 550);
      expect(eval('125×4'), 50000);
      expect(eval('100÷4'), 2500);
      expect(eval('125*4'), 50000);
      expect(eval('100/8'), 1250);
    });

    test('operator precedence and parentheses', () {
      expect(eval('2+3×4'), 1400);
      expect(eval('(2+3)×4'), 2000);
      expect(eval('10-2-3'), 500);
      expect(eval('100÷5÷2'), 1000);
    });

    test('exact decimal arithmetic (no float drift)', () {
      expect(eval('0.1+0.2'), 30);
      expect(eval('1.15×100'), 11500);
      expect(eval('19.99×3'), 5997);
    });

    test('rounds the final result half-up to paise', () {
      expect(eval('100÷3'), 3333); // 33.333…
      expect(eval('200÷3'), 6667); // 66.666…
      expect(eval('0.125'), 13); // 0.125 → 0.13
    });

    test('unary minus', () {
      expect(eval('-5+10'), 500);
      expect(eval('10×-2'), -2000);
    });

    test('percent of the previous term', () {
      expect(eval('200×10%'), 2000);
      expect(eval('50%'), 50);
    });

    test('invalid expressions return null', () {
      expect(eval(''), isNull);
      expect(eval('2+'), isNull);
      expect(eval('(2+3'), isNull);
      expect(eval('5÷0'), isNull);
      expect(eval('1..2'), isNull);
      expect(eval('abc'), isNull);
    });
  });

  group('unit price × quantity', () {
    test('multiplies exactly', () {
      expect(
        CalculatorEngine.unitTotal(unitPricePaise: 12500, quantity: '4'),
        50000,
      );
      expect(
        CalculatorEngine.unitTotal(unitPricePaise: 4999, quantity: '2.5'),
        12498,
      ); // 124.975 → 124.98
    });

    test('rejects invalid quantity', () {
      expect(
        CalculatorEngine.unitTotal(unitPricePaise: 100, quantity: ''),
        isNull,
      );
      expect(
        CalculatorEngine.unitTotal(unitPricePaise: 100, quantity: '-1'),
        isNull,
      );
      expect(
        CalculatorEngine.unitTotal(unitPricePaise: 100, quantity: 'x'),
        isNull,
      );
    });
  });
}
