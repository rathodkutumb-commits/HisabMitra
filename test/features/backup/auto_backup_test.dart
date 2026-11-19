import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/backup/application/backup_providers.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';

void main() {
  final base = AppPreferences.fromMap(const {});
  final now = DateTime(2026, 5, 10, 12);

  test('off is never due', () {
    expect(AutoBackupRunner.isDue(base, now), isFalse);
  });

  test('daily is due when never run or after 24 hours', () {
    final daily = base.copyWith(autoBackup: AutoBackupFrequency.daily);
    expect(AutoBackupRunner.isDue(daily, now), isTrue);
    expect(
      AutoBackupRunner.isDue(
        daily.copyWith(
          lastAutoBackupAt: now.subtract(const Duration(hours: 23)),
        ),
        now,
      ),
      isFalse,
    );
    expect(
      AutoBackupRunner.isDue(
        daily.copyWith(
          lastAutoBackupAt: now.subtract(const Duration(hours: 24)),
        ),
        now,
      ),
      isTrue,
    );
  });

  test('weekly waits seven days', () {
    final weekly = base.copyWith(autoBackup: AutoBackupFrequency.weekly);
    expect(
      AutoBackupRunner.isDue(
        weekly.copyWith(
          lastAutoBackupAt: now.subtract(const Duration(days: 6)),
        ),
        now,
      ),
      isFalse,
    );
    expect(
      AutoBackupRunner.isDue(
        weekly.copyWith(
          lastAutoBackupAt: now.subtract(const Duration(days: 7)),
        ),
        now,
      ),
      isTrue,
    );
  });
}
