import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/reminders/data/reminder_repository.dart';
import 'package:hisabmitra/features/reminders/domain/reminder_schedule.dart';

import '../../helpers/test_db.dart';

class _RecordingScheduler implements ReminderScheduler {
  final scheduled = <int, DateTime>{};
  final cancelled = <int>[];

  @override
  Future<void> schedule(ReminderRow r) async =>
      scheduled[r.notificationId] = r.dueAt;

  @override
  Future<void> cancel(int notificationId) async {
    cancelled.add(notificationId);
    scheduled.remove(notificationId);
  }
}

class _Fixed extends Clock {
  _Fixed(this.value);
  DateTime value;
  @override
  DateTime now() => value;
}

void main() {
  group('nextOccurrence', () {
    test('daily and weekly add days', () {
      expect(
        nextOccurrence(DateTime(2026, 1, 31, 9), ReminderRepeat.daily),
        DateTime(2026, 2, 1, 9),
      );
      expect(
        nextOccurrence(DateTime(2026, 1, 31, 9), ReminderRepeat.weekly),
        DateTime(2026, 2, 7, 9),
      );
    });

    test('monthly clamps to the last day of shorter months', () {
      expect(
        nextOccurrence(DateTime(2026, 1, 31, 9), ReminderRepeat.monthly),
        DateTime(2026, 2, 28, 9),
      );
      expect(
        nextOccurrence(DateTime(2026, 12, 15, 9), ReminderRepeat.monthly),
        DateTime(2027, 1, 15, 9),
      );
    });

    test('none has no next occurrence', () {
      expect(nextOccurrence(DateTime(2026, 1, 1), ReminderRepeat.none), isNull);
    });

    test('quarterly, half-yearly and yearly step 3, 6 and 12 months', () {
      final due = DateTime(2026, 11, 30, 9);
      expect(
        nextOccurrence(due, ReminderRepeat.quarterly),
        DateTime(2027, 2, 28, 9),
      );
      expect(
        nextOccurrence(due, ReminderRepeat.halfYearly),
        DateTime(2027, 5, 30, 9),
      );
      expect(
        nextOccurrence(due, ReminderRepeat.yearly),
        DateTime(2027, 11, 30, 9),
      );
      expect(
        nextOccurrence(DateTime(2028, 2, 29), ReminderRepeat.yearly),
        DateTime(2029, 2, 28),
      );
    });

    test('the anchor day stops month-end dates drifting', () {
      // An EMI on the 31st is due 28 Feb, and back on the 31st in March.
      expect(
        nextOccurrence(
          DateTime(2026, 2, 28, 9),
          ReminderRepeat.monthly,
          anchorDay: 31,
        ),
        DateTime(2026, 3, 31, 9),
      );
      expect(
        nextOccurrence(
          DateTime(2026, 4, 30),
          ReminderRepeat.monthly,
          anchorDay: 31,
        ),
        DateTime(2026, 5, 31),
      );
    });

    test('payment kinds are the recurring-payment types', () {
      expect(ReminderKind.emi.isPayment, isTrue);
      expect(ReminderKind.sip.isPayment, isTrue);
      expect(ReminderKind.maintenance.isPayment, isTrue);
      expect(ReminderKind.custom.isPayment, isFalse);
      expect(ReminderKind.repayment.isPayment, isFalse);
    });
  });

  group('repository', () {
    late AppDatabase db;
    late _RecordingScheduler scheduler;
    late ReminderRepository repo;
    final clock = _Fixed(DateTime(2026, 6, 1, 8));

    setUp(() {
      db = newTestDatabase();
      scheduler = _RecordingScheduler();
      repo = ReminderRepository(db, clock, const IdGenerator(), scheduler);
    });
    tearDown(() => db.close());

    ReminderDraft draft({
      ReminderRepeat repeat = ReminderRepeat.none,
      DateTime? due,
    }) => ReminderDraft(
      kind: ReminderKind.custom,
      title: 'Pay rent',
      dueAt: due ?? DateTime(2026, 6, 5, 10),
      repeat: repeat,
    );

    test('saving a future reminder schedules a notification', () async {
      final id = await repo.save(draft());
      final r = await repo.getById(id);
      expect(scheduler.scheduled[r!.notificationId], DateTime(2026, 6, 5, 10));
    });

    test(
      'completing a one-off reminder marks it done and cancels it',
      () async {
        final id = await repo.save(draft());
        await repo.complete(id);
        final r = await repo.getById(id);
        expect(r!.status, ReminderStatus.done);
        expect(scheduler.cancelled, contains(r.notificationId));
      },
    );

    test(
      'completing a repeating reminder moves it to the next occurrence',
      () async {
        final id = await repo.save(draft(repeat: ReminderRepeat.monthly));
        await repo.complete(id);
        final r = await repo.getById(id);
        expect(r!.status, ReminderStatus.pending);
        expect(r.dueAt, DateTime(2026, 7, 5, 10));
        expect(scheduler.scheduled[r.notificationId], DateTime(2026, 7, 5, 10));
      },
    );

    test('cancelling stops the notification', () async {
      final id = await repo.save(draft());
      await repo.cancel(id);
      final r = await repo.getById(id);
      expect(r!.status, ReminderStatus.cancelled);
      expect(scheduler.scheduled, isEmpty);
    });

    test('upcoming lists pending reminders soonest first', () async {
      await repo.save(draft(due: DateTime(2026, 6, 9)));
      await repo.save(draft(due: DateTime(2026, 6, 3)));
      final upcoming = await repo.watchPending().first;
      expect(upcoming.map((r) => r.dueAt.day).toList(), [3, 9]);
    });

    group('recurring payments', () {
      ReminderDraft emi({
        int? amount = 1250000,
        DateTime? due,
        int? total,
        ReminderRepeat repeat = ReminderRepeat.monthly,
        String? categoryId,
        String? id,
      }) => ReminderDraft(
        id: id,
        kind: ReminderKind.emi,
        title: 'Home loan EMI',
        dueAt: due ?? DateTime(2026, 6, 5, 10),
        repeat: repeat,
        amountPaise: amount,
        categoryId: categoryId,
        totalOccurrences: total,
      );

      test(
        'stores the fixed amount, category and number of payments',
        () async {
          final id = await repo.save(emi(total: 24, categoryId: 'cat_bills'));
          final r = (await repo.getById(id))!;
          expect(r.kind, ReminderKind.emi);
          expect(r.amountPaise, 1250000);
          expect(r.categoryId, 'cat_bills');
          expect(r.totalOccurrences, 24);
          expect(r.completedOccurrences, 0);
        },
      );

      test('a payment type needs a positive amount', () async {
        await expectLater(
          repo.save(emi(amount: null)),
          throwsA(isA<ValidationFailure>()),
        );
        await expectLater(
          repo.save(emi(amount: 0)),
          throwsA(isA<ValidationFailure>()),
        );
        await expectLater(
          repo.save(draft().copyWithAmount(-5)),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('the category must be an expense category', () async {
        await expectLater(
          repo.save(emi(categoryId: 'cat_salary')),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('a payment count needs a repeat and must be at least 1', () async {
        await expectLater(
          repo.save(emi(total: 3, repeat: ReminderRepeat.none)),
          throwsA(isA<ValidationFailure>()),
        );
        await expectLater(
          repo.save(emi(total: 0)),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('paying an EMI on the 31st keeps the 31st after February', () async {
        clock.value = DateTime(2026, 1, 20);
        final id = await repo.save(emi(due: DateTime(2026, 1, 31, 10)));
        await repo.complete(id);
        expect((await repo.getById(id))!.dueAt, DateTime(2026, 2, 28, 10));
        await repo.complete(id);
        final r = (await repo.getById(id))!;
        expect(r.dueAt, DateTime(2026, 3, 31, 10));
        expect(r.completedOccurrences, 2);
        clock.value = DateTime(2026, 6, 1, 8);
      });

      test('an overdue payment advances one instalment at a time', () async {
        // Missed EMIs are still owed, so paying one moves to the next one,
        // even if that is also in the past.
        final id = await repo.save(emi(due: DateTime(2026, 3, 5, 10)));
        await repo.complete(id);
        final r = (await repo.getById(id))!;
        expect(r.dueAt, DateTime(2026, 4, 5, 10));
        expect(r.status, ReminderStatus.pending);
        expect(
          scheduler.scheduled.containsKey(r.notificationId),
          isFalse,
          reason: 'past date',
        );
      });

      test('ends after the last of N payments', () async {
        final id = await repo.save(emi(total: 2));
        await repo.complete(id);
        expect((await repo.getById(id))!.status, ReminderStatus.pending);
        await repo.complete(id);
        final r = (await repo.getById(id))!;
        expect(r.status, ReminderStatus.done);
        expect(r.completedOccurrences, 2);
        expect(scheduler.scheduled, isEmpty);
      });

      test('editing keeps the paid count and cannot go below it', () async {
        final id = await repo.save(emi(total: 24));
        await repo.complete(id);
        await repo.complete(id);
        await repo.save(
          emi(
            id: id,
            total: 12,
            amount: 1300000,
            due: DateTime(2026, 8, 5, 10),
          ),
        );
        final r = (await repo.getById(id))!;
        expect(r.completedOccurrences, 2);
        expect(r.amountPaise, 1300000);
        await expectLater(
          repo.save(emi(id: id, total: 1, due: DateTime(2026, 8, 5, 10))),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('upcoming payments total the amounts due in a period', () async {
        await repo.save(emi(due: DateTime(2026, 6, 5)));
        await repo.save(
          ReminderDraft(
            kind: ReminderKind.sip,
            title: 'Index fund SIP',
            dueAt: DateTime(2026, 6, 10),
            repeat: ReminderRepeat.monthly,
            amountPaise: 500000,
          ),
        );
        await repo.save(draft(due: DateTime(2026, 6, 12))); // no amount
        final total = await repo.paymentsDueBetween(
          DateTime(2026, 6),
          DateTime(2026, 7),
        );
        expect(total, 1250000 + 500000);
      });
    });

    test('rescheduleAll re-registers every future pending reminder', () async {
      await repo.save(draft(due: DateTime(2026, 6, 9)));
      await repo.save(draft(due: DateTime(2026, 5, 1))); // already past
      scheduler.scheduled.clear();
      await repo.rescheduleAll();
      expect(scheduler.scheduled.length, 1);
    });
  });
}

extension on ReminderDraft {
  ReminderDraft copyWithAmount(int amount) => ReminderDraft(
    kind: kind,
    title: title,
    dueAt: dueAt,
    repeat: repeat,
    amountPaise: amount,
  );
}
