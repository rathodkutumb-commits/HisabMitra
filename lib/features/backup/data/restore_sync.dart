import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../synchronization/data/personal_outbox.dart';
import '../../synchronization/domain/personal_entity.dart';

/// Makes a restored backup the new content of the account.
///
/// Runs on the restored database **before** it replaces the live one, in a
/// single SQLite transaction: the "replace everything in the account" step
/// is queued first, then every personal record, so an interrupted restore
/// continues in the right order on the next sync. Groups and Family hisabs
/// are not taken from the backup — other members rely on the account's
/// copy, which is downloaded again.
class RestoreSync {
  RestoreSync(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  static const _syncKeys = [
    'sync.cursor',
    'sync.personalCursor',
    'sync.familyCursor',
    'sync.lastSuccess',
    PersonalOutbox.ownResetOpIdKey,
  ];

  Future<void> afterRestore() => _db.transaction(() async {
    // Groups come back from the account (attachments of group expenses go
    // with them through the foreign keys).
    await (_db.delete(
      _db.attachments,
    )..where((a) => a.groupExpenseId.isNotNull())).go();
    await _db.delete(_db.groupExpenseSplitsCache).go();
    await _db.delete(_db.groupExpensesCache).go();
    await _db.delete(_db.groupSettlementsCache).go();
    await _db.delete(_db.groupMembersCache).go();
    await _db.delete(_db.groupsCache).go();
    // Family hisabs too: a restore never changes them in the account.
    await _db.delete(_db.familyEntriesCache).go();
    await _db.delete(_db.familyMembersCache).go();
    await _db.delete(_db.familyHisabsCache).go();
    await _db.delete(_db.syncOutbox).go();
    await _db.delete(_db.syncInbox).go();
    await _db.delete(_db.syncConflicts).go();
    await (_db.delete(
      _db.appSettings,
    )..where((s) => s.key.isIn(_syncKeys))).go();
    // Every personal record is uploaded again as new.
    for (final type in PersonalEntity.values) {
      await _db.customUpdate(
        "UPDATE ${type.localTable} SET revision = 0, sync_state = 'localOnly'",
        updates: {},
      );
    }
    // Bill files are uploaded again too.
    await (_db.update(_db.attachments)..where((a) => a.groupExpenseId.isNull()))
        .write(const AttachmentsCompanion(remotePath: Value(null)));
    final outbox = PersonalOutbox(_db, _clock, _ids);
    await outbox.reset();
    await outbox.queueUnsentLocalData();
  });
}
