import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../../../core/utils/email.dart';
import '../../../core/utils/phone.dart';
import '../../backup/application/backup_providers.dart';
import '../../profile/data/profile_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../../synchronization/application/sync_controller.dart';
import '../../synchronization/domain/cloud_models.dart';
import '../../synchronization/data/local_data_wiper.dart';

/// Account details entered at sign-up, kept until the email is verified so
/// the email link still works after the app was closed.
@immutable
class PendingSignUp {
  const PendingSignUp({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory PendingSignUp.fromJson(Map<String, Object?> j) => PendingSignUp(
    name: j['name']! as String,
    email: j['email']! as String,
    phone: j['phone']! as String,
  );

  final String name;

  /// Normalised (trimmed, lower-case).
  final String email;

  /// E.164, e.g. +919876543210.
  final String phone;

  Map<String, Object?> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
  };
}

/// Compulsory account: name, email and mobile number, verified through the
/// email address (a code typed in the app, or the link in the email).
///
/// Personal records stay on the device; the account identifies the user for
/// shared groups. Once verified, the app works offline as before.
class AuthController {
  AuthController(this._ref);

  final Ref _ref;

  /// Where the email link sends the user back to (registered in the Android
  /// manifest and in Supabase → Auth → URL configuration).
  static const emailRedirectUrl = 'hisabmitra://login-callback';

  static const _pendingKey = 'account.pending';

