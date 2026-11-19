/// Money helpers. Every monetary value in HisabMitra is an `int` number of
/// paise (1 rupee = 100 paise). Floating point is never used for money.
library;

enum MoneyGrouping {
  /// 12,34,567.89 — lakh / crore grouping used in India.
  indian,

  /// 1,234,567.89 — thousands grouping.
  international,
}

abstract final class Money {
  /// Upper bound accepted from user input: ₹99,99,99,999.99 (just under 100 crore).
  static const int maxPaise = 99999999999;

  static const String rupeeSymbol = '₹';

  /// Formats [paise] for display, e.g. `₹1,23,456.78`.
  ///
  /// * [symbol] — prefix with ₹.
  /// * [compactPaise] — drop `.00` when the paise part is zero.
  /// * [signed] — prefix positive values with `+`.
  static String format(
    int paise, {
    bool symbol = true,
    bool compactPaise = false,
    bool signed = false,
    MoneyGrouping grouping = MoneyGrouping.indian,
  }) {
    final negative = paise < 0;
    final abs = paise.abs();
    final rupees = abs ~/ 100;
    final fraction = abs % 100;

    final grouped = _group(rupees.toString(), grouping);
    final buffer = StringBuffer();
    if (negative) {
      buffer.write('-');
    } else if (signed && paise > 0) {
      buffer.write('+');
    }
    if (symbol) buffer.write(rupeeSymbol);
    buffer.write(grouped);
    if (!(compactPaise && fraction == 0)) {
      buffer
        ..write('.')
        ..write(fraction.toString().padLeft(2, '0'));
    }
    return buffer.toString();
  }

  /// Short label for chart axes: ₹950, ₹12.5k, ₹3.2L, ₹1.1Cr (Indian units).
  /// Display only — truncates to one decimal using integer arithmetic.
  static String compact(int paise) {
    final negative = paise < 0;
    final rupees = paise.abs() ~/ 100;
    String scaled(int unit, String suffix) {
      final whole = rupees ~/ unit;
      final tenth = (rupees % unit) * 10 ~/ unit;
      return tenth == 0 || whole >= 100
          ? '$whole$suffix'
          : '$whole.$tenth$suffix';
    }

    final body = rupees >= 10000000
        ? scaled(10000000, 'Cr')
        : rupees >= 100000
        ? scaled(100000, 'L')
        : rupees >= 1000
        ? scaled(1000, 'k')
        : '$rupees';
    return '${negative ? '-' : ''}$rupeeSymbol$body';
  }

  /// Plain editable text for a form field: `1234.50`, `1`, `0.05`.
  static String toEditable(int paise) {
    final negative = paise < 0;
    final abs = paise.abs();
    final rupees = abs ~/ 100;
    final fraction = abs % 100;
    final sign = negative ? '-' : '';
    if (fraction == 0) return '$sign$rupees';
    return '$sign$rupees.${fraction.toString().padLeft(2, '0')}';
  }

  /// Parses user text into paise. Returns `null` for invalid, negative,
  /// over-precise (more than 2 decimals) or out-of-range input.
  ///
  /// Accepts grouping commas, spaces, a leading ₹ and Gujarati digits.
  static int? tryParse(String input) {
    var text = _normaliseDigits(input)
        .replaceAll(rupeeSymbol, '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    if (text.isEmpty) return null;
    if (text.startsWith('+')) text = text.substring(1);

    final parts = text.split('.');
    if (parts.length > 2) return null;
    final whole = parts[0];
    final frac = parts.length == 2 ? parts[1] : '';
    if (whole.isEmpty && frac.isEmpty) return null;
    if (!_isDigits(whole) || !_isDigits(frac)) return null;
    if (frac.length > 2) return null;
    // Guard against absurdly long input before integer parsing.
    if (whole.length > 12) return null;

    final rupees = whole.isEmpty ? 0 : int.parse(whole);
    final paisePart = frac.isEmpty ? 0 : int.parse(frac.padRight(2, '0'));
    final value = rupees * 100 + paisePart;
    if (value > maxPaise) return null;
    return value;
  }

  static bool _isDigits(String s) {
    for (final unit in s.codeUnits) {
      if (unit < 0x30 || unit > 0x39) return false;
    }
    return true;
  }

  /// Converts Gujarati (U+0AE6–U+0AEF) and Devanagari (U+0966–U+096F) digits
  /// to ASCII so users can type amounts with any keyboard.
  static String _normaliseDigits(String input) {
    final out = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x0AE6 && rune <= 0x0AEF) {
        out.writeCharCode(0x30 + rune - 0x0AE6);
      } else if (rune >= 0x0966 && rune <= 0x096F) {
        out.writeCharCode(0x30 + rune - 0x0966);
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }

  static String _group(String digits, MoneyGrouping grouping) {
    if (digits.length <= 3) return digits;
    final last3 = digits.substring(digits.length - 3);
    var rest = digits.substring(0, digits.length - 3);
    final groupSize = grouping == MoneyGrouping.indian ? 2 : 3;
    final groups = <String>[];
    while (rest.length > groupSize) {
      groups.insert(0, rest.substring(rest.length - groupSize));
      rest = rest.substring(0, rest.length - groupSize);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '${groups.join(',')},$last3';
  }
}
