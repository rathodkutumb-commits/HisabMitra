import '../../../core/errors/app_failure.dart';
import '../domain/cloud_models.dart';

/// Boundary to the cloud backend (Supabase). Only shared-group data and the
/// user's own profile ever cross it. Implementations map transport errors to
/// [NetworkFailure] / [AuthFailure] / [NotConfiguredFailure].
abstract interface class CloudGateway {
  bool get isConfigured;

  CloudSession? get currentSession;
  Stream<CloudSession?> get sessionChanges;

  /// Emails a sign-up / sign-in code (or link, depending on the email
  /// template) to [email]. Creates the account on first use. A link opens
  /// [redirectTo] in the app.
  Future<void> requestEmailCode(String email, {required String redirectTo});

  /// Verifies the code from the email (6–10 digits).
  Future<CloudSession> verifyEmailCode({
    required String email,
    required String code,
  });

  /// Completes sign-in from the email link (`?code=` on [redirectTo]).
  Future<CloudSession> completeEmailLink(String authCode);

  Future<void> signOut();

  /// Creates or updates the caller's profile (name and phone) and registers
  /// this device.
  Future<void> upsertProfile({
    required String displayName,
    required String phone,
    required String deviceId,
    required String appVersion,
  });

  Future<OpResult> applyOp(OutboundOp op);
  Future<List<RemoteEvent>> pullEvents({
    required int afterSeq,
    int limit = 500,
  });
  Future<GroupSnapshot> fetchGroupSnapshot(String groupId);

  Future<CreatedInvitation> createInvitation({
    required String groupId,
    String? memberId,
  });
  Future<List<InvitationInfo>> listInvitations(String groupId);
  Future<void> cancelInvitation(String invitationId);
  Future<AcceptedInvitation> acceptInvitation({
    required String code,
    required String displayName,
  });

  Future<void> uploadGroupAttachment({
    required String storagePath,
    required List<int> bytes,
    required String mimeType,
    required Map<String, Object?> metadata,
  });
  Future<List<int>> downloadGroupAttachment(String storagePath);

  /// Removes the cloud account (server-side Edge Function).
  Future<void> deleteAccount();
}

/// Used when the build has no Supabase configuration. Every call reports
/// [NotConfiguredFailure]; nothing is simulated.
class NotConfiguredCloudGateway implements CloudGateway {
  const NotConfiguredCloudGateway();

  Never _fail() => throw const NotConfiguredFailure();

  @override
  bool get isConfigured => false;
  @override
  CloudSession? get currentSession => null;
  @override
  Stream<CloudSession?> get sessionChanges => const Stream.empty();
  @override
  Future<void> requestEmailCode(
    String email, {
    required String redirectTo,
  }) async => _fail();
  @override
  Future<CloudSession> verifyEmailCode({
    required String email,
    required String code,
  }) async => _fail();
  @override
  Future<CloudSession> completeEmailLink(String authCode) async => _fail();
  @override
  Future<void> signOut() async {}
  @override
  Future<void> upsertProfile({
    required String displayName,
    required String phone,
    required String deviceId,
    required String appVersion,
  }) async => _fail();
  @override
  Future<OpResult> applyOp(OutboundOp op) async => _fail();
  @override
  Future<List<RemoteEvent>> pullEvents({
    required int afterSeq,
    int limit = 500,
  }) async => _fail();
  @override
  Future<GroupSnapshot> fetchGroupSnapshot(String groupId) async => _fail();
  @override
  Future<CreatedInvitation> createInvitation({
    required String groupId,
    String? memberId,
  }) async => _fail();
  @override
  Future<List<InvitationInfo>> listInvitations(String groupId) async => _fail();
  @override
  Future<void> cancelInvitation(String invitationId) async => _fail();
  @override
  Future<AcceptedInvitation> acceptInvitation({
    required String code,
    required String displayName,
  }) async => _fail();
  @override
  Future<void> uploadGroupAttachment({
    required String storagePath,
    required List<int> bytes,
    required String mimeType,
    required Map<String, Object?> metadata,
  }) async => _fail();
  @override
  Future<List<int>> downloadGroupAttachment(String storagePath) async =>
      _fail();
  @override
  Future<void> deleteAccount() async => _fail();
}
