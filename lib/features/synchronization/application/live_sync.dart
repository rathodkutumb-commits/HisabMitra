import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/security/safe_logger.dart';
import 'sync_controller.dart';

/// Live updates: answers change signals from the cloud with a sync.
///
/// Signals carry no data — the normal pull brings the changes in. Signals
/// that arrive within [debounce] of each other lead to one sync.
class LiveSync {
  LiveSync({
    required this.signals,
    required this.sync,
    this.debounce = const Duration(seconds: 1),
  });

  final Stream<void> Function() signals;
  final Future<void> Function() sync;
  final Duration debounce;

  StreamSubscription<void>? _sub;
  Timer? _timer;

  bool get isListening => _sub != null;

  /// Starts listening (does nothing when already listening).
  void start() {
    if (_sub != null) return;
    _sub = signals().listen(
      (_) => _schedule(),
      onError: (Object e, StackTrace s) => SafeLogger.error('live_sync', e, s),
    );
  }

  /// Stops listening and drops a sync that was about to start.
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(debounce, () {
      _timer = null;
      if (_sub == null) return;
      unawaited(_run());
    });
  }

  Future<void> _run() async {
    try {
      await sync();
    } catch (e, s) {
      // A failed sync is retried by the next signal or app start.
      SafeLogger.error('live_sync', e, s);
    }
  }
}

/// Listens for live updates while the user is signed in and the app is in
/// the foreground (state: listening). The app reports the foreground with
/// [setForeground]; sign-in and sign-out are followed automatically.
class LiveSyncController extends Notifier<bool> {
  late LiveSync _live;
  var _foreground = false;
  String? _userId;

  @override
  bool build() {
    _live = LiveSync(
      signals: () => ref.read(cloudGatewayProvider).changeSignals(),
      sync: () =>
          ref.read(syncControllerProvider.notifier).syncNow(silent: true),
    );
    ref.listen(cloudSessionProvider, (_, _) => _update());
    ref.onDispose(() => unawaited(_live.stop()));
    return false;
  }

  void setForeground(bool foreground) {
    _foreground = foreground;
    _update();
  }

  void _update() {
    final cloud = ref.read(cloudGatewayProvider);
    final userId = cloud.isConfigured ? cloud.currentSession?.userId : null;
    final want = _foreground && userId != null;
    // A different account gets its own connection.
    if (_live.isListening && (!want || userId != _userId)) {
      unawaited(_live.stop());
    }
    if (want && !_live.isListening) _live.start();
    _userId = want ? userId : null;
    state = _live.isListening;
  }
}

final liveSyncControllerProvider = NotifierProvider<LiveSyncController, bool>(
  LiveSyncController.new,
);
