import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/router/routes.dart';
import 'package:hisabmitra/features/reminders/domain/notification_route.dart';

void main() {
  test('a reminder notification remembers what it belongs to', () {
    expect(notificationPayload(familyId: 'f1'), 'family:f1');
    expect(notificationPayload(groupId: 'g1'), 'group:g1');
    expect(notificationPayload(familyId: 'f1', groupId: 'g1'), 'family:f1');
    expect(notificationPayload(), isNull);
  });

  test('tapping it opens that page', () {
    expect(routeForPayload('family:f1'), Routes.familyHome('f1'));
    expect(routeForPayload('group:g1'), Routes.group('g1'));
    expect(
      routeForPayload('family:gone'),
      Routes.familyHome('gone'),
      reason: 'a removed Family hisab still opens its page ("not found")',
    );
    for (final bad in [null, '', 'family:', 'other:x', 'nonsense']) {
      expect(routeForPayload(bad), isNull, reason: '$bad');
    }
  });
}
