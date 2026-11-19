// Backup and restore on a real device, in the app's private storage, with
// the production key-derivation strength (PBKDF2, 210 000 iterations):
//
//   flutter test integration_test/device_backup_test.dart -d emulator-5554
//
// Works in a throw-away folder under the app's temporary directory, so the
// device's real HisabMitra data and backups are never touched.
import 'dart:io';

import 'package:drift/drift.dart' show Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/backup/data/backup_service.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

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
    appVersion: 'integration-test',
  );

  Future<void> addTxn(String id, int paise, String description) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          id: id,
          ownerId: 'self',
          type: TransactionType.expense,
          amountPaise: paise,
          categoryId: 'cat_food',
          txnDate: DateTime(2026, 11, 1),
          paymentMethod: PaymentMethod.upi,
          description: Value(description),
          createdAt: DateTime(2026, 11, 1),
          updatedAt: DateTime(2026, 11, 1),
        ),
      );

  setUp(() async {
    final tmp = await getTemporaryDirectory();
    root = Directory(
      p.join(tmp.path, 'hm_it_${DateTime.now().microsecondsSinceEpoch}'),
    )..createSync(recursive: true);
    dbPath = p.join(root.path, 'hisabmitra.sqlite');
    db = open();
    await addTxn('t1', 125050, 'કરિયાણું');
    final attachments = Directory(p.join(root.path, 'attachments'))
      ..createSync();
    File(p.join(attachments.path, 'bill.jpg'))
        .writeAsBytesSync(List.generate(4096, (i) => i % 251));
    await db
        .into(db.attachments)
        .insert(
          AttachmentsCompanion.insert(
            id: 'a1',
            transactionId: const Value('t1'),
            storedName: 'bill.jpg',
            originalName: 'bill.jpg',
            mimeType: 'image/jpeg',
            sizeBytes: 4096,
            sha256: 'x',
            createdAt: DateTime(2026, 11, 1),
          ),
        );
  });

  tearDown(() async {
    await db.close();
    if (root.existsSync()) root.deleteSync(recursive: true);
  });

  testWidgets('encrypted backup and restore round-trip on the device', (
    tester,
  ) async {
    final watch = Stopwatch()..start();
    final row = await service().createBackup(password: 'hisab-123');
    final backupMs = watch.elapsedMilliseconds;
    expect(File(row.filePath).existsSync(), isTrue);

    // Change the data after the backup.
    await addTxn('t2', 999, 'later');
    await (db.delete(db.transactions)..where((t) => t.id.equals('t1'))).go();
    File(p.join(root.path, 'attachments', 'bill.jpg')).deleteSync();

    watch.reset();
    final inspection = await service().inspect(
      File(row.filePath),
      password: 'hisab-123',
    );
    final result = await service().restore(
      inspection,
      replaceDatabase: (whileClosed) async {
        await db.close();
        await whileClosed();
        db = open();
      },
    );
    final restoreMs = watch.elapsedMilliseconds;
    debugPrint('backup: ${backupMs}ms, inspect+restore: ${restoreMs}ms');

    final rows = await db.select(db.transactions).get();
    expect(rows.map((r) => r.id), ['t1']);
    expect(rows.single.description, 'કરિયાણું');
    expect(rows.single.amountPaise, 125050);
    expect(
      File(p.join(root.path, 'attachments', 'bill.jpg')).lengthSync(),
      4096,
    );
    expect(await db.integrityCheck(), isTrue);
    expect(File(result.safetyBackupPath!).existsSync(), isTrue);
  }, timeout: const Timeout(Duration(minutes: 3)));

  testWidgets('a wrong password is rejected before anything is replaced', (
    tester,
  ) async {
    final row = await service().createBackup(password: 'right-pass');
    await expectLater(
      service().inspect(File(row.filePath), password: 'wrong-pass'),
      throwsA(anything),
    );
    final rows = await db.select(db.transactions).get();
    expect(rows.single.id, 't1', reason: 'data untouched');
  }, timeout: const Timeout(Duration(minutes: 3)));
}
