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

  /// Sends one queued change: `apply_group_op`, `apply_personal_op` when
  /// [OutboundOp.isPersonal], or `apply_family_op` when [OutboundOp.isFamily].
  Future<OpResult> applyOp(OutboundOp op);
  Future<List<RemoteEvent>> pullEvents({
    required int afterSeq,
    int limit = 500,
  });
  Future<GroupSnapshot> fetchGroupSnapshot(String groupId);

  /// The user's own change feed after [afterSeq] (scope `personal`).
  Future<List<RemoteEvent>> pullPersonalEvents({
    required int afterSeq,
    int limit = 500,
  });

  /// Every live personal record of the user (new or reset phone).
  Future<PersonalSnapshot> fetchPersonalSnapshot();

  /// Family hisab change feed after [afterSeq] (every Family hisab the user
  /// is a member of; scope `family`).
  Future<List<RemoteEvent>> pullFamilyEvents({
    required int afterSeq,
    int limit = 500,
  });

  /// Every live row of one Family hisab (a new phone, or after joining).
  Future<FamilySnapshot> fetchFamilySnapshot(String familyId);

  /// Live updates: emits when a change the user may see was added to
  /// either change feed (their groups or their own records), and once each
  /// time the connection is (re)established. Carries no data — answer it
  /// with a sync. Every call opens its own connection; cancelling the
  /// subscription closes it.
  Stream<void> changeSignals();

  /// Bill files in the private `personal-attachments` bucket, stored at
  /// `<user id>/<storageName>`.
  Future<void> uploadPersonalFile({
    required String storageName,
    required List<int> bytes,
    required String mimeType,
  });
  Future<List<int>> downloadPersonalFile(String storageName);
  Future<void> deletePersonalFile(String storageName);

  Future<CreatedInvitation> createInvitation({
    required String groupId,
    String? memberId,
  });
  Future<List<InvitationInfo>> listInvitations(String groupId);
  Future<void> cancelInvitation(String invitationId);

  /// Accepts a group **or** Family hisab code (`accept_invitation`).
  Future<AcceptedInvitation> acceptInvitation({
    required String code,
    required String displayName,
  });

  /// Family hisab invitations (admins only), optionally for a named person
  /// who has no account yet.
  Future<CreatedInvitation> createFamilyInvitation({
    required String familyId,
    String? memberId,
  });
  Future<List<InvitationInfo>> listFamilyInvitations(String familyId);
  Future<void> cancelFamilyInvitation(String invitationId);

  /// The owner makes a person with the app an `admin` or a `member`.
  Future<void> setFamilyRole({required String memberId, required String role});

  Future<void> uploadGroupAttachment({
    required String storagePath,
    required List<int> bytes,
    required String mimeType,
    required Map<String, Object?> metadata,
  });
  Future<List<int>> downloadGroupAttachment(String storagePath);

  /// Family hisab bills in the private `family-attachments` bucket at
  /// `<family>/<entry>/<file>`; the record is registered after the upload.
  Future<void> uploadFamilyAttachment({
    required String storagePath,
    required List<int> bytes,
    required String mimeType,
    required Map<String, Object?> metadata,
  });
  Future<List<int>> downloadFamilyAttachment(String storagePath);

  /// Deletes a Family hisab bill for everyone.
  Future<void> deleteFamilyAttachment(String attachmentId);

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
  Future<List<RemoteEvent>> pullPersonalEvents({
    required int afterSeq,
    int limit = 500,
  }) async => _fail();
  @override
  Future<PersonalSnapshot> fetchPersonalSnapshot() async => _fail();
  @override
  Future<List<RemoteEvent>> pullFamilyEvents({
    required int afterSeq,
    int limit = 500,
  }) async => _fail();
  @override
  Future<FamilySnapshot> fetchFamilySnapshot(String familyId) async => _fail();
  @override
  Stream<void> changeSignals() => const Stream.empty();
  @override
  Future<void> uploadPersonalFile({
    required String storageName,
    required List<int> bytes,
    required String mimeType,
  }) async => _fail();
  @override
  Future<List<int>> downloadPersonalFile(String storageName) async => _fail();
  @override
  Future<void> deletePersonalFile(String storageName) async => _fail();
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
  Future<CreatedInvitation> createFamilyInvitation({
    required String familyId,
    String? memberId,
  }) async => _fail();
  @override
  Future<List<InvitationInfo>> listFamilyInvitations(String familyId) async =>
      _fail();
  @override
  Future<void> cancelFamilyInvitation(String invitationId) async => _fail();
  @override
  Future<void> setFamilyRole({
    required String memberId,
    required String role,
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
  Future<void> uploadFamilyAttachment({
    required String storagePath,
    required List<int> bytes,
    required String mimeType,
    required Map<String, Object?> metadata,
  }) async => _fail();
  @override
  Future<List<int>> downloadFamilyAttachment(String storagePath) async =>
      _fail();
  @override
  Future<void> deleteFamilyAttachment(String attachmentId) async => _fail();
  @override
  Future<void> deleteAccount() async => _fail();
}
