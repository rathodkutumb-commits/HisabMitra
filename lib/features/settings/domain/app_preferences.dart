import 'package:flutter/foundation.dart';

import '../../../app/theme/palettes.dart';
import '../../../core/money/money.dart';

enum DateFormatPreference {
  dayMonthYear('dd/MM/yyyy'),
  dayShortMonthYear('d MMM yyyy'),
  iso('yyyy-MM-dd');

  const DateFormatPreference(this.pattern);
  final String pattern;
}

enum GroupView { spreadsheet, cards, timeline }

/// How the Transactions tab shows records: day-grouped list or an
/// Excel-like sheet with a running balance.
enum TransactionsView { list, sheet }

enum AutoBackupFrequency { off, daily, weekly }

enum AiProvider { local, online }

enum GujaratiInputMode { system, transliteration, keypad }

T _enum<T extends Enum>(List<T> values, String? raw, T fallback) =>
    values.firstWhere((e) => e.name == raw, orElse: () => fallback);

bool _bool(String? raw, bool fallback) => switch (raw) {
  'true' => true,
  'false' => false,
  _ => fallback,
};

DateTime? _date(String? raw) => raw == null ? null : DateTime.tryParse(raw);

/// All user preferences. Persisted as key/value strings in `app_settings`.
/// Secrets (session, API keys) are **not** part of this class.
@immutable
class AppPreferences {
  const AppPreferences({
    required this.palette,
    required this.languageCode,
    required this.onboardingComplete,
    required this.currencyCode,
    required this.dateFormat,
    required this.grouping,
    required this.calculatorAutoCalc,
    required this.defaultGroupView,
    required this.transactionsView,
    required this.groupNotifications,
    required this.reminderNotifications,
    required this.hideAmountsInNotifications,
    required this.cloudSyncEnabled,
    required this.autoBackup,
    required this.aiEnabled,
    required this.aiProvider,
    required this.aiConsent,
    required this.aiShareNames,
    required this.gujaratiInputMode,
    required this.lastAutoBackupAt,
    required this.accountVerified,
    required this.tourPending,
    required this.sampleDataLoaded,
  });

  static const supportedLanguages = ['en', 'gu'];

  factory AppPreferences.fromMap(Map<String, String> m) {
    final lang = m[_kLanguage];
    return AppPreferences(
      palette: AppPalette.parse(m[_kPalette]),
      languageCode: supportedLanguages.contains(lang) ? lang! : 'en',
      onboardingComplete: _bool(m[_kOnboarding], false),
      // v1 supports INR only; the key exists so more currencies can be
      // added without a settings migration.
      currencyCode: 'INR',
      dateFormat: _enum(
        DateFormatPreference.values,
        m[_kDateFormat],
        DateFormatPreference.dayMonthYear,
      ),
      grouping: _enum(
        MoneyGrouping.values,
        m[_kGrouping],
        MoneyGrouping.indian,
      ),
      calculatorAutoCalc: _bool(m[_kCalcAuto], true),
      defaultGroupView: _enum(
        GroupView.values,
        m[_kGroupView],
        GroupView.spreadsheet,
      ),
      transactionsView: _enum(
        TransactionsView.values,
        m[_kTransactionsView],
        TransactionsView.list,
      ),
      groupNotifications: _bool(m[_kGroupNotify], true),
      reminderNotifications: _bool(m[_kReminderNotify], true),
      hideAmountsInNotifications: _bool(m[_kHideAmounts], true),
      cloudSyncEnabled: _bool(m[_kCloudSync], false),
      autoBackup: _enum(
        AutoBackupFrequency.values,
        m[_kAutoBackup],
        AutoBackupFrequency.off,
      ),
      aiEnabled: _bool(m[_kAiEnabled], false),
      aiProvider: _enum(AiProvider.values, m[_kAiProvider], AiProvider.local),
      aiConsent: _bool(m[_kAiConsent], false),
      aiShareNames: _bool(m[_kAiNames], false),
      gujaratiInputMode: _enum(
        GujaratiInputMode.values,
        m[_kInputMode],
        GujaratiInputMode.system,
      ),
      lastAutoBackupAt: _date(m[_kLastAutoBackup]),
      accountVerified: _bool(m[_kAccountVerified], false),
      tourPending: _bool(m[_kTourPending], false),
      sampleDataLoaded: _bool(m[_kSampleData], false),
    );
  }

  // The old 'appearance.theme' (light/dark/system) key is ignored: the app
  // is light-only since 2026-11-18.
  static const _kPalette = 'appearance.palette';
  static const _kLanguage = 'locale.language';
  static const _kOnboarding = 'onboarding.complete';
  static const _kCurrency = 'finance.currency';
  static const _kDateFormat = 'finance.dateFormat';
  static const _kGrouping = 'finance.grouping';
  static const _kCalcAuto = 'finance.calculatorAuto';
  static const _kGroupView = 'groups.defaultView';
  static const _kTransactionsView = 'transactions.view';
  static const _kAccountVerified = 'account.verified';
  static const _kTourPending = 'tour.pending';
  static const _kSampleData = 'tour.sampleData';
  static const _kGroupNotify = 'groups.notifications';
  static const _kReminderNotify = 'notifications.reminders';
  static const _kHideAmounts = 'notifications.hideAmounts';
  static const _kCloudSync = 'sync.enabled';
  static const _kAutoBackup = 'backup.auto';
  static const _kLastAutoBackup = 'backup.lastAuto';
  static const _kAiEnabled = 'ai.enabled';
  static const _kAiProvider = 'ai.provider';
  static const _kAiConsent = 'ai.consent';
  static const _kAiNames = 'ai.shareNames';
  static const _kInputMode = 'input.gujaratiMode';

