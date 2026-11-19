/// Exact calculator for amounts. Numbers are parsed into BigInt rationals,
/// so `0.1 + 0.2` is exactly `0.3`; rounding to paise (half away from zero)
/// happens once, on the final result.
library;

class Rational {
  factory Rational(BigInt numerator, BigInt denominator) {
    assert(denominator != BigInt.zero);
    final (n, d) = _norm(numerator, denominator);
    return Rational._(n, d);
  }

  const Rational._(this.num, this.den);

  factory Rational.fromInt(int v) => Rational(BigInt.from(v), BigInt.one);

  final BigInt num;
  final BigInt den;

  static (BigInt, BigInt) _norm(BigInt n, BigInt d) {
    if (d.isNegative) {
      n = -n;
      d = -d;
    }
    final g = n.gcd(d);
    if (g == BigInt.zero) return (BigInt.zero, BigInt.one);
    return (n ~/ g, d ~/ g);
  }

  /// Parses a non-negative decimal literal such as `12`, `12.5`, `.5`.
  static Rational? parseDecimal(String s) {
    if (!RegExp(r'^(\d+\.?\d*|\.\d+)$').hasMatch(s)) return null;
    final parts = s.split('.');
    final whole = parts[0].isEmpty ? '0' : parts[0];
    final frac = parts.length > 1 ? parts[1] : '';
    final n = BigInt.parse('$whole$frac');
    final d = BigInt.from(10).pow(frac.length);
    return Rational(n, d);
  }

  bool get isZero => num == BigInt.zero;

  Rational operator +(Rational o) =>
      Rational(num * o.den + o.num * den, den * o.den);
  Rational operator -(Rational o) =>
      Rational(num * o.den - o.num * den, den * o.den);
  Rational operator *(Rational o) => Rational(num * o.num, den * o.den);
  Rational operator /(Rational o) => Rational(num * o.den, den * o.num);
  Rational operator -() => Rational(-num, den);

  /// Rounds to the nearest integer, halves away from zero.
  BigInt roundHalfAwayFromZero() {
    final twice = num.abs() * BigInt.two;
    final rounded = (twice + den) ~/ (den * BigInt.two);
    return num.isNegative ? -rounded : rounded;
  }
}

abstract final class CalculatorEngine {
  static final _maxAbsPaise = BigInt.from(999999999999999);

  /// Evaluates [expression] (rupees) and returns paise, or `null` when the
  /// expression is incomplete/invalid or divides by zero.
  static int? evaluateToPaise(String expression) {
    final value = evaluate(expression);
    if (value == null) return null;
    final paise = (value * Rational.fromInt(100)).roundHalfAwayFromZero();
    if (paise.abs() > _maxAbsPaise) return null;
    return paise.toInt();
  }

  static Rational? evaluate(String expression) {
    final tokens = _tokenize(_normalise(expression));
    if (tokens == null || tokens.isEmpty) return null;
    final parser = _Parser(tokens);
    try {
      final result = parser.expression();
      if (!parser.atEnd) return null;
      return result;
    } on _CalcError {
      return null;
    }
  }

  /// Unit price (paise) × quantity (decimal text), rounded to paise.
  static int? unitTotal({
    required int unitPricePaise,
    required String quantity,
  }) {
    final q = Rational.parseDecimal(_normalise(quantity).trim());
    if (q == null || unitPricePaise < 0) return null;
    final total = (Rational.fromInt(unitPricePaise) * q)
        .roundHalfAwayFromZero();
    if (total.abs() > _maxAbsPaise) return null;
    return total.toInt();
  }

  static String _normalise(String s) {
    final out = StringBuffer();
    for (final rune in s.runes) {
      if (rune >= 0x0AE6 && rune <= 0x0AEF) {
        out.writeCharCode(0x30 + rune - 0x0AE6);
      } else if (rune == 0x2212) {
        out.write('-'); // minus sign
      } else if (rune != 0x20 && rune != 0x2C) {
        out.writeCharCode(rune); // drop spaces and grouping commas
      }
    }
    return out.toString();
  }

  static List<String>? _tokenize(String s) {
    final tokens = <String>[];
    var i = 0;
    while (i < s.length) {
      final c = s[i];
      if (RegExp(r'[0-9.]').hasMatch(c)) {
        final start = i;
        while (i < s.length && RegExp(r'[0-9.]').hasMatch(s[i])) {
          i++;
        }
        final literal = s.substring(start, i);
        if (Rational.parseDecimal(literal) == null) return null;
        tokens.add(literal);
        continue;
      }
      switch (c) {
        case '+' || '-' || '(' || ')' || '%':
          tokens.add(c);
        case '×' || '*' || 'x':
          tokens.add('×');
        case '÷' || '/':
          tokens.add('÷');
        default:
          return null;
      }
      i++;
    }
    return tokens;
  }
}

class _CalcError implements Exception {}

class _Parser {
  _Parser(this.tokens);

  final List<String> tokens;
  var _pos = 0;

  bool get atEnd => _pos >= tokens.length;
  String? get _peek => atEnd ? null : tokens[_pos];

  String _take() {
    if (atEnd) throw _CalcError();
    return tokens[_pos++];
  }

  Rational expression() {
    var value = term();
    while (_peek == '+' || _peek == '-') {
      final op = _take();
      final rhs = term();
      value = op == '+' ? value + rhs : value - rhs;
    }
    return value;
  }

  Rational term() {
    var value = factor();
    while (_peek == '×' || _peek == '÷') {
      final op = _take();
      final rhs = factor();
      if (op == '÷') {
        if (rhs.isZero) throw _CalcError();
        value = value / rhs;
      } else {
        value = value * rhs;
      }
    }
    return value;
  }

  Rational factor() {
    if (_peek == '-') {
      _take();
      return -factor();
    }
    if (_peek == '+') {
      _take();
      return factor();
    }
    var value = primary();
    while (_peek == '%') {
      _take();
      value = value / Rational.fromInt(100);
    }
    return value;
  }

  Rational primary() {
    final token = _take();
    if (token == '(') {
      final value = expression();
      if (_take() != ')') throw _CalcError();
      return value;
    }
    final number = Rational.parseDecimal(token);
    if (number == null) throw _CalcError();
    return number;
  }
}
