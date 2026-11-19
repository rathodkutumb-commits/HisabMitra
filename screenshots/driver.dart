import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves screenshots taken by screenshots/app_screenshots_test.dart.
Future<void> main() => integrationDriver(
  onScreenshot: (name, bytes, [args]) async {
    final file = File('build/screenshots/$name.png')
      ..createSync(recursive: true);
    file.writeAsBytesSync(bytes);
    return true;
  },
);
