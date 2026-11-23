import 'package:drift/drift.dart' show Table, TableInfo;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/categories/data/category_repository.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/money_ledger/data/ledger_repository.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_models.dart';
import 'package:hisabmitra/features/people/data/people_repository.dart';
import 'package:hisabmitra/features/reminders/application/notification_service.dart';
import 'package:hisabmitra/features/reminders/domain/reminder_schedule.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/account_sync_controller.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/data/local_data_wiper.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late FakeCloudClient cloud;
  late ProviderContainer c;

  setUp(() {
    db = newTestDatabase();
    cloud = FakeCloudClient(FakeCloudServer(), 'hemang');
    c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        cloudGatewayProvider.overrideWithValue(cloud),
        initialPreferencesProvider.overrideWithValue(
          AppPreferences.fromMap(const {}).copyWith(
            onboardingComplete: true,
            accountVerified: true,
            initialSyncDone: true,
          ),
        ),
      ],
    );
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  Future<int> count(TableInfo<Table, Object?> t) async =>
      (await db.select(t).get()).length;

  Future<void> someData() async {
    final p = await c
        .read(peopleRepositoryProvider)
        .save(const PersonDraft(name: 'Rahul Patel'));
    await c
        .read(transactionRepositoryProvider)
        .save(
          TransactionDraft(
            type: TransactionType.expense,
            amountPaise: 500,
            categoryId: 'cat_groceries',
            date: DateTime(2026, 11, 20),
            paymentMethod: PaymentMethod.cash,
          ),
        );
    await c
        .read(ledgerRepositoryProvider)
        .saveEntry(
          LedgerDraft(
            personId: p,
            direction: LedgerDirection.given,
            principalPaise: 1000,
            date: DateTime(2026, 11, 1),
            paymentMethod: PaymentMethod.cash,
          ),
        );
    await c
        .read(reminderRepositoryProvider)
        .save(
          ReminderDraft(
            kind: ReminderKind.custom,
            title: 'Pay',
            dueAt: DateTime(2030, 1, 1, 10),
          ),
        );
    await c
        .read(groupRepositoryProvider)
        .createGroup(
          const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
          selfName: 'Hemang',
        );
    await c
        .read(categoryRepositoryProvider)
        .save(
          const CategoryDraft(
            name: 'Tiffin',
            nameGu: 'ટિફિન',
            type: TransactionType.expense,
            iconKey: 'food',
            colorValue: 1,
          ),
        );
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'sync.personalCursor',
            value: '42',
            updatedAt: DateTime(2026),
          ),
        );
  }

  test('wipe keeps categories and settings, removes everything else', () async {
    await someData();
    final categories = await count(db.categories);
    await c
        .read(settingsControllerProvider.notifier)
        .update((p) => p.copyWith(languageCode: 'gu'));

    await c.read(localDataWiperProvider).wipeAccountData();

    expect(await count(db.persons), 0);
    expect(await count(db.transactions), 0);
    expect(await count(db.moneyLedger), 0);
    expect(await count(db.reminders), 0);
    expect(await count(db.groupsCache), 0);
    expect(await count(db.groupMembersCache), 0);
    expect(await count(db.syncOutbox), 0);
    expect(await count(db.categories), categories);
    final cursor = await (db.select(
      db.appSettings,
    )..where((s) => s.key.equals('sync.personalCursor'))).getSingleOrNull();
    expect(cursor, isNull);
    expect(c.read(settingsControllerProvider).languageCode, 'gu');
  });

  test('canSync follows the sign-in, there is no switch any more', () {
    expect(c.read(syncControllerProvider.notifier).canSync, isTrue);
  });

  test(
    'signing out offline with unsent changes, then signing in again, works',
    () async {
      cloud.online = false;
      await someData();
      expect(await db.select(db.syncOutbox).get(), isNotEmpty);
      await c.read(localDataWiperProvider).wipeAccountData();
      await c
          .read(settingsControllerProvider.notifier)
          .update(
            (p) => p.copyWith(accountVerified: false, initialSyncDone: false),
          );

      // Signed in again, back online: the first sync downloads the account.
      cloud.online = true;
      await c
          .read(settingsControllerProvider.notifier)
          .update((p) => p.copyWith(accountVerified: true));
      await c.read(accountSyncControllerProvider.notifier).run();
      expect(
        c.read(accountSyncControllerProvider).phase,
        AccountSyncPhase.done,
      );
      expect(c.read(settingsControllerProvider).initialSyncDone, isTrue);
    },
  );
}
