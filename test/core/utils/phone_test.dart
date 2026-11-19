import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/utils/phone.dart';

void main() {
  test('10-digit Indian mobile gets +91', () {
    expect(PhoneNumbers.normalize('98765 43210'), '+919876543210');
    expect(PhoneNumbers.normalize('098765-43210'), '+919876543210');
  });

  test('keeps explicit country codes', () {
    expect(PhoneNumbers.normalize('+91 98765 43210'), '+919876543210');
    expect(PhoneNumbers.normalize('919876543210'), '+919876543210');
    expect(PhoneNumbers.normalize('+1 (415) 555-2671'), '+14155552671');
  });

  test('accepts Gujarati digits', () {
    expect(PhoneNumbers.normalize('૯૮૭૬૫૪૩૨૧૦'), '+919876543210');
  });

  test('rejects invalid numbers', () {
    expect(PhoneNumbers.normalize(''), isNull);
    expect(PhoneNumbers.normalize('12345'), isNull);
    expect(
      PhoneNumbers.normalize('5876543210'),
      isNull,
    ); // Indian mobiles start 6-9
    expect(PhoneNumbers.normalize('abc'), isNull);
  });

  test('formats for display', () {
    expect(PhoneNumbers.display('+919876543210'), '+91 98765 43210');
    expect(PhoneNumbers.display('+14155552671'), '+14155552671');
  });
}
