// Generates launcher icons, splash and logo PNGs from [HmLogoPainter].
//
// Run with:  flutter test tool/generate_brand_assets_test.dart
//
// It is a "test" only so that it can use the Flutter engine for rendering;
// it is not part of the regular test suite (`flutter test` only scans test/).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/widgets/hm_logo.dart';

Future<void> _render(
  String path,
  int px,
  HmLogoVariant variant, {
  Color? background,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final size = Size.square(px.toDouble());
  if (background != null) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
  }
  HmLogoPainter(variant: variant).paint(canvas, size);
  final image = await recorder.endRecording().toImage(px, px);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  final file = File(path)..createSync(recursive: true);
  file.writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  test('generate brand assets', () async {
    const res = 'android/app/src/main/res';
    const densities = {
      'mdpi': 1.0,
      'hdpi': 1.5,
      'xhdpi': 2.0,
      'xxhdpi': 3.0,
      'xxxhdpi': 4.0,
    };
    for (final entry in densities.entries) {
      final d = entry.value;
      await _render(
        '$res/mipmap-${entry.key}/ic_launcher.png',
        (48 * d).round(),
        HmLogoVariant.tile,
      );
      await _render(
        '$res/mipmap-${entry.key}/ic_launcher_round.png',
        (48 * d).round(),
        HmLogoVariant.tile,
      );
      await _render(
        '$res/mipmap-${entry.key}/ic_launcher_foreground.png',
        (108 * d).round(),
        HmLogoVariant.adaptiveForeground,
      );
      await _render(
        '$res/mipmap-${entry.key}/ic_launcher_monochrome.png',
        (108 * d).round(),
        HmLogoVariant.mono,
      );
      // Pre-Android-12 launch screen bitmap and Android 12+ splash icon.
      await _render(
        '$res/drawable-${entry.key}/splash_logo.png',
        (160 * d).round(),
        HmLogoVariant.tile,
      );
    }
    await _render('assets/images/logo_tile.png', 512, HmLogoVariant.tile);
    await _render('assets/images/logo_light.png', 512, HmLogoVariant.light);
    await _render('assets/images/logo_small.png', 96, HmLogoVariant.tile);
    await _render('docs/images/logo_preview.png', 512, HmLogoVariant.tile);
    await _render(
      'docs/images/logo_mono_preview.png',
      256,
      HmLogoVariant.mono,
      background: const Color(0xFF1D3557),
    );
  });
}
