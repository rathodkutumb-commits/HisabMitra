import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';

class ProfileRepository {
  ProfileRepository(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;

  static const selfId = 'self';

  Stream<LocalUserProfileRow?> watch() => (_db.select(
    _db.localUserProfile,
  )..where((t) => t.id.equals(selfId))).watchSingleOrNull();

  Future<LocalUserProfileRow?> get() => (_db.select(
    _db.localUserProfile,
  )..where((t) => t.id.equals(selfId))).getSingleOrNull();

  Future<void> saveName(String name) async {
    final now = _clock.now();
    final trimmed = name.trim();
    await _db
        .into(_db.localUserProfile)
        .insert(
          LocalUserProfileCompanion.insert(
            id: selfId,
            displayName: trimmed,
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => LocalUserProfileCompanion(
              displayName: Value(trimmed),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  /// Saves the compulsory account details: name, email (normalised) and
  /// phone (E.164). [remoteUserId] links the verified cloud identity; it is
  /// null when the build has no cloud configuration.
  Future<void> saveAccount({
    required String name,
    required String email,
    required String phone,
    String? remoteUserId,
  }) async {
    final now = _clock.now();
    final trimmed = name.trim();
    await _db
        .into(_db.localUserProfile)
        .insert(
          LocalUserProfileCompanion.insert(
            id: selfId,
            displayName: trimmed,
            email: Value(email),
            phone: Value(phone),
            remoteUserId: Value(remoteUserId),
            createdAt: now,
            updatedAt: now,
          ),
          onConflict: DoUpdate(
            (_) => LocalUserProfileCompanion(
              displayName: Value(trimmed),
              email: Value(email),
              phone: Value(phone),
              remoteUserId: Value(remoteUserId),
              updatedAt: Value(now),
            ),
          ),
        );
  }

  Future<void> unlinkRemote() =>
      (_db.update(
        _db.localUserProfile,
      )..where((t) => t.id.equals(selfId))).write(
        LocalUserProfileCompanion(
          remoteUserId: const Value(null),
          updatedAt: Value(_clock.now()),
        ),
      );
}

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
  ),
);

final profileProvider = StreamProvider<LocalUserProfileRow?>(
  (ref) => ref.watch(profileRepositoryProvider).watch(),
);
