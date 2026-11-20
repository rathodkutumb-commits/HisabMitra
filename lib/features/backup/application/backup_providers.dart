import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../data/backup_service.dart';

/// App version string, overridden in `main()` from package info.
final appVersionProvider = Provider<String>((ref) => '1.0.0');

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    db: ref.watch(appDatabaseProvider),
    baseDir: getApplicationSupportDirectory,
    databasePath: AppDatabase.defaultFilePath,
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
    appVersion: ref.watch(appVersionProvider),
  ),
);

final backupHistoryProvider = StreamProvider<List<BackupHistoryRow>>(
  (ref) => ref.watch(backupServiceProvider).watchHistory(),
);
