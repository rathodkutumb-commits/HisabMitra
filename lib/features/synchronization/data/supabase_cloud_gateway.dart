import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

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
      'apply_group_op',
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
      'accept_group_invitation',
      params: {
        'p_code': code.trim().toUpperCase(),
        'p_display_name': displayName,
      },
    );
    final j = (res! as Map).cast<String, Object?>();
    return AcceptedInvitation(
      groupId: j['group_id']! as String,
      memberId: j['member_id']! as String,
    );
  });

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
