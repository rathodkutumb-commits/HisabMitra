import 'package:flutter/material.dart';

import 'hm_colors.dart';
import 'palettes.dart';

/// Builds the app's [ThemeData]. HisabMitra is light-only: each
/// [AppPalette] is a complete light colour set (TD-23).
abstract final class AppTheme {
  static const _latin = 'Poppins';
  static const _gujarati = 'NotoSansGujarati';

  static ThemeData light({
    AppPalette palette = AppPalette.defaultPalette,
    String languageCode = 'en',
  }) {
    final s = palette.spec;
    return _build(_scheme(s), _hmColors(s), s.background, languageCode);
  }

  static ColorScheme _scheme(PaletteSpec s) {
    Color mix(Color a, Color b, double t) => Color.lerp(a, b, t)!;
    return ColorScheme(
      brightness: Brightness.light,
      primary: s.primary,
      onPrimary: Colors.white,
      primaryContainer: s.primaryContainer,
      onPrimaryContainer: s.onPrimaryContainer,
      secondary: s.secondary,
      onSecondary: Colors.white,
      secondaryContainer: s.secondaryContainer,
      onSecondaryContainer: s.onSecondaryContainer,
      tertiary: s.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: s.tertiaryContainer,
      onTertiaryContainer: s.onTertiaryContainer,
      error: const Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: const Color(0xFFF9DEDC),
      onErrorContainer: const Color(0xFF410E0B),
      surface: s.surface,
      onSurface: s.onSurface,
      onSurfaceVariant: s.onSurfaceVariant,
      surfaceContainerLowest: Colors.white,
      surfaceContainerLow: mix(s.surface, s.background, 0.5),
      surfaceContainer: s.background,
      surfaceContainerHigh: mix(s.background, s.outlineVariant, 0.45),
      surfaceContainerHighest: mix(s.background, s.outlineVariant, 0.8),
      outline: s.outline,
      outlineVariant: s.outlineVariant,
      inverseSurface: mix(s.onSurface, Colors.black, 0.1),
      onInverseSurface: s.background,
      inversePrimary: s.primaryContainer,
      shadow: Colors.black,
      scrim: Colors.black,
      surfaceTint: s.primary,
    );
  }

  static HmColors _hmColors(PaletteSpec s) => HmColors(
    income: PaletteSpec.moneyIn,
    expense: s.expense,
    receivable: PaletteSpec.moneyIn,
    payable: s.expense,
    highlight: s.highlight,
    accentInk: s.tertiary,
    pattern: s.secondary.withValues(alpha: 0.10),
    heroStart: s.heroStart,
    heroEnd: s.heroEnd,
    onHero: s.onHero,
    chartPalette: s.chart,
    logo: s.logo,
  );

  static ThemeData _build(
    ColorScheme scheme,
    HmColors hm,
    Color scaffold,
    String languageCode,
  ) {
    final isGujarati = languageCode == 'gu';
    final family = isGujarati ? _gujarati : _latin;
    final fallback = isGujarati ? const [_latin] : const [_gujarati];

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      fontFamily: family,
      fontFamilyFallback: fallback,
      scaffoldBackgroundColor: scaffold,
      extensions: [hm],
    );

    final text = base.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );

    final radius = BorderRadius.circular(16);

    return base.copyWith(
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffold,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.secondary,
        foregroundColor: scheme.onSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: scheme.outlineVariant),
        // Selection is shown by colour; a checkmark would cover chip icons.
        showCheckmark: false,
        selectedColor: scheme.primaryContainer,
        secondarySelectedColor: scheme.primaryContainer,
        labelStyle: text.labelLarge,
        secondaryLabelStyle: text.labelLarge?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.6),
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minVerticalPadding: 10,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primaryContainer
                : null,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
