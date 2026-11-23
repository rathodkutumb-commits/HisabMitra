import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';
import 'package:hisabmitra/features/synchronization/application/live_sync.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

class _Clock extends Clock {
  @override
  DateTime now() => DateTime(2026, 11, 20, 10);
}

/// One signed-in phone.
class Phone {
  Phone(FakeCloudServer server, this.userId) {
    cloud = FakeCloudClient(server, userId);
    const ids = IdGenerator();
    groups = GroupRepository(db, clock, ids, currentUserId: () => userId);
    txns = TransactionRepository(db, clock, ids);
    sync = SyncService(db: db, cloud: cloud, clock: clock, ids: ids);
  }

  final String userId;
  final db = newTestDatabase();
  final clock = _Clock();
  late final FakeCloudClient cloud;
  late final GroupRepository groups;
  late final TransactionRepository txns;
  late final SyncService sync;
  var syncs = 0;

  LiveSync listen() => LiveSync(
    signals: cloud.changeSignals,
    sync: () async {
      syncs++;
      await sync.syncOnce();
    },
    debounce: Duration.zero,
  )..start();
}

/// Waits until [check] holds (10 ms steps, at most 3 s).
Future<void> eventually(Future<bool> Function() check) async {
  for (var i = 0; i < 300; i++) {
    if (await check()) return;
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('condition not met within 3 s');
}

void main() {
  group('LiveSync', () {
    late StreamController<void> signals;
    late int syncs;
    late List<Object> failNext;
    late LiveSync live;

    setUp(() {
      signals = StreamController<void>.broadcast();
      syncs = 0;
      failNext = [];
      live = LiveSync(
        signals: () => signals.stream,
        sync: () async {
          syncs++;
          if (failNext.isNotEmpty) throw failNext.removeAt(0);
        },
        debounce: const Duration(milliseconds: 20),
      );
    });
    tearDown(() async {
      await live.stop();
      await signals.close();
    });

    Future<void> settle() =>
        Future<void>.delayed(const Duration(milliseconds: 100));

    test('signals close together sync once', () async {
      live.start();
      signals
        ..add(null)
        ..add(null)
        ..add(null);
      await settle();
      expect(syncs, 1);
    });

    test('nothing syncs after stop', () async {
      live.start();
      signals.add(null);
      await live.stop();
      signals.add(null);
      await settle();
      expect(syncs, 0);
      expect(live.isListening, isFalse);
    });

    test('start twice listens once', () async {
      live
        ..start()
        ..start();
      expect(live.isListening, isTrue);
      signals.add(null);
      await settle();
      expect(syncs, 1);
    });

    test('a failing sync keeps listening', () async {
      failNext.add(const NetworkFailure());
      live.start();
      signals.add(null);
      await settle();
      signals.add(null);
      await settle();
      expect(syncs, 2);
      expect(live.isListening, isTrue);
    });
  });

  group('two phones', () {
    late FakeCloudServer server;
    late Phone hemang;
    late Phone rahul;
    late String groupId;
    late String rahulMember;
    final listeners = <LiveSync>[];

    setUp(() async {
      server = FakeCloudServer();
      hemang = Phone(server, 'hemang');
      rahul = Phone(server, 'rahul');
      groupId = await hemang.groups.createGroup(
        const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
        selfName: 'Hemang',
        members: const [MemberDraft(name: 'Rahul Patel')],
      );
      rahulMember = (await hemang.groups.watchGroup(groupId).first)!.members
          .firstWhere((m) => !m.isSelf)
          .id;
      await hemang.sync.syncOnce();
    });

    tearDown(() async {
      for (final l in listeners) {
        await l.stop();
      }
      listeners.clear();
      await hemang.db.close();
      await rahul.db.close();
    });

    Future<void> rahulJoins() async {
      final code = server.createInvitation(groupId, rahulMember);
      final accepted = await rahul.cloud.acceptInvitation(
        code: code,
        displayName: 'Rahul Patel',
      );
      await rahul.sync.joinGroup(accepted.groupId!);
    }

    Future<void> hemangAddsHotel() async {
      final d = (await hemang.groups.watchGroup(groupId).first)!;
      await hemang.groups.saveExpense(
        ExpenseDraft(
          groupId: groupId,
          description: 'Hotel',
          categoryKey: 'stay',
          amountPaise: 100000,
          paidByMemberId: d.selfMember!.id,
          date: DateTime(2026, 11, 20),
          splitMethod: SplitMethod.equal,
          participants: [for (final m in d.members) SplitParticipant(m.id, 0)],
        ),
      );
      await hemang.sync.syncOnce();
    }

    Future<bool> hasHotel(Phone p) async {
      final rows = await p.db.select(p.db.groupExpensesCache).get();
      return rows.any((e) => e.description == 'Hotel');
    }

    test(
      'a group expense reaches the other member without a manual sync',
      () async {
        await rahulJoins();
        listeners.add(rahul.listen());
        await hemangAddsHotel();
        await eventually(() => hasHotel(rahul));
      },
    );

    test('a new member shows on the other phone', () async {
      listeners.add(hemang.listen());
      await rahulJoins();
      await eventually(() async {
        final d = (await hemang.groups.watchGroup(groupId).first)!;
        return d.members.any((m) => m.userId == 'rahul');
      });
    });

    test("own records reach the same user's other phone", () async {
      final second = Phone(server, 'hemang');
      addTearDown(second.db.close);
      await second.sync.syncOnce();
      listeners.add(second.listen());
      final id = await hemang.txns.save(
        TransactionDraft(
          type: TransactionType.expense,
          amountPaise: 25000,
          categoryId: 'cat_groceries',
          date: DateTime(2026, 11, 20),
          paymentMethod: PaymentMethod.upi,
        ),
      );
      await hemang.sync.syncOnce();
      await eventually(() async {
        final rows = await second.db.select(second.db.transactions).get();
        return rows.any((t) => t.id == id);
      });
    });

    test('a phone does not hear groups it is not in', () async {
      final kiran = Phone(server, 'kiran');
      addTearDown(kiran.db.close);
      listeners.add(kiran.listen());
      await hemangAddsHotel();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(kiran.syncs, 0);
    });
  });
}
