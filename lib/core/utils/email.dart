/// Email address helpers. Validation is deliberately pragmatic (one `@`, a
/// dotted domain, no spaces); the real check is the verification code sent
/// to the address.
abstract final class EmailAddresses {
  static final _pattern = RegExp(
    r'^[A-Za-z0-9.!#$%&*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}$',
  );

  /// Trimmed, lower-case address, or null when it is not a valid address.
  static String? normalize(String input) {
    final value = input.trim().toLowerCase();
    return _pattern.hasMatch(value) ? value : null;
  }

  static bool isValid(String input) => normalize(input) != null;
}
