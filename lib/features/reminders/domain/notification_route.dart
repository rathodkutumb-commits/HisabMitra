import '../../../app/router/routes.dart';

/// What a reminder notification opens when tapped: its Family hisab or its
/// group (`family:<id>` / `group:<id>`), or nothing in particular.
String? notificationPayload({String? familyId, String? groupId}) =>
    familyId != null
    ? 'family:$familyId'
    : groupId != null
    ? 'group:$groupId'
    : null;

/// The page for a tapped notification's [payload]; null opens the app as
/// it is. A Family hisab that is gone still opens its page ("not found").
String? routeForPayload(String? payload) {
  if (payload == null) return null;
  final i = payload.indexOf(':');
  if (i <= 0 || i == payload.length - 1) return null;
  final id = payload.substring(i + 1);
  return switch (payload.substring(0, i)) {
    'family' => Routes.familyHome(id),
    'group' => Routes.group(id),
    _ => null,
  };
}
