import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';

/// In-memory mirror of `apply_personal_op`, `personal_sync_events` and
/// `get_personal_snapshot` (verified against PostgreSQL in
/// supabase/tests/20_personal_data_test.sql). Test-only.
class FakePersonalStore {
  FakePersonalStore({required this.processed, required this.isMember});

  /// Shared with the group store, like `processed_ops`.
  final Map<String, OpResult> processed;
  final bool Function(String groupId, String uid) isMember;

  /// type → id → row (rows carry `owner_id`, `revision`, `deleted_at`).
  final Map<String, Map<String, Map<String, Object?>>> rows = {
    for (final t in _types) t: {},
  };
  final List<({String owner, RemoteEvent event})> events = [];

  /// Called for every feed row (live updates in the fake cloud).
  void Function(String owner)? onEvent;

  /// Files in `personal-attachments`, keyed `<uid>/<name>`.
  final Map<String, List<int>> files = {};
  var _seq = 0;

  static const _types = [
    'person',
    'transaction',
    'ledger_entry',
    'ledger_repayment',
    'reminder',
    'attachment',
  ];

  static const _snapshotKey = {
    'person': 'people',
    'transaction': 'transactions',
    'ledger_entry': 'ledger_entries',
    'ledger_repayment': 'ledger_repayments',
    'reminder': 'reminders',
    'attachment': 'attachments',
  };

  /// Live rows of [type] for [uid] (test helper).
  List<Map<String, Object?>> live(String type, String uid) => [
    for (final r in rows[type]!.values)
      if (r['owner_id'] == uid && r['deleted_at'] == null) r,
  ];

  void _emit(
    String owner,
    String type,
    String id,
    String op,
    int rev,
    Map<String, Object?> payload,
    String opId,
  ) {
    onEvent?.call(owner);
    events.add((
      owner: owner,
      event: RemoteEvent(
        seq: ++_seq,
        groupId: '',
        scope: 'personal',
        entityType: type,
        entityId: id,
        opType: op,
        revision: rev,
        payload: Map.of(payload),
        opId: opId,
      ),
    ));
  }

  OpResult apply(OutboundOp op, String uid) {
    final done = processed[op.opId];
    if (done != null) return done;
    final result = _apply(op, uid);
    if (result is! OpRejected) processed[op.opId] = result;
    return result;
  }

  bool _owns(String uid, String type, Object? id) {
    if (id == null) return true;
    final r = rows[type]![id];
    return r != null && r['owner_id'] == uid && r['deleted_at'] == null;
  }

  int? _tombstone(String uid, String type, String id, String opId) {
    final r = rows[type]![id];
    if (r == null || r['deleted_at'] != null) return null;
    final rev = (r['revision']! as int) + 1;
    r
      ..['deleted_at'] = '2026-01-01T00:00:00Z'
      ..['revision'] = rev;
    _emit(uid, type, id, 'delete', rev, r, opId);
    return rev;
  }

  void _unlink(String uid, String type, String id, String column, String opId) {
    final r = rows[type]![id];
    if (r == null || r['deleted_at'] != null) return;
    final rev = (r['revision']! as int) + 1;
    r
      ..[column] = null
      ..['revision'] = rev;
    _emit(uid, type, id, 'upsert', rev, r, opId);
  }

  Iterable<String> _ids(
    String type,
    String uid,
    bool Function(Map<String, Object?>) test,
  ) => [
    for (final r in rows[type]!.values)
      if (r['owner_id'] == uid && r['deleted_at'] == null && test(r))
        r['id']! as String,
  ];

  int? _delete(String uid, String type, String id, String opId) {
    if (type == 'person') {
      for (final l in _ids('ledger_entry', uid, (r) => r['person_id'] == id)) {
        _delete(uid, 'ledger_entry', l, opId);
      }
      for (final t in _ids('transaction', uid, (r) => r['person_id'] == id)) {
        _unlink(uid, 'transaction', t, 'person_id', opId);
      }
      for (final m in _ids('reminder', uid, (r) => r['person_id'] == id)) {
        _unlink(uid, 'reminder', m, 'person_id', opId);
      }
    } else if (type == 'transaction') {
      for (final a in _ids(
        'attachment',
        uid,
        (r) => r['parent_type'] == 'transaction' && r['parent_id'] == id,
      )) {
        _tombstone(uid, 'attachment', a, opId);
      }
    } else if (type == 'ledger_entry') {
      for (final x in _ids(
        'ledger_repayment',
        uid,
        (r) => r['ledger_id'] == id,
      )) {
        _tombstone(uid, 'ledger_repayment', x, opId);
      }
      for (final a in _ids(
        'attachment',
        uid,
        (r) => r['parent_type'] == 'ledger_entry' && r['parent_id'] == id,
      )) {
        _tombstone(uid, 'attachment', a, opId);
      }
      for (final m in _ids(
        'reminder',
        uid,
        (r) => r['ledger_entry_id'] == id,
      )) {
        _tombstone(uid, 'reminder', m, opId);
      }
    }
    return _tombstone(uid, type, id, opId);
  }

