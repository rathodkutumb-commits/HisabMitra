import 'package:flutter/material.dart';

/// Colours of the HisabMitra mark (open chopda, ₹, family) for a palette.
@immutable
class LogoColors {
  const LogoColors({
    required this.tileStart,
    required this.tileEnd,
    required this.cover,
    required this.figures,
    required this.ink,
  });

  final Color tileStart;
  final Color tileEnd;
  final Color cover;
  final Color figures;

  /// Colour of the ₹ on the page.
  final Color ink;
}

/// One complete light colour set. All palettes are light (the app has no
/// dark mode — product decisions of 2026-11-18 and 2026-11-19, see TD-23).
@immutable
class PaletteSpec {
  const PaletteSpec({
    required this.background,
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.primary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.highlight,
    required this.heroStart,
    required this.heroEnd,
    required this.onHero,
    required this.expense,
    required this.logo,
    required this.chart,
  });

  final Color background;
  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color primary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color tertiary;
  final Color tertiaryContainer;
  final Color onTertiaryContainer;

  /// Decorative accent: Patola band, badges, selected markers.
  final Color highlight;
  final Color heroStart;
  final Color heroEnd;
  final Color onHero;

  /// Money out. Money in is always [moneyIn] (green) in every palette.
  final Color expense;
  final LogoColors logo;
  final List<Color> chart;

  static const moneyIn = Color(0xFF1E7A55);
}

/// User-selectable colour themes, each from a Gujarati craft or place.
/// Approved set of 2026-11-19 (TD-23). Saved values that are no longer in
/// this list (ajrakhNeel, sindoor, haldi) fall back to [defaultPalette].
enum AppPalette {
  /// Navy + silver + one red accent — the white salt desert of Kutch under a
  /// full moon. Default.
  rannUtsav,

  /// Sky blue + indigo — the Uttarayan kite sky.
  neelGagan,

  /// Maroon + kesar — Bandhani odhni and the red Diwali chopda.
  bandhaniLal,

  /// Saffron + plum — Navratri chaniya choli.
  kesariyo,

  /// Rani pink + turmeric + aubergine — Patan Patola silk.
  patolaRani;

  static const defaultPalette = AppPalette.rannUtsav;

  static AppPalette parse(String? raw) =>
      values.firstWhere((p) => p.name == raw, orElse: () => defaultPalette);

  PaletteSpec get spec => switch (this) {
    rannUtsav => _rannUtsav,
    neelGagan => _neelGagan,
    bandhaniLal => _bandhaniLal,
    kesariyo => _kesariyo,
    patolaRani => _patolaRani,
  };
}

const _rannUtsav = PaletteSpec(
  background: Color(0xFFF8F8F5),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF152033),
  onSurfaceVariant: Color(0xFF5D6778),
  outline: Color(0xFF7A8496),
  outlineVariant: Color(0xFFDFE3E8),
  primary: Color(0xFF1D3557),
  primaryContainer: Color(0xFFDCE6F2),
  onPrimaryContainer: Color(0xFF13294B),
  secondary: Color(0xFFC0392B),
  secondaryContainer: Color(0xFFF6DAD6),
  onSecondaryContainer: Color(0xFF5E1A12),
  // The one warm note besides the red: a deep moon-gold for group splits,
  // reminders and "partly paid" labels, readable on white.
  tertiary: Color(0xFF8A5A00),
  tertiaryContainer: Color(0xFFFBEACB),
  onTertiaryContainer: Color(0xFF4A3000),
  // Moonlight silver: decorative bands and accents on the navy hero card.
  highlight: Color(0xFFC9CDD4),
  heroStart: Color(0xFF1D3557),
  heroEnd: Color(0xFF0F1F36),
  onHero: Color(0xFFF3F6FB),
  expense: Color(0xFFC0392B),
  logo: LogoColors(
    tileStart: Color(0xFF2A4A75),
    tileEnd: Color(0xFF0F1F36),
    cover: Color(0xFFC0392B),
    figures: Color(0xFFDDE1E7),
    ink: Color(0xFF1D3557),
  ),
  chart: [
    Color(0xFF1D3557),
    Color(0xFFC0392B),
    Color(0xFFD9A520),
    Color(0xFF2F7FB5),
    Color(0xFF7A5BA6),
    Color(0xFFC2577E),
    Color(0xFF5C6B8A),
    Color(0xFFE07A5F),
  ],
);

const _bandhaniLal = PaletteSpec(
  background: Color(0xFFFBF4EA),
  surface: Color(0xFFFFFDF8),
  onSurface: Color(0xFF2A1A1E),
  onSurfaceVariant: Color(0xFF6A5256),
  outline: Color(0xFF8E7A7D),
  outlineVariant: Color(0xFFEAD9CE),
  primary: Color(0xFF8B1E3F),
  primaryContainer: Color(0xFFF4D7DF),
  onPrimaryContainer: Color(0xFF5E1129),
  secondary: Color(0xFFB5501F),
  secondaryContainer: Color(0xFFFCE3CC),
  onSecondaryContainer: Color(0xFF5A2508),
  tertiary: Color(0xFF8A6400),
  tertiaryContainer: Color(0xFFF8EBC7),
  onTertiaryContainer: Color(0xFF4A3500),
  highlight: Color(0xFFD4A017),
  heroStart: Color(0xFF8B1E3F),
  heroEnd: Color(0xFF55102A),
  onHero: Color(0xFFFFF6EE),
  expense: Color(0xFFB42318),
  logo: LogoColors(
    tileStart: Color(0xFF9E2A4C),
    tileEnd: Color(0xFF55102A),
    cover: Color(0xFFB5501F),
    figures: Color(0xFFD4A017),
    ink: Color(0xFF8B1E3F),
  ),
  chart: [
    Color(0xFF8B1E3F),
    Color(0xFFB5501F),
    Color(0xFFD4A017),
    Color(0xFF283A8C),
    Color(0xFF7A5BA6),
    Color(0xFFC2577E),
    Color(0xFF5C6B8A),
    Color(0xFFE07A5F),
  ],
);

