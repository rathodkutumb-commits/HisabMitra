import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/groups/domain/invite_code.dart';

void main() {
  test('codes are trimmed and upper-cased', () {
    expect(normalizeInviteCode(' hsqpp7g9vd '), 'HSQPP7G9VD');
  });

  test('6 to 12 letters or digits are accepted', () {
    expect(normalizeInviteCode('CODE01'), 'CODE01');
    expect(normalizeInviteCode('ABCDEF123456'), 'ABCDEF123456');
  });

  test('anything else is not a code', () {
    for (final raw in [
      null,
      '',
      'AB12',
      'ABCDEFGHIJKLM',
      'AB-123',
      'ABC 123',
      'ABC<1>23',
    ]) {
      expect(normalizeInviteCode(raw), isNull, reason: '$raw');
    }
  });
}
