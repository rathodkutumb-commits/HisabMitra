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

/// One local change sent to `apply_group_op`.
@immutable
class OutboundOp {
  const OutboundOp({
    required this.opId,
    required this.groupId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.baseRevision,
    required this.payload,
  });

  final String opId;
  final String groupId;
  final String entityType;
  final String entityId;
  final String opType;
  final int baseRevision;
  final Map<String, Object?> payload;

  Map<String, Object?> toJson() => {
    'op_id': opId,
    'group_id': groupId,
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

/// A change event from `sync_events`.
@immutable
class RemoteEvent {
  const RemoteEvent({
    required this.seq,
    required this.groupId,
    required this.entityType,
    required this.entityId,
    required this.opType,
    required this.revision,
    required this.payload,
  });

  factory RemoteEvent.fromJson(Map<String, Object?> j) => RemoteEvent(
    seq: (j['seq'] as num).toInt(),
    groupId: j['group_id']! as String,
    entityType: j['entity_type']! as String,
    entityId: j['entity_id']! as String,
    opType: j['op_type']! as String,
    revision: (j['revision'] as num).toInt(),
    payload: (j['payload']! as Map).cast<String, Object?>(),
  );

  final int seq;
  final String groupId;
  final String entityType;
  final String entityId;
  final String opType;
  final int revision;
  final Map<String, Object?> payload;
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
  const AcceptedInvitation({required this.groupId, required this.memberId});

  final String groupId;
  final String memberId;
}
