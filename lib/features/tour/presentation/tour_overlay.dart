import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../application/tour_controller.dart';

/// Spotlight tour shown above the whole app (placed in
/// `MaterialApp.builder`). Dims the screen, cuts a rounded hole around the
/// current target and shows a card with the step text.
class TourOverlay extends ConsumerStatefulWidget {
  const TourOverlay({super.key});

  @override
  ConsumerState<TourOverlay> createState() => _TourOverlayState();
}

class _TourOverlayState extends ConsumerState<TourOverlay>
    with SingleTickerProviderStateMixin {
  // Tracks the target for a moment after each step change (page
  // transitions, scrolling), then stops so the app can idle.
  late final Ticker _ticker = createTicker((elapsed) {
    _measure();
    if (elapsed > const Duration(milliseconds: 1200)) _ticker.stop();
  });
  Rect? _hole;
  int? _scrolledForStep;
  int? _trackedStep;
  var _busy = false;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Measures the target; repaints only when the hole moves.
  void _measure() {
    final step = ref.read(tourControllerProvider);
    if (step == null) return;
    final rect = _targetRect(tourSteps[step].anchor);
    if (rect != null && _scrolledForStep != step) {
      _scrolledForStep = step;
      final ctx = switch (tourSteps[step].anchor) {
        KeyAnchor(:final key) => key.currentContext,
        _ => null,
      };
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          alignment: 0.3,
          duration: const Duration(milliseconds: 250),
        );
      }
    }
    if (rect != _hole) setState(() => _hole = rect);
  }

  Rect? _targetRect(TourAnchor anchor) {
    Rect? rectOf(GlobalKey key) {
      final box = key.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.hasSize || !box.attached) return null;
      return box.localToGlobal(Offset.zero) & box.size;
    }

    return switch (anchor) {
      KeyAnchor(:final key) => rectOf(key)?.inflate(6),
      NavAnchor(:final index) => () {
        final bar = rectOf(TourTargets.navBar);
        if (bar == null) return null;
        final w = bar.width / TourTargets.navCount;
        return Rect.fromLTWH(bar.left + w * index, bar.top, w, bar.height);
      }(),
      NoAnchor() => null,
    };
  }

  Future<void> _finish(bool removeSample) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(tourControllerProvider.notifier)
          .finish(removeSample: removeSample);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = ref.watch(tourControllerProvider);
    if (step == null) {
      if (_ticker.isActive) _ticker.stop();
      _hole = null;
      _scrolledForStep = null;
      _trackedStep = null;
      return const SizedBox.shrink();
    }
    if (_trackedStep != step) {
      _trackedStep = step;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _ticker
          ..stop()
          ..start();
      });
    }

    final l = context.l10n;
    final controller = ref.read(tourControllerProvider.notifier);
    final last = controller.lastStep;
    final isFinish = step == last;
    final (title, body) = switch (step) {
      0 => (l.tour1Title, l.tour1Body),
      1 => (l.tour2Title, l.tour2Body),
      2 => (l.tour3Title, l.tour3Body),
      3 => (l.tour4Title, l.tour4Body),
      4 => (l.tour5Title, l.tour5Body),
      5 => (l.tour6Title, l.tour6Body),
      6 => (l.tour7Title, l.tour7Body),
      _ => (l.tourFinishTitle, l.tourFinishBody),
    };
    final hole = isFinish ? null : _hole;
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final card = Material(
      color: scheme.surface,
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isFinish)
              Text(
                l.tourStepOf(step + 1, last),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.primary,
                ),
              ),
            const SizedBox(height: 4),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(body, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            if (isFinish)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: _busy ? null : () => _finish(true),
                    child: Text(l.tourRemoveSample),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _busy ? null : () => _finish(false),
                    child: Text(l.tourKeepSample),
                  ),
                ],
              )
            else
              Row(
                children: [
                  TextButton(
                    onPressed: controller.skip,
                    child: Text(l.tourSkip),
                  ),
                  const Spacer(),
                  if (step > 0)
                    TextButton(
                      onPressed: controller.back,
                      child: Text(l.tourBack),
                    ),
                  FilledButton(
                    onPressed: controller.next,
                    child: Text(l.tourNext),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    // Card below a target in the top half, above one in the bottom half.
    const margin = 16.0;
    final width = (size.width - 2 * margin).clamp(0.0, 420.0);
    final left = (size.width - width) / 2;
    Widget placed;
    if (hole == null) {
      placed = Center(
        child: Padding(
          padding: const EdgeInsets.all(margin),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: card,
          ),
        ),
      );
    } else if (hole.center.dy < size.height / 2) {
      placed = Positioned(
        left: left,
        width: width,
        top: hole.bottom + 12,
        child: card,
      );
    } else {
      placed = Positioned(
        left: left,
        width: width,
        bottom: size.height - hole.top + 12,
        child: card,
      );
    }

    return Positioned.fill(
      child: Stack(
        children: [
          // Absorb taps so the app underneath is not used mid-tour.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: CustomPaint(
                painter: _SpotlightPainter(
                  hole: hole,
                  scrim: Colors.black.withValues(alpha: 0.62),
                  ring: scheme.primaryContainer,
                ),
              ),
            ),
          ),
          placed,
        ],
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.hole,
    required this.scrim,
    required this.ring,
  });

  final Rect? hole;
  final Color scrim;
  final Color ring;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Path()..addRect(Offset.zero & size);
    final h = hole;
    if (h == null) {
      canvas.drawPath(full, Paint()..color = scrim);
      return;
    }
    final rrect = RRect.fromRectAndRadius(h, const Radius.circular(16));
    final cut = Path()..addRRect(rrect);
    canvas.drawPath(
      Path.combine(PathOperation.difference, full, cut),
      Paint()..color = scrim,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = ring
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.scrim != scrim || old.ring != ring;
}