  OpResult _apply(OutboundOp op, String uid) {
    if (op.opType == 'reset') {
      for (final t in _types) {
        for (final r in rows[t]!.values) {
          if (r['owner_id'] == uid && r['deleted_at'] == null) {
            r
              ..['deleted_at'] = '2026-01-01T00:00:00Z'
              ..['revision'] = (r['revision']! as int) + 1;
          }
        }
      }
      onEvent?.call(uid);
      events.add((
        owner: uid,
        event: RemoteEvent(
          seq: ++_seq,
          groupId: '',
          scope: 'personal',
          entityType: 'all',
          entityId: '',
          opType: 'reset',
          revision: 0,
          payload: const {},
          opId: op.opId,
        ),
      ));
      return const OpApplied(0);
    }
    final table = rows[op.entityType];
    if (table == null) return const OpRejected('bad_request');
    final existing = table[op.entityId];
    if (existing != null && existing['owner_id'] != uid) {
      return const OpRejected('not_found');
    }
    final rev = existing?['revision'] as int?;
    final deleted = existing?['deleted_at'] != null;

    if (op.opType == 'delete') {
      if (existing == null) return const OpApplied(0);
      if (deleted) return OpApplied(rev!);
      if (rev != op.baseRevision) return OpConflict(rev!, Map.of(existing));
      return OpApplied(_delete(uid, op.entityType, op.entityId, op.opId)!);
    }

    if (existing != null && !(deleted && op.baseRevision == 0)) {
      if (deleted || rev != op.baseRevision) {
        return OpConflict(rev!, Map.of(existing));
      }
    }
    final p = op.payload;
    for (final k in ['amount_paise', 'principal_paise']) {
      final v = p[k];
      if (v is int && v <= 0) return const OpRejected('invalid_data');
    }
    final refsOk = switch (op.entityType) {
      'transaction' => _owns(uid, 'person', p['person_id']),
      'ledger_entry' =>
        p['person_id'] != null && _owns(uid, 'person', p['person_id']),
      'ledger_repayment' =>
        p['ledger_id'] != null && _owns(uid, 'ledger_entry', p['ledger_id']),
      'reminder' =>
        _owns(uid, 'person', p['person_id']) &&
            _owns(uid, 'ledger_entry', p['ledger_entry_id']) &&
            (p['group_id'] == null || isMember(p['group_id']! as String, uid)),
      'attachment' =>
        p['parent_id'] != null &&
            (p['parent_type'] == 'transaction' ||
                p['parent_type'] == 'ledger_entry') &&
            _owns(uid, p['parent_type']! as String, p['parent_id']),
      _ => true,
    };
    if (!refsOk) return const OpRejected('invalid_reference');

    final newRev = (rev ?? 0) + 1;
    table[op.entityId] = {
      ...switch (op.entityType) {
        'transaction' || 'ledger_entry' => {'description': ''},
        'reminder' => {
          'repeat': 'none',
          'completed_occurrences': 0,
          'status': 'pending',
        },
        _ => <String, Object?>{},
      },
      ...p,
      'id': op.entityId,
      'owner_id': uid,
      'revision': newRev,
      'deleted_at': null,
      if (op.entityType == 'attachment')
        'storage_path': '$uid/${p['storage_name']}',
    };
    _emit(
      uid,
      op.entityType,
      op.entityId,
      'upsert',
      newRev,
      table[op.entityId]!,
      op.opId,
    );
    return OpApplied(newRev);
  }

  List<RemoteEvent> pull(String uid, int afterSeq, int limit) => [
    for (final e in events)
      if (e.owner == uid && e.event.seq > afterSeq) e.event,
  ].take(limit).toList();

  PersonalSnapshot snapshot(String uid) => PersonalSnapshot(
    rows: {
      for (final t in _types)
        _snapshotKey[t]!: [for (final r in live(t, uid)) Map.of(r)],
    },
    maxSeq: events
        .where((e) => e.owner == uid)
        .fold(0, (m, e) => e.event.seq > m ? e.event.seq : m),
  );
}
