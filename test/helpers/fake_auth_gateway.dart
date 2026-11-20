import 'dart:async';

import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/features/synchronization/data/cloud_gateway.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';

/// Records auth calls; accepts [validCode] and the link code `pkce-ok`.
class FakeAuthGateway implements CloudGateway {
  FakeAuthGateway({this.configured = true});

  final bool configured;
  CloudSession? session;
  final codeRequests = <(String email, String redirectTo)>[];
  final profileUpserts = <Map<String, String>>[];
  String validCode = '12345678';
  final _changes = StreamController<CloudSession?>.broadcast();

  @override
  bool get isConfigured => configured;
  @override
  CloudSession? get currentSession => session;
  @override
  Stream<CloudSession?> get sessionChanges => _changes.stream;

  @override
  Future<void> requestEmailCode(
    String email, {
    required String redirectTo,
  }) async => codeRequests.add((email, redirectTo));

  @override
  Future<CloudSession> verifyEmailCode({
    required String email,
    required String code,
  }) async {
    if (code != validCode) throw const AuthFailure('invalid_otp');
    return session = CloudSession(userId: 'user-1', email: email);
  }

  @override
  Future<CloudSession> completeEmailLink(String authCode) async {
    if (authCode != 'pkce-ok') throw const AuthFailure('link_invalid');
    return session = const CloudSession(
      userId: 'user-1',
      email: 'hemang@example.com',
    );
  }

  @override
  Future<void> upsertProfile({
    required String displayName,
    required String phone,
    required String deviceId,
    required String appVersion,
  }) async => profileUpserts.add({'name': displayName, 'phone': phone});

  @override
  Future<void> signOut() async => session = null;

  @override
  Future<List<RemoteEvent>> pullEvents({
    required int afterSeq,
    int limit = 500,
  }) async => const [];

  @override
  Future<List<RemoteEvent>> pullPersonalEvents({
    required int afterSeq,
    int limit = 500,
  }) async => const [];

  @override
  Future<PersonalSnapshot> fetchPersonalSnapshot() async =>
      const PersonalSnapshot(rows: {}, maxSeq: 0);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
