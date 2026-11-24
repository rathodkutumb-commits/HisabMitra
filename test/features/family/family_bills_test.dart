import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/attachments/data/attachment_service.dart';
import 'package:hisabmitra/features/family/application/family_sharing.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

class _Clock extends Clock {
  DateTime value = DateTime(2026, 11, 23, 10);
  @override
  DateTime now() => value;
}

/// One person's phone with its own private files folder.
class Phone {
  Phone(FakeCloudServer server, String uid, this.dir) {
    cloud = FakeCloudClient(server, uid);
    const ids = IdGenerator();
    files = AttachmentService(
      db,
      clock,
      ids,
      baseDir: () async => dir,
      cloud: cloud,
    );
    sync = SyncService(
      db: db,
      cloud: cloud,
      clock: clock,
      ids: ids,
      beforePush: files.uploadPendingFiles,
    );
    sharing = FamilySharing(cloud, sync);
    family = FamilyRepository(
      db,
      clock,
      ids,
      currentUserId: () => uid,
      deleteFiles: files.deleteFiles,
    );
    sync.familyRows.onFilesRemoved = files.deleteFiles;
  }

  final Directory dir;
  final db = newTestDatabase();
  final clock = _Clock();
  late final FakeCloudClient cloud;
  late final FamilyRepository family;
  late final AttachmentService files;
  late final SyncService sync;
  late final FamilySharing sharing;

  Future<List<AttachmentRow>> bills() => db.select(db.attachments).get();

  void later() => clock.value = clock.value.add(const Duration(minutes: 5));
}

void main() {
  late FakeCloudServer server;
  late Directory tmp;
  late Phone hemang;
  late Phone rahul;
  late String home;
  late String rent;
  const bytes = [7, 7, 7, 1];

  setUp(() async {
    server = FakeCloudServer();
    tmp = await Directory.systemTemp.createTemp('hm_family_bills_');
    hemang = Phone(server, 'hemang', Directory('${tmp.path}/h')..createSync());
    rahul = Phone(server, 'rahul', Directory('${tmp.path}/r')..createSync());
    home = await hemang.family.createFamily(
      const FamilyDraft(name: 'Home'),
      selfName: 'Hemang',
      people: const [FamilyPersonDraft(name: 'Rahul Patel')],
    );
    final d = (await hemang.family.watchFamily(home).first)!;
    await hemang.sync.syncOnce();
    final inv = await hemang.sharing.createInvitation(
      familyId: home,
      memberId: d.members.last.id,
    );
    await rahul.sharing.join(
      await rahul.cloud.acceptInvitation(code: inv.code, displayName: 'Rahul'),
    );
    await hemang.sync.syncOnce();

    // Rent paid, with its bill — written while offline.
    hemang.cloud.online = false;
    rent = await hemang.family.saveEntry(
      FamilyEntryDraft(
        familyId: home,
        memberId: d.self!.id,
        kind: FamilyEntryKind.expense,
        amountPaise: 1500000,
        date: DateTime(2026, 11, 5),
        categoryId: 'cat_rent',
      ),
    );
    final src = File('${tmp.path}/rent.jpg')..writeAsBytesSync(bytes);
    await hemang.files.commit(
      await hemang.files.stage(src),
      parent: AttachmentParent.familyEntry,
      parentId: rent,
    );
    hemang.cloud.online = true;
    hemang.later();
  });
  tearDown(() async {
    await hemang.db.close();
    await rahul.db.close();
    await tmp.delete(recursive: true);
  });

  test('a bill on money out reaches the other member', () async {
    await hemang.sync.syncOnce(); // the entry reaches the account first
    await hemang.sync.syncOnce(); // then its bill
    final mine = (await hemang.bills()).single;
    expect(mine.remotePath, '$home/$rent/${mine.storedName}');

    await rahul.sync.syncOnce();
    final theirs = (await rahul.bills()).single;
    expect((theirs.familyEntryId, theirs.storedName), (rent, ''));
    final file = await rahul.files.ensureLocal(theirs);
    expect(file!.readAsBytesSync(), bytes);
    expect((await rahul.family.watchFamily(home).first)!.billEntryIds, {rent});
  });

  test('a deleted bill disappears for everyone', () async {
    await hemang.sync.syncOnce();
    await hemang.sync.syncOnce();
    await rahul.sync.syncOnce();
    final theirs = (await rahul.bills()).single;

    await rahul.files.delete(theirs.id);
    expect(await rahul.bills(), isEmpty);
    await hemang.sync.syncOnce();
    expect(await hemang.bills(), isEmpty);
    expect(
      (await hemang.family.watchFamily(home).first)!.billEntryIds,
      isEmpty,
    );
  });

  test('a deleted entry takes its bills off both phones', () async {
    await hemang.sync.syncOnce();
    await hemang.sync.syncOnce();
    await rahul.sync.syncOnce();
    final mine = (await hemang.bills()).single;
    expect((await hemang.files.fileFor(mine.storedName)).existsSync(), isTrue);
    expect(await rahul.bills(), hasLength(1));

    await hemang.family.deleteEntry(rent);
    expect(await hemang.bills(), isEmpty);
    expect(
      (await hemang.files.fileFor(mine.storedName)).existsSync(),
      isFalse,
      reason: 'the file goes too',
    );
    await hemang.sync.syncOnce();
    await rahul.sync.syncOnce();
    expect(await rahul.bills(), isEmpty);
  });

  test('a new phone gets the bills with the Family hisab', () async {
    await hemang.sync.syncOnce();
    await hemang.sync.syncOnce();
    final fresh = Phone(
      server,
      'rahul',
      Directory('${tmp.path}/fresh')..createSync(),
    );
    addTearDown(fresh.db.close);
    await fresh.sync.syncOnce();
    expect((await fresh.bills()).single.familyEntryId, rent);
  });
}
