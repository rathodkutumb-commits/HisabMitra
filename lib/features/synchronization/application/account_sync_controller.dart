import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';
import '../../groups/data/group_repository.dart';
import '../../settings/application/settings_controller.dart';
import '../data/personal_outbox.dart';
import 'sync_controller.dart';

enum AccountSyncPhase { idle, uploading, downloading, offline, done, failed }

@immutable
class AccountSyncState {
  const AccountSyncState({
    this.phase = AccountSyncPhase.idle,
    this.done = 0,
    this.total = 0,
  });

  final AccountSyncPhase phase;

  /// Changes uploaded so far, of [total] (upload phase).
  final int done;
  final int total;
}

/// The first sync of a phone with the account: uploads what an older app
/// version kept only on the phone, then downloads everything in the account
/// (new or reset phone). Marks `initialSyncDone` when the account and the
/// phone agree.
class AccountSyncController extends Notifier<AccountSyncState> {
  var _running = false;

  @override
  AccountSyncState build() => const AccountSyncState();

  AppDatabase get _db => ref.read(appDatabaseProvider);

  /// Queues every record never uploaded (written before v4) and saves
  /// phone-only groups to the account. Sample data stays on the phone.
  /// Returns how many records and groups were queued.
  Future<int> queueUnsentData() async {
    var n = await ref.read(personalOutboxProvider).queueUnsentLocalData();
    final uid = ref.read(cloudGatewayProvider).currentSession?.userId;
    if (uid == null) return n;
    final sample = await _sampleGroupIds();
    final local = await (_db.select(
      _db.groupsCache,
    )..where((g) => g.isShared.equals(false) & g.deletedAt.isNull())).get();
    final groups = ref.read(groupRepositoryProvider);
    for (final g in local) {
      if (sample.contains(g.id)) continue;
      await groups.markShared(g.id, ownerUserId: uid);
      n++;
    }
    return n;
  }

  Future<Set<String>> _sampleGroupIds() async {
    final row =
        await (_db.select(_db.appSettings)
              ..where((s) => s.key.equals(PersonalOutbox.sampleIdsKey)))
            .getSingleOrNull();
    if (row == null) return const {};
    try {
      final groups = (jsonDecode(row.value) as Map)['groups'];
      return {if (groups is List) ...groups.whereType<String>()};
    } on FormatException {
      return const {};
    }
  }

  Future<int> _pending() async => (await (_db.select(
    _db.syncOutbox,
  )..where((o) => o.status.equalsValue(OutboxStatus.pending))).get()).length;

  /// Runs the first sync. [retryNow] skips the wait after a failed attempt
  /// (the "Retry" button).
  Future<void> run({bool retryNow = false}) async {
    if (_running) return;
    _running = true;
    try {
      await queueUnsentData();
      if (retryNow) {
        await (_db.update(_db.syncOutbox)
              ..where((o) => o.status.equalsValue(OutboxStatus.pending)))
            .write(const SyncOutboxCompanion(nextAttemptAt: Value(null)));
      }
      final total = await _pending();
      state = AccountSyncState(
        phase: total > 0
            ? AccountSyncPhase.uploading
            : AccountSyncPhase.downloading,
        total: total,
      );
      final sync = ref.read(syncServiceProvider);
      for (var round = 0; round < 50; round++) {
        final report = await sync.syncOnce();
        if (!ref.mounted) return;
        final left = await _pending();
        if (report.offline) {
          state = AccountSyncState(
            phase: AccountSyncPhase.offline,
            done: total - left,
            total: total,
          );
          return;
        }
        state = AccountSyncState(
          phase: left > 0
              ? AccountSyncPhase.uploading
              : AccountSyncPhase.downloading,
          done: total - left,
          total: total,
        );
        if (left == 0) break;
        if (report.pushed == 0) {
          // Nothing moved (waiting to retry): try again on the next start.
          state = AccountSyncState(
            phase: AccountSyncPhase.offline,
            done: total - left,
            total: total,
          );
          return;
        }
      }
      await ref
          .read(settingsControllerProvider.notifier)
          .update((p) => p.copyWith(initialSyncDone: true));
      if (!ref.mounted) return;
      state = AccountSyncState(
        phase: AccountSyncPhase.done,
        done: total,
        total: total,
      );
    } catch (e, s) {
      SafeLogger.error('account_sync', e, s);
      if (ref.mounted) {
        state = AccountSyncState(
          phase: AccountSyncPhase.failed,
          done: state.done,
          total: state.total,
        );
      }
    } finally {
      _running = false;
    }
  }
}

final accountSyncControllerProvider =
    NotifierProvider<AccountSyncController, AccountSyncState>(
      AccountSyncController.new,
    );

/// "Continue in background" on the first-sync screen, for this run of the
/// app only (the screen comes back on the next start until it completes).
class AccountSyncDeferred extends Notifier<bool> {
  @override
  bool build() => false;

  void defer() => state = true;
}

final accountSyncDeferredProvider = NotifierProvider<AccountSyncDeferred, bool>(
  AccountSyncDeferred.new,
);
