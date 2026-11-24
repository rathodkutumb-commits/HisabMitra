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
import '../../synchronization/application/sync_controller.dart';
import '../../synchronization/data/cloud_gateway.dart';
import '../../synchronization/data/personal_outbox.dart';
import '../../synchronization/domain/personal_entity.dart';

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
    PersonalOutbox? outbox,
    CloudGateway? cloud,
  }) : _baseDir = baseDir ?? getApplicationSupportDirectory,
       _outbox = outbox ?? PersonalOutbox(_db, _clock, _ids),
       _cloud = cloud ?? const NotConfiguredCloudGateway();

  final PersonalOutbox _outbox;
  final CloudGateway _cloud;

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

  /// Android may close the app while the camera is open (low memory). The
  /// picker then keeps the photo for the restarted app; this stages it.
  /// Returns null when there is nothing to recover or on any error.
  Future<StagedAttachment?> recoverLostPhoto() async {
    try {
      final lost = await ImagePicker().retrieveLostData();
      final file = lost.file;
      if (lost.isEmpty || file == null) return null;
      return await stage(File(file.path), originalName: file.name);
    } catch (e, s) {
      SafeLogger.error('attachment_recover', e, s);
      return null;
    }
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
    await _db.transaction(() async {
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
              familyEntryId: Value(
                parent == AttachmentParent.familyEntry ? parentId : null,
              ),
              storedName: storedName,
              originalName: staged.originalName,
              mimeType: staged.mimeType,
              sizeBytes: staged.sizeBytes,
              sha256: staged.sha256,
              createdAt: _clock.now(),
            ),
          );
      // Personal bills are saved to the account (the file is uploaded
      // first, see [uploadPendingFiles]); group and Family hisab bills go
      // to the group or Family hisab.
      if (parent == AttachmentParent.transaction ||
          parent == AttachmentParent.ledgerEntry) {
        await _outbox.upsert(PersonalEntity.attachment, id);
      }
    });
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
          AttachmentParent.familyEntry => t.familyEntryId.equals(parentId),
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
    // A Family hisab bill already in the account is deleted there first, so
    // it disappears for everyone (needs the internet).
    final remote = row.remotePath;
    if (row.familyEntryId != null && remote != null && remote.isNotEmpty) {
      await _cloud.deleteFamilyAttachment(row.id);
    }
    await _db.transaction(() async {
      if (row.groupExpenseId == null && row.familyEntryId == null) {
        await _outbox.delete(
          PersonalEntity.attachment,
          id,
          extra: {'storage_name': row.storedName},
        );
      }
      await (_db.delete(_db.attachments)..where((a) => a.id.equals(id))).go();
    });
    await deleteFiles([row.storedName]);
  }

  /// Uploads bill files not yet in the account, before their records are
  /// sent. A file that is gone or refused is marked `remotePath = ''` and
  /// never retried, so its record still syncs. Stops quietly when offline.
  Future<void> uploadPendingFiles() async {
    if (!_cloud.isConfigured || _cloud.currentSession == null) return;
    final rows = await (_db.select(
      _db.attachments,
    )..where((a) => a.remotePath.isNull())).get();
    for (final a in rows) {
      final file = await fileFor(a.storedName);
      try {
        if (a.familyEntryId != null) {
          final entry = await (_db.select(
            _db.familyEntriesCache,
          )..where((e) => e.id.equals(a.familyEntryId!))).getSingleOrNull();
          // The entry must be in the account first; retried next sync.
          if (entry == null || entry.revision == 0) continue;
          if (!file.existsSync()) {
            await _setRemote(a.id, '');
            continue;
          }
          final path = '${entry.familyId}/${entry.id}/${a.storedName}';
          await _cloud.uploadFamilyAttachment(
            storagePath: path,
            bytes: await file.readAsBytes(),
            mimeType: a.mimeType,
            metadata: {
              'id': a.id,
              'family_id': entry.familyId,
              'entry_id': entry.id,
              'storage_path': path,
              'mime_type': a.mimeType,
              'size_bytes': a.sizeBytes,
              'sha256': a.sha256,
            },
          );
          await _setRemote(a.id, path);
        } else if (a.groupExpenseId == null) {
          if (a.storedName.isEmpty || !file.existsSync()) {
            await _setRemote(a.id, '');
            continue;
          }
          await _cloud.uploadPersonalFile(
            storageName: a.storedName,
            bytes: await file.readAsBytes(),
            mimeType: a.mimeType,
          );
          await _setRemote(a.id, a.storedName);
        } else {
          final expense = await (_db.select(
            _db.groupExpensesCache,
          )..where((e) => e.id.equals(a.groupExpenseId!))).getSingleOrNull();
          if (expense == null) continue;
          final group = await (_db.select(
            _db.groupsCache,
          )..where((g) => g.id.equals(expense.groupId))).getSingleOrNull();
          // Phone-only (sample) groups keep their bills; an expense the
          // server doesn't have yet is retried on the next sync.
          if (group == null || !group.isShared || expense.revision == 0) {
            continue;
          }
          if (!file.existsSync()) {
            await _setRemote(a.id, '');
            continue;
          }
          final path = '${group.id}/${expense.id}/${a.storedName}';
          await _cloud.uploadGroupAttachment(
            storagePath: path,
            bytes: await file.readAsBytes(),
            mimeType: a.mimeType,
            metadata: {
              'id': a.id,
              'group_id': group.id,
              'expense_id': expense.id,
              'storage_path': path,
              'mime_type': a.mimeType,
              'size_bytes': a.sizeBytes,
              'sha256': a.sha256,
            },
          );
          await _setRemote(a.id, path);
        }
      } on NetworkFailure {
        return;
      } on AuthFailure {
        return;
      } on AppFailure catch (e, s) {
        SafeLogger.error('attachment_upload', e, s);
        await _setRemote(a.id, '');
      }
    }
  }

  Future<void> _setRemote(String id, String path) =>
      (_db.update(_db.attachments)..where((a) => a.id.equals(id))).write(
        AttachmentsCompanion(remotePath: Value(path)),
      );

  /// The bill's file on this phone, downloading it from the account first
  /// when needed. Null when it cannot be had (offline, gone).
  Future<File?> ensureLocal(AttachmentRow a) async {
    if (a.storedName.isNotEmpty) {
      final local = await fileFor(a.storedName);
      if (local.existsSync()) return local;
    }
    final remote = a.remotePath;
    if (remote == null || remote.isEmpty) return null;
    try {
      final bytes = a.familyEntryId != null
          ? await _cloud.downloadFamilyAttachment(remote)
          : a.groupExpenseId == null
          ? await _cloud.downloadPersonalFile(a.storedName)
          : await _cloud.downloadGroupAttachment(remote);
      var name = a.storedName;
      if (name.isEmpty) {
        // Bills shared by other members arrive without a local name.
        name = '${a.id}${p.extension(remote)}';
        await (_db.update(_db.attachments)..where((x) => x.id.equals(a.id)))
            .write(AttachmentsCompanion(storedName: Value(name)));
      }
      final file = await fileFor(name);
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e, s) {
      SafeLogger.error('attachment_download', e, s);
      return null;
    }
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
    outbox: ref.watch(personalOutboxProvider),
    cloud: ref.watch(cloudGatewayProvider),
  ),
);

/// A camera photo recovered after Android closed the app; added to the next
/// new form that has attachments, once.
class RecoveredPhoto extends Notifier<StagedAttachment?> {
  @override
  StagedAttachment? build() => null;

  void set(StagedAttachment photo) => state = photo;

  /// Returns the photo and forgets it.
  StagedAttachment? take() {
    final photo = state;
    state = null;
    return photo;
  }
}

final recoveredPhotoProvider =
    NotifierProvider<RecoveredPhoto, StagedAttachment?>(RecoveredPhoto.new);

final attachmentsForProvider =
    StreamProvider.family<List<AttachmentRow>, (AttachmentParent, String)>(
      (ref, args) =>
          ref.watch(attachmentServiceProvider).watchFor(args.$1, args.$2),
    );

final attachmentProvider = StreamProvider.family<AttachmentRow?, String>(
  (ref, id) => ref.watch(attachmentServiceProvider).watchById(id),
);
