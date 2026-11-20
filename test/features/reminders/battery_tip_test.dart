import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/reminders/data/app_details_launcher.dart';

import '../../helpers/app_harness.dart';

class _FakeLauncher extends AppDetailsLauncher {
  var opened = 0;

  @override
  Future<void> open() async => opened++;
}

final _tip = find.textContaining('battery saving can stop reminders');

void main() {
  testApp('tip opens the app settings, and Got it hides it for good', (
    tester,
  ) async {
    final launcher = _FakeLauncher();
    await pumpHisabMitra(
      tester,
      overrides: [appDetailsLauncherProvider.overrideWithValue(launcher)],
    );
    await tester.tap(find.byTooltip('Reminders').first);
    await tester.pumpAndSettle();
    expect(_tip, findsOneWidget);

    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(launcher.opened, 1);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
    expect(_tip, findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Reminders').first);
    await tester.pumpAndSettle();
    expect(_tip, findsNothing);
  });
}
