import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/backup/application/backup_providers.dart';
import '../features/reminders/application/notification_service.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/tour/presentation/tour_overlay.dart';
import '../features/synchronization/application/sync_controller.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

class HisabMitraApp extends ConsumerStatefulWidget {
  const HisabMitraApp({super.key});

  @override
  ConsumerState<HisabMitraApp> createState() => _HisabMitraAppState();
}

class _HisabMitraAppState extends ConsumerState<HisabMitraApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notice = AppBootstrap.takeNotice();
      if (notice != null) {
        _messengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(notice)),
        );
      }
      _onForeground();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _onForeground();
  }

  /// Best-effort work whenever the app comes to the foreground: notification
  /// setup, a due automatic backup and a sync attempt. Never blocks the UI.
  void _onForeground() {
    unawaited(ref.read(notificationServiceProvider).initialize());
    unawaited(ref.read(autoBackupRunnerProvider).runIfDue());
    unawaited(ref.read(syncControllerProvider.notifier).syncNow(silent: true));
  }

  @override
  Widget build(BuildContext context) {
    final prefs = ref.watch(settingsControllerProvider);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'HisabMitra',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _messengerKey,
      theme: AppTheme.light(
        palette: prefs.palette,
        languageCode: prefs.languageCode,
      ),
      // Light-only by product decision (TD-23); never follow a dark system
      // setting.
      themeMode: ThemeMode.light,
      locale: localeFor(prefs),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        // Keep notification texts in the user's language.
        final l = AppLocalizations.of(context);
        ref.read(notificationServiceProvider).texts = NotificationTexts(
          genericTitle: l.notificationGenericTitle,
          genericBody: l.notificationGenericBody,
          paymentBody: l.notificationPaymentBody,
        );
        return Stack(
          children: [child ?? const SizedBox.shrink(), const TourOverlay()],
        );
      },
    );
  }
}
