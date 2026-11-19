import 'package:flutter/material.dart';

import '../../../app/theme/palettes.dart';
import '../../../core/l10n/l10n_x.dart';

String paletteName(AppLocalizations l, AppPalette p) => switch (p) {
  AppPalette.rannUtsav => l.paletteRannUtsav,
  AppPalette.neelGagan => l.paletteNeelGagan,
  AppPalette.bandhaniLal => l.paletteBandhaniLal,
  AppPalette.kesariyo => l.paletteKesariyo,
  AppPalette.patolaRani => l.palettePatolaRani,
};

String paletteDescription(AppLocalizations l, AppPalette p) => switch (p) {
  AppPalette.rannUtsav => l.paletteRannUtsavDesc,
  AppPalette.neelGagan => l.paletteNeelGaganDesc,
  AppPalette.bandhaniLal => l.paletteBandhaniLalDesc,
  AppPalette.kesariyo => l.paletteKesariyoDesc,
  AppPalette.patolaRani => l.palettePatolaRaniDesc,
};

/// Bottom sheet listing every palette with a colour preview.
Future<AppPalette?> showPalettePicker(
  BuildContext context,
  AppPalette current,
) {
  return showModalBottomSheet<AppPalette>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final l = ctx.l10n;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
          ),
          child: RadioGroup<AppPalette>(
            groupValue: current,
            onChanged: (v) => Navigator.pop(ctx, v),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    l.settingsTheme,
                    style: Theme.of(ctx).textTheme.titleMedium,
                  ),
                ),
                for (final p in AppPalette.values)
                  RadioListTile<AppPalette>(
                    value: p,
                    controlAffinity: ListTileControlAffinity.trailing,
                    secondary: PaletteSwatch(palette: p),
                    title: Text(paletteName(l, p)),
                    subtitle: Text(paletteDescription(l, p)),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Small preview: hero gradient tile with secondary and accent dots.
class PaletteSwatch extends StatelessWidget {
  const PaletteSwatch({super.key, required this.palette, this.size = 44});

  final AppPalette palette;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = palette.spec;
    Widget dot(Color c) => Container(
      width: size * 0.3,
      height: size * 0.3,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.08),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.25),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [s.heroStart, s.heroEnd],
          ),
          border: Border.all(color: s.outlineVariant),
        ),
        alignment: Alignment.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [dot(s.secondary), dot(s.highlight)],
        ),
      ),
    );
  }
}
