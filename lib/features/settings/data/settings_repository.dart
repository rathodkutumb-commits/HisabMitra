import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../domain/app_preferences.dart';

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<AppPreferences> load() async {
    final rows = await _db.select(_db.appSettings).get();
    return AppPreferences.fromMap({for (final r in rows) r.key: r.value});
  }

  Future<void> save(AppPreferences prefs, DateTime now) async {
    final map = prefs.toMap();
    await _db.batch((b) {
      for (final e in map.entries) {
        b.insert(
          _db.appSettings,
          AppSettingsCompanion.insert(
            key: e.key,
            value: e.value,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  /// Raw value access for internal bookkeeping (e.g. sync cursor).
  Future<String?> readRaw(String key) async {
    final row = await (_db.select(
      _db.appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> writeRaw(String key, String value, DateTime now) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: key, value: value, updatedAt: now),
      );
}
