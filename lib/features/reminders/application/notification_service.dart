import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';
import '../../settings/application/settings_controller.dart';
import '../data/reminder_repository.dart';
import '../../synchronization/data/personal_outbox.dart';

/// Localised notification texts, resolved by the UI layer.
class NotificationTexts {
  const NotificationTexts({
    required this.genericTitle,
    required this.genericBody,
    this.paymentBody = _amountOnly,
  });

  final String genericTitle;
  final String genericBody;

  /// "₹12,500.00 due" for recurring payments (amount already formatted).
  final String Function(String amount) paymentBody;

  static String _amountOnly(String amount) => amount;
}

/// Schedules [schedule] as an exact alarm when [canExact], otherwise
/// inexact. If Android refuses the exact alarm, it retries once as inexact so
/// the reminder is never dropped. Errors from the inexact attempt propagate.
@visibleForTesting
Future<void> scheduleWithFallback({
  required bool canExact,
  required Future<void> Function(AndroidScheduleMode mode) schedule,
}) async {
  if (canExact) {
    try {
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
      return;
    } on PlatformException catch (e, s) {
      SafeLogger.error('notification_exact_refused', e, s);
    }
  }
  await schedule(AndroidScheduleMode.inexactAllowWhileIdle);
}

/// Schedules local notifications for reminders.
///
/// Privacy: when "hide amounts" is on (default), notifications show only a
/// generic text — never names or amounts. Reminders use exact alarms
/// (USE_EXACT_ALARM, granted automatically on Android 13+) so they arrive at
/// the set time; if Android refuses an exact alarm the reminder is scheduled
/// as inexact instead.
class NotificationService implements ReminderScheduler {
  NotificationService(this._ref);

  final Ref _ref;
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<bool>? _init;
  NotificationTexts texts = const NotificationTexts(
    genericTitle: 'HisabMitra',
    genericBody: 'You have a reminder',
  );

  static const _channelId = 'hisabmitra_reminders';

  String _body(ReminderRow r) {
    final amount = r.amountPaise;
    if (amount == null) return r.note ?? texts.genericBody;
    final due = texts.paymentBody(_ref.read(formattersProvider).money(amount));
    return r.note == null ? due : '$due · ${r.note}';
  }

  bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<bool> initialize() => _init ??= _doInit();

  Future<bool> _doInit() async {
    if (!_supported) return false;
    try {
      tzdata.initializeTimeZones();
      final local = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(local.identifier));
    } catch (e, s) {
      SafeLogger.error('timezone_init', e, s);
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    }
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      return true;
    } catch (e, s) {
      SafeLogger.error('notifications_init', e, s);
      return false;
    }
  }

  /// Asks for POST_NOTIFICATIONS (Android 13+). Called only when the user
  /// creates a reminder — never on app start.
  Future<bool> requestPermission() async {
    if (!await initialize()) return false;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> schedule(ReminderRow r) async {
    final prefs = _ref.read(settingsControllerProvider);
    if (!prefs.reminderNotifications) return;
    if (!await initialize()) return;
    final hide = prefs.hideAmountsInNotifications;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final canExact = await android?.canScheduleExactNotifications() ?? false;
      await scheduleWithFallback(
        canExact: canExact,
        schedule: (mode) => _plugin.zonedSchedule(
          id: r.notificationId,
          scheduledDate: tz.TZDateTime.from(r.dueAt, tz.local),
          title: hide ? texts.genericTitle : r.title,
          body: hide ? texts.genericBody : _body(r),
          androidScheduleMode: mode,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              'Reminders',
              channelDescription: 'Repayment, collection and custom reminders',
              importance: Importance.high,
              priority: Priority.high,
              visibility: NotificationVisibility.private,
            ),
          ),
        ),
      );
    } catch (e, s) {
      SafeLogger.error('notification_schedule', e, s);
    }
  }

  @override
  Future<void> cancel(int notificationId) async {
    if (!await initialize()) return;
    try {
      await _plugin.cancel(id: notificationId);
    } catch (e, s) {
      SafeLogger.error('notification_cancel', e, s);
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>(
  NotificationService.new,
);

final reminderRepositoryProvider = Provider<ReminderRepository>(
  (ref) => ReminderRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
    ref.watch(notificationServiceProvider),
    outbox: ref.watch(personalOutboxProvider),
  ),
);

final pendingRemindersProvider = StreamProvider.family<List<ReminderRow>, int?>(
  (ref, limit) =>
      ref.watch(reminderRepositoryProvider).watchPending(limit: limit),
);

final closedRemindersProvider = StreamProvider<List<ReminderRow>>(
  (ref) => ref.watch(reminderRepositoryProvider).watchClosed(),
);
