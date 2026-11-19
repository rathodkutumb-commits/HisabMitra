/// Phonetic English → Gujarati transliteration.
///
/// This is *not* character replacement: input is tokenised with longest
/// match into consonants, vowels and signs, then rebuilt into aksharas:
///  * a vowel after a consonant becomes a matra (dependent vowel sign),
///    `a` being the inherent vowel;
///  * two consonants in a row are joined with the virama (U+0ACD), which
///    the text shaper renders as a conjunct (ક + ્ + ર → ક્ર);
///  * a vowel at the start of a syllable is written as an independent vowel.
///
/// Scheme summary (case-sensitive; unknown capitals fall back to lowercase):
///   vowels  a aa/A i ii/ee/I u uu/oo/U Ru e ai o au
///   k kh g gh NG ch chh/Ch jh j NY T Th D Dh N t th d dh n
///   p ph/f b bh m y r l L v/w sh Sh s h ksh/x jn/GY
///   M or .n = anusvara (ં), H = visarga (ઃ), MM = candrabindu (ઁ)
library;

abstract final class GujaratiTransliterator {
  static const _virama = '્';

  static const Map<String, String> _consonants = {
    'k': 'ક',
    'kh': 'ખ',
    'g': 'ગ',
    'gh': 'ઘ',
    'NG': 'ઙ',
    'c': 'ચ',
    'ch': 'ચ',
    'chh': 'છ',
    'Ch': 'છ',
    'j': 'જ',
    'jh': 'ઝ',
    'z': 'ઝ',
    'NY': 'ઞ',
    'T': 'ટ',
    'Th': 'ઠ',
    'D': 'ડ',
    'Dh': 'ઢ',
    'N': 'ણ',
    't': 'ત',
    'th': 'થ',
    'd': 'દ',
    'dh': 'ધ',
    'n': 'ન',
    'p': 'પ',
    'ph': 'ફ',
    'f': 'ફ',
    'b': 'બ',
    'bh': 'ભ',
    'm': 'મ',
    'y': 'ય',
    'r': 'ર',
    'l': 'લ',
    'L': 'ળ',
    'v': 'વ',
    'w': 'વ',
    'sh': 'શ',
    'Sh': 'ષ',
    's': 'સ',
    'h': 'હ',
    'q': 'ક',
    'ksh': 'ક્ષ',
    'x': 'ક્ષ',
    'jn': 'જ્ઞ',
    'GY': 'જ્ઞ',
  };

  /// token → (independent vowel, matra). Matra '' = inherent `a`.
  static const Map<String, (String, String)> _vowels = {
    'a': ('અ', ''),
    'aa': ('આ', 'ા'),
    'A': ('આ', 'ા'),
    'i': ('ઇ', 'િ'),
    'ii': ('ઈ', 'ી'),
    'ee': ('ઈ', 'ી'),
    'I': ('ઈ', 'ી'),
    'u': ('ઉ', 'ુ'),
    'uu': ('ઊ', 'ૂ'),
    'oo': ('ઊ', 'ૂ'),
    'U': ('ઊ', 'ૂ'),
    'Ru': ('ઋ', 'ૃ'),
    'e': ('એ', 'ે'),
    'ai': ('ઐ', 'ૈ'),
    'o': ('ઓ', 'ો'),
    'au': ('ઔ', 'ૌ'),
  };

  static const Map<String, String> _signs = {
    'M': 'ં',
    '.n': 'ં',
    'H': 'ઃ',
    'MM': 'ઁ',
  };

  static final int _maxToken = [
    ..._consonants.keys,
    ..._vowels.keys,
    ..._signs.keys,
  ].fold(0, (m, k) => k.length > m ? k.length : m);

  static bool isLatinLetter(String ch) {
    if (ch.isEmpty) return false;
    final c = ch.codeUnitAt(0);
    return (c >= 0x41 && c <= 0x5A) || (c >= 0x61 && c <= 0x7A);
  }

  /// Transliterates a whole string; non-Latin characters pass through and
  /// terminate the current word.
  static String transliterate(String input) {
    final out = StringBuffer();
    var i = 0;
    var afterConsonant = false;
    while (i < input.length) {
      final match = _match(input, i);
      if (match == null) {
        // '.' only matters as part of '.n'; everything else passes through.
        out.write(input[i]);
        afterConsonant = false;
        i++;
        continue;
      }
      final (token, kind, value) = match;
      switch (kind) {
        case _Kind.consonant:
          if (afterConsonant) out.write(_virama);
          out.write(value);
          afterConsonant = true;
        case _Kind.vowel:
          final (independent, matra) = _vowels[value]!;
          out.write(afterConsonant ? matra : independent);
          afterConsonant = false;
        case _Kind.sign:
          out.write(value);
          afterConsonant = false;
      }
      i += token.length;
    }
    return out.toString();
  }

  static (String, _Kind, String)? _match(String s, int start) {
    return _matchCase(s, start, s) ?? _matchLower(s, start);
  }

  static (String, _Kind, String)? _matchLower(String s, int start) {
    if (!isLatinLetter(s[start])) return null;
    final lower = s.toLowerCase();
    return _matchCase(lower, start, lower);
  }

  static (String, _Kind, String)? _matchCase(String s, int start, String src) {
    for (var len = _maxToken; len >= 1; len--) {
      if (start + len > src.length) continue;
      final token = src.substring(start, start + len);
      final c = _consonants[token];
      if (c != null) return (token, _Kind.consonant, c);
      if (_vowels.containsKey(token)) return (token, _Kind.vowel, token);
      final sign = _signs[token];
      if (sign != null) return (token, _Kind.sign, sign);
    }
    return null;
  }
}

enum _Kind { consonant, vowel, sign }
