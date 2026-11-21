final _code = RegExp(r'^[A-Z0-9]{6,12}$');

/// The invitation code in its canonical form (trimmed, upper-case), or null
/// when [raw] is not 6–12 letters/digits. Used for codes typed in and for
/// codes that arrive in an invitation link.
String? normalizeInviteCode(String? raw) {
  final code = raw?.trim().toUpperCase() ?? '';
  return _code.hasMatch(code) ? code : null;
}