  /// Validates and normalises the details, or throws [AuthFailure].
  static PendingSignUp validate({
    required String name,
    required String email,
    required String phone,
  }) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) throw const AuthFailure('name_required');
    final cleanEmail = EmailAddresses.normalize(email);
    if (cleanEmail == null) throw const AuthFailure('invalid_email');
    final cleanPhone = PhoneNumbers.normalize(phone);
    if (cleanPhone == null) throw const AuthFailure('invalid_phone');
    return PendingSignUp(name: cleanName, email: cleanEmail, phone: cleanPhone);
  }

  /// Saves the details and emails a verification code / link.
  Future<PendingSignUp> requestCode({
    required String name,
    required String email,
    required String phone,
  }) async {
    final pending = validate(name: name, email: email, phone: phone);
    await _writeSetting(_pendingKey, jsonEncode(pending.toJson()));
    await _ref
        .read(cloudGatewayProvider)
        .requestEmailCode(pending.email, redirectTo: emailRedirectUrl);
    return pending;
  }

  /// Details waiting for verification, if any.
  Future<PendingSignUp?> pendingSignUp() async {
    final raw = await _readSetting(_pendingKey);
    if (raw == null) return null;
    try {
      return PendingSignUp.fromJson(
        (jsonDecode(raw) as Map).cast<String, Object?>(),
      );
    } on Object {
      return null;
    }
  }

  /// Verifies the code from the email (6–10 digits, spaces ignored).
  Future<void> verifyCode(String code) async {
    final pending = await pendingSignUp();
    if (pending == null) throw const AuthFailure('no_pending');
    final digits = code.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 6 || digits.length > 10) {
      throw const AuthFailure('invalid_otp');
    }
    final session = await _ref
        .read(cloudGatewayProvider)
        .verifyEmailCode(email: pending.email, code: digits);
    await _complete(pending, session);
  }

  /// Completes sign-up from the email link (`hisabmitra://login-callback`).
  Future<void> completeWithLink(String authCode) async {
    final session = await _ref
        .read(cloudGatewayProvider)
        .completeEmailLink(authCode);
    var pending = await pendingSignUp();
    if (pending == null) {
      // Link opened on a device without saved details: use the profile.
      final profile = await _ref.read(profileRepositoryProvider).get();
      final phone = profile?.phone;
      final email = session.email ?? profile?.email;
      if (profile == null || phone == null || email == null) {
        throw const AuthFailure('no_pending');
      }
      pending = PendingSignUp(
        name: profile.displayName,
        email: email,
        phone: phone,
      );
    }
    await _complete(pending, session);
  }

  Future<void> _complete(PendingSignUp p, CloudSession session) async {
    await _ref
        .read(profileRepositoryProvider)
        .saveAccount(
          name: p.name,
          email: session.email ?? p.email,
          phone: p.phone,
          remoteUserId: session.userId,
        );
    try {
      await _ref
          .read(cloudGatewayProvider)
          .upsertProfile(
            displayName: p.name,
            phone: p.phone,
            deviceId: await _deviceId(),
            appVersion: _ref.read(appVersionProvider),
          );
    } on NetworkFailure {
      // Retried at the next sign-in; verification itself succeeded.
    }
    await _deleteSetting(_pendingKey);
    await _ref
        .read(settingsControllerProvider.notifier)
        .update(
          (prefs) => prefs.copyWith(
            onboardingComplete: true,
            accountVerified: true,
            // First sign-up on this device: offer the guided tour.
            tourPending: !prefs.onboardingComplete || prefs.tourPending,
          ),
        );
    // Pull shared groups in the background; verification is already done.
    unawaited(_ref.read(syncControllerProvider.notifier).syncNow(silent: true));
  }

  /// Builds without a cloud configuration (development) cannot verify an
  /// email: the details are validated and kept on the device only.
  Future<void> saveWithoutCloud({
    required String name,
    required String email,
    required String phone,
  }) async {
    final p = validate(name: name, email: email, phone: phone);
    await _ref
        .read(profileRepositoryProvider)
        .saveAccount(name: p.name, email: p.email, phone: p.phone);
    await _ref
        .read(settingsControllerProvider.notifier)
        .update(
          (prefs) =>
              prefs.copyWith(onboardingComplete: true, tourPending: true),
        );
  }

  /// Changes made on this phone that have not reached the account yet
  /// (waiting or failed). Signing out with any of them loses them.
  Future<int> unsentChanges() async =>
      (await _db.select(_db.syncOutbox).get()).length;

  /// Signs out and removes the phone's copy of the account's data (it stays
  /// in the account). Categories and settings stay on the phone; the app
  /// asks to verify the email again.
  Future<void> signOut() async {
    await _ref.read(cloudGatewayProvider).signOut();
    await _forgetAccountOnPhone();
  }

  Future<void> _forgetAccountOnPhone() async {
    await _ref.read(localDataWiperProvider).wipeAccountData();
    await _ref.read(profileRepositoryProvider).unlinkRemote();
    await _ref
        .read(settingsControllerProvider.notifier)
        .update(
          (p) => p.copyWith(
            accountVerified: false,
            initialSyncDone: false,
            sampleDataLoaded: false,
          ),
        );
  }

  /// The cloud session is gone (signed out elsewhere, revoked): ask for
  /// verification again. Nothing local is removed.
  Future<void> markSessionLost() => _ref
      .read(settingsControllerProvider.notifier)
      .update((p) => p.copyWith(accountVerified: false));

  /// Deletes the account with all of its records and bills, and the
  /// phone's copy of them. A new verified account is needed to keep using
  /// the app.
  Future<void> deleteAccount() async {
    await _ref.read(cloudGatewayProvider).deleteAccount();
    await _forgetAccountOnPhone();
  }

  // ------------------------------------------------------------ settings

  AppDatabase get _db => _ref.read(appDatabaseProvider);

  Future<String?> _readSetting(String key) async => (await (_db.select(
    _db.appSettings,
  )..where((s) => s.key.equals(key))).getSingleOrNull())?.value;

  Future<void> _writeSetting(String key, String value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: key,
          value: value,
          updatedAt: _ref.read(clockProvider).now(),
        ),
      );

  Future<void> _deleteSetting(String key) =>
      (_db.delete(_db.appSettings)..where((s) => s.key.equals(key))).go();

  Future<String> _deviceId() async {
    const key = 'device.id';
    final existing = await _readSetting(key);
    if (existing != null) return existing;
    final id = _ref.read(idGeneratorProvider).newId();
    await _writeSetting(key, id);
    return id;
  }
}

final authControllerProvider = Provider<AuthController>(AuthController.new);
