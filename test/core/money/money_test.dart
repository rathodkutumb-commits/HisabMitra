import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/money/money.dart';

void main() {
  group('Money.format (Indian grouping)', () {
    test('formats zero', () {
      expect(Money.format(0), '₹0.00');
    });

    test('formats paise below one rupee', () {
      expect(Money.format(5), '₹0.05');
      expect(Money.format(99), '₹0.99');
    });

    test('uses Indian lakh/crore grouping', () {
      expect(Money.format(100000), '₹1,000.00');
      expect(Money.format(12345678), '₹1,23,456.78');
      expect(Money.format(1234567890), '₹1,23,45,678.90');
    });

    test('formats negatives with leading minus', () {
      expect(Money.format(-150050), '-₹1,500.50');
    });

    test('international grouping', () {
      expect(
        Money.format(1234567890, grouping: MoneyGrouping.international),
        '₹12,345,678.90',
      );
    });

    test('can omit symbol and trailing zero paise', () {
      expect(Money.format(250000, symbol: false), '2,500.00');
      expect(Money.format(250000, compactPaise: true), '₹2,500');
      expect(Money.format(250050, compactPaise: true), '₹2,500.50');
    });

    test('signed adds plus for positive values', () {
      expect(Money.format(1000, signed: true), '+₹10.00');
      expect(Money.format(-1000, signed: true), '-₹10.00');
      expect(Money.format(0, signed: true), '₹0.00');
    });
  });

  group('Money.compact', () {
    test('uses Indian units for chart labels', () {
      expect(Money.compact(95000), '₹950');
      expect(Money.compact(1250000), '₹12.5k');
      expect(Money.compact(32000000), '₹3.2L');
      expect(Money.compact(1100000000), '₹1.1Cr');
      expect(Money.compact(-200000), '-₹2k');
    });
  });

  group('Money.toEditable', () {
    test('produces plain text for form fields', () {
      expect(Money.toEditable(123450), '1234.50');
      expect(Money.toEditable(100), '1');
      expect(Money.toEditable(5), '0.05');
      expect(Money.toEditable(0), '0');
    });
  });

  group('Money.tryParse', () {
    test('parses whole rupees', () {
      expect(Money.tryParse('10'), 1000);
    });

    test('parses one and two decimal places exactly', () {
      expect(Money.tryParse('10.5'), 1050);
      expect(Money.tryParse('10.25'), 1025);
      expect(Money.tryParse('0.05'), 5);
      expect(Money.tryParse('.5'), 50);
    });

    test('ignores grouping commas, spaces and rupee symbol', () {
      expect(Money.tryParse('1,23,456.78'), 12345678);
      expect(Money.tryParse(' ₹ 1,000 '), 100000);
    });

    test('accepts Gujarati digits', () {
      expect(Money.tryParse('૧૨૫.૫૦'), 12550);
    });

    test('rejects more than two decimals', () {
      expect(Money.tryParse('1.234'), isNull);
    });

    test('rejects garbage, empty and negative input', () {
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse('1.2.3'), isNull);
      expect(Money.tryParse('-5'), isNull);
      expect(Money.tryParse('.'), isNull);
    });

    test('rejects values above the maximum', () {
      expect(Money.tryParse('1000000000000'), isNull);
      expect(Money.tryParse('999999999.99'), 99999999999);
    });

    test('does not lose precision on values floats cannot represent', () {
      // 0.1 + 0.2 style issues must not appear.
      expect(Money.tryParse('0.29'), 29);
      expect(Money.tryParse('1.15'), 115);
      expect(Money.tryParse('8.20'), 820);
    });
  });
}
