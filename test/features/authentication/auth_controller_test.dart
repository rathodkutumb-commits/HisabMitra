import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/authentication/application/auth_controller.dart';
import 'package:hisabmitra/features/profile/data/profile_repository.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';

import '../../helpers/fake_auth_gateway.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late FakeAuthGateway cloud;

  ProviderContainer container({bool configured = true}) {
    cloud = FakeAuthGateway(configured: configured);
    final c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        cloudGatewayProvider.overrideWithValue(cloud),
        syncControllerProvider.overrideWith(_RecordingSync.new),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
        initialPreferencesProvider.overrideWithValue(
          AppPreferences.fromMap(const {}),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => db = newTestDatabase());
  tearDown(() => db.close());

  Future<void> request(ProviderContainer c) => c
      .read(authControllerProvider)
      .requestCode(
        name: ' Hemang ',
        email: ' Hemang@Example.com ',
        phone: '98765 43210',
      );

  group('requestCode', () {
    test('needs a name, a valid email and a valid phone', () async {
      final auth = container().read(authControllerProvider);
      Future<void> send(String name, String email, String phone) =>
          auth.requestCode(name: name, email: email, phone: phone);

      await expectLater(
        send('', 'hemang@example.com', '9876543210'),
        throwsA(
          isA<AuthFailure>().having((f) => f.code, 'code', 'name_required'),
        ),
      );
      await expectLater(
        send('Hemang', 'hemang@', '9876543210'),
        throwsA(
          isA<AuthFailure>().having((f) => f.code, 'code', 'invalid_email'),
        ),
      );
      await expectLater(
        send('Hemang', 'hemang@example.com', '12345'),
        throwsA(
          isA<AuthFailure>().having((f) => f.code, 'code', 'invalid_phone'),
        ),
      );
      expect(cloud.codeRequests, isEmpty);
    });

    test('sends the code to the normalised email with the app link', () async {
      final c = container();
      await request(c);
      expect(cloud.codeRequests, [
        ('hemang@example.com', AuthController.emailRedirectUrl),
      ]);
    });

    test(
      'pending details survive an app restart (for the email link)',
      () async {
        await request(container());
        final pending = await container()
            .read(authControllerProvider)
            .pendingSignUp();
        expect(pending?.name, 'Hemang');
        expect(pending?.email, 'hemang@example.com');
        expect(pending?.phone, '+919876543210');
      },
    );
  });

  group('verification', () {
    Future<void> expectAccountComplete(ProviderContainer c) async {
      final profile = await c.read(profileRepositoryProvider).get();
      expect(profile?.displayName, 'Hemang');
      expect(profile?.email, 'hemang@example.com');
      expect(profile?.phone, '+919876543210');
      expect(profile?.remoteUserId, 'user-1');
      expect(cloud.profileUpserts.single, {
        'name': 'Hemang',
        'phone': '+919876543210',
      });
      final prefs = c.read(settingsControllerProvider);
      expect(prefs.onboardingComplete, isTrue);
      expect(prefs.accountVerified, isTrue);
      expect(prefs.cloudSyncEnabled, isTrue);
      expect(await c.read(authControllerProvider).pendingSignUp(), isNull);
      // Shared groups are pulled in the background after verification.
      final sync = c.read(syncControllerProvider.notifier) as _RecordingSync;
      expect(sync.calls, 1);
    }

    test('a wrong or too short code is rejected', () async {
      final c = container();
      await request(c);
      final auth = c.read(authControllerProvider);
      await expectLater(
        auth.verifyCode('123'),
        throwsA(
          isA<AuthFailure>().having((f) => f.code, 'code', 'invalid_otp'),
        ),
      );
      await expectLater(
        auth.verifyCode('00000000'),
        throwsA(
          isA<AuthFailure>().having((f) => f.code, 'code', 'invalid_otp'),
        ),
      );
      expect(c.read(settingsControllerProvider).accountVerified, isFalse);
    });

    test('the emailed code completes the account', () async {
      final c = container();
      await request(c);
      await c.read(authControllerProvider).verifyCode(' 1234 5678 ');
      await expectAccountComplete(c);
    });

    test('the emailed link completes the account', () async {
      final c = container();
      await request(c);
      await c.read(authControllerProvider).completeWithLink('pkce-ok');
      await expectAccountComplete(c);
    });

    test('verifying without a pending sign-up asks to start again', () async {
      final c = container();
      await expectLater(
        c.read(authControllerProvider).verifyCode('12345678'),
        throwsA(isA<AuthFailure>().having((f) => f.code, 'code', 'no_pending')),
      );
    });
  });

  test(
    'without a cloud configuration the details are kept on the device',
    () async {
      final c = container(configured: false);
      await c
          .read(authControllerProvider)
          .saveWithoutCloud(
            name: 'Hemang',
            email: 'hemang@example.com',
            phone: '9876543210',
          );
      final profile = await c.read(profileRepositoryProvider).get();
      expect(profile?.email, 'hemang@example.com');
      expect(profile?.phone, '+919876543210');
      expect(c.read(settingsControllerProvider).onboardingComplete, isTrue);
      expect(c.read(settingsControllerProvider).accountVerified, isFalse);
    },
  );

  test('sign-out keeps local data and asks to verify again', () async {
    final c = container();
    await request(c);
    await c.read(authControllerProvider).verifyCode('12345678');
    await c.read(authControllerProvider).signOut();
    final profile = await c.read(profileRepositoryProvider).get();
    expect(profile?.displayName, 'Hemang');
    expect(profile?.email, 'hemang@example.com');
    expect(profile?.remoteUserId, isNull);
    expect(c.read(settingsControllerProvider).accountVerified, isFalse);
    expect(c.read(settingsControllerProvider).onboardingComplete, isTrue);
  });

  test('a lost cloud session asks to verify again', () async {
    final c = container();
    await request(c);
    await c.read(authControllerProvider).verifyCode('12345678');
    await c.read(authControllerProvider).markSessionLost();
    expect(c.read(settingsControllerProvider).accountVerified, isFalse);
  });
}

/// Records sync requests instead of syncing (sync has its own tests).
class _RecordingSync extends SyncController {
  var calls = 0;

  @override
  SyncStatus build() => const SyncStatus();

  @override
  Future<SyncReport?> syncNow({bool silent = false}) async {
    calls++;
    return null;
  }
}
