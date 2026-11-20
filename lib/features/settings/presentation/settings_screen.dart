import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../reminders/application/notification_service.dart';
import '../application/settings_controller.dart';
import '../domain/app_preferences.dart';
import 'palette_picker.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    void set(AppPreferences Function(AppPreferences) f) => controller.update(f);

    Future<T?> choose<T>(
      String title,
      List<(T, String, String?)> options,
      T current,
    ) {
      return showModalBottomSheet<T>(
        context: context,
        builder: (ctx) => SafeArea(
          child: RadioGroup<T>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(ctx, v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
                for (final (value, label, desc) in options)
                  RadioListTile<T>(
                    value: value,
                    title: Text(label),
                    subtitle: desc == null ? null : Text(desc),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      );
    }

    String viewLabel(GroupView v) => switch (v) {
      GroupView.spreadsheet => l.groupViewSpreadsheet,
      GroupView.cards => l.groupViewCards,
      GroupView.timeline => l.groupViewTimeline,
    };
    String inputLabel(GujaratiInputMode m) => switch (m) {
      GujaratiInputMode.system => l.inputModeSystem,
      GujaratiInputMode.transliteration => l.inputModeTransliteration,
      GujaratiInputMode.keypad => l.inputModeKeypad,
    };
    final sample = DateTime(2026, 8, 15);

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          SectionHeader(title: l.settingsAppearance),
          ListTile(
            leading: PaletteSwatch(palette: p.palette, size: 36),
            title: Text(l.settingsTheme),
            subtitle: Text(paletteName(l, p.palette)),
            onTap: () async {
              final v = await showPalettePicker(context, p.palette);
              if (v != null) set((x) => x.copyWith(palette: v));
            },
          ),
          ListTile(
            leading: const Icon(Icons.translate_rounded),
            title: Text(l.settingsLanguage),
            subtitle: Text(
              p.languageCode == 'gu' ? l.languageGujarati : l.languageEnglish,
            ),
            onTap: () async {
              final v = await choose(l.settingsLanguage, [
                ('gu', l.languageGujarati, null),
                ('en', l.languageEnglish, null),
              ], p.languageCode);
              if (v != null) set((x) => x.copyWith(languageCode: v));
            },
          ),
          ListTile(
            leading: const Icon(Icons.keyboard_rounded),
            title: Text(l.settingsGujaratiInput),
            subtitle: Text(inputLabel(p.gujaratiInputMode)),
            onTap: () async {
              final v = await choose(l.settingsGujaratiInput, [
                for (final m in GujaratiInputMode.values)
                  (m, inputLabel(m), null),
              ], p.gujaratiInputMode);
              if (v != null) set((x) => x.copyWith(gujaratiInputMode: v));
            },
          ),
          SectionHeader(title: l.settingsFinance),
          ListTile(
            leading: const Icon(Icons.currency_rupee_rounded),
            title: Text(l.settingsCurrency),
            subtitle: Text(l.currencyInr),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month_rounded),
            title: Text(l.settingsDateFormat),
            subtitle: Text(ref.fmt.date(sample)),
            onTap: () async {
              final v = await choose(l.settingsDateFormat, [
                for (final f in DateFormatPreference.values)
                  (f, Formatters(p.copyWith(dateFormat: f)).date(sample), null),
              ], p.dateFormat);
              if (v != null) set((x) => x.copyWith(dateFormat: v));
            },
          ),
          ListTile(
            leading: const Icon(Icons.pin_rounded),
            title: Text(l.settingsNumberFormat),
            subtitle: Text(Money.format(12345600, grouping: p.grouping)),
            onTap: () async {
              final v = await choose(l.settingsNumberFormat, [
                (MoneyGrouping.indian, l.numberFormatIndian, null),
                (
                  MoneyGrouping.international,
                  l.numberFormatInternational,
                  null,
                ),
              ], p.grouping);
              if (v != null) set((x) => x.copyWith(grouping: v));
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.calculate_rounded),
            title: Text(l.settingsCalculatorAuto),
            subtitle: Text(l.settingsCalculatorAutoDesc),
            value: p.calculatorAutoCalc,
            onChanged: (v) => set((x) => x.copyWith(calculatorAutoCalc: v)),
          ),
          ListTile(
            leading: const Icon(Icons.category_rounded),
            title: Text(l.settingsCategories),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.categories),
          ),
          SectionHeader(title: l.settingsGroupSection),
          ListTile(
            leading: const Icon(Icons.view_quilt_rounded),
            title: Text(l.settingsDefaultGroupView),
            subtitle: Text(viewLabel(p.defaultGroupView)),
            onTap: () async {
              final v = await choose(l.settingsDefaultGroupView, [
                for (final g in GroupView.values) (g, viewLabel(g), null),
              ], p.defaultGroupView);
              if (v != null) set((x) => x.copyWith(defaultGroupView: v));
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.groups_rounded),
            title: Text(l.settingsGroupNotifications),
            value: p.groupNotifications,
            onChanged: (v) => set((x) => x.copyWith(groupNotifications: v)),
          ),
          SectionHeader(title: l.settingsNotifications),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_active_rounded),
            title: Text(l.settingsReminderNotifications),
            value: p.reminderNotifications,
            onChanged: (v) async {
              await controller.update(
                (x) => x.copyWith(reminderNotifications: v),
              );
              final repo = ref.read(reminderRepositoryProvider);
              v
                  ? await repo.rescheduleAll()
                  : await repo.cancelAllNotifications();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.visibility_off_rounded),
            title: Text(l.settingsHideAmounts),
            subtitle: Text(l.settingsHideAmountsDesc),
            value: p.hideAmountsInNotifications,
            onChanged: (v) async {
              await controller.update(
                (x) => x.copyWith(hideAmountsInNotifications: v),
              );
              await ref.read(reminderRepositoryProvider).rescheduleAll();
            },
          ),
          ListTile(
            leading: const Icon(Icons.alarm_rounded),
            title: Text(l.settingsReminders),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.reminders),
          ),
          if (AppConfig.isCloudConfigured) ...[
            SectionHeader(title: l.settingsSync),
            ListTile(
              leading: const Icon(Icons.sync_rounded),
              title: Text(l.settingsSyncStatus),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push(Routes.sync),
            ),
          ],
          SectionHeader(title: l.settingsBackup),
          ListTile(
            leading: const Icon(Icons.backup_rounded),
            title: Text(l.settingsBackup),
            subtitle: Text(l.settingsBackupDesc),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.backup),
          ),
          SectionHeader(title: l.settingsAi),
          ListTile(
            leading: const Icon(Icons.auto_awesome_rounded),
            title: Text(l.settingsAi),
            subtitle: Text(
              p.aiEnabled
                  ? (p.aiProvider == AiProvider.local
                        ? l.aiProviderLocal
                        : l.aiProviderOnline)
                  : l.autoBackupOff,
            ),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('${Routes.ai}/settings'),
          ),
          SectionHeader(title: l.settingsAccount),
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: Text(l.settingsProfile),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.profile),
          ),
          SectionHeader(title: l.settingsAbout),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(l.settingsAbout),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(Routes.about),
          ),
        ],
      ),
    );
  }
}
