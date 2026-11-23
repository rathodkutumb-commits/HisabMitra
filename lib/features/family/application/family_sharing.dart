import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../synchronization/application/sync_controller.dart';
import '../../synchronization/data/cloud_gateway.dart';
import '../../synchronization/data/sync_service.dart';
import '../../synchronization/domain/cloud_models.dart';

/// Sharing a Family hisab with people who have the app: invitations,
/// joining and roles. These need the internet (unlike entries, which are
/// saved on the phone first).
class FamilySharing {
  FamilySharing(this._cloud, this._sync);

  final CloudGateway _cloud;
  final SyncService _sync;

  /// Loads a Family hisab the user just joined; returns its id.
  Future<String> join(AcceptedInvitation accepted) async {
    final id = accepted.familyId!;
    await _sync.loadFamilySnapshot(id);
    return id;
  }

  /// An invitation code, optionally for a named person. Unsent changes are
  /// uploaded first, so a person added a moment ago can be invited.
  Future<CreatedInvitation> createInvitation({
    required String familyId,
    String? memberId,
  }) async {
    await _sync.syncOnce();
    return _cloud.createFamilyInvitation(
      familyId: familyId,
      memberId: memberId,
    );
  }

  Future<List<InvitationInfo>> invitations(String familyId) =>
      _cloud.listFamilyInvitations(familyId);

  Future<void> cancel(String invitationId) =>
      _cloud.cancelFamilyInvitation(invitationId);

  /// The owner makes a person an `admin` or a `member`; the change comes
  /// back through the feed.
  Future<void> setRole(String memberId, String role) async {
    await _cloud.setFamilyRole(memberId: memberId, role: role);
    await _sync.syncOnce();
  }
}

final familySharingProvider = Provider<FamilySharing>(
  (ref) => FamilySharing(
    ref.watch(cloudGatewayProvider),
    ref.watch(syncServiceProvider),
  ),
);
