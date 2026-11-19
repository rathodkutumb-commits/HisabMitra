import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../../../core/security/safe_logger.dart';

/// A picked file copied into private staging storage, not yet linked.
@immutable
class StagedAttachment {
  const StagedAttachment({
    required this.path,
    required this.originalName,
    required this.mimeType,
    required this.sizeBytes,
    required this.sha256,
  });

  final String path;
  final String originalName;
  final String mimeType;
  final int sizeBytes;
  final String sha256;

  bool get isImage => mimeType.startsWith('image/');
}

/// Stores bills/receipts in app-private storage (`<support>/attachments`).
/// Nothing here uploads anything; cloud sharing of group attachments is a
/// separate, explicit action.
class AttachmentService {
  AttachmentService(
    this._db,
    this._clock,
    this._ids, {
    Future<Directory> Function()? baseDir,
  }) : _baseDir = baseDir ?? getApplicationSupportDirectory;

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final Future<Directory> Function() _baseDir;

  static const maxBytes = 10 * 1024 * 1024;
  static const _types = {
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.png': 'image/png',
    '.webp': 'image/webp',
    '.heic': 'image/heic',
    '.pdf': 'application/pdf',
  };

  Future<Directory> attachmentsDir() async {
    final dir = Directory(p.join((await _baseDir()).path, 'attachments'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<Directory> _stagingDir() async {
    final dir = Directory(p.join((await attachmentsDir()).path, 'staging'));
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  Future<File> fileFor(String storedName) async =>
      File(p.join((await attachmentsDir()).path, storedName));

  /// Validates and copies [source] into staging.
  Future<StagedAttachment> stage(File source, {String? originalName}) async {
    final name = originalName ?? p.basename(source.path);
    final ext = p.extension(name).toLowerCase();
    final mime = _types[ext];
    if (mime == null) throw const AttachmentFailure('type');
    if (!source.existsSync()) throw const NotFoundFailure();
    final size = source.lengthSync();
    if (size > maxBytes) throw const AttachmentFailure('too_large');
    if (size == 0) throw const AttachmentFailure('type');
    try {
      final staging = await _stagingDir();
      final target = File(p.join(staging.path, '${_ids.newId()}$ext'));
      await source.copy(target.path);
      final digest = sha256.convert(await target.readAsBytes()).toString();
      return StagedAttachment(
        path: target.path,
        originalName: name,
        mimeType: mime,
        sizeBytes: size,
        sha256: digest,
      );
    } on FileSystemException catch (e, s) {
      SafeLogger.error('attachment_stage', e, s);
      throw const StorageFailure();
    }
  }

  Future<StagedAttachment?> pickImage({required bool camera}) async {
    final picked = await ImagePicker().pickImage(
      source: camera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2400,
    );
    if (picked == null) return null;
    final staged = await stage(File(picked.path), originalName: picked.name);
    if (camera) {
      // Camera captures land in the app cache; remove the original copy.
      try {
        await File(picked.path).delete();
      } on FileSystemException {
        // Best effort only.
      }
    }
    return staged;
  }

  Future<StagedAttachment?> pickPdf() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    final path = picked?.path;
    if (path == null) return null;
    return stage(File(path), originalName: picked!.name);
  }

  /// Moves a staged file into permanent storage and links it to a parent.
  Future<String> commit(
    StagedAttachment staged, {
    required AttachmentParent parent,
    required String parentId,
  }) async {
    final id = _ids.newId();
    final ext = p.extension(staged.path);
    final storedName = '$id$ext';
    final target = await fileFor(storedName);
    try {
      await File(staged.path).rename(target.path);
    } on FileSystemException {
      await File(staged.path).copy(target.path);
      await File(staged.path).delete();
    }
    await _db
        .into(_db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: id,
            transactionId: Value(
              parent == AttachmentParent.transaction ? parentId : null,
            ),
            ledgerEntryId: Value(
              parent == AttachmentParent.ledgerEntry ? parentId : null,
            ),
            groupExpenseId: Value(
              parent == AttachmentParent.groupExpense ? parentId : null,
            ),
            storedName: storedName,
            originalName: staged.originalName,
            mimeType: staged.mimeType,
            sizeBytes: staged.sizeBytes,
            sha256: staged.sha256,
            createdAt: _clock.now(),
          ),
        );
    return id;
  }

  Future<void> discard(StagedAttachment staged) async {
    final f = File(staged.path);
    if (f.existsSync()) await f.delete();
  }

  Stream<List<AttachmentRow>> watchFor(
    AttachmentParent parent,
    String parentId,
  ) {
    final a = _db.attachments;
    final q = _db.select(a)
      ..where(
        (t) => switch (parent) {
          AttachmentParent.transaction => t.transactionId.equals(parentId),
          AttachmentParent.ledgerEntry => t.ledgerEntryId.equals(parentId),
          AttachmentParent.groupExpense => t.groupExpenseId.equals(parentId),
        },
      )
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return q.watch();
  }

  Stream<AttachmentRow?> watchById(String id) => (_db.select(
    _db.attachments,
  )..where((a) => a.id.equals(id))).watchSingleOrNull();

  Future<void> delete(String id) async {
    final row = await (_db.select(
      _db.attachments,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    if (row == null) return;
    await (_db.delete(_db.attachments)..where((a) => a.id.equals(id))).go();
    await deleteFiles([row.storedName]);
  }

  /// Removes files whose DB rows were already deleted (e.g. by cascade).
  Future<void> deleteFiles(List<String> storedNames) async {
    for (final name in storedNames) {
      final f = await fileFor(name);
      try {
        if (f.existsSync()) await f.delete();
      } on FileSystemException catch (e, s) {
        SafeLogger.error('attachment_delete', e, s);
      }
    }
  }

  /// Clears abandoned staging files (e.g. after a form was dismissed).
  Future<void> cleanStaging() async {
    final dir = await _stagingDir();
    for (final f in dir.listSync().whereType<File>()) {
      try {
        f.deleteSync();
      } on FileSystemException {
        // ignore
      }
    }
  }
}

final attachmentServiceProvider = Provider<AttachmentService>(
  (ref) => AttachmentService(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final attachmentsForProvider =
    StreamProvider.family<List<AttachmentRow>, (AttachmentParent, String)>(
      (ref, args) =>
          ref.watch(attachmentServiceProvider).watchFor(args.$1, args.$2),
    );

final attachmentProvider = StreamProvider.family<AttachmentRow?, String>(
  (ref, id) => ref.watch(attachmentServiceProvider).watchById(id),
);
