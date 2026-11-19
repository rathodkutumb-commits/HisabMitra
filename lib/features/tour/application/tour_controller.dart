import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../../../app/router/routes.dart';
import '../../settings/application/settings_controller.dart';
import '../data/sample_data_service.dart';

/// Widgets highlighted by the tour. Each key is attached to exactly one
/// widget in the app.
abstract final class TourTargets {
  static final hero = GlobalKey(debugLabel: 'tour-hero');
  static final khata = GlobalKey(debugLabel: 'tour-khata');
  static final quickActions = GlobalKey(debugLabel: 'tour-quick-actions');
  static final sheetToggle = GlobalKey(debugLabel: 'tour-sheet-toggle');

  /// The bottom navigation bar; a destination is one fifth of its width.
  static final navBar = GlobalKey(debugLabel: 'tour-nav-bar');
  static const navCount = 5;
}

/// What a step points at.
sealed class TourAnchor {
  const TourAnchor();
}

class KeyAnchor extends TourAnchor {
  const KeyAnchor(this.key);
  final GlobalKey key;
}

/// Destination [index] of the bottom navigation bar.
class NavAnchor extends TourAnchor {
  const NavAnchor(this.index);
  final int index;
}

/// No highlight: a centred card (the last step).
class NoAnchor extends TourAnchor {
  const NoAnchor();
}

class TourStep {
  const TourStep(this.anchor, this.route);

  final TourAnchor anchor;

  /// Opened before the step is shown.
  final String route;
}

/// The tour: dashboard → hisab → khata → groups → more → finish.
final tourSteps = <TourStep>[
  TourStep(KeyAnchor(TourTargets.hero), Routes.home),
  TourStep(KeyAnchor(TourTargets.khata), Routes.home),
  TourStep(KeyAnchor(TourTargets.quickActions), Routes.home),
  TourStep(KeyAnchor(TourTargets.sheetToggle), Routes.transactions),
  const TourStep(NavAnchor(2), Routes.people),
  const TourStep(NavAnchor(3), Routes.groups),
  const TourStep(NavAnchor(4), Routes.more),
  const TourStep(NoAnchor(), Routes.home),
];

/// Current step index, or null when no tour is running.
class TourController extends Notifier<int?> {
  @override
  int? build() => null;

  int get lastStep => tourSteps.length - 1;

  /// Loads the sample data (once) and shows the first step.
  Future<void> start() async {
    await ref.read(sampleDataServiceProvider).load();
    _show(0);
  }

  void next() {
    final s = state;
    if (s == null) return;
    _show(s < lastStep ? s + 1 : null);
  }

  void back() {
    final s = state;
    if (s == null || s == 0) return;
    _show(s - 1);
  }

  /// Jumps to the finish card (keep or remove the sample data).
  void skip() => _show(lastStep);

  /// Ends the tour; [removeSample] also removes the sample data.
  Future<void> finish({required bool removeSample}) async {
    _show(null);
    if (removeSample) await ref.read(sampleDataServiceProvider).remove();
  }

  void _show(int? step) {
    state = step;
    if (step != null) ref.read(routerProvider).go(tourSteps[step].route);
  }
}

final tourControllerProvider = NotifierProvider<TourController, int?>(
  TourController.new,
);

/// Offer the tour once after the first sign-up on this device.
Future<void> markTourOffered(WidgetRef ref) => ref
    .read(settingsControllerProvider.notifier)
    .update((p) => p.copyWith(tourPending: false));
