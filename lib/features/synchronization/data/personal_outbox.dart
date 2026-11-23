import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../domain/personal_entity.dart';

/// Queues changes to personal records for upload to the user's account
/// (`apply_personal_op`), exactly like shared-group changes: the outbox row
/// is written in the **same SQLite transaction** as the change, so a change
/// is never saved without its upload, or the other way round.
///
/// Callers run [upsert] after writing a row and [delete] before deleting
/// one, inside their own `_db.transaction`.
class PersonalOutbox {
  PersonalOutbox(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  /// Suppression depth per database, shared by every instance (repositories
  /// may each hold their own [PersonalOutbox]).
  static final _suppressed = Expando<int>('personalOutboxSuppressed');

  static const sampleIdsKey = 'tour.sampleIds';
  static const ownResetOpIdKey = 'sync.ownResetOpId';

  bool get _isSuppressed => (_suppressed[_db] ?? 0) > 0;

  /// Runs [body] without queuing anything (guided-tour sample data).
  Future<T> withoutUpload<T>(Future<T> Function() body) async {
    _suppressed[_db] = (_suppressed[_db] ?? 0) + 1;
    try {
      return await body();
    } finally {
      _suppressed[_db] = (_suppressed[_db] ?? 1) - 1;
    }
  }

  Future<Set<String>> _sampleIds() async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((s) => s.key.equals(sampleIdsKey))).getSingleOrNull();
    if (row == null) return const {};
    try {
      final json = (jsonDecode(row.value) as Map).cast<String, Object?>();
      return {
        for (final list in json.values)
          if (list is List) ...list.whereType<String>(),
      };
    } on FormatException {
      return const {};
    }
  }

  Future<bool> _skip(String id) async =>
      _isSuppressed || (await _sampleIds()).contains(id);

  /// Queues the current state of the row [id] of [type].
  Future<void> upsert(PersonalEntity type, String id) async {
    if (await _skip(id)) return;
    final row = await personalPayload(_db, type, id);
    if (row == null) return;
    await _insert(
      type: type.wire,
      entityId: id,
      opType: 'upsert',
      baseRevision: row.revision,
      payload: row.payload,
    );
    await _db.customUpdate(
      "UPDATE ${type.localTable} SET sync_state = 'pending' WHERE id = ?",
      variables: [Variable.withString(id)],
      updates: {_tableOf(type)},
    );
  }

  /// Queues the deletion of [id]. Call **before** deleting the row (its
  /// revision is read here). Linked records are deleted by the server too.
  Future<void> delete(
    PersonalEntity type,
    String id, {
    Map<String, Object?> extra = const {},
  }) async {
    if (await _skip(id)) return;
    final rev = await _db
        .customSelect(
          'SELECT revision FROM ${type.localTable} WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    await _insert(
      type: type.wire,
      entityId: id,
      opType: 'delete',
      baseRevision: rev?.read<int>('revision') ?? 0,
      payload: {'id': id, ...extra},
    );
  }

  /// Queues every record never uploaded (`localOnly`, e.g. written by an
  /// app version before records were saved to the account), parents first.
  /// Sample data is skipped. Returns how many were queued.
  Future<int> queueUnsentLocalData() => _db.transaction(() async {
    if (_isSuppressed) return 0;
    final sample = await _sampleIds();
    var n = 0;
    for (final type in const [
      PersonalEntity.person,
      PersonalEntity.ledgerEntry,
      PersonalEntity.repayment,
      PersonalEntity.transaction,
      PersonalEntity.reminder,
      PersonalEntity.attachment,
    ]) {
      final groupBills = type == PersonalEntity.attachment
          ? ' AND group_expense_id IS NULL'
          : '';
      final ids = await _db
          .customSelect(
            'SELECT id FROM ${type.localTable} '
            "WHERE sync_state = 'localOnly'$groupBills ORDER BY created_at",
          )
          .map((r) => r.read<String>('id'))
          .get();
      for (final id in ids) {
        if (sample.contains(id)) continue;
        await upsert(type, id);
        n++;
      }
    }
    return n;
  });

  /// Queues "replace everything in the account" (restore of a backup).
  Future<void> reset() async {
    final opId = await _insert(
      type: 'all',
      entityId: '',
      opType: 'reset',
      baseRevision: 0,
      payload: const {},
    );
    await _db
        .into(_db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: ownResetOpIdKey,
            value: opId,
            updatedAt: _clock.now(),
          ),
        );
  }

  Future<String> _insert({
    required String type,
    required String entityId,
    required String opType,
    required int baseRevision,
    required Map<String, Object?> payload,
  }) async {
    final opId = _ids.newId();
    await _db
        .into(_db.syncOutbox)
        .insert(
          SyncOutboxCompanion.insert(
            opId: opId,
            groupId: '',
            scope: const Value('personal'),
            entityType: type,
            entityId: entityId,
            opType: opType,
            payload: jsonEncode(payload),
            baseRevision: baseRevision,
            createdAt: _clock.now(),
          ),
        );
    return opId;
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

final personalOutboxProvider = Provider<PersonalOutbox>(
  (ref) => PersonalOutbox(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

// ------------------------------------------------------------------ payloads

/// A local row as sent to the server, and the revision it is based on.
typedef PersonalRowPayload = ({Map<String, Object?> payload, int revision});

String _day(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

String _instant(DateTime d) => d.toUtc().toIso8601String();

Future<Map<String, Object?>> _categorySnapshot(
  AppDatabase db,
  String? categoryId,
) async {
  if (categoryId == null) return const {};
  final c = await (db.select(
    db.categories,
  )..where((x) => x.id.equals(categoryId))).getSingleOrNull();
  if (c == null) return {'category_id': categoryId};
  return {
    'category_id': c.id,
    'category_name': c.name,
    if (c.nameGu != null) 'category_name_gu': c.nameGu,
    'category_system_key': c.systemKey,
    'category_icon': c.iconKey,
    'category_color': c.colorValue,
  };
}

/// The wire form of the local row [id] of [type] (null when missing).
Future<PersonalRowPayload?> personalPayload(
  AppDatabase db,
  PersonalEntity type,
  String id,
) async {
  switch (type) {
    case PersonalEntity.person:
      final r = await (db.select(
        db.persons,
      )..where((x) => x.id.equals(id))).getSingleOrNull();
      if (r == null) return null;
      return (
        revision: r.revision,
        payload: {
          'id': r.id,
          'name': r.name,
          'phone': r.phone,
          'email': r.email,
          'description': r.description,
          'notes': r.notes,
          'created_at': _instant(r.createdAt),
        },
      );
    case PersonalEntity.transaction:
      final r = await (db.select(
        db.transactions,
      )..where((x) => x.id.equals(id))).getSingleOrNull();
      if (r == null) return null;
      return (
        revision: r.revision,
        payload: {
          'id': r.id,
          'type': r.type.name,
          'amount_paise': r.amountPaise,
          ...await _categorySnapshot(db, r.categoryId),
          'txn_date': _day(r.txnDate),
          'payment_method': r.paymentMethod.name,
          'person_id': r.personId,
          'description': r.description,
          'notes': r.notes,
          'created_at': _instant(r.createdAt),
        },
      );
    case PersonalEntity.ledgerEntry:
      final r = await (db.select(
        db.moneyLedger,
      )..where((x) => x.id.equals(id))).getSingleOrNull();
      if (r == null) return null;
      return (
        revision: r.revision,
        payload: {
          'id': r.id,
          'person_id': r.personId,
          'direction': r.direction.name,
          'principal_paise': r.principalPaise,
          'entry_date': _day(r.entryDate),
          'due_date': r.dueDate == null ? null : _day(r.dueDate!),
          'payment_method': r.paymentMethod.name,
          'description': r.description,
          'notes': r.notes,
          'created_at': _instant(r.createdAt),
        },
      );
    case PersonalEntity.repayment:
      final r = await (db.select(
        db.moneySettlements,
      )..where((x) => x.id.equals(id))).getSingleOrNull();
      if (r == null) return null;
      return (
        revision: r.revision,
        payload: {
          'id': r.id,
          'ledger_id': r.ledgerId,
          'amount_paise': r.amountPaise,
          'settled_on': _day(r.settledOn),
          'payment_method': r.paymentMethod.name,
          'notes': r.notes,
          'created_at': _instant(r.createdAt),
        },
      );
    case PersonalEntity.reminder:
      final r = await (db.select(
        db.reminders,
      )..where((x) => x.id.equals(id))).getSingleOrNull();
      if (r == null) return null;
      return (
        revision: r.revision,
        payload: {
          'id': r.id,
          'kind': r.kind.name,
          'title': r.title,
          'note': r.note,
          'due_at': _instant(r.dueAt),
          'repeat': r.repeat.name,
          'person_id': r.personId,
          'ledger_entry_id': r.ledgerEntryId,
          'group_id': r.groupId,
          'amount_paise': r.amountPaise,
          ...await _categorySnapshot(db, r.categoryId),
          'anchor_day': r.anchorDay,
          'total_occurrences': r.totalOccurrences,
          'completed_occurrences': r.completedOccurrences,
          'status': r.status.name,
          'created_at': _instant(r.createdAt),
        },
      );
    case PersonalEntity.attachment:
      final r = await (db.select(
        db.attachments,
      )..where((x) => x.id.equals(id))).getSingleOrNull();
      if (r == null) return null;
      final isTxn = r.transactionId != null;
      if (!isTxn && r.ledgerEntryId == null) return null; // group bill
      return (
        revision: r.revision,
        payload: {
          'id': r.id,
          'parent_type': isTxn ? 'transaction' : 'ledger_entry',
          'parent_id': isTxn ? r.transactionId : r.ledgerEntryId,
          'storage_name': r.storedName,
          'original_name': r.originalName,
          'mime_type': r.mimeType,
          'size_bytes': r.sizeBytes,
          'sha256': r.sha256,
          'created_at': _instant(r.createdAt),
        },
      );
  }
}
