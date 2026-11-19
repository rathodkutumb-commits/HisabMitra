import 'package:flutter/material.dart';

import '../../app/theme/hm_colors.dart';
import '../../app/theme/palettes.dart';

enum HmLogoVariant {
  /// Palette-coloured rounded tile + full mark. Launcher icon, in-app logo.
  tile,

  /// Mark on a transparent background.
  light,

  /// Single-colour silhouette (Android 13 themed icon).
  mono,

  /// Foreground layer for Android adaptive icons (mark only, scaled into
  /// the 66/108 safe zone).
  adaptiveForeground,
}

/// The HisabMitra mark: an open red *chopda* (traditional Gujarati ledger)
/// with a ₹ on the right page and three family heads above it. Coloured by
/// the active palette.
class HmLogo extends StatelessWidget {
  const HmLogo({super.key, this.size = 48, this.variant = HmLogoVariant.tile});

  final double size;
  final HmLogoVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<HmColors>()?.logo;
    return Semantics(
      label: 'HisabMitra',
      image: true,
      child: CustomPaint(
        size: Size.square(size),
        painter: HmLogoPainter(variant: variant, colors: colors),
      ),
    );
  }
}

class HmLogoPainter extends CustomPainter {
  HmLogoPainter({required this.variant, LogoColors? colors})
    : colors = colors ?? AppPalette.defaultPalette.spec.logo;

  final HmLogoVariant variant;
  final LogoColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.save();
    canvas.translate((size.width - s) / 2, (size.height - s) / 2);

