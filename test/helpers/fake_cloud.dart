import 'dart:async';

import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/features/synchronization/data/cloud_gateway.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';

import 'fake_personal_cloud.dart';

/// In-memory server mirroring `apply_group_op` / `sync_events` semantics
/// (verified against PostgreSQL in supabase/tests). Test-only.
class FakeCloudServer {
  final Map<String, Map<String, Object?>> groups = {};
  final Map<String, Map<String, Object?>> members = {};
  final Map<String, Map<String, Object?>> expenses = {};
  final Map<String, Map<String, Object?>> settlements = {};
  final List<RemoteEvent> events = [];
  final Map<String, OpResult> processed = {};
  final Map<String, ({String groupId, String? memberId, bool used})>
  invitations = {};
  var _seq = 0;
  var _codes = 0;

  /// Personal records of every user (`apply_personal_op` and its feed).
  late final personal = FakePersonalStore(
    processed: processed,
    isMember: isMember,
  )..onEvent = (owner) => _changes.add((groupId: null, owner: owner));

  /// Every new feed row, like Supabase Realtime before RLS is applied.
  final _changes =
      StreamController<({String? groupId, String? owner})>.broadcast();
  Stream<({String? groupId, String? owner})> get changes => _changes.stream;

  /// Files in `group-attachments`, keyed by storage path.
  final Map<String, List<int>> groupFiles = {};

  /// When true the server applies the next op but the response is "lost".
  var dropNextResponse = false;

  bool isMember(String groupId, String uid) => members.values.any(
    (m) =>
        m['group_id'] == groupId &&
        m['user_id'] == uid &&
        m['deleted_at'] == null,
  );

  Map<String, Object?> _table(String type) => switch (type) {
    'member' => members,
    'expense' => expenses,
    'settlement' => settlements,
    _ => groups,
  };

  void _emit(
    String groupId,
    String type,
    String id,
    String op,
    int rev,
    Map<String, Object?> payload,
  ) {
    _changes.add((groupId: groupId, owner: null));
    events.add(
      RemoteEvent(
        seq: ++_seq,
        groupId: groupId,
        entityType: type,
        entityId: id,
        opType: op,
        revision: rev,
        payload: Map.of(payload),
      ),
    );
  }

  OpResult apply(OutboundOp op, String uid) {
    final done = processed[op.opId];
    if (done != null) return done;
    final result = _apply(op, uid);
    if (result is! OpRejected) processed[op.opId] = result;
    return result;
  }

