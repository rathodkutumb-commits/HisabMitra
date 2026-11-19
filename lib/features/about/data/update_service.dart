import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/config/app_config.dart';
import '../../../core/errors/app_failure.dart';
import '../../backup/application/backup_providers.dart';
import '../domain/release_info.dart';

enum UpdateCheck { notConfigured, upToDate, available }

/// Why a downloaded APK was not handed to the installer.
enum UpdateRejection {
  noChecksum,
  checksumMismatch,
  wrongPackage,
  notNewer,
  signatureMismatch,
  unreadable,
}

class UpdateRejectedFailure implements Exception {
  const UpdateRejectedFailure(this.reason);
  final UpdateRejection reason;
}

/// Checks GitHub Releases and installs verified updates through Android's
/// package installer. Nothing is installed silently: Android always asks
/// the user to confirm.
class UpdateService {
  UpdateService({required this.currentVersion, http.Client? client})
    : _client = client ?? http.Client();

  final String currentVersion;
  final http.Client _client;
  static const _channel = MethodChannel('hisabmitra/installer');
  static const _packageName = 'com.hisabmitra.app';

  Uri get _latestUri => Uri.parse(
    'https://api.github.com/repos/${AppConfig.githubOwner}/${AppConfig.githubRepo}/releases/latest',
  );

  Future<(UpdateCheck, ReleaseInfo?)> check() async {
    if (!AppConfig.isUpdateCheckConfigured) {
      return (UpdateCheck.notConfigured, null);
    }
    http.Response res;
    try {
      res = await _client
          .get(
            _latestUri,
            headers: {
              'Accept': 'application/vnd.github+json',
              'User-Agent': 'HisabMitra-App',
            },
          )
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw const NetworkFailure();
    } on TimeoutException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }
    if (res.statusCode == 404) return (UpdateCheck.upToDate, null);
    if (res.statusCode != 200) throw const NetworkFailure();
    final release = ReleaseInfo.fromGitHub(
      (jsonDecode(res.body) as Map).cast<String, Object?>(),
    );
    final current = AppVersion.tryParse(currentVersion);
    if (release == null || current == null || !(release.version > current)) {
      return (UpdateCheck.upToDate, release);
    }
    return (UpdateCheck.available, release);
  }

  /// Downloads the APK into the private update cache, verifies its SHA-256
  /// against the published checksum, its package name, version and signing
  /// certificate, and returns the verified file.
  Future<File> downloadAndVerify(
    ReleaseInfo r, {
    void Function(double progress)? onProgress,
  }) async {
    if (r.checksumUrl == null) {
      throw const UpdateRejectedFailure(UpdateRejection.noChecksum);
    }
    final sumRes = await _client
        .get(Uri.parse(r.checksumUrl!))
        .timeout(const Duration(seconds: 20));
    final expected = sumRes.statusCode == 200
        ? parseSha256(sumRes.body, r.apkName)
        : null;
    if (expected == null) {
      throw const UpdateRejectedFailure(UpdateRejection.noChecksum);
    }

    final dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'updates'),
    );
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);
    final file = File(p.join(dir.path, 'hisabmitra-update.apk'));
    final sink = file.openWrite();
    final digestSink = _DigestSink();
    final hasher = sha256.startChunkedConversion(digestSink);
    try {
      final res = await _client.send(http.Request('GET', Uri.parse(r.apkUrl)));
      if (res.statusCode != 200) throw const NetworkFailure();
      final total = res.contentLength ?? r.apkSize;
      var received = 0;
      await for (final chunk in res.stream) {
        sink.add(chunk);
        hasher.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
    } on SocketException {
      throw const NetworkFailure();
    } finally {
      await sink.close();
      hasher.close();
    }
    if (digestSink.value.toString() != expected) {
      file.deleteSync();
      throw const UpdateRejectedFailure(UpdateRejection.checksumMismatch);
    }
    await _verifyPackage(file, r);
    return file;
  }

  Future<void> _verifyPackage(File apk, ReleaseInfo r) async {
    final info = await _channel.invokeMapMethod<String, Object?>('inspectApk', {
      'path': apk.path,
    });
    final self = await _channel.invokeMapMethod<String, Object?>('selfInfo');
    if (info == null || self == null) {
      throw const UpdateRejectedFailure(UpdateRejection.unreadable);
    }
    if (info['packageName'] != _packageName) {
      throw const UpdateRejectedFailure(UpdateRejection.wrongPackage);
    }
    if (((info['versionCode'] as num?) ?? 0) <=
        ((self['versionCode'] as num?) ?? 0)) {
      throw const UpdateRejectedFailure(UpdateRejection.notNewer);
    }
    final newSigners = ((info['signers'] as List?) ?? const [])
        .cast<String>()
        .toSet();
    final ourSigners = ((self['signers'] as List?) ?? const [])
        .cast<String>()
        .toSet();
    if (newSigners.isEmpty || !newSigners.containsAll(ourSigners)) {
      throw const UpdateRejectedFailure(UpdateRejection.signatureMismatch);
    }
  }

  Future<bool> canInstall() async =>
      await _channel.invokeMethod<bool>('canInstall') ?? false;

  Future<void> openInstallPermissionSettings() =>
      _channel.invokeMethod<void>('openInstallSettings');

  /// Opens Android's installer for the verified file; the user confirms.
  Future<void> install(File apk) =>
      _channel.invokeMethod<void>('installApk', {'path': apk.path});
}

class _DigestSink implements Sink<Digest> {
  late Digest value;

  @override
  void add(Digest data) => value = data;

  @override
  void close() {}
}

final updateServiceProvider = Provider<UpdateService>(
  (ref) => UpdateService(currentVersion: ref.watch(appVersionProvider)),
);
