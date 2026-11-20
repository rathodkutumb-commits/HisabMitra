import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens Android's "App info" page for HisabMitra, where the user can allow
/// background activity / turn off battery restrictions so reminders arrive.
class AppDetailsLauncher {
  static const _channel = MethodChannel('hisabmitra/system');

  Future<void> open() async {
    try {
      await _channel.invokeMethod<void>('openAppDetails');
    } on PlatformException {
      // No settings screen available: nothing else to do.
    } on MissingPluginException {
      // Not on Android.
    }
  }
}

final appDetailsLauncherProvider = Provider<AppDetailsLauncher>(
  (_) => AppDetailsLauncher(),
);