  final AppPalette palette;
  final String languageCode;
  final bool onboardingComplete;
  final String currencyCode;
  final DateFormatPreference dateFormat;
  final MoneyGrouping grouping;
  final bool calculatorAutoCalc;
  final GroupView defaultGroupView;
  final TransactionsView transactionsView;

  /// The user verified their email on this device (sign-up is compulsory
  /// when the build has a cloud configuration). Stays true offline; set to
  /// false on sign-out or when the cloud session is lost.
  final bool accountVerified;

  /// Offer the guided tour on the dashboard (set when onboarding finishes).
  final bool tourPending;

  /// Tour sample data is in the database (shows a "remove" banner).
  final bool sampleDataLoaded;
  final bool groupNotifications;
  final bool reminderNotifications;
  final bool hideAmountsInNotifications;
  final bool cloudSyncEnabled;
  final AutoBackupFrequency autoBackup;
  final bool aiEnabled;
  final AiProvider aiProvider;
  final bool aiConsent;
  final bool aiShareNames;
  final GujaratiInputMode gujaratiInputMode;
  final DateTime? lastAutoBackupAt;

  /// Online AI requires the assistant on, the online engine selected and
  /// explicit data-sharing consent.
  bool get canUseOnlineAi =>
      aiEnabled && aiProvider == AiProvider.online && aiConsent;

  Map<String, String> toMap() => {
    _kPalette: palette.name,
    _kLanguage: languageCode,
    _kOnboarding: '$onboardingComplete',
    _kCurrency: currencyCode,
    _kDateFormat: dateFormat.name,
    _kGrouping: grouping.name,
    _kCalcAuto: '$calculatorAutoCalc',
    _kGroupView: defaultGroupView.name,
    _kTransactionsView: transactionsView.name,
    _kGroupNotify: '$groupNotifications',
    _kReminderNotify: '$reminderNotifications',
    _kHideAmounts: '$hideAmountsInNotifications',
    _kCloudSync: '$cloudSyncEnabled',
    _kAutoBackup: autoBackup.name,
    _kAiEnabled: '$aiEnabled',
    _kAiProvider: aiProvider.name,
    _kAiConsent: '$aiConsent',
    _kAiNames: '$aiShareNames',
    _kInputMode: gujaratiInputMode.name,
    _kAccountVerified: '$accountVerified',
    _kTourPending: '$tourPending',
    _kSampleData: '$sampleDataLoaded',
    if (lastAutoBackupAt != null)
      _kLastAutoBackup: lastAutoBackupAt!.toUtc().toIso8601String(),
  };

  AppPreferences copyWith({
    AppPalette? palette,
    String? languageCode,
    bool? onboardingComplete,
    DateFormatPreference? dateFormat,
    MoneyGrouping? grouping,
    bool? calculatorAutoCalc,
    GroupView? defaultGroupView,
    TransactionsView? transactionsView,
    bool? groupNotifications,
    bool? reminderNotifications,
    bool? hideAmountsInNotifications,
    bool? cloudSyncEnabled,
    AutoBackupFrequency? autoBackup,
    bool? aiEnabled,
    AiProvider? aiProvider,
    bool? aiConsent,
    bool? aiShareNames,
    GujaratiInputMode? gujaratiInputMode,
    DateTime? lastAutoBackupAt,
    bool? accountVerified,
    bool? tourPending,
    bool? sampleDataLoaded,
  }) {
    return AppPreferences(
      palette: palette ?? this.palette,
      languageCode: languageCode ?? this.languageCode,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      currencyCode: currencyCode,
      dateFormat: dateFormat ?? this.dateFormat,
      grouping: grouping ?? this.grouping,
      calculatorAutoCalc: calculatorAutoCalc ?? this.calculatorAutoCalc,
      defaultGroupView: defaultGroupView ?? this.defaultGroupView,
      transactionsView: transactionsView ?? this.transactionsView,
      groupNotifications: groupNotifications ?? this.groupNotifications,
      reminderNotifications:
          reminderNotifications ?? this.reminderNotifications,
      hideAmountsInNotifications:
          hideAmountsInNotifications ?? this.hideAmountsInNotifications,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      autoBackup: autoBackup ?? this.autoBackup,
      aiEnabled: aiEnabled ?? this.aiEnabled,
      aiProvider: aiProvider ?? this.aiProvider,
      aiConsent: aiConsent ?? this.aiConsent,
      aiShareNames: aiShareNames ?? this.aiShareNames,
      gujaratiInputMode: gujaratiInputMode ?? this.gujaratiInputMode,
      lastAutoBackupAt: lastAutoBackupAt ?? this.lastAutoBackupAt,
      accountVerified: accountVerified ?? this.accountVerified,
      tourPending: tourPending ?? this.tourPending,
      sampleDataLoaded: sampleDataLoaded ?? this.sampleDataLoaded,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppPreferences && mapEquals(other.toMap(), toMap());

  @override
  int get hashCode => Object.hashAllUnordered(
    toMap().entries.map((e) => Object.hash(e.key, e.value)),
  );
}
