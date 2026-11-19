// Captures the dashboard in every colour theme with the same sample data:
//
//   flutter drive -d emulator-5554 \
//     --driver=screenshots/driver.dart \
//     --target=screenshots/theme_screenshots_test.dart
//
// PNGs are written to build/screenshots/theme_<palette>.png.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/theme/palettes.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/tour/data/sample_data_service.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/app_harness.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dashboard in every theme', (tester) async {
    await binding.convertFlutterSurfaceToImage();
    await pumpHisabMitra(
      tester,
      prefs: AppPreferences.fromMap(const {})
          .copyWith(onboardingComplete: true),
    );
    // The harness fixes a phone size for host tests; use the real screen.
    tester.view.reset();
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    await container.read(sampleDataServiceProvider).load();
    final settings = container.read(settingsControllerProvider.notifier);
    // Hide the "sample data" banner for clean pictures.
    await settings.update((p) => p.copyWith(sampleDataLoaded: false));

    for (final palette in AppPalette.values) {
      await settings.update((p) => p.copyWith(palette: palette));
      await tester.pumpAndSettle();
      await binding.takeScreenshot('theme_${palette.name}');
    }
  });
}
