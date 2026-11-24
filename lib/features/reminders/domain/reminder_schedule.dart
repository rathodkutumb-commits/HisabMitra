import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';

/// Next due time for a repeating reminder, or null for one-off reminders.
///
/// Month-based repeats land on [anchorDay] (default: the day of [due]),
/// clamped to the month's length: an EMI anchored to the 31st is due
/// 28/29 Feb and back on 31 Mar.
DateTime? nextOccurrence(
  DateTime due,
  ReminderRepeat repeat, {
  int? anchorDay,
}) {
  final months = repeat.months;
  switch (repeat) {
    case ReminderRepeat.none:
      return null;
    case ReminderRepeat.daily:
      return DateTime(due.year, due.month, due.day + 1, due.hour, due.minute);
    case ReminderRepeat.weekly:
      return DateTime(due.year, due.month, due.day + 7, due.hour, due.minute);
    case ReminderRepeat.monthly ||
        ReminderRepeat.quarterly ||
        ReminderRepeat.halfYearly ||
        ReminderRepeat.yearly:
      final target = DateTime(due.year, due.month + months!);
      final lastDay = DateTime(target.year, target.month + 1, 0).day;
      final wanted = anchorDay ?? due.day;
      return DateTime(
        target.year,
        target.month,
        wanted > lastDay ? lastDay : wanted,
        due.hour,
        due.minute,
      );
  }
}

/// Total of fixed payments falling due in [from, to) across pending
/// [reminders]. Every occurrence counts (a weekly payment counts each week),
/// stopping at each series' last payment.
int sumPaymentsDue(
  Iterable<ReminderRow> reminders,
  DateTime from,
  DateTime to,
) {
  var total = 0;
  for (final r in reminders) {
    final amount = r.amountPaise;
    if (amount == null || r.status != ReminderStatus.pending) continue;
    var remaining = r.totalOccurrences == null
        ? null
        : r.totalOccurrences! - r.completedOccurrences;
    DateTime? due = r.dueAt;
    while (due != null &&
        due.isBefore(to) &&
        (remaining == null || remaining > 0)) {
      if (!due.isBefore(from)) total += amount;
      if (remaining != null) remaining--;
      due = nextOccurrence(due, r.repeat, anchorDay: r.anchorDay);
    }
  }
  return total;
}

@immutable
class ReminderDraft {
  const ReminderDraft({
    this.id,
    required this.kind,
    required this.title,
    required this.dueAt,
    this.repeat = ReminderRepeat.none,
    this.note,
    this.personId,
    this.ledgerEntryId,
    this.groupId,
    this.familyId,
    this.amountPaise,
    this.categoryId,
    this.totalOccurrences,
  });

  final String? id;
  final ReminderKind kind;
  final String title;
  final DateTime dueAt;
  final ReminderRepeat repeat;
  final String? note;
  final String? personId;
  final String? ledgerEntryId;
  final String? groupId;

  /// The Family hisab this reminder belongs to (its payment is recorded
  /// there, and its notification opens it).
  final String? familyId;

  /// Fixed amount; required for payment kinds (EMI, SIP, ...).
  final int? amountPaise;

  /// Expense category used when the payment is recorded.
  final String? categoryId;

  /// Number of payments in the series (e.g. 24 EMIs); null = no end.
  final int? totalOccurrences;
}
