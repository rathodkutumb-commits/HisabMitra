import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/backup/data/backup_service.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late String dbPath;
  late AppDatabase db;

  AppDatabase open() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    return AppDatabase(NativeDatabase(File(dbPath)));
  }

  BackupService service() => BackupService(
    db: db,
    baseDir: () async => root,
    databasePath: () async => dbPath,
    clock: const Clock(),
    ids: const IdGenerator(),
    appVersion: '1.0.0+1',
    kdfIterations: 1000,
  );

  Future<void> addTxn(String id, int paise) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          id: id,
          ownerId: 'self',
          type: TransactionType.expense,
          amountPaise: paise,
          categoryId: 'cat_food',
          txnDate: DateTime(2026, 1, 1),
          paymentMethod: PaymentMethod.cash,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );

  setUp(() async {
    root = Directory.systemTemp.createTempSync('hm_backup_');
    dbPath = p.join(root.path, 'hisabmitra.sqlite');
    db = open();
    await addTxn('t1', 12345);
    // An attachment file + row.
    final dir = Directory(p.join(root.path, 'attachments'))..createSync();
    File(p.join(dir.path, 'a1.jpg')).writeAsBytesSync([1, 2, 3, 4]);
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'a1',
            transactionId: const Value('t1'),
            storedName: 'a1.jpg',
            originalName: 'bill.jpg',
            mimeType: 'image/jpeg',
            sizeBytes: 4,
            sha256: 'x',
            createdAt: DateTime(2026, 1, 1),
          ),
        );
  });

  tearDown(() async {
    await db.close();
    root.deleteSync(recursive: true);
  });

  test(
    'creates a ZIP with database, attachments and a checksummed manifest',
    () async {
      final row = await service().createBackup();
      final file = File(row.filePath);
      expect(file.existsSync(), isTrue);
      expect(row.encrypted, isFalse);
      final archive = ZipDecoder().decodeBytes(file.readAsBytesSync());
      final names = archive.files.map((f) => f.name).toSet();
      expect(
        names,
        containsAll(['manifest.json', 'database.sqlite', 'attachments/a1.jpg']),
      );
      final manifest = jsonDecode(
        utf8.decode(archive.findFile('manifest.json')!.content),
      ) as Map<String, Object?>;
      expect(manifest['schemaVersion'], AppDatabase.currentSchemaVersion);
      expect((manifest['files']! as List).length, 2);
      final history = await service().watchHistory().first;
      expect(history.single.id, row.id);
    },
  );

  test('inspect accepts a valid backup and reports its contents', () async {
    final row = await service().createBackup();
    final inspection = await service().inspect(File(row.filePath));
    expect(inspection.counts['transactions'], 1);
    expect(inspection.attachmentCount, 1);
    expect(inspection.missingAttachments, 0);
  });

  test('inspect rejects a tampered backup (checksum mismatch)', () async {
    final row = await service().createBackup();
    final archive = ZipDecoder().decodeBytes(
      File(row.filePath).readAsBytesSync(),
    );
    final tampered = Archive();
    for (final f in archive.files) {
      final bytes = f.name == 'attachments/a1.jpg' ? [9, 9, 9, 9] : f.content;
      tampered.addFile(ArchiveFile.bytes(f.name, bytes));
    }
    final bad = File(p.join(root.path, 'bad.zip'))
      ..writeAsBytesSync(ZipEncoder().encodeBytes(tampered));
    expect(
      () => service().inspect(bad),
      throwsA(isA<BackupFailure>().having((f) => f.code, 'code', 'corrupt')),
    );
  });

  test('inspect rejects files that are not backups', () async {
    final junk = File(p.join(root.path, 'junk.zip'))
      ..writeAsBytesSync(utf8.encode('hello'));
    expect(
      () => service().inspect(junk),
      throwsA(isA<BackupFailure>().having((f) => f.code, 'code', 'not_backup')),
    );
  });

  test('encrypted backups need the right password', () async {
    final row = await service().createBackup(password: 'secret-123');
    expect(row.encrypted, isTrue);
    final file = File(row.filePath);
    expect(
      () => service().inspect(file),
      throwsA(
        isA<BackupFailure>().having((f) => f.code, 'code', 'password_required'),
      ),
    );
    expect(
      () => service().inspect(file, password: 'wrong'),
      throwsA(
        isA<BackupFailure>().having((f) => f.code, 'code', 'wrong_password'),
      ),
    );
    final ok = await service().inspect(file, password: 'secret-123');
    expect(ok.counts['transactions'], 1);
  });

  test('restore replaces the data after taking a safety backup', () async {
    final row = await service().createBackup();
    // Change data after the backup.
    await addTxn('t2', 999);
    await (db.delete(db.transactions)..where((t) => t.id.equals('t1'))).go();
    File(p.join(root.path, 'attachments', 'a1.jpg')).deleteSync();

    final inspection = await service().inspect(File(row.filePath));
    final result = await service().restore(
      inspection,
      replaceDatabase: (whileClosed) async {
        await db.close();
        await whileClosed();
        db = open();
      },
    );
    expect(result.safetyBackupPath, isNotNull);
    expect(File(result.safetyBackupPath!).existsSync(), isTrue);

    final ids = await db.select(db.transactions).map((t) => t.id).get();
    expect(ids, ['t1']);
    expect(
      File(p.join(root.path, 'attachments', 'a1.jpg')).existsSync(),
      isTrue,
    );
    expect(await db.integrityCheck(), isTrue);
    // The safety backup is listed in the restored database's history.
    final history = await service().watchHistory().first;
    expect(history.any((h) => h.kind == BackupKind.safety), isTrue);
  });

  test(
    'restore prepares the restored database before swapping it in',
    () async {
      final row = await service().createBackup();
      await addTxn('t2', 999);
      final inspection = await service().inspect(File(row.filePath));
      String? prepared;
      await service().restore(
        inspection,
        prepareRestoredDatabase: (path) async {
          prepared = path;
          final staged = AppDatabase(NativeDatabase(File(path)));
          await staged
              .into(staged.appSettings)
              .insert(
                AppSettingsCompanion.insert(
                  key: 'restore.prepared',
                  value: 'yes',
                  updatedAt: DateTime(2026),
                ),
              );
          await staged.close();
        },
        replaceDatabase: (whileClosed) async {
          await db.close();
          await whileClosed();
          db = open();
        },
      );
      expect(prepared, isNotNull);
      final marker = await (db.select(
        db.appSettings,
      )..where((s) => s.key.equals('restore.prepared'))).getSingleOrNull();
      expect(
        marker?.value,
        'yes',
        reason: 'the prepared file is the one swapped in',
      );
    },
  );
}
