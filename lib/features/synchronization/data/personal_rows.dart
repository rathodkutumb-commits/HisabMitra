import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../reminders/data/notification_ids.dart';
import '../../reminders/data/reminder_repository.dart';
import '../domain/personal_entity.dart';

/// Outcome of writing one server record into the phone's copy.
enum PersonalApplyResult {
  applied,

  /// The phone already has this revision (or newer).
  unchanged,

  /// A record it refers to (person, khata entry, group, parent) is not on
  /// the phone yet; try again after the rest of the batch.
  waiting,
}

/// Writes personal records from the server (feed events, snapshots, the
/// server side of a conflict) into the phone's copy.
class PersonalRowApplier {
  PersonalRowApplier(
    this._db,
    this._clock, {
    this._scheduler,
    this.onFilesRemoved,
  });

  final AppDatabase _db;
  final Clock _clock;
  final ReminderScheduler? _scheduler;

  /// Called with the stored file names of bills removed by a server change.
  Future<void> Function(List<String> storedNames)? onFilesRemoved;

  static T _enum<T extends Enum>(List<T> values, Object? raw, T fallback) =>
      values.firstWhere((e) => e.name == raw, orElse: () => fallback);

  static DateTime _date(Object? v) {
    final d = DateTime.parse(v! as String);
    return DateTime(d.year, d.month, d.day);
  }

  static DateTime? _dateOrNull(Object? v) => v == null ? null : _date(v);

  DateTime _instant(Object? v) =>
      v == null ? _clock.now() : DateTime.parse(v as String).toLocal();

  static int? _int(Object? v) => (v as num?)?.toInt();

