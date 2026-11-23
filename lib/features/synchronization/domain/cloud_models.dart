import 'package:flutter/foundation.dart';

/// A signed-in Supabase identity (phone OTP verified).
@immutable
class CloudSession {
  const CloudSession({required this.userId, this.email, this.phone});

  final String userId;

  /// Verified email of the signed-in user.
  final String? email;
  final String? phone;
}

/// One local change sent to `apply_group_op` (scope `group`) or
/// `apply_personal_op` (scope `personal`, no group).
@immutable
class OutboundOp {
  const OutboundOp({
    required this.opId,
    required this.groupId,
    this.scope = 'group',
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.baseRevision,
    required this.payload,
  });

  final String opId;
  final String groupId;

  /// `group` or `personal`.
  final String scope;
  final String entityType;
  final String entityId;
  final String opType;
  final int baseRevision;
  final Map<String, Object?> payload;

  bool get isPersonal => scope == 'personal';

  /// A Family hisab change (`apply_family_op`); [groupId] holds the family id.
  bool get isFamily => scope == 'family';

  Map<String, Object?> toJson() => {
    'op_id': opId,
    if (scope == 'group') 'group_id': groupId,
    if (isFamily) 'family_id': groupId,
    'entity_type': entityType,
    'entity_id': entityId,
    'op_type': opType,
    'base_revision': baseRevision,
    'payload': payload,
  };
}

sealed class OpResult {
  const OpResult();

  static OpResult fromJson(Map<String, Object?> json) =>
      switch (json['status']) {
        'applied' => OpApplied((json['revision'] as num).toInt()),
        'conflict' => OpConflict(
          (json['revision'] as num).toInt(),
          (json['current'] as Map?)?.cast<String, Object?>(),
        ),
        _ => OpRejected(json['code'] as String? ?? 'unknown'),
      };
}

class OpApplied extends OpResult {
  const OpApplied(this.revision);
  final int revision;
}

/// The server has a newer [revision]; [current] is its version of the row.
class OpConflict extends OpResult {
  const OpConflict(this.revision, this.current);
  final int revision;
  final Map<String, Object?>? current;
}

class OpRejected extends OpResult {
  const OpRejected(this.code);
  final String code;
}

/// A change event from `sync_events` (scope `group`) or
/// `personal_sync_events` (scope `personal`, empty [groupId]).
@immutable
class RemoteEvent {
  const RemoteEvent({
    required this.seq,
    required this.groupId,
    this.scope = 'group',
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.revision,
    required this.payload,
    this.opId,
  });

  factory RemoteEvent.fromJson(
    Map<String, Object?> j, {
    String scope = 'group',
  }) => RemoteEvent(
    seq: (j['seq'] as num).toInt(),
    // Family hisab events carry `family_id`; it fills the same field.
    groupId: j['group_id'] as String? ?? j['family_id'] as String? ?? '',
    scope: scope,
    entityType: j['entity_type']! as String,
    // The personal reset event has no entity.
    entityId: j['entity_id'] as String? ?? '',
    opType: j['op_type']! as String,
    revision: (j['revision'] as num).toInt(),
    payload: (j['payload']! as Map).cast<String, Object?>(),
    opId: j['op_id'] as String?,
  );

  final int seq;
  final String groupId;

  /// `group` or `personal`.
  final String scope;
  final String entityType;
  final String entityId;
  final String opType;
  final int revision;
  final Map<String, Object?> payload;

  /// The operation that caused this event (personal feed only).
  final String? opId;
}

/// All of the user's live personal records (`get_personal_snapshot`), by
/// kind, and the feed position to continue from.
@immutable
class PersonalSnapshot {
  const PersonalSnapshot({required this.rows, required this.maxSeq});

  /// Snapshot keys in the order records must be applied (parents first).
  static const kinds = [
    'people',
    'ledger_entries',
    'ledger_repayments',
    'transactions',
    'reminders',
    'attachments',
  ];

  factory PersonalSnapshot.fromJson(Map<String, Object?> j) => PersonalSnapshot(
    rows: {
      for (final k in kinds)
        k: ((j[k] as List?) ?? const [])
            .map((e) => (e as Map).cast<String, Object?>())
            .toList(),
    },
    maxSeq: (j['max_seq'] as num? ?? 0).toInt(),
  );

  final Map<String, List<Map<String, Object?>>> rows;
  final int maxSeq;
}

/// Complete current state of one group (`get_group_snapshot`).
@immutable
class GroupSnapshot {
  const GroupSnapshot({
    required this.group,
    required this.members,
    required this.expenses,
    required this.settlements,
    required this.maxSeq,
  });

  factory GroupSnapshot.fromJson(Map<String, Object?> j) {
    List<Map<String, Object?>> list(String k) => ((j[k] as List?) ?? const [])
        .map((e) => (e as Map).cast<String, Object?>())
        .toList();
    return GroupSnapshot(
      group: (j['group']! as Map).cast<String, Object?>(),
      members: list('members'),
      expenses: list('expenses'),
      settlements: list('settlements'),
      maxSeq: (j['max_seq'] as num? ?? 0).toInt(),
    );
  }

  final Map<String, Object?> group;
  final List<Map<String, Object?>> members;
  final List<Map<String, Object?>> expenses;
  final List<Map<String, Object?>> settlements;
  final int maxSeq;
}

@immutable
class CreatedInvitation {
  const CreatedInvitation({
    required this.id,
    required this.code,
    required this.expiresAt,
  });

  final String id;
  final String code;
  final DateTime expiresAt;
}

@immutable
class InvitationInfo {
  const InvitationInfo({
    required this.id,
    required this.status,
    required this.expiresAt,
    required this.memberId,
    required this.createdAt,
  });

  final String id;
  final String status;
  final DateTime expiresAt;
  final String? memberId;
  final DateTime createdAt;
}

@immutable
class AcceptedInvitation {
  const AcceptedInvitation({
    this.groupId,
    this.familyId,
    required this.memberId,
  });

  /// `accept_invitation`: `{kind, group_id | family_id, member_id}`; no
  /// `kind` means a group (`accept_group_invitation`).
  factory AcceptedInvitation.fromJson(Map<String, Object?> j) =>
      j['kind'] == 'family'
      ? AcceptedInvitation(
          familyId: j['family_id']! as String,
          memberId: j['member_id']! as String,
        )
      : AcceptedInvitation(
          groupId: j['group_id']! as String,
          memberId: j['member_id']! as String,
        );

  /// Set for a group code.
  final String? groupId;

  /// Set for a Family hisab code.
  final String? familyId;
  final String memberId;

  bool get isFamily => familyId != null;
}

/// Full current state of one Family hisab (`get_family_snapshot`).
class FamilySnapshot {
  const FamilySnapshot({
    required this.family,
    required this.members,
    required this.entries,
    required this.maxSeq,
  });

  factory FamilySnapshot.fromJson(Map<String, Object?> j) {
    List<Map<String, Object?>> rows(Object? v) => ((v as List?) ?? const [])
        .map((e) => (e as Map).cast<String, Object?>())
        .toList();
    return FamilySnapshot(
      family: ((j['family'] as Map?) ?? const {}).cast<String, Object?>(),
      members: rows(j['members']),
      entries: rows(j['entries']),
      maxSeq: (j['max_seq'] as num? ?? 0).toInt(),
    );
  }

  final Map<String, Object?> family;
  final List<Map<String, Object?>> members;
  final List<Map<String, Object?>> entries;
  final int maxSeq;
}
