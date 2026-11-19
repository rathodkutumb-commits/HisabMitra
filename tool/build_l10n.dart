// Merges per-feature string fragments into the ARB files used by
// `flutter gen-l10n`, and fails if English and Gujarati drift apart.
//
//   l10n/en/*.json  ─┐
//                    ├─► lib/l10n/app_en.arb, lib/l10n/app_gu.arb
//   l10n/gu/*.json  ─┘
//
// Usage: dart run tool/build_l10n.dart && flutter gen-l10n
//
// English fragments may contain "@key" metadata (placeholders). Gujarati
// fragments contain translations only.
import 'dart:convert';
import 'dart:io';

Map<String, Object?> _readDir(String locale) {
  final dir = Directory('l10n/$locale');
  final files =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  final merged = <String, Object?>{};
  for (final file in files) {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, Object?>;
    for (final entry in data.entries) {
      if (merged.containsKey(entry.key)) {
        stderr.writeln('Duplicate key "${entry.key}" in ${file.path}');
        exit(1);
      }
      merged[entry.key] = entry.value;
    }
  }
  return merged;
}

Set<String> _placeholders(String text) =>
    // Only real placeholders: `{name}` or `{name,` (ICU plural/select).
    RegExp(r'\{(\w+)[},]').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  final en = _readDir('en');
  final gu = _readDir('gu');
  final enKeys = en.keys.where((k) => !k.startsWith('@')).toSet();
  final guKeys = gu.keys.where((k) => !k.startsWith('@')).toSet();

  final errors = <String>[];
  for (final k in enKeys.difference(guKeys)) {
    errors.add('Missing Gujarati translation: $k');
  }
  for (final k in guKeys.difference(enKeys)) {
    errors.add('Gujarati key not in English: $k');
  }
  for (final k in enKeys.intersection(guKeys)) {
    final a = _placeholders(en[k]! as String);
    final b = _placeholders(gu[k]! as String);
    if (!a.containsAll(b)) {
      errors.add('Placeholder mismatch for $k: en=$a gu=$b');
    }
  }
  if (errors.isNotEmpty) {
    errors.forEach(stderr.writeln);
    exit(1);
  }

  const encoder = JsonEncoder.withIndent('  ');
  File('lib/l10n/app_en.arb')
      .writeAsStringSync('${encoder.convert({'@@locale': 'en', ...en})}\n');
  File('lib/l10n/app_gu.arb')
      .writeAsStringSync('${encoder.convert({'@@locale': 'gu', ...gu})}\n');
  stdout.writeln('Wrote ${enKeys.length} strings for en and gu.');
}
