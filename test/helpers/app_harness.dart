import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/app.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'test_db.dart';

/// [testWidgets] for full-app tests: unmounts the app at the end of the body
/// so Drift's stream-cleanup timers fire before the binding checks for
/// pending timers.
void testApp(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    try {
      await body(tester);
    } finally {
      // Always unmount, also after a failure: otherwise screens keep
      // listening to the database while it is closed, which hangs the
      // remaining tests on a device.
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    }
  });
}

/// Boots the real app (router, theme, localisation) on an in-memory DB.
Future<AppDatabase> pumpHisabMitra(
  WidgetTester tester, {
  AppPreferences? prefs,
  String? profileName = 'Hemang',
  List<Override> overrides = const [],
}) async {
  await initializeDateFormatting('en');
  await initializeDateFormatting('gu');
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  final db = newTestDatabase();
  if (profileName != null) {
    await db
        .into(db.localUserProfile)
        .insert(
          LocalUserProfileCompanion.insert(
            id: 'self',
            displayName: profileName,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialPreferencesProvider.overrideWithValue(
          prefs ??
              AppPreferences.fromMap(const {})
                  .copyWith(onboardingComplete: true),
        ),
        ...overrides,
      ],
      child: const HisabMitraApp(),
    ),
  );
  // Splash animation + redirect.
  await tester.pump(const Duration(milliseconds: 1600));
  await tester.pumpAndSettle();
  addTearDown(db.close);
  return db;
}

/// Pumps frames for [duration] in 100 ms steps. Use on screens with a
/// running countdown, where `pumpAndSettle` would never settle.
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  final steps = duration.inMilliseconds ~/ 100;
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
