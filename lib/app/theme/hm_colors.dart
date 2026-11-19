import 'package:flutter/material.dart';

import 'palettes.dart';

/// Semantic colours that Material's [ColorScheme] does not cover.
@immutable
class HmColors extends ThemeExtension<HmColors> {
  const HmColors({
    required this.income,
    required this.expense,
    required this.receivable,
    required this.payable,
    required this.highlight,
    required this.accentInk,
    required this.pattern,
    required this.heroStart,
    required this.heroEnd,
    required this.onHero,
    required this.chartPalette,
    required this.logo,
  });

  final Color income;
  final Color expense;
  final Color receivable;
  final Color payable;

  /// Decorative accents (bands, dividers, selected markers, text on the
  /// hero card). Not guaranteed readable on light surfaces.
  final Color highlight;

  /// Accent for text and small icons on light surfaces, e.g. "partly paid"
  /// labels. Always meets WCAG AA (4.5:1) on the surface colour.
  final Color accentInk;

  /// Colour used by the decorative Bandhani / Patola painters (already
  /// carries low alpha).
  final Color pattern;

  /// Gradient for hero cards (dashboard balance card, splash).
  final Color heroStart;
  final Color heroEnd;
  final Color onHero;

  /// Categorical chart colours.
  final List<Color> chartPalette;

  /// Colours of the HisabMitra mark for the active palette.
  final LogoColors logo;

  static HmColors of(BuildContext context) =>
      Theme.of(context).extension<HmColors>()!;

  @override
  HmColors copyWith({
    Color? income,
    Color? expense,
    Color? receivable,
    Color? payable,
    Color? highlight,
    Color? accentInk,
    Color? pattern,
    Color? heroStart,
    Color? heroEnd,
    Color? onHero,
    List<Color>? chartPalette,
    LogoColors? logo,
  }) {
    return HmColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      receivable: receivable ?? this.receivable,
      payable: payable ?? this.payable,
      highlight: highlight ?? this.highlight,
      accentInk: accentInk ?? this.accentInk,
      pattern: pattern ?? this.pattern,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
      onHero: onHero ?? this.onHero,
      chartPalette: chartPalette ?? this.chartPalette,
      logo: logo ?? this.logo,
    );
  }

  @override
  HmColors lerp(covariant HmColors? other, double t) {
    if (other == null) return this;
    return HmColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      receivable: Color.lerp(receivable, other.receivable, t)!,
      payable: Color.lerp(payable, other.payable, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      pattern: Color.lerp(pattern, other.pattern, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
      onHero: Color.lerp(onHero, other.onHero, t)!,
      chartPalette: t < 0.5 ? chartPalette : other.chartPalette,
      logo: t < 0.5 ? logo : other.logo,
    );
  }
}