const _kesariyo = PaletteSpec(
  background: Color(0xFFFFF5EA),
  surface: Color(0xFFFFFCF7),
  onSurface: Color(0xFF2A1B24),
  onSurfaceVariant: Color(0xFF6A5660),
  outline: Color(0xFF8E7A84),
  outlineVariant: Color(0xFFF0DCCB),
  primary: Color(0xFFC2410C),
  primaryContainer: Color(0xFFFFE0CC),
  onPrimaryContainer: Color(0xFF7A2A06),
  secondary: Color(0xFF6B2D5C),
  secondaryContainer: Color(0xFFF2DCEB),
  onSecondaryContainer: Color(0xFF3E1535),
  tertiary: Color(0xFF8A5E00),
  tertiaryContainer: Color(0xFFFBEBC4),
  onTertiaryContainer: Color(0xFF4A3200),
  highlight: Color(0xFFE3A21A),
  heroStart: Color(0xFFC2410C),
  heroEnd: Color(0xFF7A2A06),
  onHero: Color(0xFFFFF7EF),
  expense: Color(0xFF9F1D4A),
  logo: LogoColors(
    tileStart: Color(0xFFD0531C),
    tileEnd: Color(0xFF7A2A06),
    cover: Color(0xFF6B2D5C),
    figures: Color(0xFFFFD27A),
    ink: Color(0xFFC2410C),
  ),
  chart: [
    Color(0xFFC2410C),
    Color(0xFF6B2D5C),
    Color(0xFFE3A21A),
    Color(0xFF283A8C),
    Color(0xFF2F7FB5),
    Color(0xFFC2577E),
    Color(0xFF8A6B3A),
    Color(0xFF9F1D4A),
  ],
);

const _patolaRani = PaletteSpec(
  background: Color(0xFFFFF4F8),
  surface: Color(0xFFFFFCFD),
  onSurface: Color(0xFF2B1424),
  onSurfaceVariant: Color(0xFF6A5262),
  outline: Color(0xFF8E7686),
  outlineVariant: Color(0xFFF2D7E3),
  primary: Color(0xFFB0175F),
  primaryContainer: Color(0xFFFBD3E4),
  onPrimaryContainer: Color(0xFF7A0E41),
  secondary: Color(0xFF3A1D4A),
  secondaryContainer: Color(0xFFE8DDF0),
  onSecondaryContainer: Color(0xFF2A1236),
  tertiary: Color(0xFF8A6200),
  tertiaryContainer: Color(0xFFFBE7B8),
  onTertiaryContainer: Color(0xFF4A3400),
  highlight: Color(0xFFE0A800),
  heroStart: Color(0xFFB0175F),
  heroEnd: Color(0xFF6E0B3A),
  onHero: Color(0xFFFFF5FA),
  expense: Color(0xFFC2251E),
  logo: LogoColors(
    tileStart: Color(0xFFC0286E),
    tileEnd: Color(0xFF6E0B3A),
    cover: Color(0xFF3A1D4A),
    figures: Color(0xFFF2C230),
    ink: Color(0xFFB0175F),
  ),
  chart: [
    Color(0xFFB0175F),
    Color(0xFF3A1D4A),
    Color(0xFFE0A800),
    Color(0xFF2F7FB5),
    Color(0xFFB4401F),
    Color(0xFF7A5BA6),
    Color(0xFF5C6B8A),
    Color(0xFFC2577E),
  ],
);

const _neelGagan = PaletteSpec(
  background: Color(0xFFF2F6FC),
  surface: Color(0xFFFFFFFF),
  onSurface: Color(0xFF152238),
  onSurfaceVariant: Color(0xFF4F5C74),
  outline: Color(0xFF76839A),
  outlineVariant: Color(0xFFDCE4F0),
  primary: Color(0xFF2F6DB5),
  primaryContainer: Color(0xFFD8E6F8),
  onPrimaryContainer: Color(0xFF123A6E),
  secondary: Color(0xFF1B3A7A),
  secondaryContainer: Color(0xFFE2E3F5),
  onSecondaryContainer: Color(0xFF121F4A),
  tertiary: Color(0xFF8A6200),
  tertiaryContainer: Color(0xFFF8EBC6),
  onTertiaryContainer: Color(0xFF4A3400),
  highlight: Color(0xFFD9A520),
  heroStart: Color(0xFF2F6DB5),
  heroEnd: Color(0xFF1B3A7A),
  onHero: Color(0xFFF4F8FF),
  expense: Color(0xFFB23A3A),
  logo: LogoColors(
    tileStart: Color(0xFF3B7CC6),
    tileEnd: Color(0xFF1B3A7A),
    cover: Color(0xFF1B3A7A),
    figures: Color(0xFFF0C24A),
    ink: Color(0xFF2F6DB5),
  ),
  chart: [
    Color(0xFF2F6DB5),
    Color(0xFF1B3A7A),
    Color(0xFFD9A520),
    Color(0xFFB23A3A),
    Color(0xFF7A5BA6),
    Color(0xFFC2577E),
    Color(0xFF5C6B8A),
    Color(0xFFE07A5F),
  ],
);
