import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/theme/palettes.dart';
import 'package:hisabmitra/core/money/money.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';

void main() {
  test('defaults: Rann Utsav palette, English, Indian grouping, AI off', () {
    final p = AppPreferences.fromMap(const {});
    expect(p.palette, AppPalette.rannUtsav);
    expect(p.languageCode, 'en');
    expect(p.onboardingComplete, isFalse);
    expect(p.grouping, MoneyGrouping.indian);
    expect(p.aiEnabled, isFalse);
    expect(p.aiConsent, isFalse);
    expect(p.cloudSyncEnabled, isFalse);
    expect(p.autoBackup, AutoBackupFrequency.off);
    expect(p.defaultGroupView, GroupView.spreadsheet);
    expect(p.transactionsView, TransactionsView.list);
    expect(p.accountVerified, isFalse);
    expect(p.tourPending, isFalse);
    expect(p.sampleDataLoaded, isFalse);
  });

  test('round-trips through the key/value map', () {
    final original = AppPreferences.fromMap(const {}).copyWith(
      palette: AppPalette.patolaRani,
      languageCode: 'gu',
      onboardingComplete: true,
      dateFormat: DateFormatPreference.iso,
      grouping: MoneyGrouping.international,
      calculatorAutoCalc: false,
      defaultGroupView: GroupView.timeline,
      transactionsView: TransactionsView.sheet,
      accountVerified: true,
      tourPending: true,
      sampleDataLoaded: true,
      autoBackup: AutoBackupFrequency.weekly,
      aiEnabled: true,
      aiProvider: AiProvider.online,
      aiConsent: true,
      gujaratiInputMode: GujaratiInputMode.transliteration,
      lastAutoBackupAt: DateTime.utc(2026, 5, 1, 10),
    );
    final restored = AppPreferences.fromMap(original.toMap());
    expect(restored, original);
  });

  test('ignores corrupted values and falls back to defaults', () {
    final p = AppPreferences.fromMap(const {
      'appearance.palette': 'purple',
      'locale.language': 'fr',
      'ai.enabled': 'maybe',
      'backup.lastAuto': 'not-a-date',
    });
    expect(p.palette, AppPalette.rannUtsav);
    expect(p.languageCode, 'en');
    expect(p.aiEnabled, isFalse);
    expect(p.lastAutoBackupAt, isNull);
  });

  test('a saved palette that was removed moves to Rann Utsav', () {
    final p = AppPreferences.fromMap(const {'appearance.palette': 'haldi'});
    expect(p.palette, AppPalette.rannUtsav);
  });

  test('online AI is only usable with consent', () {
    final p = AppPreferences.fromMap(const {})
        .copyWith(aiEnabled: true, aiProvider: AiProvider.online);
    expect(p.canUseOnlineAi, isFalse);
    expect(p.copyWith(aiConsent: true).canUseOnlineAi, isTrue);
  });
}
