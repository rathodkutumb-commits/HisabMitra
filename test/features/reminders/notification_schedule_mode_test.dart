import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/reminders/application/notification_service.dart';

void main() {
  late List<AndroidScheduleMode> modes;
  setUp(() => modes = []);

  Future<void> Function(AndroidScheduleMode) recorder({
    Set<AndroidScheduleMode> failing = const {},
  }) => (mode) async {
    modes.add(mode);
    if (failing.contains(mode)) {
      throw PlatformException(code: 'exact_alarms_not_permitted');
    }
  };

  test('uses an exact alarm when allowed', () async {
    await scheduleWithFallback(canExact: true, schedule: recorder());
    expect(modes, [AndroidScheduleMode.exactAllowWhileIdle]);
  });

  test('uses an inexact alarm when exact alarms are not allowed', () async {
    await scheduleWithFallback(canExact: false, schedule: recorder());
    expect(modes, [AndroidScheduleMode.inexactAllowWhileIdle]);
  });

  test('falls back to inexact when the exact alarm is refused', () async {
    await scheduleWithFallback(
      canExact: true,
      schedule: recorder(failing: {AndroidScheduleMode.exactAllowWhileIdle}),
    );
    expect(modes, [
      AndroidScheduleMode.exactAllowWhileIdle,
      AndroidScheduleMode.inexactAllowWhileIdle,
    ]);
  });

  test('a failing inexact alarm is reported, not swallowed', () async {
    await expectLater(
      scheduleWithFallback(
        canExact: false,
        schedule: recorder(
          failing: {AndroidScheduleMode.inexactAllowWhileIdle},
        ),
      ),
      throwsA(isA<PlatformException>()),
    );
  });
}
