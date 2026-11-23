import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/synchronization/data/supabase_cloud_gateway.dart';

void main() {
  test('every live-update connection gets its own channel', () {
    // A quick pause/resume opens a new channel while the old one is still
    // being removed; the same name would let the old one's leave close it.
    final first = SupabaseCloudGateway.feedTopic('user-1');
    final second = SupabaseCloudGateway.feedTopic('user-1');
    expect(first, startsWith('feeds:user-1'));
    expect(second, isNot(first));
  });

  test('live updates listen to all three feeds', () {
    expect(SupabaseCloudGateway.liveFeeds, [
      'sync_events',
      'personal_sync_events',
      'family_sync_events',
    ]);
  });
}
