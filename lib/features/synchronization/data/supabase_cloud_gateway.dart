import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/config/app_config.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/security/safe_logger.dart';
import '../../authentication/data/secure_session_storage.dart';
import '../domain/cloud_models.dart';
import 'cloud_gateway.dart';

/// [CloudGateway] backed by Supabase (Auth, PostgREST RPC, Storage, Edge
/// Functions). Uses only the public anon key; authorisation is enforced by
/// RLS and SECURITY DEFINER functions on the server.
class SupabaseCloudGateway implements CloudGateway {
  SupabaseCloudGateway(this._client);

  final SupabaseClient _client;
  static var _initialized = false;
  static const _timeout = Duration(seconds: 20);
  static const _bucket = 'group-attachments';

  /// Initialises Supabase once (called from `main`). Safe to call when the
  /// build is not configured — it simply does nothing.
  static Future<bool> initialize() async {
    if (_initialized) return true;
    if (!AppConfig.isCloudConfigured) return false;
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabasePublishableKey,
        authOptions: const FlutterAuthClientOptions(
          localStorage: SecureSessionStorage(),
          detectSessionInUri: false,
        ),
      );
      _initialized = true;
    } catch (e, s) {
      SafeLogger.error('supabase_init', e, s);
    }
    return _initialized;
  }

  static bool get isInitialized => _initialized;

  // ----------------------------------------------------------- errors

  Future<T> _call<T>(Future<T> Function() body) async {
    try {
      return await body().timeout(_timeout);
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    } on HandshakeException {
      throw const NetworkFailure();
    } on AuthException catch (e) {
      throw _authFailure(e);
    } on PostgrestException catch (e) {
      throw _dbFailure(e.message, e.code);
    } on StorageException catch (e) {
      SafeLogger.info('storage_error', {'status': e.statusCode});
      throw const ValidationFailure('cloud_storage');
    } on FunctionException catch (e) {
      SafeLogger.info('function_error', {'status': e.status});
      throw const UnexpectedFailure();
    }
  }

  static AppFailure _authFailure(AuthException e) {
    final code = (e.code ?? '').toLowerCase();
    final message = e.message.toLowerCase();
    if (e is AuthRetryableFetchException) return const NetworkFailure();
    if (e.statusCode == '429' || code.contains('rate_limit')) {
      return const AuthFailure('rate_limited');
    }
    // Supabase's built-in mailer only delivers to the project's team until
    // a custom SMTP sender is configured.
    if (code == 'email_address_not_authorized' ||
        message.contains('not authorized')) {
      return const AuthFailure('email_not_authorized');
    }
    if (code == 'email_address_invalid' ||
        (message.contains('email') && message.contains('invalid'))) {
      return const AuthFailure('invalid_email');
    }
    if (code == 'flow_state_not_found' ||
        code == 'flow_state_expired' ||
        code == 'bad_code_verifier') {
      return const AuthFailure('link_invalid');
    }
    if (code == 'otp_expired' || message.contains('expired')) {
      return const AuthFailure('otp_expired');
    }
    if (code.contains('otp') ||
        message.contains('invalid') ||
        message.contains('token')) {
      return const AuthFailure('invalid_otp');
    }
    if (code.contains('phone')) return const AuthFailure('invalid_phone');
    if (e is AuthSessionMissingException) {
      return const AuthFailure('session_expired');
    }
    return const AuthFailure('unknown');
  }

  /// Server functions raise short codes (`forbidden`, `invalid_code`, …).
  static AppFailure _dbFailure(String message, String? code) {
    const known = {
      'forbidden',
      'invalid_code',
      'expired',
      'already_member',
      'invitation_pending',
      'invalid_member',
      'invalid_data',
      'not_authenticated',
    };
    if (code == 'PGRST301' || message == 'not_authenticated') {
      return const AuthFailure('session_expired');
    }
    if (known.contains(message)) return ValidationFailure(message);
    SafeLogger.info('db_error', {'code': code});
    return const UnexpectedFailure();
  }

  // ------------------------------------------------------------- auth

  @override
  bool get isConfigured => true;

  static CloudSession? _toSession(Session? s) =>
      s == null ? null : CloudSession(userId: s.user.id, email: s.user.email);

  @override
  CloudSession? get currentSession => _toSession(_client.auth.currentSession);

  @override
  Stream<CloudSession?> get sessionChanges =>
      _client.auth.onAuthStateChange.map((s) => _toSession(s.session));

  @override
  Future<void> requestEmailCode(String email, {required String redirectTo}) =>
      _call(
        () => _client.auth.signInWithOtp(
          email: email,
          emailRedirectTo: redirectTo,
          shouldCreateUser: true,
        ),
      );

  @override
  Future<CloudSession> verifyEmailCode({
    required String email,
    required String code,
  }) => _call(() async {
    final res = await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
    final session = _toSession(res.session);
    if (session == null) throw const AuthFailure('invalid_otp');
    return session;
  });

  @override
  Future<CloudSession> completeEmailLink(String authCode) => _call(() async {
    final res = await _client.auth.exchangeCodeForSession(authCode);
    return _toSession(res.session)!;
  });

  @override
  Future<void> signOut() => _call(() => _client.auth.signOut());

  @override
  Future<void> upsertProfile({
    required String displayName,
    required String phone,
    required String deviceId,
    required String appVersion,
  }) => _call(() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthFailure('session_expired');
    final now = DateTime.now().toUtc().toIso8601String();
    await _client.from('user_profiles').upsert({
      'id': uid,
      'display_name': displayName,
      'phone': phone,
      'updated_at': now,
    });
    await _client.from('user_devices').upsert({
      'id': deviceId,
      'user_id': uid,
      'platform': Platform.isIOS ? 'ios' : 'android',
      'app_version': appVersion,
      'last_seen_at': now,
    });
  });

  // ------------------------------------------------------------- sync

  @override
  Future<OpResult> applyOp(OutboundOp op) => _call(() async {
    final res = await _client.rpc<Object?>(
      op.isPersonal
          ? 'apply_personal_op'
          : op.isFamily
          ? 'apply_family_op'
          : 'apply_group_op',
      params: {'p_op': op.toJson()},
    );
    return OpResult.fromJson((res! as Map).cast<String, Object?>());
  });

  @override
  Future<List<RemoteEvent>> pullEvents({
    required int afterSeq,
    int limit = 500,
  }) => _call(() async {
    final rows = await _client
        .from('sync_events')
        .select(
          'seq, group_id, entity_type, entity_id, op_type, revision, payload',
        )
        .gt('seq', afterSeq)
        .order('seq', ascending: true)
        .limit(limit);
    return [for (final r in rows) RemoteEvent.fromJson(r)];
  });

  @override
  Future<List<RemoteEvent>> pullPersonalEvents({
    required int afterSeq,
    int limit = 500,
  }) => _call(() async {
    final rows = await _client
        .from('personal_sync_events')
        .select(
          'seq, entity_type, entity_id, op_type, revision, payload, op_id',
        )
        .gt('seq', afterSeq)
        .order('seq', ascending: true)
        .limit(limit);
    return [for (final r in rows) RemoteEvent.fromJson(r, scope: 'personal')];
  });

  @override
  Future<List<RemoteEvent>> pullFamilyEvents({
    required int afterSeq,
    int limit = 500,
  }) => _call(() async {
    final rows = await _client
        .from('family_sync_events')
        .select(
          'seq, family_id, entity_type, entity_id, op_type, revision, payload, op_id',
        )
        .gt('seq', afterSeq)
        .order('seq', ascending: true)
        .limit(limit);
    return [for (final r in rows) RemoteEvent.fromJson(r, scope: 'family')];
  });

  @override
  Future<FamilySnapshot> fetchFamilySnapshot(String familyId) =>
      _call(() async {
        final res = await _client.rpc<Object?>(
          'get_family_snapshot',
          params: {'p_family_id': familyId},
        );
        return FamilySnapshot.fromJson((res! as Map).cast<String, Object?>());
      });

  @override
  Future<PersonalSnapshot> fetchPersonalSnapshot() => _call(() async {
    final res = await _client.rpc<Object?>('get_personal_snapshot');
    return PersonalSnapshot.fromJson((res! as Map).cast<String, Object?>());
  });

  static var _feedConnections = 0;

  /// Realtime channel name for one live-update connection. Unique per
  /// connection: after a quick pause/resume the old channel may still be
  /// leaving, and a shared name would let its leave close the new one.
  @visibleForTesting
  /// Change feeds that live updates listen to (RLS decides which rows reach
  /// this user; personal rows are also filtered by owner).
  static const liveFeeds = [
    'sync_events',
    'personal_sync_events',
    'family_sync_events',
  ];

  static String feedTopic(String uid) => 'feeds:$uid:${++_feedConnections}';

  @override
  Stream<void> changeSignals() {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return const Stream.empty();
    RealtimeChannel? channel;
    late final StreamController<void> signals;
    void signal(PostgresChangePayload _) {
      if (!signals.isClosed) signals.add(null);
    }

    signals = StreamController<void>(
      onListen: () {
        // Realtime applies each feed's RLS: group and Family hisab events
        // only reach their members.
        var c = _client.channel(feedTopic(uid));
        for (final table in liveFeeds) {
          c = c.onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: table,
            filter: table == 'personal_sync_events'
                ? PostgresChangeFilter(
                    type: PostgresChangeFilterType.eq,
                    column: 'owner_id',
                    value: uid,
                  )
                : null,
            callback: signal,
          );
        }
        channel = c.subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.subscribed) {
            // Changes made while disconnected: sync once on (re)connect.
            if (!signals.isClosed) signals.add(null);
          } else {
            SafeLogger.info('realtime', {'status': status.name});
          }
        });
      },
      onCancel: () async {
        final c = channel;
        channel = null;
        if (c != null) await _client.removeChannel(c);
      },
    );
    return signals.stream;
  }

  @override
  Future<GroupSnapshot> fetchGroupSnapshot(String groupId) => _call(() async {
    final res = await _client.rpc<Object?>(
      'get_group_snapshot',
      params: {'p_group_id': groupId},
    );
    return GroupSnapshot.fromJson((res! as Map).cast<String, Object?>());
  });

  // ------------------------------------------------------- invitations

  @override
  Future<CreatedInvitation> createInvitation({
    required String groupId,
    String? memberId,
  }) => _call(() async {
    final res = await _client.rpc<Object?>(
      'create_group_invitation',
      params: {'p_group_id': groupId, 'p_member_id': memberId},
    );
    final j = (res! as Map).cast<String, Object?>();
    return CreatedInvitation(
      id: j['invitation_id']! as String,
      code: j['code']! as String,
      expiresAt: DateTime.parse(j['expires_at']! as String).toLocal(),
    );
  });

  @override
  Future<List<InvitationInfo>> listInvitations(String groupId) =>
      _call(() async {
        final rows = await _client
            .from('group_invitations')
            .select('id, status, expires_at, member_id, created_at')
            .eq('group_id', groupId)
            .order('created_at', ascending: false);
        return [
          for (final r in rows)
            InvitationInfo(
              id: r['id'] as String,
              status: r['status'] as String,
              expiresAt: DateTime.parse(r['expires_at'] as String).toLocal(),
              memberId: r['member_id'] as String?,
              createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
            ),
        ];
      });

  @override
  Future<void> cancelInvitation(String invitationId) => _call(
    () => _client.rpc<Object?>(
      'cancel_group_invitation',
      params: {'p_invitation_id': invitationId},
    ),
  );

  @override
  Future<AcceptedInvitation> acceptInvitation({
    required String code,
    required String displayName,
  }) => _call(() async {
    final res = await _client.rpc<Object?>(
      'accept_invitation',
      params: {
        'p_code': code.trim().toUpperCase(),
        'p_display_name': displayName,
      },
    );
    return AcceptedInvitation.fromJson((res! as Map).cast<String, Object?>());
  });

  @override
  Future<CreatedInvitation> createFamilyInvitation({
    required String familyId,
    String? memberId,
  }) => _call(() async {
    final res = await _client.rpc<Object?>(
      'create_family_invitation',
      params: {'p_family_id': familyId, 'p_member_id': memberId},
    );
    final j = (res! as Map).cast<String, Object?>();
    return CreatedInvitation(
      id: j['invitation_id']! as String,
      code: j['code']! as String,
      expiresAt: DateTime.parse(j['expires_at']! as String).toLocal(),
    );
  });

  @override
  Future<List<InvitationInfo>> listFamilyInvitations(String familyId) =>
      _call(() async {
        final rows = await _client
            .from('family_invitations')
            .select('id, status, expires_at, member_id, created_at')
            .eq('family_id', familyId)
            .order('created_at', ascending: false);
        return [
          for (final r in rows)
            InvitationInfo(
              id: r['id'] as String,
              status: r['status'] as String,
              expiresAt: DateTime.parse(r['expires_at'] as String).toLocal(),
              memberId: r['member_id'] as String?,
              createdAt: DateTime.parse(r['created_at'] as String).toLocal(),
            ),
        ];
      });

  @override
  Future<void> cancelFamilyInvitation(String invitationId) => _call(
    () => _client.rpc<Object?>(
      'cancel_family_invitation',
      params: {'p_invitation_id': invitationId},
    ),
  );

  @override
  Future<void> setFamilyRole({
    required String memberId,
    required String role,
  }) => _call(
    () => _client.rpc<Object?>(
      'set_family_member_role',
      params: {'p_member_id': memberId, 'p_role': role},
    ),
  );

  // ------------------------------------------------------- attachments

  @override
  Future<void> uploadGroupAttachment({
    required String storagePath,
    required List<int> bytes,
    required String mimeType,
    required Map<String, Object?> metadata,
  }) => _call(() async {
    await _client.storage
        .from(_bucket)
        .uploadBinary(
          storagePath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );
    await _client.rpc<Object?>(
      'register_group_attachment',
      params: {'p': metadata},
    );
  });

  @override
  Future<List<int>> downloadGroupAttachment(String storagePath) =>
      _call(() => _client.storage.from(_bucket).download(storagePath));

  static const _familyBucket = 'family-attachments';

  @override
  Future<void> uploadFamilyAttachment({
    required String storagePath,
    required List<int> bytes,
    required String mimeType,
    required Map<String, Object?> metadata,
  }) => _call(() async {
    // upsert: a retry after a lost answer finds the file already there.
    await _client.storage
        .from(_familyBucket)
        .uploadBinary(
          storagePath,
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );
    await _client.rpc<Object?>(
      'register_family_attachment',
      params: {'p': metadata},
    );
  });

  @override
  Future<List<int>> downloadFamilyAttachment(String storagePath) =>
      _call(() => _client.storage.from(_familyBucket).download(storagePath));

  @override
  Future<void> deleteFamilyAttachment(String attachmentId) => _call(() async {
    final rows = await _client
        .from('family_attachments')
        .select('storage_path')
        .eq('id', attachmentId);
    await _client.rpc<Object?>(
      'delete_family_attachment',
      params: {'p_id': attachmentId},
    );
    // The file too (best effort: the record is what other phones follow).
    try {
      await _client.storage.from(_familyBucket).remove([
        for (final r in rows) r['storage_path'] as String,
      ]);
    } catch (e, s) {
      SafeLogger.error('family_bill_file_delete', e, s);
    }
  });

  static const _personalBucket = 'personal-attachments';

  String _personalPath(String storageName) {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthFailure('session_expired');
    return '$uid/$storageName';
  }

  @override
  Future<void> uploadPersonalFile({
    required String storageName,
    required List<int> bytes,
    required String mimeType,
  }) => _call(() async {
    await _client.storage
        .from(_personalBucket)
        .uploadBinary(
          _personalPath(storageName),
          Uint8List.fromList(bytes),
          fileOptions: FileOptions(contentType: mimeType, upsert: true),
        );
  });

  @override
  Future<List<int>> downloadPersonalFile(String storageName) => _call(
    () => _client.storage
        .from(_personalBucket)
        .download(_personalPath(storageName)),
  );

  @override
  Future<void> deletePersonalFile(String storageName) => _call(() async {
    await _client.storage.from(_personalBucket).remove([
      _personalPath(storageName),
    ]);
  });

  // ----------------------------------------------------------- account

  @override
  Future<void> deleteAccount() => _call(() async {
    final res = await _client.functions.invoke(
      'delete-account',
      method: HttpMethod.post,
    );
    if (res.status != 200) throw const UnexpectedFailure();
    await _client.auth.signOut();
  });
}
