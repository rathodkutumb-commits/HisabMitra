import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/attachments/data/attachment_service.dart';
import '../features/reminders/application/notification_service.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/tour/presentation/tour_overlay.dart';
import '../features/synchronization/application/live_sync.dart';
import '../features/synchronization/application/sync_controller.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import 'router/app_router.dart';
import 'router/routes.dart';
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
      unawaited(_recoverCameraPhoto());
    });
  }

  /// After Android closed the app while the camera was open, offers the
  /// photo for a new expense (the next new form picks it up).
  Future<void> _recoverCameraPhoto() async {
    if (kIsWeb || !Platform.isAndroid) return;
    final photo = await ref.read(attachmentServiceProvider).recoverLostPhoto();
    if (photo == null || !mounted) return;
    ref.read(recoveredPhotoProvider.notifier).set(photo);
    final messenger = _messengerKey.currentState;
    if (messenger == null) return;
    final l = AppLocalizations.of(messenger.context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(l.photoRecovered),
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: l.photoRecoveredAction,
          onPressed: () =>
              ref.read(routerProvider).push(Routes.newTransaction()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _onForeground();
      case AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        // Live updates only while the app is on screen.
        ref.read(liveSyncControllerProvider.notifier).setForeground(false);
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// Best-effort work whenever the app comes to the foreground: notification
  /// setup, a sync attempt and live updates. Never blocks the UI.
  void _onForeground() {
    unawaited(ref.read(notificationServiceProvider).initialize());
    unawaited(ref.read(syncControllerProvider.notifier).syncNow(silent: true));
    ref.read(liveSyncControllerProvider.notifier).setForeground(true);
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
