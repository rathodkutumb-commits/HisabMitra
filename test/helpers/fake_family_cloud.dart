import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';

/// In-memory mirror of `apply_family_op`, `family_sync_events` and
/// `get_family_snapshot` (verified against PostgreSQL in
/// supabase/tests/40_family_hisab_test.sql). Test-only.
class FakeFamilyStore {
  FakeFamilyStore({required this.processed});

  /// Shared with the other stores, like `processed_ops`.
  final Map<String, OpResult> processed;

  final Map<String, Map<String, Object?>> families = {};
  final Map<String, Map<String, Object?>> members = {};
  final Map<String, Map<String, Object?>> entries = {};
  final List<RemoteEvent> events = [];
  var _seq = 0;

  /// Called for every feed row (live updates in the fake cloud).
  void Function(String familyId)? onEvent;

  bool isMember(String familyId, String uid) =>
      families[familyId]?['deleted_at'] == null &&
      members.values.any(
        (m) =>
            m['family_id'] == familyId &&
            m['user_id'] == uid &&
            m['status'] == 'active' &&
            m['deleted_at'] == null,
      );

  /// The feed stays readable after the Family hisab is deleted
  /// (`is_family_reader`), so other phones learn about the delete.
  bool isReader(String familyId, String uid) => members.values.any(
    (m) =>
        m['family_id'] == familyId &&
        m['user_id'] == uid &&
        m['status'] == 'active' &&
        m['deleted_at'] == null,
  );

  bool isAdmin(String familyId, String uid) => members.values.any(
    (m) =>
        m['family_id'] == familyId &&
        m['user_id'] == uid &&
        m['status'] == 'active' &&
        m['deleted_at'] == null &&
        (m['role'] == 'owner' || m['role'] == 'admin'),
  );

  void _emit(
    String familyId,
    String type,
    String id,
    String op,
    int rev,
    Map<String, Object?> row,
    String opId,
  ) {
    onEvent?.call(familyId);
    events.add(
      RemoteEvent(
        seq: ++_seq,
        groupId: familyId,
        scope: 'family',
        entityType: type,
        entityId: id,
        opType: op,
        revision: rev,
        payload: Map.of(row),
        opId: opId,
      ),
    );
  }

  OpResult apply(OutboundOp op, String uid) {
    final done = processed[op.opId];
    if (done != null) return done;
    final result = _apply(op, uid);
    if (result is! OpRejected && result is! OpConflict) {
      processed[op.opId] = result;
    }
    return result;
  }

  static const _kinds = {'salary', 'extra_income', 'contribution', 'expense'};

