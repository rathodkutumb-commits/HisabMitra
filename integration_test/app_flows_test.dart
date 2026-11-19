// Runs every full-app flow from test/widget/app_flow_test.dart on a real
// Android device or emulator (real Skia/Impeller rendering, real fonts and
// Gujarati shaping, real SQLite build):
//
//   flutter test integration_test/app_flows_test.dart -d emulator-5554
//
// Each flow uses an in-memory database, so the device's own HisabMitra data
// is never touched. Flows covered: onboarding, add expense, validation,
// create group + split + balances, Gujarati settings, palettes, the
// Excel-like transactions sheet and typing with the Gujarati keypad.
import 'package:integration_test/integration_test.dart';

import '../test/widget/app_flow_test.dart' as flows;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  flows.main();
}
