import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/utils/email.dart';

void main() {
  test('normalises case and spaces', () {
    expect(
      EmailAddresses.normalize('  Hemang.Rathod@Gmail.com '),
      'hemang.rathod@gmail.com',
    );
  });

  test('accepts common addresses', () {
    for (final ok in [
      'a@b.in',
      'hemang+hisab@example.co.in',
      'first.last@sub.domain.org',
      'user_99@mail-host.com',
    ]) {
      expect(EmailAddresses.isValid(ok), isTrue, reason: ok);
    }
  });

  test('rejects malformed addresses', () {
    for (final bad in [
      '',
      'hemang',
      'hemang@',
      '@gmail.com',
      'hemang@gmail',
      'hemang @gmail.com',
      'hemang@@gmail.com',
      'hemang@gmail.c',
      'hemang@.com',
    ]) {
      expect(EmailAddresses.isValid(bad), isFalse, reason: bad);
      expect(EmailAddresses.normalize(bad), isNull, reason: bad);
    }
  });
}
