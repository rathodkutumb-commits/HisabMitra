import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../domain/enums.dart';
import 'app_database.steps.dart';
import 'seed.dart';
import 'tables.dart';

export '../domain/enums.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    LocalUserProfile,
    AppSettings,
    BackupHistory,
    Categories,
    Persons,
    Transactions,
    MoneyLedger,
    MoneySettlements,
    GroupsCache,
    GroupMembersCache,
    GroupExpensesCache,
    GroupExpenseSplitsCache,
    GroupSettlementsCache,
    FamilyHisabsCache,
    FamilyMembersCache,
    FamilyEntriesCache,
    Attachments,
    Reminders,
    SyncOutbox,
    SyncInbox,
    SyncConflicts,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Current schema version. Bump together with a new step in [migration]
  /// and a `dart run drift_dev make-migrations` schema dump.
  static const int currentSchemaVersion = 7;

  static const String fileName = 'hisabmitra.sqlite';

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await seedDefaultCategories(this, DateTime.now());
    },
    // Upgrades are applied step by step. Existing user data is never
    // dropped; every step must be additive or data-preserving.
    onUpgrade: stepByStep(
      from1To2: (m, schema) async {
        // v2: recurring payments (EMI, SIP, maintenance…) on reminders.
        final r = schema.reminders;
        await m.addColumn(r, r.amountPaise);
        await m.addColumn(r, r.categoryId);
        await m.addColumn(r, r.anchorDay);
        await m.addColumn(r, r.totalOccurrences);
        await m.addColumn(r, r.completedOccurrences);
      },
      from2To3: (m, schema) async {
        // v3: compulsory, verified email on the user's own profile.
        final p = schema.localUserProfile;
        await m.addColumn(p, p.email);
      },
      from3To4: (m, schema) async {
        // v4: personal records are saved to the account (upload state), and
        // the sync tables carry a scope (group / personal).
        await m.addColumn(schema.persons, schema.persons.revision);
        await m.addColumn(schema.persons, schema.persons.syncState);
        await m.addColumn(schema.transactions, schema.transactions.revision);
        await m.addColumn(schema.transactions, schema.transactions.syncState);
        await m.addColumn(schema.moneyLedger, schema.moneyLedger.revision);
        await m.addColumn(schema.moneyLedger, schema.moneyLedger.syncState);
        await m.addColumn(
          schema.moneySettlements,
          schema.moneySettlements.revision,
        );
        await m.addColumn(
          schema.moneySettlements,
          schema.moneySettlements.syncState,
        );
        await m.addColumn(schema.reminders, schema.reminders.revision);
        await m.addColumn(schema.reminders, schema.reminders.syncState);
        await m.addColumn(schema.attachments, schema.attachments.revision);
        await m.addColumn(schema.attachments, schema.attachments.syncState);
        await m.addColumn(schema.syncOutbox, schema.syncOutbox.scope);
        // The inbox key becomes (scope, seq): rebuild the table.
        await m.alterTable(
          TableMigration(
            schema.syncInbox,
            newColumns: [schema.syncInbox.scope, schema.syncInbox.opId],
          ),
        );
        await m.addColumn(schema.syncConflicts, schema.syncConflicts.scope);
      },
      from4To5: (m, schema) async {
        // v5: custom categories can have a Gujarati name too.
        await m.addColumn(schema.categories, schema.categories.nameGu);
      },
      from5To6: (m, schema) async {
        // v6: Family hisab (shared home purse) — three new tables.
        await m.createTable(schema.familyHisabsCache);
        await m.createTable(schema.familyMembersCache);
        await m.createTable(schema.familyEntriesCache);
        await m.createIndex(schema.idxFamilyMembersFamily);
        await m.createIndex(schema.idxFamilyEntriesFamily);
      },
      from6To7: (m, schema) async {
        // v7: bills on Family hisab money out (the table's check changes,
        // so it is rebuilt) and reminders linked to a Family hisab.
        await m.alterTable(
          TableMigration(
            schema.attachments,
            newColumns: [schema.attachments.familyEntryId],
          ),
        );
        await m.addColumn(schema.reminders, schema.reminders.familyId);
      },
    ),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) return;
      // Re-insert built-in categories that might be missing after restore of
      // an older backup.
      await seedDefaultCategories(this, DateTime.now());
    },
  );

  /// Absolute path of the on-device database file.
  static Future<String> defaultFilePath() async {
    final dir = await getApplicationSupportDirectory();
    return p.join(dir.path, fileName);
  }

  /// Opens the production database stored in app-private storage.
  static AppDatabase open() {
    return AppDatabase(
      driftDatabase(
        name: 'hisabmitra',
        native: const DriftNativeOptions(databasePath: defaultFilePath),
      ),
    );
  }

  /// Writes a consistent snapshot of the live database to [targetPath]
  /// (used by backups).
  Future<void> snapshotTo(String targetPath) async {
    final target = File(targetPath);
    if (target.existsSync()) target.deleteSync();
    await customStatement('VACUUM INTO ?', [targetPath]);
  }

  /// Runs SQLite's integrity check; returns true when the DB is healthy.
  Future<bool> integrityCheck() async {
    final rows = await customSelect('PRAGMA integrity_check').get();
    return rows.length == 1 && rows.first.data.values.first == 'ok';
  }
}
