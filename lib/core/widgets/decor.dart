import 'package:flutter/material.dart';

import '../../app/theme/hm_colors.dart';
import '../../app/theme/patterns.dart';

/// Very subtle Bandhani dot texture behind [child]. Use for empty states,
/// onboarding and hero areas — not behind forms or tables.
class BandhaniBackground extends StatelessWidget {
  const BandhaniBackground({super.key, required this.child, this.opacity = 1});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final hm = HmColors.of(context);
    return CustomPaint(
      painter: BandhaniPatternPainter(
        color: hm.pattern.withValues(alpha: hm.pattern.a * opacity),
      ),
      child: child,
    );
  }
}

/// Thin Patola lozenge band, used under section titles and hero cards.
class PatolaDivider extends StatelessWidget {
  const PatolaDivider({super.key, this.height = 8, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hm = HmColors.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: width,
        child: CustomPaint(
          painter: PatolaBandPainter(
            primary: scheme.secondary.withValues(alpha: 0.75),
            accent: hm.highlight,
          ),
        ),
      ),
    );
  }
}

/// Festive toran garland for the top of onboarding/splash screens.
class ToranStrip extends StatelessWidget {
  const ToranStrip({super.key, this.height = 40});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hm = HmColors.of(context);
    return ExcludeSemantics(
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: ToranPainter(
            // Green is reserved for "money in" (TD-23), so leaves take the
            // palette colour.
            leaf: scheme.primary,
            flower: hm.highlight,
            string: scheme.secondary,
          ),
        ),
      ),
    );
  }
}
