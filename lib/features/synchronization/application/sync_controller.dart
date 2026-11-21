import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';
import '../data/cloud_gateway.dart';
import '../data/supabase_cloud_gateway.dart';
import '../data/sync_service.dart';
import '../domain/cloud_models.dart';
import '../../reminders/application/notification_service.dart';
import '../../attachments/data/attachment_service.dart';

final cloudGatewayProvider = Provider<CloudGateway>(
  (ref) => SupabaseCloudGateway.isInitialized
      ? SupabaseCloudGateway(Supabase.instance.client)
      : const NotConfiguredCloudGateway(),
);

final cloudSessionProvider = StreamProvider<CloudSession?>((ref) async* {
  final cloud = ref.watch(cloudGatewayProvider);
  yield cloud.currentSession;
  yield* cloud.sessionChanges;
});

/// True when the device reports any network connection.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> r) =>
      r.any((c) => c != ConnectivityResult.none);
  try {
    yield online(await connectivity.checkConnectivity());
    yield* connectivity.onConnectivityChanged.map(online);
  } catch (_) {
    yield true; // Unknown — let requests decide.
  }
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    db: ref.watch(appDatabaseProvider),
    cloud: ref.watch(cloudGatewayProvider),
    clock: ref.watch(clockProvider),
    ids: ref.watch(idGeneratorProvider),
    // Reminders downloaded from the account notify on this phone too.
    scheduler: ref.watch(notificationServiceProvider),
    beforePush: () => ref.read(attachmentServiceProvider).uploadPendingFiles(),
  );
  service.personal.onFilesRemoved = (names) =>
      ref.read(attachmentServiceProvider).deleteFiles(names);
  return service;
});

final syncOverviewProvider = StreamProvider<SyncOverview>(
  (ref) => ref.watch(syncServiceProvider).watchOverview(),
);

final openConflictsProvider = StreamProvider<List<ConflictRow>>(
  (ref) => ref.watch(syncServiceProvider).openConflicts(),
);

final failedOpsProvider = StreamProvider<List<OutboxRow>>(
  (ref) => ref.watch(syncServiceProvider).watchFailedOps(),
);

@immutable
class SyncStatus {
  const SyncStatus({this.running = false, this.lastReport, this.lastError});

  final bool running;
  final SyncReport? lastReport;
  final Object? lastError;
}

class SyncController extends Notifier<SyncStatus> {
  Timer? _debounce;

  @override
  SyncStatus build() {
    // Push shortly after local changes to shared groups are queued.
    final db = ref.watch(appDatabaseProvider);
    final sub = db.select(db.syncOutbox).watch().listen((ops) {
      if (ops.isEmpty) return;
      _debounce?.cancel();
      _debounce = Timer(
        const Duration(seconds: 3),
        () => syncNow(silent: true),
      );
    });
    ref.onDispose(() {
      _debounce?.cancel();
      sub.cancel();
    });
    return const SyncStatus();
  }

  bool get canSync {
    final cloud = ref.read(cloudGatewayProvider);
    // Being signed in means syncing: records live in the account.
    return cloud.isConfigured && cloud.currentSession != null;
  }

  /// A silent sync was asked for while one was running.
  var _again = false;

  /// Runs one push + pull. With [silent] errors are recorded, never thrown.
  ///
  /// While a sync runs, a silent request returns null at once and one more
  /// sync follows the running one (a live update arriving mid-sync may have
  /// been added after that sync's pull).
  Future<SyncReport?> syncNow({bool silent = false}) async {
    if (state.running) {
      if (silent) _again = true;
      return null;
    }
    try {
      return await _syncOnce(silent: silent);
    } finally {
      if (_again && ref.mounted) {
        _again = false;
        unawaited(syncNow(silent: true));
      }
    }
  }

  Future<SyncReport?> _syncOnce({required bool silent}) async {
    if (!canSync) {
      if (silent) return null;
      throw ref.read(cloudGatewayProvider).isConfigured
          ? const AuthFailure('session_expired')
          : const NotConfiguredFailure();
    }
    if (ref.read(connectivityProvider).value == false) {
      if (silent) return null;
      throw const NetworkFailure();
    }
    state = SyncStatus(running: true, lastReport: state.lastReport);
    try {
      final report = await ref.read(syncServiceProvider).syncOnce();
      // The app (or a test) may have shut down while syncing.
      if (!ref.mounted) return report;
      state = SyncStatus(lastReport: report);
      if (report.offline && !silent) throw const NetworkFailure();
      return report;
    } catch (e, s) {
      SafeLogger.error('sync_failed', e, s);
      if (!ref.mounted) return null;
      state = SyncStatus(lastReport: state.lastReport, lastError: e);
      if (!silent) rethrow;
      return null;
    }
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);
