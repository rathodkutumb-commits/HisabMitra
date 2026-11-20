import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sql;

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';

@immutable
class BackupInspection {
  const BackupInspection({
    required this.sourcePath,
    required this.stagingDir,
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.attachmentCount,
    required this.missingAttachments,
    required this.counts,
  });

  final String sourcePath;
  final Directory stagingDir;
  final int schemaVersion;
  final String appVersion;
  final DateTime createdAt;
  final int attachmentCount;

  /// Attachment rows whose file is not in the backup (reported, not fatal).
  final int missingAttachments;

  /// Record counts: transactions, persons, ledger, groups.
  final Map<String, int> counts;
}

@immutable
class RestoreResult {
  const RestoreResult({required this.counts, required this.safetyBackupPath});

  final Map<String, int> counts;
  final String? safetyBackupPath;
}

/// Local backup and restore (docs/BACKUP_RESTORE.md).
///
/// Format: a ZIP containing `manifest.json`, `database.sqlite` (a consistent
/// `VACUUM INTO` snapshot, which also carries app settings) and
/// `attachments/*`. The manifest lists the SHA-256 of every file.
///
/// Optional encryption wraps the whole ZIP:
/// `HMBK | v1 | iterations(u32 BE) | salt(16) | nonce(12) | ciphertext | mac(16)`
/// using AES-256-GCM with a PBKDF2-HMAC-SHA256 derived key. The password is
/// never stored.
class BackupService {
  BackupService({
    required this._db,
    required this._baseDir,
    required this._databasePath,
    required this._clock,
    required this._ids,
    required this._appVersion,
    this.kdfIterations = 210000,
  });

  final AppDatabase _db;
  final Future<Directory> Function() _baseDir;
  final Future<String> Function() _databasePath;
  final Clock _clock;
  final IdGenerator _ids;
  final String _appVersion;
  final int kdfIterations;

  static const _format = 'hisabmitra-backup';
  static const _formatVersion = 1;
  static const _magic = [0x48, 0x4D, 0x42, 0x4B]; // "HMBK"
  static const _zipMagic = [0x50, 0x4B, 0x03, 0x04]; // "PK\3\4"

