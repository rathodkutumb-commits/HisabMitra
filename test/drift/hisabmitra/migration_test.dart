// dart format width=80
// ignore_for_file: unused_local_variable, unused_import
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';

import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test(
    'v1 → v2 keeps existing reminders and gives them payment defaults',
    () async {
      // Schema snapshots store DateTime as Unix seconds.
      int secs(DateTime d) => d.millisecondsSinceEpoch ~/ 1000;
      final created = secs(DateTime.utc(2026, 5, 1));
      final due = secs(DateTime.utc(2026, 6, 30, 9));
      final oldReminder = v1.RemindersData(
        id: 'r1',
        kind: 'custom',
        title: 'Pay society bill',
        note: 'Wing B',
        dueAt: due,
        repeat: 'monthly',
        notificationId: 42,
        status: 'pending',
        createdAt: created,
        updatedAt: created,
      );
      final expected = v2.RemindersData(
        id: 'r1',
        kind: 'custom',
        title: 'Pay society bill',
        note: 'Wing B',
        dueAt: due,
        repeat: 'monthly',
        amountPaise: null,
        categoryId: null,
        anchorDay: null,
        totalOccurrences: null,
        completedOccurrences: 0,
        notificationId: 42,
        status: 'pending',
        createdAt: created,
        updatedAt: created,
      );

      await verifier.testWithDataIntegrity(
        oldVersion: 1,
        newVersion: 2,
        createOld: v1.DatabaseAtV1.new,
        createNew: v2.DatabaseAtV2.new,
        openTestedDatabase: AppDatabase.new,
        createItems: (batch, oldDb) =>
            batch.insert(oldDb.reminders, oldReminder),
        validateItems: (newDb) async {
          expect(await newDb.select(newDb.reminders).get(), [expected]);
        },
      );
    },
  );

  test('v2 → v3 keeps the profile and adds an empty email', () async {
    final at = DateTime.utc(2026, 11, 1).millisecondsSinceEpoch ~/ 1000;
    const old = v2.LocalUserProfileData(
      createdAt: 0,
      updatedAt: 0,
      id: 'self',
      displayName: 'Hemang',
      phone: '+919876543210',
      remoteUserId: null,
    );
    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.localUserProfile,
        old.copyWith(createdAt: at, updatedAt: at),
      ),
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.localUserProfile).get(), [
          v3.LocalUserProfileData(
            createdAt: at,
            updatedAt: at,
            id: 'self',
            displayName: 'Hemang',
            phone: '+919876543210',
            email: null,
            remoteUserId: null,
          ),
        ]);
      },
    );
  });
}