  OpResult _apply(OutboundOp op, String uid) {
    final p = op.payload;
    if (op.entityType == 'group') {
      final existing = groups[op.groupId];
      if (existing == null) {
        groups[op.groupId] =
            {
                ...p,
                'id': op.groupId,
                'owner_id': uid,
                'revision': 1,
                'deleted_at': null,
              }
              ..remove('owner_member_id')
              ..remove('owner_display_name');
        final ownerId = p['owner_member_id']! as String;
        members[ownerId] = {
          'id': ownerId,
          'group_id': op.groupId,
          'user_id': uid,
          'display_name': p['owner_display_name'],
          'role': 'owner',
          'status': 'active',
          'sort_order': 0,
          'revision': 1,
          'deleted_at': null,
        };
        _emit(
          op.groupId,
          'group',
          op.groupId,
          'upsert',
          1,
          groups[op.groupId]!,
        );
        _emit(op.groupId, 'member', ownerId, 'upsert', 1, members[ownerId]!);
        return const OpApplied(1);
      }
      if (!isMember(op.groupId, uid)) return const OpRejected('forbidden');
      final rev = existing['revision']! as int;
      if (rev != op.baseRevision) return OpConflict(rev, Map.of(existing));
      existing
        ..addAll(p)
        ..remove('owner_member_id')
        ..remove('owner_display_name')
        ..['revision'] = rev + 1;
      _emit(op.groupId, 'group', op.groupId, 'upsert', rev + 1, existing);
      return OpApplied(rev + 1);
    }
    if (!isMember(op.groupId, uid)) return const OpRejected('forbidden');
    final table = _table(op.entityType);
    final existing = table[op.entityId] as Map<String, Object?>?;
    final live = existing != null && existing['deleted_at'] == null;
    if (op.opType == 'delete') {
      if (!live) return const OpRejected('not_found');
      final rev = existing['revision']! as int;
      if (rev != op.baseRevision) return OpConflict(rev, Map.of(existing));
      existing
        ..['deleted_at'] = '2026-01-01T00:00:00Z'
        ..['revision'] = rev + 1;
      _emit(
        op.groupId,
        op.entityType,
        op.entityId,
        'delete',
        rev + 1,
        existing,
      );
      return OpApplied(rev + 1);
    }
    if (op.entityType == 'expense') {
      final splits = (p['splits']! as List).cast<Map<String, Object?>>();
      final sum = splits.fold<int>(0, (a, s) => a + (s['share_paise']! as int));
      if (sum != p['amount_paise']) return const OpRejected('split_mismatch');
    }
    if (!live) {
      if (existing != null) return const OpRejected('not_found');
      table[op.entityId] = {
        ...p,
        'id': op.entityId,
        'group_id': op.groupId,
        if (op.entityType == 'member') 'user_id': null,
        'revision': 1,
        'deleted_at': null,
      };
      _emit(
        op.groupId,
        op.entityType,
        op.entityId,
        'upsert',
        1,
        table[op.entityId]! as Map<String, Object?>,
      );
      return const OpApplied(1);
    }
    final rev = existing['revision']! as int;
    if (rev != op.baseRevision) return OpConflict(rev, Map.of(existing));
    final userId = existing['user_id'];
    existing
      ..addAll(p)
      ..['revision'] = rev + 1;
    if (op.entityType == 'member') existing['user_id'] = userId;
    _emit(op.groupId, op.entityType, op.entityId, 'upsert', rev + 1, existing);
    return OpApplied(rev + 1);
  }

  String createInvitation(String groupId, String? memberId) {
    final code = 'CODE${(_codes++).toString().padLeft(4, '0')}';
    invitations[code] = (groupId: groupId, memberId: memberId, used: false);
    return code;
  }

  AcceptedInvitation accept(String code, String uid, String name) {
    final inv = invitations[code];
    if (inv == null || inv.used) throw const ValidationFailure('invalid_code');
    invitations[code] = (
      groupId: inv.groupId,
      memberId: inv.memberId,
      used: true,
    );
    final memberId = inv.memberId ?? 'm-$uid';
    final m =
        members[memberId] ??
        {
          'id': memberId,
          'group_id': inv.groupId,
          'display_name': name,
          'role': 'member',
          'status': 'active',
          'sort_order': 9,
          'revision': 0,
          'deleted_at': null,
        };
    m['user_id'] = uid;
    m['revision'] = (m['revision']! as int) + 1;
    members[memberId] = m;
    _emit(inv.groupId, 'member', memberId, 'upsert', m['revision']! as int, m);
    return AcceptedInvitation(groupId: inv.groupId, memberId: memberId);
  }

  GroupSnapshot snapshot(String groupId, String uid) {
    if (!isMember(groupId, uid)) throw const AuthFailure('forbidden');
    return GroupSnapshot(
      group: Map.of(groups[groupId]!),
      members: [
        for (final m in members.values)
          if (m['group_id'] == groupId) Map.of(m),
      ],
      expenses: [
        for (final e in expenses.values)
          if (e['group_id'] == groupId) Map.of(e),
      ],
      settlements: [
        for (final s in settlements.values)
          if (s['group_id'] == groupId) Map.of(s),
      ],
      maxSeq: events
          .where((e) => e.groupId == groupId)
          .fold(0, (m, e) => e.seq > m ? e.seq : m),
    );
  }
}

/// One signed-in device talking to [FakeCloudServer].
class FakeCloudClient implements CloudGateway {
  FakeCloudClient(this.server, this.userId);

  final FakeCloudServer server;
  final String userId;
  var online = true;
  final applied = <String>[];

  void _net() {
    if (!online) throw const NetworkFailure();
  }

  @override
  bool get isConfigured => true;
  @override
  CloudSession? get currentSession =>
      CloudSession(userId: userId, email: '$userId@example.com');
  @override
  Stream<CloudSession?> get sessionChanges => const Stream.empty();

