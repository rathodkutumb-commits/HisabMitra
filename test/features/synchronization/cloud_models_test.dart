import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/synchronization/domain/cloud_models.dart';

void main() {
  test('personal op JSON has no group id', () {
    const op = OutboundOp(
      opId: 'o1',
      groupId: '',
      scope: 'personal',
      entityType: 'person',
      entityId: 'p1',
      opType: 'upsert',
      baseRevision: 2,
      payload: {'name': 'Rahul Patel'},
    );
    final json = op.toJson();
    expect(json.containsKey('group_id'), isFalse);
    expect(json['op_id'], 'o1');
    expect(json['entity_type'], 'person');
    expect(json['entity_id'], 'p1');
    expect(json['op_type'], 'upsert');
    expect(json['base_revision'], 2);
    expect(json['payload'], {'name': 'Rahul Patel'});
  });

  test('group op JSON is unchanged', () {
    const op = OutboundOp(
      opId: 'o1',
      groupId: 'g1',
      entityType: 'expense',
      entityId: 'e1',
      opType: 'upsert',
      baseRevision: 0,
      payload: {},
    );
    expect(op.scope, 'group');
    expect(op.toJson()['group_id'], 'g1');
  });

  test('a personal reset event has no entity id', () {
    final e = RemoteEvent.fromJson(const {
      'seq': 7,
      'entity_type': 'all',
      'entity_id': null,
      'op_type': 'reset',
      'revision': 0,
      'payload': <String, Object?>{},
    }, scope: 'personal');
    expect(e.scope, 'personal');
    expect(e.groupId, '');
    expect(e.entityId, '');
    expect(e.opType, 'reset');
  });

  test('the personal snapshot keeps rows by kind and the feed position', () {
    final s = PersonalSnapshot.fromJson(const {
      'people': [
        {'id': 'p1', 'name': 'Rahul Patel'},
      ],
      'transactions': <Object?>[],
      'max_seq': 42,
    });
    expect(s.rows['people'], [
      {'id': 'p1', 'name': 'Rahul Patel'},
    ]);
    expect(s.rows['transactions'], isEmpty);
    expect(s.rows['reminders'], isEmpty);
    expect(s.maxSeq, 42);
  });
}