  OpResult _apply(OutboundOp op, String uid) {
    final f = op.groupId;
    final p = op.payload;
    switch (op.entityType) {
      case 'family':
        final existing = families[f];
        if (existing == null || existing['deleted_at'] != null) {
          if (existing != null || op.opType != 'upsert') {
            return const OpRejected('not_found');
          }
          final ownerId = p['owner_member_id']! as String;
          families[f] = {
            'id': f,
            'name': p['name'],
            'opening_balance_paise': p['opening_balance_paise'] ?? 0,
            'owner_id': uid,
            'revision': 1,
            'deleted_at': null,
          };
          members[ownerId] = {
            'id': ownerId,
            'family_id': f,
            'user_id': uid,
            'name': p['owner_display_name'] ?? 'Owner',
            'phone': null,
            'role': 'owner',
            'status': 'active',
            'sort_order': 0,
            'revision': 1,
            'deleted_at': null,
          };
          _emit(f, 'family', f, 'upsert', 1, families[f]!, op.opId);
          _emit(f, 'member', ownerId, 'upsert', 1, members[ownerId]!, op.opId);
          return const OpApplied(1);
        }
        if (!isAdmin(f, uid)) return const OpRejected('forbidden');
        final rev = existing['revision']! as int;
        if (rev != op.baseRevision) return OpConflict(rev, Map.of(existing));
        if (op.opType == 'delete') {
          existing
            ..['deleted_at'] = '2026-01-01T00:00:00Z'
            ..['revision'] = rev + 1;
          _emit(f, 'family', f, 'delete', rev + 1, existing, op.opId);
        } else {
          existing
            ..['name'] = p['name']
            ..['opening_balance_paise'] =
                p['opening_balance_paise'] ?? existing['opening_balance_paise']
            ..['revision'] = rev + 1;
          _emit(f, 'family', f, 'upsert', rev + 1, existing, op.opId);
        }
        return OpApplied(rev + 1);

      case 'member':
        if (!isMember(f, uid) || !isAdmin(f, uid)) {
          return const OpRejected('forbidden');
        }
        final m = members[op.entityId];
        final live = m != null && m['deleted_at'] == null;
        if (op.opType == 'delete') {
          if (!live) return const OpRejected('not_found');
          if (m['role'] == 'owner') return const OpRejected('forbidden');
          final rev = m['revision']! as int;
          if (rev != op.baseRevision) return OpConflict(rev, Map.of(m));
          m
            ..['status'] = 'removed'
            ..['deleted_at'] = '2026-01-01T00:00:00Z'
            ..['revision'] = rev + 1;
          _emit(f, 'member', op.entityId, 'delete', rev + 1, m, op.opId);
          return OpApplied(rev + 1);
        }
        if (live) {
          final rev = m['revision']! as int;
          if (rev != op.baseRevision) return OpConflict(rev, Map.of(m));
          m
            ..['name'] = p['name']
            ..['phone'] = p['phone']
            ..['sort_order'] = p['sort_order'] ?? m['sort_order']
            ..['revision'] = rev + 1;
          _emit(f, 'member', op.entityId, 'upsert', rev + 1, m, op.opId);
          return OpApplied(rev + 1);
        }
        if (m != null) return const OpRejected('not_found');
        members[op.entityId] = {
          'id': op.entityId,
          'family_id': f,
          'user_id': null,
          'name': p['name'],
          'phone': p['phone'],
          'role': 'member',
          'status': 'active',
          'sort_order': p['sort_order'] ?? 0,
          'revision': 1,
          'deleted_at': null,
        };
        _emit(
          f,
          'member',
          op.entityId,
          'upsert',
          1,
          members[op.entityId]!,
          op.opId,
        );
        return const OpApplied(1);

      case 'entry':
        if (!isMember(f, uid)) return const OpRejected('forbidden');
        final e = entries[op.entityId];
        final live = e != null && e['deleted_at'] == null;
        if (op.opType == 'delete') {
          if (!live) return const OpApplied(0);
          final rev = e['revision']! as int;
          if (rev != op.baseRevision) return OpConflict(rev, Map.of(e));
          e
            ..['deleted_at'] = '2026-01-01T00:00:00Z'
            ..['revision'] = rev + 1;
          _emit(f, 'entry', op.entityId, 'delete', rev + 1, e, op.opId);
          return OpApplied(rev + 1);
        }
        final member = members[p['member_id']];
        if (member == null || member['family_id'] != f) {
          return const OpRejected('invalid_reference');
        }
        final kind = p['kind'];
        final amount = p['amount_paise'];
        final isExpense = kind == 'expense';
        if (!_kinds.contains(kind) ||
            amount is! int ||
            amount <= 0 ||
            isExpense !=
                (p['category_id'] != null && p['category_name'] != null)) {
          return const OpRejected('invalid_data');
        }
        if (live) {
          final rev = e['revision']! as int;
          if (rev != op.baseRevision) return OpConflict(rev, Map.of(e));
          e
            ..addAll(p)
            ..['revision'] = rev + 1;
          _emit(f, 'entry', op.entityId, 'upsert', rev + 1, e, op.opId);
          return OpApplied(rev + 1);
        }
        if (e != null) return const OpRejected('not_found');
        entries[op.entityId] = {
          ...p,
          'id': op.entityId,
          'family_id': f,
          'created_by': uid,
          'revision': 1,
          'deleted_at': null,
        };
        _emit(
          f,
          'entry',
          op.entityId,
          'upsert',
          1,
          entries[op.entityId]!,
          op.opId,
        );
        return const OpApplied(1);
    }
    return const OpRejected('bad_request');
  }

  /// `can_read_family_event`: readers see the feed; a removed person still
  /// sees the events of their own person row (their removal).
  bool canRead(RemoteEvent e, String uid) =>
      isReader(e.groupId, uid) ||
      (e.entityType == 'member' && members[e.entityId]?['user_id'] == uid);

  List<RemoteEvent> pull(String uid, int afterSeq, int limit) => events
      .where((e) => e.seq > afterSeq && canRead(e, uid))
      .take(limit)
      .toList();

  // ------------------------------------------------------------------ bills

  /// Files in `family-attachments` and `family_attachments` rows.
  final Map<String, List<int>> files = {};
  final Map<String, Map<String, Object?>> attachments = {};

  void registerAttachment(Map<String, Object?> p, String uid) {
    final f = p['family_id']! as String;
    if (!isMember(f, uid)) throw const ValidationFailure('forbidden');
    final id = p['id']! as String;
    if (attachments.containsKey(id)) return;
    final entry = entries[p['entry_id']];
    if (entry == null ||
        entry['family_id'] != f ||
        entry['deleted_at'] != null) {
      throw const ValidationFailure('invalid_entry');
    }
    if (!files.containsKey(p['storage_path'])) {
      throw const ValidationFailure('invalid_path');
    }
    attachments[id] = {...p, 'deleted_at': null};
    _emit(f, 'attachment', id, 'upsert', 1, attachments[id]!, 'bill-$id');
  }

  void deleteAttachment(String id, String uid) {
    final a = attachments[id];
    if (a == null || a['deleted_at'] != null) return;
    final f = a['family_id']! as String;
    if (!isMember(f, uid)) throw const ValidationFailure('forbidden');
    a['deleted_at'] = '2026-01-01T00:00:00Z';
    files.remove(a['storage_path']);
    _emit(f, 'attachment', id, 'delete', 2, a, 'bill-del-$id');
  }

