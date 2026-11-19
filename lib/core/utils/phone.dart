/// Phone number normalisation to E.164. Indian numbers are the default:
/// a bare 10-digit mobile starting with 6–9 becomes `+91XXXXXXXXXX`.
abstract final class PhoneNumbers {
  static String? normalize(String input) {
    final buffer = StringBuffer();
    var hasPlus = false;
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.writeCharCode(rune);
      } else if (rune >= 0x0AE6 && rune <= 0x0AEF) {
        buffer.writeCharCode(0x30 + rune - 0x0AE6);
      } else if (rune == 0x2B && buffer.isEmpty) {
        hasPlus = true;
      } else if (' -()./'.runes.contains(rune)) {
        continue;
      } else {
        return null;
      }
    }
    var digits = buffer.toString();
    if (digits.isEmpty) return null;

    if (hasPlus) {
      if (digits.startsWith('91')) return _indian(digits.substring(2));
      return digits.length >= 8 && digits.length <= 15 ? '+$digits' : null;
    }
    if (digits.length == 12 && digits.startsWith('91')) {
      return _indian(digits.substring(2));
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      digits = digits.substring(1);
    }
    return _indian(digits);
  }

  static String? _indian(String tenDigits) {
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(tenDigits)) return null;
    return '+91$tenDigits';
  }

  static bool isValid(String input) => normalize(input) != null;

  static String display(String e164) {
    if (e164.startsWith('+91') && e164.length == 13) {
      return '+91 ${e164.substring(3, 8)} ${e164.substring(8)}';
    }
    return e164;
  }
}
