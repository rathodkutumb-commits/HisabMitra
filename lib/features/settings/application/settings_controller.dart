import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../data/settings_repository.dart';
import '../domain/app_preferences.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

/// Preferences loaded before `runApp` so the first frame already has the
/// right theme and language. Overridden in `main()` / tests.
final initialPreferencesProvider = Provider<AppPreferences>(
  (ref) => AppPreferences.fromMap(const {}),
);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppPreferences>(
      SettingsController.new,
    );

class SettingsController extends Notifier<AppPreferences> {
  @override
  AppPreferences build() => ref.read(initialPreferencesProvider);

  Future<void> update(AppPreferences Function(AppPreferences) change) async {
    final next = change(state);
    state = next;
    await ref
        .read(settingsRepositoryProvider)
        .save(next, ref.read(clockProvider).now());
  }
}

/// Convenience formatter bound to the current preferences.
class Formatters {
  Formatters(this.prefs);

  final AppPreferences prefs;

  String money(int paise, {bool signed = false, bool compact = false}) =>
      Money.format(
        paise,
        grouping: prefs.grouping,
        signed: signed,
        compactPaise: compact,
      );

  String date(DateTime d) =>
      DateFormat(prefs.dateFormat.pattern, prefs.languageCode).format(d);

  String time(DateTime d) => DateFormat.jm(prefs.languageCode).format(d);

  String dateTime(DateTime d) => '${date(d)} ${time(d)}';

  String monthYear(DateTime d) =>
      DateFormat.yMMMM(prefs.languageCode).format(d);

  String shortMonth(DateTime d) => DateFormat.MMM(prefs.languageCode).format(d);

  String dayMonth(DateTime d) => DateFormat.MMMd(prefs.languageCode).format(d);
}

final formattersProvider = Provider<Formatters>(
  (ref) => Formatters(ref.watch(settingsControllerProvider)),
);

extension FormattersX on WidgetRef {
  Formatters get fmt => watch(formattersProvider);
}

Locale localeFor(AppPreferences p) => Locale(p.languageCode);
