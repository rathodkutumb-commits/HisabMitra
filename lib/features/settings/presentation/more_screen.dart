import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../tour/application/tour_controller.dart';
import '../../../core/widgets/hm_logo.dart';
import '../../profile/data/profile_repository.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final profile = ref.watch(profileProvider).value;

    Widget tile(
      IconData icon,
      Color color,
      String title,
      String route, {
      String? subtitle,
    }) => ListTile(
      leading: IconBadge(icon: icon, color: color),
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () => context.push(route),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.navMore)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: profile == null
                    ? const HmLogo(size: 48)
                    : InitialsAvatar(name: profile.displayName, radius: 24),
                title: Text(
                  profile?.displayName ?? l.appName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                subtitle: Text(profile?.phone ?? l.privateOnDevice),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.push(Routes.profile),
              ),
            ),
          ),
          SectionHeader(title: l.quickActions),
          tile(
            Icons.insights_rounded,
            scheme.primary,
            l.reportsTitle,
            Routes.reports,
          ),
          tile(
            Icons.auto_awesome_rounded,
            scheme.tertiary,
            l.settingsAi,
            Routes.ai,
          ),
          tile(
            Icons.alarm_rounded,
            scheme.secondary,
            l.remindersTitle,
            Routes.reminders,
          ),
          tile(
            Icons.calculate_rounded,
            scheme.primary,
            l.calculatorTitle,
            Routes.calculator,
          ),
          tile(
            Icons.category_rounded,
            scheme.tertiary,
            l.categoriesTitle,
            Routes.categories,
          ),
          SectionHeader(title: l.settingsBackup),
          tile(
            Icons.backup_rounded,
            scheme.secondary,
            l.settingsBackup,
            Routes.backup,
            subtitle: l.settingsBackupDesc,
          ),
          if (AppConfig.isCloudConfigured)
            tile(
              Icons.cloud_sync_rounded,
              scheme.primary,
              l.settingsSyncStatus,
              Routes.sync,
            ),
          SectionHeader(title: l.settingsTitle),
          tile(
            Icons.settings_rounded,
            scheme.primary,
            l.settingsTitle,
            Routes.settings,
          ),
          ListTile(
            leading: IconBadge(
              icon: Icons.tour_rounded,
              color: scheme.tertiary,
            ),
            title: Text(l.moreAppTour),
            subtitle: Text(l.moreAppTourDesc),
            trailing: const Icon(Icons.play_circle_outline_rounded),
            onTap: () => ref.read(tourControllerProvider.notifier).start(),
          ),
          tile(
            Icons.info_outline_rounded,
            scheme.secondary,
            l.settingsAbout,
            Routes.about,
          ),
        ],
      ),
    );
  }
}
