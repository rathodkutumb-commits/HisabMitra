import 'dart:math';

import '../../../core/database/app_database.dart';

final _random = Random.secure();

/// A free 31-bit id for the Android notification of a reminder. Ids are
/// per phone: the same reminder has a different id on each phone.
Future<int> newNotificationId(AppDatabase db) async {
  while (true) {
    final candidate = 1 + _random.nextInt(0x7FFFFFFE);
    final clash = await (db.select(
      db.reminders,
    )..where((r) => r.notificationId.equals(candidate))).getSingleOrNull();
    if (clash == null) return candidate;
  }
}
