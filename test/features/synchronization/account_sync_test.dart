import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/profile/data/profile_repository.dart';
import 'package:hisabmitra/features/settings/application/settings_controller.dart';
import 'package:hisabmitra/features/settings/domain/app_preferences.dart';
import 'package:hisabmitra/features/synchronization/application/account_sync_controller.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';
import 'package:hisabmitra/features/tour/data/sample_data_service.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late FakeCloudServer server;
  late FakeCloudClient cloud;
  late ProviderContainer c;

  setUp(() {
    db = newTestDatabase();
    server = FakeCloudServer();
    cloud = FakeCloudClient(server, 'hemang');
    c = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        cloudGatewayProvider.overrideWithValue(cloud),
        initialPreferencesProvider.overrideWithValue(
          AppPreferences.fromMap(const {})
              .copyWith(onboardingComplete: true, accountVerified: true),
        ),
      ],
    );
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  final now = DateTime(2026, 11, 1);

  /// Records written by an older version of the app (never uploaded).
  Future<void> oldData({int people = 3, int entries = 5}) async {
    for (var i = 0; i < people; i++) {
      await db
          .into(db.persons)
          .insert(
            PersonsCompanion.insert(
              id: 'p$i',
              name: 'Person $i',
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    for (var i = 0; i < entries; i++) {
      await db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: 't$i',
              ownerId: 'self',
              type: TransactionType.expense,
              amountPaise: 1000 + i,
              categoryId: 'cat_groceries',
              txnDate: now,
              paymentMethod: PaymentMethod.cash,
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
  }

  Future<int> pending() async => (await db.select(db.syncOutbox).get()).length;

  test('first upload queues every unsent record once', () async {
    await oldData();
    expect(
      await c.read(accountSyncControllerProvider.notifier).queueUnsentData(),
      8,
    );
    expect(await pending(), 8);
    expect(
      await c.read(accountSyncControllerProvider.notifier).queueUnsentData(),
      0,
    );
    expect(await pending(), 8);
  });

  test('a phone-only group is shared during the first upload', () async {
    final local = GroupRepository(db, _clock(), const IdGenerator());
    final id = await local.createGroup(
      const GroupDraft(name: 'Family', groupType: GroupType.family),
      selfName: 'Hemang',
    );
    await c.read(accountSyncControllerProvider.notifier).queueUnsentData();
    final g = (await local.watchGroup(id).first)!;
    expect(g.group.isShared, isTrue);
    expect(
      (await db.select(db.syncOutbox).get()).map((o) => o.entityType),
      contains('group'),
    );
  });

  test('sample data is not uploaded', () async {
    await c.read(profileRepositoryProvider).saveName('Hemang');
    await c.read(sampleDataServiceProvider).load();
    expect(
      await c.read(accountSyncControllerProvider.notifier).queueUnsentData(),
      0,
    );
    expect(await pending(), 0);
  });

  test('the account\'s records and the phone\'s are merged', () async {
    // Another phone already saved two entries to the account.
    for (final id in ['x1', 'x2']) {
      server.personal.apply(
        OutboundOp(
          opId: 'op-$id',
          groupId: '',
          scope: 'personal',
          entityType: 'transaction',
          entityId: id,
          opType: 'upsert',
          baseRevision: 0,
          payload: const {
            'type': 'expense',
            'amount_paise': 700,
            'category_id': 'cat_groceries',
            'category_name': 'Groceries',
            'category_system_key': 'groceries',
            'category_icon': 'grocery',
            'category_color': 1,
            'txn_date': '2026-11-02',
            'payment_method': 'upi',
          },
        ),
        'hemang',
      );
    }
    await oldData();
    await c.read(accountSyncControllerProvider.notifier).run();
    expect(c.read(accountSyncControllerProvider).phase, AccountSyncPhase.done);
    expect(server.personal.live('transaction', 'hemang'), hasLength(7));
    expect(server.personal.live('person', 'hemang'), hasLength(3));
    expect(await db.select(db.transactions).get(), hasLength(7));
    expect(c.read(settingsControllerProvider).initialSyncDone, isTrue);
  });

  test('offline: the phase says so and the next run completes', () async {
    await oldData(people: 1, entries: 1);
    cloud.online = false;
    final ctl = c.read(accountSyncControllerProvider.notifier);
    await ctl.run();
    expect(
      c.read(accountSyncControllerProvider).phase,
      AccountSyncPhase.offline,
    );
    expect(c.read(settingsControllerProvider).initialSyncDone, isFalse);
    cloud.online = true;
    await ctl.run(retryNow: true);
    expect(c.read(accountSyncControllerProvider).phase, AccountSyncPhase.done);
    expect(server.personal.live('transaction', 'hemang'), hasLength(1));
  });
}

Clock _clock() => const _FixedClock();

class _FixedClock implements Clock {
  const _FixedClock();
  @override
  DateTime now() => DateTime(2026, 11, 1, 10);
}
