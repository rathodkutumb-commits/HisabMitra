import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Bandhani (tie-dye) inspired dot motif: small rings of dots on a diagonal
/// lattice. Meant to be drawn at very low alpha behind content.
class BandhaniPatternPainter extends CustomPainter {
  const BandhaniPatternPainter({required this.color, this.spacing = 28});

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final dot = spacing * 0.055;
    final ring = spacing * 0.17;
    var row = 0;
    for (var y = spacing / 2; y < size.height + spacing; y += spacing * 0.86) {
      final offset = row.isOdd ? spacing / 2 : 0.0;
      for (var x = offset; x < size.width + spacing; x += spacing) {
        canvas.drawCircle(Offset(x, y), dot * 1.1, paint);
        for (var i = 0; i < 6; i++) {
          final a = i * math.pi / 3;
          canvas.drawCircle(
            Offset(x + ring * math.cos(a), y + ring * math.sin(a)),
            dot * 0.75,
            paint,
          );
        }
      }
      row++;
    }
  }

  @override
  bool shouldRepaint(BandhaniPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}

/// Patola inspired band: a row of nested lozenges (diamonds) with dots.
/// Used as a thin decorative divider under section headers and hero cards.
class PatolaBandPainter extends CustomPainter {
  const PatolaBandPainter({required this.primary, required this.accent});

  final Color primary;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final w = h * 1.4;
    final outer = Paint()..color = primary;
    final inner = Paint()..color = accent;
    final count = (size.width / w).ceil() + 1;
    for (var i = 0; i < count; i++) {
      final cx = i * w + w / 2;
      final cy = h / 2;
      final big = Path()
        ..moveTo(cx, 0)
        ..lineTo(cx + w / 2, cy)
        ..lineTo(cx, h)
        ..lineTo(cx - w / 2, cy)
        ..close();
      canvas.drawPath(big, outer);
      final small = Path()
        ..moveTo(cx, h * 0.25)
        ..lineTo(cx + w * 0.22, cy)
        ..lineTo(cx, h * 0.75)
        ..lineTo(cx - w * 0.22, cy)
        ..close();
      canvas.drawPath(small, inner);
      canvas.drawCircle(Offset(cx, cy), h * 0.07, outer);
    }
  }

  @override
  bool shouldRepaint(PatolaBandPainter oldDelegate) =>
      oldDelegate.primary != primary || oldDelegate.accent != accent;
}

/// Toran (festive door garland): a string with alternating leaf flags.
class ToranPainter extends CustomPainter {
  const ToranPainter({
    required this.leaf,
    required this.flower,
    required this.string,
  });

  final Color leaf;
  final Color flower;
  final Color string;

  @override
  void paint(Canvas canvas, Size size) {
    final stringPaint = Paint()
      ..color = string
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final top = size.height * 0.12;
    canvas.drawLine(Offset(0, top), Offset(size.width, top), stringPaint);

    const step = 26.0;
    final leafPaint = Paint()..color = leaf;
    final flowerPaint = Paint()..color = flower;
    var i = 0;
    for (var x = step / 2; x < size.width; x += step) {
      final leafHeight = size.height * (i.isEven ? 0.85 : 0.6);
      final path = Path()
        ..moveTo(x - step * 0.32, top)
        ..quadraticBezierTo(
          x - step * 0.3,
          top + leafHeight * 0.6,
          x,
          top + leafHeight,
        )
        ..quadraticBezierTo(
          x + step * 0.3,
          top + leafHeight * 0.6,
          x + step * 0.32,
          top,
        )
        ..close();
      canvas.drawPath(path, i.isEven ? leafPaint : flowerPaint);
      canvas.drawCircle(Offset(x, top), 3, flowerPaint);
      i++;
    }
  }

  @override
  bool shouldRepaint(ToranPainter oldDelegate) =>
      oldDelegate.leaf != leaf ||
      oldDelegate.flower != flower ||
      oldDelegate.string != string;
}
