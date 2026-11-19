import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/providers.dart';
import 'core/security/safe_logger.dart';
import 'features/backup/application/backup_providers.dart';
import 'features/synchronization/data/supabase_cloud_gateway.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/domain/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en');
  await initializeDateFormatting('gu');
  FlutterError.onError = (details) {
    SafeLogger.error('flutter_error', details.exception, details.stack);
    FlutterError.presentError(details);
  };
  // Cloud is optional: without --dart-define configuration this is a no-op.
  await SupabaseCloudGateway.initialize();
  var version = '1.0.0';
  try {
    final info = await PackageInfo.fromPlatform();
    version = '${info.version}+${info.buildNumber}';
  } catch (_) {
    // Package info is unavailable in some test hosts; keep the default.
  }
  runApp(AppBootstrap(appVersion: version));
}

/// Opens the database, loads preferences, and hosts the [ProviderScope].
///
/// [AppBootstrap.restart] closes and reopens everything — used after a
/// backup restore replaces the database file.
class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key, this.appVersion = '1.0.0'});

  final String appVersion;

  /// One-time message shown by the rebuilt app after a restart (e.g. the
  /// result of a restore, computed before the old UI was torn down).
  static String? noticeAfterRestart;

  static String? takeNotice() {
    final n = noticeAfterRestart;
    noticeAfterRestart = null;
    return n;
  }

  static Future<void> restart(BuildContext context) =>
      context.findAncestorStateOfType<_AppBootstrapState>()!._restart();

  /// Closes the database so its file can be replaced, runs [whileClosed],
  /// then reopens and rebuilds the app.
  static Future<void> replaceDatabase(
    BuildContext context,
    Future<void> Function() whileClosed,
  ) => context.findAncestorStateOfType<_AppBootstrapState>()!._replace(
    whileClosed,
  );

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  AppDatabase? _db;
  AppPreferences? _prefs;
  Object? _error;
  var _generation = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_open());
  }

  Future<void> _open() async {
    try {
      final db = AppDatabase.open();
      final prefs = await SettingsRepository(db).load();
      if (!mounted) return;
      setState(() {
        _db = db;
        _prefs = prefs;
        _error = null;
        _generation++;
      });
    } catch (e, s) {
      SafeLogger.error('bootstrap_failed', e, s);
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _restart() async {
    final old = _db;
    setState(() {
      _db = null;
      _prefs = null;
    });
    await old?.close();
    await _open();
  }

  Future<void> _replace(Future<void> Function() whileClosed) async {
    final old = _db;
    setState(() {
      _db = null;
      _prefs = null;
    });
    await old?.close();
    try {
      await whileClosed();
    } finally {
      await _open();
    }
  }

  @override
  void dispose() {
    unawaited(_db?.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'HisabMitra could not open its data. Please restart the app.\n'
                'હિસાબમિત્ર ડેટા ખોલી શક્યું નહીં. કૃપા કરીને એપ ફરી શરૂ કરો.',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }
    final db = _db;
    final prefs = _prefs;
    if (db == null || prefs == null) {
      // Matches the native splash (Rann Utsav salt white) to avoid a flash.
      return const ColoredBox(color: Color(0xFFF8F8F5));
    }
    return ProviderScope(
      key: ValueKey(_generation),
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        initialPreferencesProvider.overrideWithValue(prefs),
        appVersionProvider.overrideWithValue(widget.appVersion),
      ],
      child: const HisabMitraApp(),
    );
  }
}
