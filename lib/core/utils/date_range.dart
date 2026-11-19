import 'package:flutter/foundation.dart';

enum PeriodPreset { thisMonth, lastMonth, thisYear, custom }

/// Half-open local-date interval `[start, endExclusive)`.
@immutable
class DateRange {
  const DateRange(this.start, this.endExclusive);

  final DateTime start;
  final DateTime endExclusive;

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  factory DateRange.month(int year, int month) =>
      DateRange(DateTime(year, month), DateTime(year, month + 1));

  factory DateRange.forPreset(PeriodPreset preset, DateTime now) {
    switch (preset) {
      case PeriodPreset.thisMonth:
      case PeriodPreset.custom:
        return DateRange.month(now.year, now.month);
      case PeriodPreset.lastMonth:
        return DateRange.month(now.year, now.month - 1);
      case PeriodPreset.thisYear:
        return DateRange(DateTime(now.year), DateTime(now.year + 1));
    }
  }

  /// Inclusive calendar dates [from]..[to] (order-insensitive).
  factory DateRange.custom(DateTime from, DateTime to) {
    var a = dateOnly(from);
    var b = dateOnly(to);
    if (b.isBefore(a)) (a, b) = (b, a);
    return DateRange(a, DateTime(b.year, b.month, b.day + 1));
  }

  /// [count] consecutive month buckets ending with the month of [now].
  static List<DateRange> lastMonths(DateTime now, int count) => [
    for (var i = count - 1; i >= 0; i--)
      DateRange.month(now.year, now.month - i),
  ];

  /// Inclusive last calendar day.
  DateTime get endInclusive =>
      DateTime(endExclusive.year, endExclusive.month, endExclusive.day - 1);

  bool contains(DateTime d) => !d.isBefore(start) && d.isBefore(endExclusive);

  bool get isWholeMonth =>
      start.day == 1 && endExclusive == DateTime(start.year, start.month + 1);

  /// The period of the same shape immediately before this one.
  DateRange previous() {
    if (isWholeMonth) return DateRange.month(start.year, start.month - 1);
    if (start.month == 1 &&
        start.day == 1 &&
        endExclusive == DateTime(start.year + 1)) {
      return DateRange(DateTime(start.year - 1), start);
    }
    final days = endExclusive.difference(start).inDays;
    return DateRange(
      DateTime(start.year, start.month, start.day - days),
      start,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DateRange &&
      other.start == start &&
      other.endExclusive == endExclusive;

  @override
  int get hashCode => Object.hash(start, endExclusive);

  @override
  String toString() => 'DateRange($start – $endExclusive)';
}
