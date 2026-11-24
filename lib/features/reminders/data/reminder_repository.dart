import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../domain/reminder_schedule.dart';
import '../../synchronization/data/personal_outbox.dart';
import '../../synchronization/domain/personal_entity.dart';
import 'notification_ids.dart';

/// Platform notification scheduling (implemented by NotificationService).
abstract interface class ReminderScheduler {
  Future<void> schedule(ReminderRow reminder);
  Future<void> cancel(int notificationId);
}

class ReminderRepository {
  ReminderRepository(
    this._db,
    this._clock,
    this._ids,
    this._scheduler, {
    PersonalOutbox? outbox,
  }) : _outbox = outbox ?? PersonalOutbox(_db, _clock, _ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final ReminderScheduler _scheduler;
  final PersonalOutbox _outbox;

  Stream<List<ReminderRow>> watchPending({int? limit}) {
    final q = _db.select(_db.reminders)
      ..where((r) => r.status.equalsValue(ReminderStatus.pending))
      ..orderBy([(r) => OrderingTerm.asc(r.dueAt)]);
    if (limit != null) q.limit(limit);
    return q.watch();
  }

  Stream<List<ReminderRow>> watchClosed() =>
      (_db.select(_db.reminders)
            ..where((r) => r.status.equalsValue(ReminderStatus.pending).not())
            ..orderBy([(r) => OrderingTerm.desc(r.updatedAt)]))
          .watch();

  Future<ReminderRow?> getById(String id) => (_db.select(
    _db.reminders,
  )..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<void> _validate(ReminderDraft d, {required int completed}) async {
    final amount = d.amountPaise;
    if (amount != null && amount <= 0) {
      throw const ValidationFailure('amount');
    }
    if (d.kind.isPayment && amount == null) {
      throw const ValidationFailure('amount');
    }
    final total = d.totalOccurrences;
    if (total != null) {
      if (d.repeat == ReminderRepeat.none || total < 1) {
        throw const ValidationFailure('payment_count');
      }
      // The series cannot end at or before the payments already made.
      if (completed > 0 && total <= completed) {
        throw const ValidationFailure('payment_count');
      }
    }
    if (d.categoryId != null) {
      final c = await (_db.select(
        _db.categories,
      )..where((x) => x.id.equals(d.categoryId!))).getSingleOrNull();
      if (c == null || c.type != TransactionType.expense) {
        throw const ValidationFailure('category_type');
      }
    }
  }

  Future<String> save(ReminderDraft d) async {
    final title = d.title.trim();
    if (title.isEmpty) throw const ValidationFailure('required');
    final existing = d.id == null ? null : await getById(d.id!);
    if (d.id != null && existing == null) throw const NotFoundFailure();
    await _validate(d, completed: existing?.completedOccurrences ?? 0);
    final now = _clock.now();
    final note = d.note?.trim();
    // The reminder and its upload to the account are saved together.
    final id = await _db.transaction(() async {
      late final String id;
      if (d.id == null) {
        id = _ids.newId();
        await _db
            .into(_db.reminders)
            .insert(
              RemindersCompanion.insert(
                id: id,
                kind: d.kind,
                title: title,
                note: Value(note == null || note.isEmpty ? null : note),
                dueAt: d.dueAt,
                repeat: Value(d.repeat),
                amountPaise: Value(d.amountPaise),
                categoryId: Value(d.categoryId),
                anchorDay: Value(d.dueAt.day),
                totalOccurrences: Value(d.totalOccurrences),
                personId: Value(d.personId),
                ledgerEntryId: Value(d.ledgerEntryId),
                groupId: Value(d.groupId),
                familyId: Value(d.familyId),
                notificationId: await newNotificationId(_db),
                createdAt: now,
                updatedAt: now,
              ),
            );
      } else {
        id = d.id!;
        final n =
            await (_db.update(
              _db.reminders,
            )..where((r) => r.id.equals(id))).write(
              RemindersCompanion(
                kind: Value(d.kind),
                title: Value(title),
                note: Value(note == null || note.isEmpty ? null : note),
                dueAt: Value(d.dueAt),
                repeat: Value(d.repeat),
                amountPaise: Value(d.amountPaise),
                categoryId: Value(d.categoryId),
                anchorDay: Value(d.dueAt.day),
                totalOccurrences: Value(d.totalOccurrences),
                status: const Value(ReminderStatus.pending),
                updatedAt: Value(now),
              ),
            );
        if (n == 0) throw const NotFoundFailure();
      }
      await _outbox.upsert(PersonalEntity.reminder, id);
      return id;
    });
    final row = (await getById(id))!;
    await _scheduler.cancel(row.notificationId);
    if (row.dueAt.isAfter(now)) await _scheduler.schedule(row);
    return id;
  }

  /// Marks the current occurrence done (paid). Repeating reminders roll to
  /// their next date; a series with a payment count ends after the last one.
  ///
  /// Payments advance one instalment at a time: a missed EMI is still owed,
  /// so the next due date may also be in the past. Plain reminders skip
  /// straight to the next future date.
  Future<void> complete(String id) async {
    final r = await getById(id);
    if (r == null) throw const NotFoundFailure();
    await _scheduler.cancel(r.notificationId);
    final now = _clock.now();
    final completed = r.completedOccurrences + 1;
    final total = r.totalOccurrences;
    DateTime? next(DateTime from) =>
        nextOccurrence(from, r.repeat, anchorDay: r.anchorDay);
    var due = (total != null && completed >= total) ? null : next(r.dueAt);
    if (r.amountPaise == null) {
      while (due != null && !due.isAfter(now)) {
        due = next(due);
      }
    }
    await _db.transaction(() async {
      await (_db.update(_db.reminders)..where((x) => x.id.equals(id))).write(
        RemindersCompanion(
          completedOccurrences: Value(completed),
          dueAt: due == null ? const Value.absent() : Value(due),
          status: due == null
              ? const Value(ReminderStatus.done)
              : const Value.absent(),
          updatedAt: Value(now),
        ),
      );
      await _outbox.upsert(PersonalEntity.reminder, id);
    });
    if (due != null && due.isAfter(now)) {
      await _scheduler.schedule((await getById(id))!);
    }
  }

  /// Total of fixed payments falling due in [from, to); see [sumPaymentsDue].
  Future<int> paymentsDueBetween(DateTime from, DateTime to) async =>
      sumPaymentsDue(await watchPending().first, from, to);

  Future<void> cancel(String id) async {
    final r = await getById(id);
    if (r == null) throw const NotFoundFailure();
    await _scheduler.cancel(r.notificationId);
    await _setStatus(id, ReminderStatus.cancelled);
  }

  Future<void> delete(String id) async {
    final r = await getById(id);
    if (r == null) return;
    await _scheduler.cancel(r.notificationId);
    await _db.transaction(() async {
      await _outbox.delete(PersonalEntity.reminder, id);
      await (_db.delete(_db.reminders)..where((x) => x.id.equals(id))).go();
    });
  }

  Future<void> _setStatus(String id, ReminderStatus status) =>
      _db.transaction(() async {
        await (_db.update(_db.reminders)..where((x) => x.id.equals(id))).write(
          RemindersCompanion(
            status: Value(status),
            updatedAt: Value(_clock.now()),
          ),
        );
        await _outbox.upsert(PersonalEntity.reminder, id);
      });

  /// Re-registers all future pending reminders (after restore, permission
  /// grant or notification setting change).
  Future<void> rescheduleAll() async {
    final now = _clock.now();
    final pending = await watchPending().first;
    for (final r in pending) {
      await _scheduler.cancel(r.notificationId);
      if (r.dueAt.isAfter(now)) await _scheduler.schedule(r);
    }
  }

  Future<void> cancelAllNotifications() async {
    for (final r in await watchPending().first) {
      await _scheduler.cancel(r.notificationId);
    }
  }
}
