import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/synchronization/application/live_sync.dart';
import 'package:hisabmitra/features/synchronization/application/sync_controller.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';

import '../../helpers/fake_auth_gateway.dart';

void main() {
  const hemang = CloudSession(userId: 'user-1', email: 'hemang@example.com');

  ({ProviderContainer container, FakeAuthGateway cloud}) setUpWith({
    bool configured = true,
    CloudSession? session = hemang,
  }) {
    final cloud = FakeAuthGateway(configured: configured)..session = session;
    final container = ProviderContainer(
      overrides: [cloudGatewayProvider.overrideWithValue(cloud)],
    );
    addTearDown(container.dispose);
    container.listen(liveSyncControllerProvider, (_, _) {});
    return (container: container, cloud: cloud);
  }

  test('listens only in the foreground while signed in', () async {
    final (:container, :cloud) = setUpWith();
    final live = container.read(liveSyncControllerProvider.notifier);
    expect(container.read(liveSyncControllerProvider), isFalse);

    live.setForeground(true);
    expect(container.read(liveSyncControllerProvider), isTrue);
    expect(cloud.signals.hasListener, isTrue);

    live.setForeground(false);
    await pumpEventQueue();
    expect(container.read(liveSyncControllerProvider), isFalse);
    expect(cloud.signals.hasListener, isFalse);
  });

  test('stops on sign-out and starts again on sign-in', () async {
    final (:container, :cloud) = setUpWith();
    container.read(liveSyncControllerProvider.notifier).setForeground(true);
    await pumpEventQueue();

    cloud.setSession(null);
    await pumpEventQueue();
    expect(container.read(liveSyncControllerProvider), isFalse);
    expect(cloud.signals.hasListener, isFalse);

    cloud.setSession(hemang);
    await pumpEventQueue();
    expect(container.read(liveSyncControllerProvider), isTrue);
    expect(cloud.signals.hasListener, isTrue);
  });

  test('never listens without a cloud configuration', () async {
    final (:container, :cloud) = setUpWith(configured: false);
    container.read(liveSyncControllerProvider.notifier).setForeground(true);
    await pumpEventQueue();
    expect(container.read(liveSyncControllerProvider), isFalse);
    expect(cloud.signals.hasListener, isFalse);
  });
}
