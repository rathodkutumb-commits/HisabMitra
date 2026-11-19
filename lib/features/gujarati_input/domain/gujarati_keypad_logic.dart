/// Pure logic behind HisabMitra's on-screen Gujarati keypad.
///
/// The keypad shows two rows of context-sensitive suggestions above the
/// consonant keys:
///  * right after a consonant (e.g. ક) — its barakhadi: કા કિ કી … કં કઃ,
///    the half form ક્ (to build conjuncts such as પુણ્ય or હર્ષ), the
///    ra-conjunct ક્ર and the English-loanword forms કૅ કૉ;
///  * anywhere else — the independent vowels અ આ ઇ … and a key that adds
///    anusvara (ં) to the previous syllable.
///
/// Tapping a suggestion inserts only the sign (matra, virama, …); the
/// consonant is already in the text. Unicode shaping then composes the
/// syllable, so the stored text is standard Gujarati Unicode.
library;

enum SuggestionKind { barakhadi, vowels }

class KeypadSuggestion {
  const KeypadSuggestion({
    required this.label,
    required this.insert,
    this.enabled = true,
  });

  /// What the key shows, e.g. "કા".
  final String label;

  /// What the key inserts at the cursor, e.g. "ા".
  final String insert;
  final bool enabled;

  @override
  String toString() => 'KeypadSuggestion($label → $insert, enabled: $enabled)';
}

class KeypadSuggestions {
  const KeypadSuggestions(this.kind, this.items);

  final SuggestionKind kind;

  /// Always [GujaratiKeypadLogic.suggestionCount] items, so the keypad's
  /// height never jumps while typing.
  final List<KeypadSuggestion> items;
}

abstract final class GujaratiKeypadLogic {
  static const virama = '્';
  static const anusvara = 'ં';

  static const suggestionCount = 16;

  /// Signs offered after a consonant, in barakhadi order, then the half
  /// form, the ra-conjunct, vocalic r and the candra e / candra o used in
  /// English loanwords (બૅંક, કૉલેજ).
  static const barakhadiSigns = [
    'ા', 'િ', 'ી', 'ુ', 'ૂ', 'ે', 'ૈ', 'ો', //
    'ૌ', 'ં', 'ઃ', virama, '$viramaર', 'ૃ', 'ૅ', 'ૉ',
  ];

  /// Independent vowels (the 16th slot is the anusvara key).
  static const vowels = [
    'અ', 'આ', 'ઇ', 'ઈ', 'ઉ', 'ઊ', 'એ', 'ઐ', //
    'ઓ', 'ઔ', 'અં', 'અઃ', 'ઋ', 'ઍ', 'ઑ',
  ];

  // Gujarati consonants ક (U+0A95) … હ (U+0AB9), skipping unassigned
  // code points, plus ૹ (U+0AF9).
  static bool isConsonant(int cp) =>
      (cp >= 0x0A95 && cp <= 0x0AA8) ||
      (cp >= 0x0AAA && cp <= 0x0AB0) ||
      cp == 0x0AB2 ||
      cp == 0x0AB3 ||
      (cp >= 0x0AB5 && cp <= 0x0AB9) ||
      cp == 0x0AF9;

  /// Independent vowels અ (U+0A85) … ઔ (U+0A94), plus ૠ ૡ.
  static bool isIndependentVowel(int cp) =>
      (cp >= 0x0A85 && cp <= 0x0A94) || cp == 0x0AE0 || cp == 0x0AE1;

  /// Vowel signs (matras) ા … ૌ, plus ૢ ૣ.
  static bool isVowelSign(int cp) =>
      (cp >= 0x0ABE && cp <= 0x0ACC) || cp == 0x0AE2 || cp == 0x0AE3;

  /// The consonant or conjunct at the end of [before] when it carries no
  /// vowel sign yet ("લક્ષ" → "ક્ષ", "કા" → null).
  static String? trailingBareCluster(String before) {
    final cps = before.runes.toList();
    if (cps.isEmpty || !isConsonant(cps.last)) return null;
    var start = cps.length - 1;
    // Walk back over "consonant + virama" pairs: સ્ત્ર = સ ્ ત ્ ર.
    while (start >= 2 &&
        cps[start - 1] == virama.runes.first &&
        isConsonant(cps[start - 2])) {
      start -= 2;
    }
    return String.fromCharCodes(cps.sublist(start));
  }

  /// The syllable at the end of [before] that can still take an anusvara:
  /// a consonant cluster or an independent vowel, optionally followed by a
  /// vowel sign ("ગા", "અ", "મે"). Null after a space, a virama or an
  /// existing anusvara/visarga.
  static String? _syllableForAnusvara(String before) {
    final cps = before.runes.toList();
    if (cps.isEmpty) return null;
    final end = cps.length;
    var start = end - 1;
    if (isVowelSign(cps[start])) start--;
    if (start < 0) return null;
    if (isIndependentVowel(cps[start])) {
      return String.fromCharCodes(cps.sublist(start, end));
    }
    if (!isConsonant(cps[start])) return null;
    final cluster = trailingBareCluster(
      String.fromCharCodes(cps.sublist(0, start + 1)),
    );
    final clusterLength = cluster!.runes.length;
    return String.fromCharCodes(cps.sublist(start + 1 - clusterLength, end));
  }

  /// Suggestions for the text before the cursor. [forceVowels] shows the
  /// vowels even right after a consonant (for words like ગઈ, થઈ).
  static KeypadSuggestions suggestionsFor(
    String before, {
    bool forceVowels = false,
  }) {
    final cluster = trailingBareCluster(before);
    if (cluster != null && !forceVowels) {
      return KeypadSuggestions(SuggestionKind.barakhadi, [
        for (final sign in barakhadiSigns)
          KeypadSuggestion(label: '$cluster$sign', insert: sign),
      ]);
    }
    final syllable = _syllableForAnusvara(before);
    return KeypadSuggestions(SuggestionKind.vowels, [
      for (final v in vowels) KeypadSuggestion(label: v, insert: v),
      KeypadSuggestion(
        label: syllable == null ? '◌$anusvara' : '$syllable$anusvara',
        insert: anusvara,
        enabled: syllable != null,
      ),
    ]);
  }
}
