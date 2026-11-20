import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Personal records are saved to the user's account (Part B): no visible
/// text may still promise that they never leave the phone.
void main() {
  Map<String, String> texts(String lang) {
    final arb = jsonDecode(
      File('lib/l10n/app_$lang.arb').readAsStringSync(),
    ) as Map<String, Object?>;
    return {
      for (final e in arb.entries)
        if (!e.key.startsWith('@') && e.value is String)
          e.key: e.value! as String,
    };
  }

  test('no English text promises phone-only storage', () {
    const phrases = [
      'never leave',
      'stays on your phone',
      'stay on this phone',
      'stored only on this phone',
      'Not uploaded anywhere',
      'Local data is kept',
      'Everything on this phone is kept',
      'on your phone —',
      'stored on this device',
      'safe on this device',
    ];
    final bad = [
      for (final e in texts('en').entries)
        for (final p in phrases)
          if (e.value.toLowerCase().contains(p.toLowerCase())) '${e.key}: $p',
    ];
    expect(bad, isEmpty);
  });

  test('no Gujarati text promises phone-only storage', () {
    const phrases = [
      'ફક્ત આ ફોનમાં જ',
      'નોંધો આ ફોનમાં જ રહેશે',
      'ડેટા ફોનમાં જ રહેશે',
      'તમારા ફોનમાં જ રાખે',
      'ક્યાંય અપલોડ થયું નથી',
      'આ ફોનમાં સંગ્રહિત',
      'ફોન છોડતી નથી',
    ];
    final bad = [
      for (final e in texts('gu').entries)
        for (final p in phrases)
          if (e.value.contains(p)) '${e.key}: $p',
    ];
    expect(bad, isEmpty);
  });
}
