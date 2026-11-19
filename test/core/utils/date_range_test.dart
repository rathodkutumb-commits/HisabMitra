import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/utils/date_range.dart';

void main() {
  final now = DateTime(2026, 1, 15, 18, 30);

  test('this month spans the 1st to the 1st of next month (exclusive)', () {
    final r = DateRange.forPreset(PeriodPreset.thisMonth, now);
    expect(r.start, DateTime(2026, 1, 1));
    expect(r.endExclusive, DateTime(2026, 2, 1));
  });

  test('last month rolls back across the year boundary', () {
    final r = DateRange.forPreset(PeriodPreset.lastMonth, now);
    expect(r.start, DateTime(2025, 12, 1));
    expect(r.endExclusive, DateTime(2026, 1, 1));
  });

  test('this year covers Jan 1 to next Jan 1', () {
    final r = DateRange.forPreset(PeriodPreset.thisYear, now);
    expect(r.start, DateTime(2026, 1, 1));
    expect(r.endExclusive, DateTime(2027, 1, 1));
  });

  test('custom range includes the whole end day', () {
    final r = DateRange.custom(
      DateTime(2026, 3, 10, 9),
      DateTime(2026, 3, 12, 8),
    );
    expect(r.start, DateTime(2026, 3, 10));
    expect(r.endExclusive, DateTime(2026, 3, 13));
    expect(r.contains(DateTime(2026, 3, 12, 23, 59)), isTrue);
    expect(r.contains(DateTime(2026, 3, 13)), isFalse);
  });

  test('custom range swaps reversed dates', () {
    final r = DateRange.custom(DateTime(2026, 3, 12), DateTime(2026, 3, 10));
    expect(r.start, DateTime(2026, 3, 10));
    expect(r.endExclusive, DateTime(2026, 3, 13));
  });

  test('previous period of a month is the previous month', () {
    final r = DateRange.forPreset(
      PeriodPreset.thisMonth,
      DateTime(2026, 3, 31),
    );
    final prev = r.previous();
    expect(prev.start, DateTime(2026, 2, 1));
    expect(prev.endExclusive, DateTime(2026, 3, 1));
  });

  test('lastMonths returns consecutive month buckets ending this month', () {
    final buckets = DateRange.lastMonths(now, 3);
    expect(buckets.map((b) => b.start).toList(), [
      DateTime(2025, 11, 1),
      DateTime(2025, 12, 1),
      DateTime(2026, 1, 1),
    ]);
    expect(buckets.last.endExclusive, DateTime(2026, 2, 1));
  });
}
