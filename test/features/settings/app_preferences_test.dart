import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/theme/palettes.dart';
import 'package:hisabmitra/core/money/money.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';

void main() {
  test('defaults: Rann Utsav palette, English, Indian grouping, AI on', () {
    final p = AppPreferences.fromMap(const {});
    expect(p.palette, AppPalette.rannUtsav);
    expect(p.languageCode, 'en');
    expect(p.onboardingComplete, isFalse);
    expect(p.grouping, MoneyGrouping.indian);
    expect(p.aiEnabled, isTrue);
    expect(p.canUseOnlineAi, isFalse);
    expect(p.aiConsent, isFalse);
    expect(p.defaultGroupView, GroupView.spreadsheet);
    expect(p.transactionsView, TransactionsView.list);
    expect(p.accountVerified, isFalse);
    expect(p.tourPending, isFalse);
    expect(p.sampleDataLoaded, isFalse);
    expect(p.reminderBatteryTipDismissed, isFalse);
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
      reminderBatteryTipDismissed: true,
      aiEnabled: true,
      aiProvider: AiProvider.online,
      aiConsent: true,
      gujaratiInputMode: GujaratiInputMode.transliteration,
    );
    final restored = AppPreferences.fromMap(original.toMap());
    expect(restored, original);
  });

  test('ignores corrupted values and falls back to defaults', () {
    final p = AppPreferences.fromMap(const {
      'appearance.palette': 'purple',
      'locale.language': 'fr',
      'ai.assistant.enabled': 'maybe',
    });
    expect(p.palette, AppPalette.rannUtsav);
    expect(p.languageCode, 'en');
    expect(p.aiEnabled, isTrue);
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

  group('on-phone AI assistant default', () {
    test('an old stored "off" is ignored, so existing installs get it on', () {
      final p = AppPreferences.fromMap(const {'ai.enabled': 'false'});
      expect(p.aiEnabled, isTrue);
    });

    test('turning it off is saved under the new key', () {
      final off = AppPreferences.fromMap(const {
        'ai.assistant.enabled': 'false',
      });
      expect(off.aiEnabled, isFalse);
      expect(off.toMap()['ai.assistant.enabled'], 'false');
      expect(AppPreferences.fromMap(off.toMap()).aiEnabled, isFalse);
    });
  });
}
