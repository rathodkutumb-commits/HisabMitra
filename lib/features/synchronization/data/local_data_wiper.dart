import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';
import '../../attachments/data/attachment_service.dart';
import '../../reminders/application/notification_service.dart';
import '../../reminders/data/reminder_repository.dart';

/// Removes the phone's copy of the account's data (sign-out, account
/// deletion): personal records, groups, Family hisabs, bills and sync state. Categories
/// and app settings belong to the phone and stay.
class LocalDataWiper {
  LocalDataWiper(this._db, {this.scheduler, this.deleteFiles});

  final AppDatabase _db;
  final ReminderScheduler? scheduler;
  final Future<void> Function(List<String> storedNames)? deleteFiles;

  /// Settings that describe the account's sync position or sample data.
  static const accountSettingKeys = [
    'sync.cursor',
    'sync.personalCursor',
    'sync.familyCursor',
    'sync.lastSuccess',
    'sync.ownResetOpId',
    'tour.sampleIds',
  ];

  Future<void> wipeAccountData() async {
    for (final r in await _db.select(_db.reminders).get()) {
      try {
        await scheduler?.cancel(r.notificationId);
      } catch (e, s) {
        SafeLogger.error('wipe_cancel_notification', e, s);
      }
    }
    final files = [
      for (final a in await _db.select(_db.attachments).get())
        if (a.storedName.isNotEmpty) a.storedName,
    ];
    await _db.transaction(() async {
      await _db.delete(_db.attachments).go();
      await _db.delete(_db.reminders).go();
      await _db.delete(_db.moneySettlements).go();
      await _db.delete(_db.moneyLedger).go();
      await _db.delete(_db.transactions).go();
      await _db.delete(_db.persons).go();
      await _db.delete(_db.groupExpenseSplitsCache).go();
      await _db.delete(_db.groupExpensesCache).go();
      await _db.delete(_db.groupSettlementsCache).go();
      await _db.delete(_db.groupMembersCache).go();
      await _db.delete(_db.groupsCache).go();
      await _db.delete(_db.familyEntriesCache).go();
      await _db.delete(_db.familyMembersCache).go();
      await _db.delete(_db.familyHisabsCache).go();
      await _db.delete(_db.syncOutbox).go();
      await _db.delete(_db.syncInbox).go();
      await _db.delete(_db.syncConflicts).go();
      await (_db.delete(
        _db.appSettings,
      )..where((s) => s.key.isIn(accountSettingKeys))).go();
    });
    if (files.isNotEmpty) await deleteFiles?.call(files);
  }
}

final localDataWiperProvider = Provider<LocalDataWiper>(
  (ref) => LocalDataWiper(
    ref.watch(appDatabaseProvider),
    scheduler: ref.watch(notificationServiceProvider),
    deleteFiles: (names) =>
        ref.read(attachmentServiceProvider).deleteFiles(names),
  ),
);