  @override
  Future<OpResult> applyOp(OutboundOp op) async {
    _net();
    final r = op.isPersonal
        ? server.personal.apply(op, userId)
        : server.apply(op, userId);
    applied.add(op.opId);
    if (server.dropNextResponse) {
      server.dropNextResponse = false;
      throw const NetworkFailure();
    }
    return r;
  }

  @override
  Future<List<RemoteEvent>> pullEvents({
    required int afterSeq,
    int limit = 500,
  }) async {
    _net();
    return server.events
        .where((e) => e.seq > afterSeq && server.isMember(e.groupId, userId))
        .take(limit)
        .toList();
  }

  @override
  Future<GroupSnapshot> fetchGroupSnapshot(String groupId) async {
    _net();
    return server.snapshot(groupId, userId);
  }

  @override
  Future<List<RemoteEvent>> pullPersonalEvents({
    required int afterSeq,
    int limit = 500,
  }) async {
    _net();
    return server.personal.pull(userId, afterSeq, limit);
  }

  @override
  Future<PersonalSnapshot> fetchPersonalSnapshot() async {
    _net();
    return server.personal.snapshot(userId);
  }

  /// Rows of this user's groups (membership checked on delivery, like RLS)
  /// and of their own records.
  @override
  Stream<void> changeSignals() => server.changes
      .where(
        (c) => c.groupId != null
            ? server.isMember(c.groupId!, userId)
            : c.owner == userId,
      )
      .map((_) {});

  /// Names of personal files this device uploaded, in order.
  final uploadedFiles = <String>[];

  /// When true, file uploads fail like a dropped connection.
  var failFileUploads = false;

  @override
  Future<void> uploadPersonalFile({
    required String storageName,
    required List<int> bytes,
    required String mimeType,
  }) async {
    _net();
    if (failFileUploads) throw const NetworkFailure();
    server.personal.files['$userId/$storageName'] = List.of(bytes);
    uploadedFiles.add(storageName);
  }

  @override
  Future<List<int>> downloadPersonalFile(String storageName) async {
    _net();
    final f = server.personal.files['$userId/$storageName'];
    if (f == null) throw const NotFoundFailure();
    return f;
  }

  @override
  Future<void> deletePersonalFile(String storageName) async {
    _net();
    server.personal.files.remove('$userId/$storageName');
  }

  @override
  Future<AcceptedInvitation> acceptInvitation({
    required String code,
    required String displayName,
  }) async {
    _net();
    return server.accept(code, userId, displayName);
  }

  @override
  Future<CreatedInvitation> createInvitation({
    required String groupId,
    String? memberId,
  }) async {
    _net();
    return CreatedInvitation(
      id: 'inv',
      code: server.createInvitation(groupId, memberId),
      expiresAt: DateTime(2030),
    );
  }

  @override
  Future<void> requestEmailCode(
    String email, {
    required String redirectTo,
  }) async => _net();
  @override
  Future<CloudSession> verifyEmailCode({
    required String email,
    required String code,
  }) async => currentSession!;
  @override
  Future<CloudSession> completeEmailLink(String authCode) async =>
      currentSession!;
  @override
  Future<void> signOut() async {}
  @override
  Future<void> upsertProfile({
    required String displayName,
    required String phone,
    required String deviceId,
    required String appVersion,
  }) async => _net();
  @override
  Future<List<InvitationInfo>> listInvitations(String groupId) async =>
      const [];
  @override
  Future<void> cancelInvitation(String invitationId) async {}
  @override
  Future<void> uploadGroupAttachment({
    required String storagePath,
    required List<int> bytes,
    required String mimeType,
    required Map<String, Object?> metadata,
  }) async {
    _net();
    if (failFileUploads) throw const NetworkFailure();
    server.groupFiles[storagePath] = List.of(bytes);
  }

  @override
  Future<List<int>> downloadGroupAttachment(String storagePath) async {
    _net();
    final f = server.groupFiles[storagePath];
    if (f == null) throw const NotFoundFailure();
    return f;
  }

  @override
  Future<void> deleteAccount() async {}
}
