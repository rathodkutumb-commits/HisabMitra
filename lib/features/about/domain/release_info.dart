import 'package:flutter/foundation.dart';

@immutable
class AppVersion implements Comparable<AppVersion> {
  const AppVersion(this.major, this.minor, this.patch, this.build);

  final int major;
  final int minor;
  final int patch;
  final int build;

  static final _pattern = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:\+(\d+))?$');

  static AppVersion? tryParse(String raw) {
    final m = _pattern.firstMatch(raw.trim());
    if (m == null) return null;
    return AppVersion(
      int.parse(m.group(1)!),
      int.parse(m.group(2)!),
      int.parse(m.group(3)!),
      int.parse(m.group(4) ?? '0'),
    );
  }

  @override
  int compareTo(AppVersion o) {
    for (final (a, b) in [
      (major, o.major),
      (minor, o.minor),
      (patch, o.patch),
      (build, o.build),
    ]) {
      if (a != b) return a.compareTo(b);
    }
    return 0;
  }

  bool operator >(AppVersion o) => compareTo(o) > 0;

  @override
  bool operator ==(Object other) =>
      other is AppVersion && compareTo(other) == 0;

  @override
  int get hashCode => Object.hash(major, minor, patch, build);

  @override
  String toString() => '$major.$minor.$patch${build == 0 ? '' : '+$build'}';
}

/// A published GitHub release that carries an APK.
@immutable
class ReleaseInfo {
  const ReleaseInfo({
    required this.version,
    required this.name,
    required this.notes,
    required this.pageUrl,
    required this.apkUrl,
    required this.apkName,
    required this.apkSize,
    required this.checksumUrl,
    required this.publishedAt,
  });

  final AppVersion version;
  final String name;
  final String notes;
  final String pageUrl;
  final String apkUrl;
  final String apkName;
  final int apkSize;

  /// URL of a `<apk>.sha256` (or SHA256SUMS) asset; null when not published.
  final String? checksumUrl;
  final DateTime? publishedAt;

  /// Parses `GET /repos/{owner}/{repo}/releases/latest`.
  static ReleaseInfo? fromGitHub(Map<String, Object?> j) {
    if (j['draft'] == true || j['prerelease'] == true) return null;
    final version = AppVersion.tryParse(j['tag_name'] as String? ?? '');
    if (version == null) return null;
    final assets = ((j['assets'] as List?) ?? const [])
        .cast<Map<String, Object?>>();
    final apk = assets
        .where(
          (a) => (a['name'] as String? ?? '').toLowerCase().endsWith('.apk'),
        )
        .firstOrNull;
    if (apk == null) return null;
    final apkName = apk['name']! as String;
    final checksum = assets.where((a) {
      final n = (a['name'] as String? ?? '').toLowerCase();
      return n == '${apkName.toLowerCase()}.sha256' ||
          n == 'sha256sums.txt' ||
          n == 'sha256sums';
    }).firstOrNull;
    return ReleaseInfo(
      version: version,
      name: j['name'] as String? ?? version.toString(),
      notes: j['body'] as String? ?? '',
      pageUrl: j['html_url'] as String? ?? '',
      apkUrl: apk['browser_download_url']! as String,
      apkName: apkName,
      apkSize: (apk['size'] as num?)?.toInt() ?? 0,
      checksumUrl: checksum?['browser_download_url'] as String?,
      publishedAt: DateTime.tryParse(j['published_at'] as String? ?? ''),
    );
  }
}

/// Extracts the SHA-256 for [fileName] from `sha256sum` output or a bare
/// hash file. Returns a lowercase hex digest or null.
String? parseSha256(String content, String fileName) {
  final hex = RegExp(r'^[0-9a-fA-F]{64}$');
  final lines = content
      .split(RegExp(r'\r?\n'))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  if (lines.length == 1 && hex.hasMatch(lines.single)) {
    return lines.single.toLowerCase();
  }
  for (final line in lines) {
    final parts = line.split(RegExp(r'\s+'));
    if (parts.length < 2 || !hex.hasMatch(parts.first)) continue;
    final name = parts.sublist(1).join(' ').replaceFirst(RegExp(r'^\*'), '');
    if (name == fileName) return parts.first.toLowerCase();
  }
  return null;
}
