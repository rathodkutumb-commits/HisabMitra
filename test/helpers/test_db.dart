import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:hisabmitra/core/database/app_database.dart';

/// Fresh in-memory database with the production schema + seeds.
AppDatabase newTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}
