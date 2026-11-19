import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/app/theme/app_theme.dart';
import 'package:hisabmitra/app/theme/hm_colors.dart';
import 'package:hisabmitra/app/theme/palettes.dart';

double _lum(Color c) {
  double ch(double v) =>
      v <= 0.03928 ? v / 12.92 : pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * ch(c.r) + 0.7152 * ch(c.g) + 0.0722 * ch(c.b);
}

double contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  return (max(la, lb) + 0.05) / (min(la, lb) + 0.05);
}

void main() {
  test('the approved five palettes, Rann Utsav first and default', () {
    expect(AppPalette.values, [
      AppPalette.rannUtsav,
      AppPalette.neelGagan,
      AppPalette.bandhaniLal,
      AppPalette.kesariyo,
      AppPalette.patolaRani,
    ]);
    expect(AppPalette.defaultPalette, AppPalette.rannUtsav);
    expect(AppPalette.parse('unknown'), AppPalette.rannUtsav);
    expect(AppPalette.parse(null), AppPalette.rannUtsav);
    expect(AppPalette.parse('kesariyo'), AppPalette.kesariyo);
  });

  test('palettes removed on 2026-11-19 fall back to Rann Utsav', () {
    for (final removed in ['ajrakhNeel', 'sindoor', 'haldi']) {
      expect(AppPalette.parse(removed), AppPalette.rannUtsav, reason: removed);
    }
  });

  test('Rann Utsav uses the approved navy, red and salt white', () {
    final s = AppPalette.rannUtsav.spec;
    expect(s.primary, const Color(0xFF1D3557));
    expect(s.secondary, const Color(0xFFC0392B));
    expect(s.background, const Color(0xFFF8F8F5));
    expect(s.highlight, const Color(0xFFC9CDD4));
    expect(s.heroStart, const Color(0xFF1D3557));
  });

  for (final palette in AppPalette.values) {
    group(palette.name, () {
      final theme = AppTheme.light(palette: palette);
      final scheme = theme.colorScheme;
      final hm = theme.extension<HmColors>()!;

      test(
        'is a light theme',
        () => expect(theme.brightness, Brightness.light),
      );

      test('meets WCAG AA contrast for buttons, containers and text', () {
        expect(
          contrast(scheme.primary, scheme.onPrimary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(scheme.secondary, scheme.onSecondary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(scheme.primaryContainer, scheme.onPrimaryContainer),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(theme.scaffoldBackgroundColor, scheme.onSurface),
          greaterThanOrEqualTo(7),
        );
        expect(
          contrast(scheme.surface, scheme.onSurfaceVariant),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          contrast(hm.heroStart, hm.onHero),
          greaterThanOrEqualTo(3),
          reason: 'large hero text',
        );
        expect(
          contrast(scheme.surface, hm.accentInk),
          greaterThanOrEqualTo(4.5),
          reason: 'status pills such as "partly paid"',
        );
      });

      test('money colours are readable; money in stays green', () {
        expect(contrast(scheme.surface, hm.income), greaterThanOrEqualTo(4.5));
        expect(contrast(scheme.surface, hm.expense), greaterThanOrEqualTo(4.5));
        expect(hm.income, const Color(0xFF1E7A55));
      });

      test('no green theme colour (only money-in is green)', () {
        for (final c in [
          scheme.primary,
          scheme.secondary,
          hm.heroStart,
          hm.heroEnd,
        ]) {
          final hsl = HSLColor.fromColor(c);
          final greenish =
              hsl.hue > 80 && hsl.hue < 170 && hsl.saturation > 0.25;
          expect(greenish, isFalse, reason: '$c is green');
        }
      });
    });
  }
}