  Future<int?> _localRevision(PersonalEntity type, String id) async {
    final row = await _db
        .customSelect(
          'SELECT revision FROM ${type.localTable} WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return row?.read<int>('revision');
  }

  Future<bool> _exists(String table, Object? id) async {
    if (id == null) return true;
    final row = await _db
        .customSelect(
          'SELECT 1 FROM $table WHERE id = ?',
          variables: [Variable.withString(id as String)],
        )
        .getSingleOrNull();
    return row != null;
  }

  /// Writes [row] (wire form) at [revision]. Skips rows the phone already
  /// has at that revision unless [force].
  Future<PersonalApplyResult> apply(
    PersonalEntity type,
    Map<String, Object?> row,
    int revision, {
    bool deleted = false,
    bool force = false,
  }) async {
    final id = row['id']! as String;
    final local = await _localRevision(type, id);
    if (!force && local != null && local >= revision) {
      return PersonalApplyResult.unchanged;
    }
    if (deleted || row['deleted_at'] != null) {
      if (local == null) return PersonalApplyResult.unchanged;
      await _deleteLocal(type, id);
      return PersonalApplyResult.applied;
    }
    final ok = switch (type) {
      PersonalEntity.person => true,
      PersonalEntity.transaction => await _exists('persons', row['person_id']),
      PersonalEntity.ledgerEntry => await _exists('persons', row['person_id']),
      PersonalEntity.repayment => await _exists(
        'money_ledger',
        row['ledger_id'],
      ),
      PersonalEntity.reminder =>
        await _exists('persons', row['person_id']) &&
            await _exists('money_ledger', row['ledger_entry_id']) &&
            await _exists('groups_cache', row['group_id']),
      PersonalEntity.attachment => await _exists(
        row['parent_type'] == 'ledger_entry' ? 'money_ledger' : 'transactions',
        row['parent_id'],
      ),
    };
    if (!ok) return PersonalApplyResult.waiting;
    await _db.transaction(() => _write(type, id, row, revision));
    if (type == PersonalEntity.reminder) await _reschedule(id);
    return PersonalApplyResult.applied;
  }

  Future<void> _write(
    PersonalEntity type,
    String id,
    Map<String, Object?> r,
    int revision,
  ) async {
    final created = _instant(r['created_at']);
    final updated = _instant(r['updated_at']);
    const synced = Value(SyncState.synced);
    switch (type) {
      case PersonalEntity.person:
        await _db
            .into(_db.persons)
            .insertOnConflictUpdate(
              PersonsCompanion.insert(
                id: id,
                name: r['name']! as String,
                phone: Value(r['phone'] as String?),
                email: Value(r['email'] as String?),
                description: Value(r['description'] as String?),
                notes: Value(r['notes'] as String?),
                createdAt: created,
                updatedAt: updated,
                revision: Value(revision),
                syncState: synced,
              ),
            );
      case PersonalEntity.transaction:
        final txnType = _enum(
          TransactionType.values,
          r['type'],
          TransactionType.expense,
        );
        await _ensureCategory(r, txnType);
        await _db
            .into(_db.transactions)
            .insertOnConflictUpdate(
              TransactionsCompanion.insert(
                id: id,
                ownerId: localOwnerId,
                type: txnType,
                amountPaise: _int(r['amount_paise'])!,
                categoryId: r['category_id']! as String,
                txnDate: _date(r['txn_date']),
                paymentMethod: _enum(
                  PaymentMethod.values,
                  r['payment_method'],
                  PaymentMethod.other,
                ),
                personId: Value(r['person_id'] as String?),
                description: Value(r['description'] as String? ?? ''),
                notes: Value(r['notes'] as String?),
                createdAt: created,
                updatedAt: updated,
                revision: Value(revision),
                syncState: synced,
              ),
            );
      case PersonalEntity.ledgerEntry:
        await _db
            .into(_db.moneyLedger)
            .insertOnConflictUpdate(
              MoneyLedgerCompanion.insert(
                id: id,
                personId: r['person_id']! as String,
                direction: _enum(
                  LedgerDirection.values,
                  r['direction'],
                  LedgerDirection.given,
                ),
                principalPaise: _int(r['principal_paise'])!,
                entryDate: _date(r['entry_date']),
                dueDate: Value(_dateOrNull(r['due_date'])),
                paymentMethod: _enum(
                  PaymentMethod.values,
                  r['payment_method'],
                  PaymentMethod.other,
                ),
                description: Value(r['description'] as String? ?? ''),
                notes: Value(r['notes'] as String?),
                createdAt: created,
                updatedAt: updated,
                revision: Value(revision),
                syncState: synced,
              ),
            );
      case PersonalEntity.repayment:
        await _db
            .into(_db.moneySettlements)
            .insertOnConflictUpdate(
              MoneySettlementsCompanion.insert(
                id: id,
                ledgerId: r['ledger_id']! as String,
                amountPaise: _int(r['amount_paise'])!,
                settledOn: _date(r['settled_on']),
                paymentMethod: _enum(
                  PaymentMethod.values,
                  r['payment_method'],
                  PaymentMethod.other,
                ),
                notes: Value(r['notes'] as String?),
                createdAt: created,
                updatedAt: updated,
                revision: Value(revision),
                syncState: synced,
              ),
            );
      case PersonalEntity.reminder:
        if (r['category_id'] != null) {
          await _ensureCategory(r, TransactionType.expense);
        }
        final existing = await (_db.select(
          _db.reminders,
        )..where((x) => x.id.equals(id))).getSingleOrNull();
        await _db
            .into(_db.reminders)
            .insertOnConflictUpdate(
              RemindersCompanion.insert(
                id: id,
                kind: _enum(
                  ReminderKind.values,
                  r['kind'],
                  ReminderKind.custom,
                ),
                title: r['title']! as String,
                note: Value(r['note'] as String?),
                dueAt: _instant(r['due_at']),
                repeat: Value(
                  _enum(
                    ReminderRepeat.values,
                    r['repeat'],
                    ReminderRepeat.none,
                  ),
                ),
                personId: Value(r['person_id'] as String?),
                ledgerEntryId: Value(r['ledger_entry_id'] as String?),
                groupId: Value(r['group_id'] as String?),
                amountPaise: Value(_int(r['amount_paise'])),
                categoryId: Value(r['category_id'] as String?),
                anchorDay: Value(_int(r['anchor_day'])),
                totalOccurrences: Value(_int(r['total_occurrences'])),
                completedOccurrences: Value(
                  _int(r['completed_occurrences']) ?? 0,
                ),
                notificationId:
                    existing?.notificationId ?? await newNotificationId(_db),
                status: Value(
                  _enum(
                    ReminderStatus.values,
                    r['status'],
                    ReminderStatus.pending,
                  ),
                ),
                createdAt: created,
                updatedAt: updated,
                revision: Value(revision),
                syncState: synced,
              ),
            );
      case PersonalEntity.attachment:
        final onLedger = r['parent_type'] == 'ledger_entry';
        final name = r['storage_name']! as String;
        // This phone's own bill: keep its file state (it may never have had
        // a file to upload).
        final mine = await (_db.select(
          _db.attachments,
        )..where((x) => x.id.equals(id))).getSingleOrNull();
        await _db
            .into(_db.attachments)
            .insertOnConflictUpdate(
              AttachmentsCompanion.insert(
                id: id,
                transactionId: Value(
                  onLedger ? null : r['parent_id'] as String?,
                ),
                ledgerEntryId: Value(
                  onLedger ? r['parent_id'] as String? : null,
                ),
                storedName: name,
                originalName: r['original_name']! as String,
                mimeType: r['mime_type']! as String,
                sizeBytes: _int(r['size_bytes'])!,
                sha256: r['sha256']! as String,
                // In the account: the file can be downloaded by this name.
                remotePath: mine == null ? Value(name) : Value(mine.remotePath),
                createdAt: created,
                revision: Value(revision),
                syncState: synced,
              ),
            );
    }
  }

  /// Re-creates a category that exists on another phone but not here, from
  /// the copy an entry carries (categories themselves stay on each phone).
  Future<void> _ensureCategory(
    Map<String, Object?> r,
    TransactionType type,
  ) async {
    final id = r['category_id'] as String?;
    if (id == null) return;
    final have = await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (have != null) return;
    final key = r['category_system_key'] as String?;
    final keyTaken =
        key != null &&
        await (_db.select(
              _db.categories,
            )..where((c) => c.systemKey.equals(key))).getSingleOrNull() !=
            null;
    final maxOrder = _db.categories.sortOrder.max();
    final order = await (_db.selectOnly(
      _db.categories,
    )..addColumns([maxOrder])).getSingle();
    final now = _clock.now();
    final name = (r['category_name'] as String?)?.trim();
    final nameGu = (r['category_name_gu'] as String?)?.trim();
    await _db
        .into(_db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: id,
            systemKey: Value(keyTaken ? null : key),
            name: name == null || name.isEmpty ? 'Category' : name,
            nameGu: Value(nameGu == null || nameGu.isEmpty ? null : nameGu),
            type: type,
            iconKey: r['category_icon'] as String? ?? 'more',
            colorValue: _int(r['category_color']) ?? 0xFF607D8B,
            sortOrder: Value((order.read(maxOrder) ?? 0) + 1),
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  Future<void> _reschedule(String id) async {
    final scheduler = _scheduler;
    if (scheduler == null) return;
    final r = await (_db.select(
      _db.reminders,
    )..where((x) => x.id.equals(id))).getSingleOrNull();
    if (r == null) return;
    await scheduler.cancel(r.notificationId);
    if (r.status == ReminderStatus.pending && r.dueAt.isAfter(_clock.now())) {
      await scheduler.schedule(r);
    }
  }

  Future<void> _cancelReminders(Iterable<ReminderRow> rows) async {
    final scheduler = _scheduler;
    if (scheduler == null) return;
    for (final r in rows) {
      await scheduler.cancel(r.notificationId);
    }
  }

  /// Removes a record and what the phone's foreign keys remove with it.
  Future<void> _deleteLocal(PersonalEntity type, String id) async {
    final files = <String>[];
    Future<void> collectFiles(
      Expression<bool> Function($AttachmentsTable a) where,
    ) async {
      files.addAll(
        await (_db.select(
          _db.attachments,
        )..where(where)).map((a) => a.storedName).get(),
      );
    }

    switch (type) {
      case PersonalEntity.reminder:
        await _cancelReminders(
          await (_db.select(
            _db.reminders,
          )..where((r) => r.id.equals(id))).get(),
        );
      case PersonalEntity.attachment:
        await collectFiles((a) => a.id.equals(id));
      case PersonalEntity.transaction:
        await collectFiles((a) => a.transactionId.equals(id));
      case PersonalEntity.ledgerEntry:
        await collectFiles((a) => a.ledgerEntryId.equals(id));
        await _cancelReminders(
          await (_db.select(
            _db.reminders,
          )..where((r) => r.ledgerEntryId.equals(id))).get(),
        );
      case PersonalEntity.person:
        final ledger = await (_db.select(
          _db.moneyLedger,
        )..where((l) => l.personId.equals(id))).map((l) => l.id).get();
        if (ledger.isNotEmpty) {
          await collectFiles((a) => a.ledgerEntryId.isIn(ledger));
          await _cancelReminders(
            await (_db.select(
              _db.reminders,
            )..where((r) => r.ledgerEntryId.isIn(ledger))).get(),
          );
        }
      case PersonalEntity.repayment:
        break;
    }
    await _db.customStatement('DELETE FROM ${type.localTable} WHERE id = ?', [
      id,
    ]);
    _db.notifyUpdates({
      TableUpdate.onTable(_tableOf(type), kind: UpdateKind.delete),
    });
    if (files.isNotEmpty) await onFilesRemoved?.call(files);
  }

  /// A restore on another phone replaced everything in the account: drop the
  /// phone's copy (records with unsent changes stay and upload again).
  Future<void> applyReset() async {
    final pending = {
      for (final o in await (_db.select(
        _db.syncOutbox,
      )..where((o) => o.scope.equals('personal'))).get())
        o.entityId,
    };
    bool keep(String id) => pending.contains(id);
    await _cancelReminders(
      (await _db.select(_db.reminders).get()).where((r) => !keep(r.id)),
    );
    final files = [
      for (final a in await _db.select(_db.attachments).get())
        if (a.groupExpenseId == null && !keep(a.id)) a.storedName,
    ];
    await _db.transaction(() async {
      for (final type in const [
        PersonalEntity.attachment,
        PersonalEntity.repayment,
        PersonalEntity.reminder,
        PersonalEntity.ledgerEntry,
        PersonalEntity.transaction,
        PersonalEntity.person,
      ]) {
        final extra = type == PersonalEntity.attachment
            ? ' AND group_expense_id IS NULL'
            : '';
        final keepIds = pending.toList();
        await _db.customStatement(
          'DELETE FROM ${type.localTable} WHERE id NOT IN '
          '(${List.filled(keepIds.length, '?').join(', ')})$extra',
          keepIds,
        );
      }
    });
    _db.notifyUpdates({
      for (final t in PersonalEntity.values)
        TableUpdate.onTable(_tableOf(t), kind: UpdateKind.delete),
    });
    if (files.isNotEmpty) await onFilesRemoved?.call(files);
  }

  /// Records the server revision and upload state of a local record.
  Future<void> setState(
    PersonalEntity type,
    String id, {
    int? revision,
    SyncState? state,
  }) async {
    final sets = <String>[];
    final vars = <Variable<Object>>[];
    if (revision != null) {
      sets.add('revision = ?');
      vars.add(Variable.withInt(revision));
    }
    if (state != null) {
      sets.add('sync_state = ?');
      vars.add(Variable.withString(state.name));
    }
    if (sets.isEmpty) return;
    vars.add(Variable.withString(id));
    await _db.customUpdate(
      'UPDATE ${type.localTable} SET ${sets.join(', ')} WHERE id = ?',
      variables: vars,
      updates: {_tableOf(type)},
    );
  }

  TableInfo<Table, Object?> _tableOf(PersonalEntity type) => switch (type) {
    PersonalEntity.person => _db.persons,
    PersonalEntity.transaction => _db.transactions,
    PersonalEntity.ledgerEntry => _db.moneyLedger,
    PersonalEntity.repayment => _db.moneySettlements,
    PersonalEntity.reminder => _db.reminders,
    PersonalEntity.attachment => _db.attachments,
  };
}
