import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/dashboard/presentation/dashboard_screen.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/presentation/account_sync_screen.dart';

import '../helpers/app_harness.dart';
import '../helpers/fake_cloud.dart';

AppPreferences _signedIn() =>
    AppPreferences.fromMap(const {})
        .copyWith(onboardingComplete: true, accountVerified: true);

void main() {
  testApp('a signed-in phone that never synced gets its hisab, then Home', (
    tester,
  ) async {
    final cloud = FakeCloudClient(FakeCloudServer(), 'hemang');
    await pumpHisabMitra(
      tester,
      prefs: _signedIn(),
      overrides: [cloudGatewayProvider.overrideWithValue(cloud)],
    );
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(AccountSyncScreen), findsNothing);
  });

  testApp('offline: the screen says so and Continue in background goes Home', (
    tester,
  ) async {
    final cloud = FakeCloudClient(FakeCloudServer(), 'hemang')..online = false;
    await pumpHisabMitra(
      tester,
      prefs: _signedIn(),
      overrides: [cloudGatewayProvider.overrideWithValue(cloud)],
    );
    await tester.pumpAndSettle();
    expect(find.byType(AccountSyncScreen), findsOneWidget);
    expect(find.textContaining('No internet'), findsOneWidget);

    await tester.tap(find.text('Continue in background'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
