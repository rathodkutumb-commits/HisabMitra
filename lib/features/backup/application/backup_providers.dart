import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_preferences.dart';
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

/// Runs a due automatic backup when the app comes to the foreground
/// (TD-18: no background scheduler).
class AutoBackupRunner {
  AutoBackupRunner(this._ref);

  final Ref _ref;
  var _running = false;

  static Duration? intervalFor(AutoBackupFrequency f) => switch (f) {
    AutoBackupFrequency.off => null,
    AutoBackupFrequency.daily => const Duration(days: 1),
    AutoBackupFrequency.weekly => const Duration(days: 7),
  };

  static bool isDue(AppPreferences prefs, DateTime now) {
    final interval = intervalFor(prefs.autoBackup);
    if (interval == null) return false;
    final last = prefs.lastAutoBackupAt;
    return last == null || now.difference(last) >= interval;
  }

  Future<void> runIfDue() async {
    if (_running) return;
    final prefs = _ref.read(settingsControllerProvider);
    final now = _ref.read(clockProvider).now();
    if (!isDue(prefs, now)) return;
    _running = true;
    try {
      final service = _ref.read(backupServiceProvider);
      await service.createBackup(kind: BackupKind.automatic);
      await service.pruneAutomatic();
      await _ref
          .read(settingsControllerProvider.notifier)
          .update((p) => p.copyWith(lastAutoBackupAt: now));
    } catch (e, s) {
      SafeLogger.error('auto_backup', e, s);
    } finally {
      _running = false;
    }
  }
}

final autoBackupRunnerProvider = Provider<AutoBackupRunner>(
  AutoBackupRunner.new,
);
