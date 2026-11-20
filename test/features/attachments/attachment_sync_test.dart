import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/attachments/data/attachment_service.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

class _Clock extends Clock {
  DateTime value = DateTime(2026, 11, 20, 10);
  @override
  DateTime now() => value;
}

/// One phone with its own private files folder.
class Phone {
  Phone(FakeCloudServer server, this.dir) {
    cloud = FakeCloudClient(server, 'hemang');
    const ids = IdGenerator();
    files = AttachmentService(
      db,
      clock,
      ids,
      baseDir: () async => dir,
      cloud: cloud,
    );
    txns = TransactionRepository(db, clock, ids);
    groups = GroupRepository(db, clock, ids, currentUserId: () => 'hemang');
    sync = SyncService(
      db: db,
      cloud: cloud,
      clock: clock,
      ids: ids,
      beforePush: files.uploadPendingFiles,
    );
    sync.personal.onFilesRemoved = files.deleteFiles;
  }

  final Directory dir;
  final db = newTestDatabase();
  final clock = _Clock();
  late final FakeCloudClient cloud;
  late final AttachmentService files;
  late final TransactionRepository txns;
  late final GroupRepository groups;
  late final SyncService sync;

  Future<AttachmentRow> only() async =>
      (await db.select(db.attachments).get()).single;
}

void main() {
  late FakeCloudServer server;
  late Directory tmp;
  late Phone p1;
  const bytes = [1, 2, 3, 4, 5];

  setUp(() async {
    server = FakeCloudServer();
    tmp = await Directory.systemTemp.createTemp('hm_bills_');
    p1 = Phone(server, Directory('${tmp.path}/p1')..createSync());
  });
  tearDown(() async {
    await p1.db.close();
    await tmp.delete(recursive: true);
  });

  Future<String> billOnExpense(Phone p) async {
    final txn = await p.txns.save(
      TransactionDraft(
        type: TransactionType.expense,
        amountPaise: 25000,
        categoryId: 'cat_groceries',
        date: DateTime(2026, 11, 20),
        paymentMethod: PaymentMethod.upi,
      ),
    );
    final src = File('${tmp.path}/bill.jpg')..writeAsBytesSync(bytes);
    final staged = await p.files.stage(src);
    return p.files.commit(
      staged,
      parent: AttachmentParent.transaction,
      parentId: txn,
    );
  }

  test('a bill uploads before its record', () async {
    final id = await billOnExpense(p1);
    await p1.sync.syncOnce();
    final local = await p1.only();
    expect(server.personal.files['hemang/${local.storedName}'], bytes);
    final row = server.personal.rows['attachment']![id]!;
    expect(row['storage_path'], 'hemang/${local.storedName}');
    expect(local.remotePath, local.storedName);
    expect(local.syncState, SyncState.synced);
  });

  test('the record waits while its file is not uploaded yet', () async {
    final id = await billOnExpense(p1);
    p1.cloud.failFileUploads = true;
    await p1.sync.syncOnce();
    expect(server.personal.rows['attachment']![id], isNull);
    expect(
      (await p1.db.select(p1.db.syncOutbox).get()).map((o) => o.entityId),
      contains(id),
    );
    p1.cloud.failFileUploads = false;
    await p1.sync.syncOnce();
    expect(server.personal.rows['attachment']![id], isNotNull);
  });

  test('the other phone downloads the bill when shown', () async {
    await billOnExpense(p1);
    await p1.sync.syncOnce();
    final p2 = Phone(server, Directory('${tmp.path}/p2')..createSync());
    addTearDown(p2.db.close);
    await p2.sync.syncOnce();
    final row = await p2.only();
    expect(row.remotePath, isNotNull);
    expect((await p2.files.fileFor(row.storedName)).existsSync(), isFalse);
    final file = await p2.files.ensureLocal(row);
    expect(file, isNotNull);
    expect(file!.readAsBytesSync(), bytes);
  });

  test('deleting a bill removes the stored file', () async {
    final id = await billOnExpense(p1);
    await p1.sync.syncOnce();
    final name = (await p1.only()).storedName;
    await p1.files.delete(id);
    await p1.sync.syncOnce();
    expect(server.personal.files.containsKey('hemang/$name'), isFalse);
    expect(server.personal.rows['attachment']![id]!['deleted_at'], isNotNull);
  });

  test('a group expense bill uploads to the group bucket', () async {
    final groupId = await p1.groups.createGroup(
      const GroupDraft(name: 'Goa Trip', groupType: GroupType.trip),
      selfName: 'Hemang',
      members: const [MemberDraft(name: 'Rahul Patel')],
    );
    final d = (await p1.groups.watchGroup(groupId).first)!;
    final me = d.selfMember!.id;
    final expense = await p1.groups.saveExpense(
      ExpenseDraft(
        groupId: groupId,
        description: 'Hotel',
        categoryKey: 'stay',
        amountPaise: 100000,
        paidByMemberId: me,
        date: DateTime(2026, 11, 20),
        splitMethod: SplitMethod.equal,
        participants: [for (final m in d.members) SplitParticipant(m.id, 0)],
      ),
    );
    await p1.sync.syncOnce(); // group and expense reach the server first
    final src = File('${tmp.path}/hotel.jpg')..writeAsBytesSync(bytes);
    await p1.files.commit(
      await p1.files.stage(src),
      parent: AttachmentParent.groupExpense,
      parentId: expense,
    );
    await p1.sync.syncOnce();
    final row = await p1.only();
    expect(row.remotePath, '$groupId/$expense/${row.storedName}');
    expect(server.groupFiles[row.remotePath], bytes);
  });

  test('a bill whose file is gone still lets its record sync', () async {
    final id = await billOnExpense(p1);
    final row = await p1.only();
    (await p1.files.fileFor(row.storedName)).deleteSync();
    await p1.sync.syncOnce();
    expect(server.personal.rows['attachment']![id], isNotNull);
    expect((await p1.only()).remotePath, '');
    expect(await p1.db.select(p1.db.syncOutbox).get(), isEmpty);
  });
}
