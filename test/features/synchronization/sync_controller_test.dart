import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/data/sync_service.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';

import '../../helpers/fake_cloud.dart';
import '../../helpers/test_db.dart';

/// Counts group pulls; can hold the first one until [release].
class _GatedCloud extends FakeCloudClient {
  _GatedCloud(FakeCloudServer server) : super(server, 'hemang');

  var pulls = 0;
  Completer<void>? gate;

  void release() => gate?.complete();

  @override
  Future<List<RemoteEvent>> pullEvents({
    required int afterSeq,
    int limit = 500,
  }) async {
    pulls++;
    final g = gate;
    if (g != null) {
      await g.future;
      gate = null;
    }
    return super.pullEvents(afterSeq: afterSeq, limit: limit);
  }
}

void main() {
  late ProviderContainer container;
  late _GatedCloud cloud;

  setUp(() {
    final db = newTestDatabase();
    cloud = _GatedCloud(FakeCloudServer());
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        cloudGatewayProvider.overrideWithValue(cloud),
        syncServiceProvider.overrideWithValue(
          SyncService(
            db: db,
            cloud: cloud,
            clock: const Clock(),
            ids: const IdGenerator(),
          ),
        ),
        connectivityProvider.overrideWith((ref) => Stream.value(true)),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
  });

  test('a silent request during a sync runs once more afterwards', () async {
    final controller = container.read(syncControllerProvider.notifier);
    cloud.gate = Completer<void>();
    final first = controller.syncNow(silent: true);
    await pumpEventQueue();
    expect(cloud.pulls, 1);
    expect(await controller.syncNow(silent: true), isNull);
    expect(await controller.syncNow(silent: true), isNull);
    cloud.release();
    await first;
    await pumpEventQueue(times: 100);
    expect(cloud.pulls, 2);
  });

  test('no request, no extra run', () async {
    final controller = container.read(syncControllerProvider.notifier);
    await controller.syncNow(silent: true);
    await pumpEventQueue(times: 100);
    expect(cloud.pulls, 1);
  });
}