  // ------------------------------------------------------------ invitations

  /// Codes of `family_invitations` (plain, as the inviter sees them).
  final Map<
    String,
    ({String id, String familyId, String? memberId, String status})
  >
  invitations = {};
  var _codes = 0;
  var _joined = 0;

  String createInvitation(String familyId, String? memberId, String uid) {
    if (!isMember(familyId, uid) || !isAdmin(familyId, uid)) {
      throw const ValidationFailure('forbidden');
    }
    if (memberId != null) {
      final m = members[memberId];
      if (m == null ||
          m['family_id'] != familyId ||
          m['user_id'] != null ||
          m['status'] != 'active') {
        throw const ValidationFailure('invalid_member');
      }
      if (invitations.values.any(
        (i) => i.memberId == memberId && i.status == 'pending',
      )) {
        throw const ValidationFailure('invitation_pending');
      }
    }
    final code = 'FAMCODE${(_codes++).toString().padLeft(3, '0')}';
    invitations[code] = (
      id: 'finv-$_codes',
      familyId: familyId,
      memberId: memberId,
      status: 'pending',
    );
    return code;
  }

  List<InvitationInfo> listInvitations(String familyId) => [
    for (final i in invitations.values)
      if (i.familyId == familyId)
        InvitationInfo(
          id: i.id,
          status: i.status,
          expiresAt: DateTime(2030),
          memberId: i.memberId,
          createdAt: DateTime(2026),
        ),
  ];

  void cancelInvitation(String id) {
    final code = invitations.keys.firstWhere((k) => invitations[k]!.id == id);
    final i = invitations[code]!;
    invitations[code] = (
      id: i.id,
      familyId: i.familyId,
      memberId: i.memberId,
      status: 'cancelled',
    );
  }

  AcceptedInvitation accept(String code, String uid, String name) {
    final inv = invitations[code];
    if (inv == null ||
        inv.status != 'pending' ||
        families[inv.familyId]?['deleted_at'] != null) {
      throw const ValidationFailure('invalid_code');
    }
    if (isMember(inv.familyId, uid)) {
      throw const ValidationFailure('already_member');
    }
    final String memberId;
    if (inv.memberId != null) {
      final m = members[inv.memberId];
      if (m == null || m['user_id'] != null || m['status'] != 'active') {
        throw const ValidationFailure('invalid_code');
      }
      m
        ..['user_id'] = uid
        ..['revision'] = (m['revision']! as int) + 1;
      memberId = inv.memberId!;
    } else {
      memberId = 'fm-joined-${++_joined}';
      members[memberId] = {
        'id': memberId,
        'family_id': inv.familyId,
        'user_id': uid,
        'name': name,
        'phone': null,
        'role': 'member',
        'status': 'active',
        'sort_order': 99,
        'revision': 1,
        'deleted_at': null,
      };
    }
    invitations[code] = (
      id: inv.id,
      familyId: inv.familyId,
      memberId: inv.memberId,
      status: 'accepted',
    );
    final m = members[memberId]!;
    _emit(
      inv.familyId,
      'member',
      memberId,
      'upsert',
      m['revision']! as int,
      m,
      'accept-$code',
    );
    return AcceptedInvitation(familyId: inv.familyId, memberId: memberId);
  }

  /// `set_family_member_role`.
  void setRole(String memberId, String role, String uid) {
    final m = members[memberId];
    final f = m == null ? null : families[m['family_id']];
    if (m == null || f == null || f['owner_id'] != uid) {
      throw const ValidationFailure('forbidden');
    }
    if (m['role'] == 'owner' ||
        m['user_id'] == null ||
        m['status'] != 'active') {
      throw const ValidationFailure('forbidden');
    }
    if (role != 'admin' && role != 'member') {
      throw const ValidationFailure('invalid_data');
    }
    m
      ..['role'] = role
      ..['revision'] = (m['revision']! as int) + 1;
    _emit(
      m['family_id']! as String,
      'member',
      memberId,
      'upsert',
      m['revision']! as int,
      m,
      'role-$memberId-${m['revision']}',
    );
  }

  FamilySnapshot snapshot(String familyId, String uid) {
    if (!isMember(familyId, uid)) throw StateError('forbidden');
    return FamilySnapshot(
      family: Map.of(families[familyId]!),
      members: [
        for (final m in members.values)
          if (m['family_id'] == familyId) Map.of(m),
      ],
      entries: [
        for (final e in entries.values)
          if (e['family_id'] == familyId && e['deleted_at'] == null) Map.of(e),
      ],
      attachments: [
        for (final a in attachments.values)
          if (a['family_id'] == familyId &&
              a['deleted_at'] == null &&
              entries[a['entry_id']]?['deleted_at'] == null)
            Map.of(a),
      ],
      maxSeq: events
          .where((e) => e.groupId == familyId)
          .fold(0, (m, e) => e.seq > m ? e.seq : m),
    );
  }
}