    if (variant == HmLogoVariant.tile) {
      final rect = Rect.fromLTWH(0, 0, s, s);
      final tile = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.22));
      canvas.drawRRect(
        tile,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors.tileStart, colors.tileEnd],
          ).createShader(rect),
      );
    }

    // Mark geometry is defined on a unit square; adaptive foreground shrinks
    // it into the central safe zone.
    final markScale = variant == HmLogoVariant.adaptiveForeground ? 0.62 : 1.0;
    canvas.translate(s * (1 - markScale) / 2, s * (1 - markScale) / 2);
    if (variant == HmLogoVariant.mono) {
      // Needed so the rupee can be cut out of the silhouette (BlendMode.clear).
      canvas.saveLayer(Rect.fromLTWH(0, 0, s, s), Paint());
      _paintMark(canvas, s * markScale);
      canvas.restore();
    } else {
      _paintMark(canvas, s * markScale);
    }
    canvas.restore();
  }

  void _paintMark(Canvas canvas, double s) {
    final mono = variant == HmLogoVariant.mono;
    const white = Colors.white;

    // On a transparent background light figures would vanish, so they take
    // the cover colour there.
    final figures = mono
        ? white
        : (variant == HmLogoVariant.light ? colors.cover : colors.figures);
    final gold = mono ? white : colors.figures;
    final cover = mono ? white : colors.cover;
    final page = mono ? Colors.transparent : const Color(0xFFFFF8EC);
    final ink = mono ? white : colors.ink;
    final lineColor = mono ? white : colors.cover.withValues(alpha: 0.35);

    Offset p(double x, double y) => Offset(x * s, y * s);

    // Family: three people (head + rounded body), parent in the middle.
    final personPaint = Paint()..color = figures;
    void person(double cx, double headY, double headR, double bodyW) {
      canvas.drawCircle(p(cx, headY), s * headR, personPaint);
      final bodyTop = headY + headR + 0.025;
      final bodyH = bodyW * 0.7;
      final rect = Rect.fromLTWH(
        (cx - bodyW / 2) * s,
        bodyTop * s,
        bodyW * s,
        bodyH * 2 * s,
      );
      final body = Path()
        ..addArc(rect, 3.14159, 3.14159)
        ..close();
      canvas.drawPath(body, personPaint);
    }

    person(0.31, 0.215, 0.045, 0.15);
    person(0.69, 0.215, 0.045, 0.15);
    person(0.5, 0.165, 0.058, 0.19);

    // Book cover, slightly larger than the pages.
    final coverPath = Path()
      ..moveTo(0.5 * s, 0.43 * s)
      ..quadraticBezierTo(0.32 * s, 0.36 * s, 0.11 * s, 0.40 * s)
      ..lineTo(0.11 * s, 0.84 * s)
      ..quadraticBezierTo(0.32 * s, 0.80 * s, 0.5 * s, 0.88 * s)
      ..quadraticBezierTo(0.68 * s, 0.80 * s, 0.89 * s, 0.84 * s)
      ..lineTo(0.89 * s, 0.40 * s)
      ..quadraticBezierTo(0.68 * s, 0.36 * s, 0.5 * s, 0.43 * s)
      ..close();
    canvas.drawPath(coverPath, Paint()..color = cover);

    if (!mono) {
      Path pageFor(bool left) {
        final dir = left ? -1.0 : 1.0;
        return Path()
          ..moveTo(0.5 * s, 0.45 * s)
          ..quadraticBezierTo(
            (0.5 + dir * 0.17) * s,
            0.385 * s,
            (0.5 + dir * 0.35) * s,
            0.415 * s,
          )
          ..lineTo((0.5 + dir * 0.35) * s, 0.80 * s)
          ..quadraticBezierTo(
            (0.5 + dir * 0.17) * s,
            0.77 * s,
            0.5 * s,
            0.835 * s,
          )
          ..close();
      }

      final pagePaint = Paint()..color = page;
      canvas.drawPath(pageFor(true), pagePaint);
      canvas.drawPath(pageFor(false), pagePaint);

      // Ledger rules on the left page.
      final rule = Paint()
        ..color = lineColor
        ..strokeWidth = s * 0.018
        ..strokeCap = StrokeCap.round;
      for (var i = 0; i < 4; i++) {
        final y = 0.52 + i * 0.075;
        canvas.drawLine(p(0.21, y), p(0.44, y + 0.01), rule);
      }
    }

    // Gold spine.
    canvas.drawLine(
      p(0.5, 0.45),
      p(0.5, 0.835),
      Paint()
        ..color = gold
        ..strokeWidth = s * 0.025
        ..strokeCap = StrokeCap.round,
    );

    // Rupee on the right page (on the cover colour for mono).
    _paintRupee(
      canvas,
      origin: p(0.585, 0.5),
      height: s * 0.26,
      color: mono ? Colors.black.withValues(alpha: 0) : ink,
      monoCutout: mono,
      s: s,
    );
  }

  void _paintRupee(
    Canvas canvas, {
    required Offset origin,
    required double height,
    required Color color,
    required bool monoCutout,
    required double s,
  }) {
    final w = height * 0.62;
    final x0 = origin.dx;
    final y0 = origin.dy;
    final paint = Paint()
      ..color = monoCutout ? Colors.white : color
      ..style = PaintingStyle.stroke
      ..strokeWidth = height * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (monoCutout) {
      // In mono mode the page area is transparent and the cover is white,
      // so draw the rupee as a clear cut-out.
      paint.blendMode = BlendMode.clear;
    }
    final path = Path()
      ..moveTo(x0, y0)
      ..lineTo(x0 + w, y0)
      ..moveTo(x0, y0 + height * 0.22)
      ..lineTo(x0 + w, y0 + height * 0.22)
      ..moveTo(x0, y0)
      ..lineTo(x0 + w * 0.3, y0)
      ..cubicTo(
        x0 + w * 0.92,
        y0,
        x0 + w * 0.92,
        y0 + height * 0.46,
        x0 + w * 0.3,
        y0 + height * 0.46,
      )
      ..lineTo(x0, y0 + height * 0.46)
      ..lineTo(x0 + w * 0.82, y0 + height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(HmLogoPainter oldDelegate) =>
      oldDelegate.variant != variant || oldDelegate.colors != colors;
}