  Future<Directory> backupsDir() async {
    final dir = Directory(p.join((await _baseDir()).path, 'backups'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<Directory> _attachmentsDir() async =>
      Directory(p.join((await _baseDir()).path, 'attachments'));

  Stream<List<BackupHistoryRow>> watchHistory() => (_db.select(
    _db.backupHistory,
  )..orderBy([(b) => OrderingTerm.desc(b.createdAt)])).watch();

  static String _sha(List<int> bytes) =>
      crypto.sha256.convert(bytes).toString();

  // ----------------------------------------------------------------- create

  Future<BackupHistoryRow> createBackup({
    BackupKind kind = BackupKind.manual,
    String? password,
  }) async {
    final dir = await backupsDir();
    final now = _clock.now();
    final id = _ids.newId();
    final tmp = File(p.join(dir.path, 'tmp_$id.sqlite'));
    try {
      await _db.snapshotTo(tmp.path);
      final dbBytes = await tmp.readAsBytes();
      final archive = Archive();
      final files = <Map<String, Object?>>[];
      void add(String name, Uint8List bytes) {
        archive.addFile(ArchiveFile.bytes(name, bytes));
        files.add({'path': name, 'size': bytes.length, 'sha256': _sha(bytes)});
      }

      add('database.sqlite', dbBytes);
      var attachmentCount = 0;
      final attachments = await _attachmentsDir();
      if (attachments.existsSync()) {
        for (final f in attachments.listSync().whereType<File>()) {
          add('attachments/${p.basename(f.path)}', await f.readAsBytes());
          attachmentCount++;
        }
      }
      final manifest = {
        'format': _format,
        'formatVersion': _formatVersion,
        'appVersion': _appVersion,
        'schemaVersion': AppDatabase.currentSchemaVersion,
        'createdAt': now.toUtc().toIso8601String(),
        'attachmentCount': attachmentCount,
        'files': files,
      };
      archive.addFile(
        ArchiveFile.bytes(
          'manifest.json',
          utf8.encode(const JsonEncoder.withIndent('  ').convert(manifest)),
        ),
      );
      var bytes = ZipEncoder().encodeBytes(archive);
      final encrypted = password != null && password.isNotEmpty;
      if (encrypted) bytes = await _encrypt(bytes, password);

      final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
      final suffix = switch (kind) {
        BackupKind.manual => '',
        BackupKind.automatic => '_auto',
        BackupKind.safety => '_safety',
      };
      final name = 'HisabMitra_$stamp$suffix.${encrypted ? 'hmbak' : 'zip'}';
      final out = File(p.join(dir.path, name));
      await out.writeAsBytes(bytes, flush: true);
      final row = BackupHistoryRow(
        id: id,
        fileName: name,
        filePath: out.path,
        sizeBytes: bytes.length,
        sha256: _sha(bytes),
        encrypted: encrypted,
        kind: kind,
        schemaVersion: AppDatabase.currentSchemaVersion,
        appVersion: _appVersion,
        createdAt: now,
      );
      await _db.into(_db.backupHistory).insert(row);
      return row;
    } on FileSystemException catch (e, s) {
      SafeLogger.error('backup_create', e, s);
      throw const BackupFailure('io');
    } finally {
      if (tmp.existsSync()) tmp.deleteSync();
    }
  }

  Future<Uint8List> _encrypt(Uint8List plain, String password) async {
    final random = Random.secure();
    final salt = Uint8List.fromList(
      List.generate(16, (_) => random.nextInt(256)),
    );
    final key = await _deriveKey(password, salt, kdfIterations);
    final aes = AesGcm.with256bits();
    final nonce = aes.newNonce();
    final box = await aes.encrypt(plain, secretKey: key, nonce: nonce);
    final header = BytesBuilder()
      ..add(_magic)
      ..addByte(1)
      ..add((ByteData(4)..setUint32(0, kdfIterations)).buffer.asUint8List())
      ..add(salt)
      ..add(nonce)
      ..add(box.cipherText)
      ..add(box.mac.bytes);
    return header.toBytes();
  }

  static Future<SecretKey> _deriveKey(
    String password,
    List<int> salt,
    int iterations,
  ) => Pbkdf2.hmacSha256(
    iterations: iterations,
    bits: 256,
  ).deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);

  Future<Uint8List> _decrypt(Uint8List data, String password) async {
    if (data.length < 4 + 1 + 4 + 16 + 12 + 16 || data[4] != 1) {
      throw const BackupFailure('not_backup');
    }
    final iterations = ByteData.sublistView(data, 5, 9).getUint32(0);
    if (iterations < 1000 || iterations > 10000000) {
      throw const BackupFailure('not_backup');
    }
    final salt = data.sublist(9, 25);
    final nonce = data.sublist(25, 37);
    final cipher = data.sublist(37, data.length - 16);
    final mac = Mac(data.sublist(data.length - 16));
    final key = await _deriveKey(password, salt, iterations);
    try {
      final plain = await AesGcm.with256bits().decrypt(
        SecretBox(cipher, nonce: nonce, mac: mac),
        secretKey: key,
      );
      return Uint8List.fromList(plain);
    } on SecretBoxAuthenticationError {
      throw const BackupFailure('wrong_password');
    }
  }

  static bool _startsWith(Uint8List data, List<int> prefix) {
    if (data.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (data[i] != prefix[i]) return false;
    }
    return true;
  }

  // ---------------------------------------------------------------- inspect

  /// Fully validates a backup and extracts it to a private staging folder.
  /// Nothing in the live data is touched.
  Future<BackupInspection> inspect(File file, {String? password}) async {
    Uint8List data;
    try {
      data = await file.readAsBytes();
    } on FileSystemException {
      throw const BackupFailure('io');
    }
    if (_startsWith(data, _magic)) {
      if (password == null || password.isEmpty) {
        throw const BackupFailure('password_required');
      }
      data = await _decrypt(data, password);
    }
    if (!_startsWith(data, _zipMagic)) throw const BackupFailure('not_backup');

    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(data, verify: true);
    } catch (_) {
      throw const BackupFailure('corrupt');
    }
    final manifestFile = archive.findFile('manifest.json');
    if (manifestFile == null) throw const BackupFailure('not_backup');
    Map<String, Object?> manifest;
    try {
      manifest =
          jsonDecode(utf8.decode(manifestFile.content)) as Map<String, Object?>;
    } catch (_) {
      throw const BackupFailure('not_backup');
    }
    if (manifest['format'] != _format) throw const BackupFailure('not_backup');
    final schema = manifest['schemaVersion'];
    if (schema is! int) throw const BackupFailure('not_backup');
    if (schema > AppDatabase.currentSchemaVersion) {
      throw const BackupFailure('newer_schema');
    }

    // Verify every listed file, and reject unsafe paths (zip-slip).
    final listed =
        (manifest['files'] as List?)?.cast<Map<String, Object?>>() ?? const [];
    final listedNames = <String>{};
    for (final entry in listed) {
      final name = entry['path'] as String? ?? '';
      if (!_safeName(name)) throw const BackupFailure('corrupt');
      final f = archive.findFile(name);
      if (f == null) throw const BackupFailure('corrupt');
      final bytes = f.content;
      if (bytes.length != entry['size'] || _sha(bytes) != entry['sha256']) {
        throw const BackupFailure('corrupt');
      }
      listedNames.add(name);
    }
    if (!listedNames.contains('database.sqlite')) {
      throw const BackupFailure('corrupt');
    }
    for (final f in archive.files) {
      if (f.isFile &&
          f.name != 'manifest.json' &&
          !listedNames.contains(f.name)) {
        throw const BackupFailure('corrupt');
      }
    }

    // Extract to staging.
    final dir = await backupsDir();
    for (final old in dir.listSync().whereType<Directory>().where(
      (d) => p.basename(d.path).startsWith('staging_'),
    )) {
      old.deleteSync(recursive: true);
    }
    final staging = Directory(p.join(dir.path, 'staging_${_ids.newId()}'))
      ..createSync();
    Directory(p.join(staging.path, 'attachments')).createSync();
    for (final name in listedNames) {
      final out = File(p.joinAll([staging.path, ...name.split('/')]));
      await out.writeAsBytes(archive.findFile(name)!.content, flush: true);
    }

    // Database integrity + contents (read-only; the file is not modified).
    final dbFile = p.join(staging.path, 'database.sqlite');
    final counts = <String, int>{};
    var attachmentRows = <String>[];
    try {
      final raw = sql.sqlite3.open(dbFile, mode: sql.OpenMode.readOnly);
      try {
        final check = raw.select('PRAGMA integrity_check');
        if (check.length != 1 || check.first.values.first != 'ok') {
          throw const BackupFailure('db_integrity');
        }
        int count(String query) => raw.select(query).first.values.first! as int;
        counts['transactions'] = count('SELECT COUNT(*) FROM transactions');
        counts['persons'] = count('SELECT COUNT(*) FROM persons');
        counts['ledger'] = count('SELECT COUNT(*) FROM money_ledger');
        counts['groups'] = count(
          'SELECT COUNT(*) FROM groups_cache WHERE deleted_at IS NULL',
        );
        attachmentRows = [
          for (final r in raw.select('SELECT stored_name FROM attachments'))
            r['stored_name'] as String,
        ];
      } finally {
        raw.close();
      }
    } on BackupFailure {
      staging.deleteSync(recursive: true);
      rethrow;
    } catch (e, s) {
      SafeLogger.error('backup_inspect_db', e, s);
      staging.deleteSync(recursive: true);
      throw const BackupFailure('db_integrity');
    }
    final missing = attachmentRows
        .where(
          (n) => !File(p.join(staging.path, 'attachments', n)).existsSync(),
        )
        .length;

    return BackupInspection(
      sourcePath: file.path,
      stagingDir: staging,
      schemaVersion: schema,
      appVersion: manifest['appVersion'] as String? ?? '',
      createdAt:
          DateTime.tryParse(manifest['createdAt'] as String? ?? '')
              ?.toLocal() ??
          _clock.now(),
      attachmentCount: listedNames
          .where((n) => n.startsWith('attachments/'))
          .length,
      missingAttachments: missing,
      counts: counts,
    );
  }

  static bool _safeName(String name) {
    if (name.isEmpty ||
        name.startsWith('/') ||
        name.contains('\\') ||
        name.contains(':')) {
      return false;
    }
    final parts = name.split('/');
    if (parts.any((s) => s.isEmpty || s == '.' || s == '..')) return false;
    if (name == 'database.sqlite') return true;
    return parts.length == 2 && parts.first == 'attachments';
  }

  Future<void> discardInspection(BackupInspection i) async {
    if (i.stagingDir.existsSync()) await i.stagingDir.delete(recursive: true);
  }

  // ---------------------------------------------------------------- restore

  /// Replaces the live data with an inspected backup.
  ///
  /// 1. A safety backup of the current data is written first.
  /// 2. [replaceDatabase] must close the live database, run the given
  ///    callback (which swaps the files) and reopen the database.
  /// 3. The swapped-in database is integrity-checked before the old files
  ///    are discarded; on any failure the previous files are put back.
  ///
  /// [prepareRestoredDatabase] runs on the restored database file before it
  /// is swapped in (e.g. queue it for upload to the account), so the change
  /// and the restore happen together.
  Future<RestoreResult> restore(
    BackupInspection inspection, {
    required Future<void> Function(Future<void> Function() whileClosed)
    replaceDatabase,
    Future<void> Function(String restoredDatabasePath)? prepareRestoredDatabase,
  }) async {
    final safety = await createBackup(kind: BackupKind.safety);
    if (prepareRestoredDatabase != null) {
      await prepareRestoredDatabase(
        p.join(inspection.stagingDir.path, 'database.sqlite'),
      );
    }
    final dbPath = await _databasePath();
    final attachments = await _attachmentsDir();
    final base = await _baseDir();

    await replaceDatabase(() async {
      final dbFile = File(dbPath);
      final dbBak = File('$dbPath.restore-bak');
      final attBak = Directory(p.join(base.path, 'attachments.restore-bak'));
      if (dbBak.existsSync()) dbBak.deleteSync();
      if (attBak.existsSync()) attBak.deleteSync(recursive: true);
      for (final suffix in ['-wal', '-shm', '-journal']) {
        final f = File('$dbPath$suffix');
        if (f.existsSync()) f.deleteSync();
      }
      if (dbFile.existsSync()) dbFile.renameSync(dbBak.path);
      if (attachments.existsSync()) attachments.renameSync(attBak.path);
      try {
        File(p.join(inspection.stagingDir.path, 'database.sqlite'))
            .copySync(dbPath);
        _copyDir(
          Directory(p.join(inspection.stagingDir.path, 'attachments')),
          attachments,
        );
        final raw = sql.sqlite3.open(dbPath);
        try {
          final check = raw.select('PRAGMA integrity_check');
          if (check.length != 1 || check.first.values.first != 'ok') {
            throw const BackupFailure('db_integrity');
          }
          // Keep the safety backup visible in the restored history.
          raw.execute(
            'INSERT OR REPLACE INTO backup_history (id, file_name, file_path, size_bytes, sha256, encrypted, kind, '
            'schema_version, app_version, created_at) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [
              safety.id,
              safety.fileName,
              safety.filePath,
              safety.sizeBytes,
              safety.sha256,
              safety.encrypted ? 1 : 0,
              safety.kind.name,
              safety.schemaVersion,
              safety.appVersion,
              safety.createdAt.millisecondsSinceEpoch ~/ 1000,
            ],
          );
        } finally {
          raw.close();
        }
      } catch (e, s) {
        SafeLogger.error('restore_swap', e, s);
        if (dbFile.existsSync()) dbFile.deleteSync();
        if (attachments.existsSync()) attachments.deleteSync(recursive: true);
        if (dbBak.existsSync()) dbBak.renameSync(dbPath);
        if (attBak.existsSync()) attBak.renameSync(attachments.path);
        throw e is BackupFailure ? e : const BackupFailure('io');
      }
      if (dbBak.existsSync()) dbBak.deleteSync();
      if (attBak.existsSync()) attBak.deleteSync(recursive: true);
    });
    await discardInspection(inspection);
    return RestoreResult(
      counts: inspection.counts,
      safetyBackupPath: safety.filePath,
    );
  }

  static void _copyDir(Directory from, Directory to) {
    to.createSync(recursive: true);
    if (!from.existsSync()) return;
    for (final f in from.listSync().whereType<File>()) {
      f.copySync(p.join(to.path, p.basename(f.path)));
    }
  }

  // ------------------------------------------------------------ housekeeping

  Future<void> deleteBackup(String id) async {
    final row = await (_db.select(
      _db.backupHistory,
    )..where((b) => b.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    final f = File(row.filePath);
    if (f.existsSync()) f.deleteSync();
    await (_db.delete(_db.backupHistory)..where((b) => b.id.equals(id))).go();
  }
}
