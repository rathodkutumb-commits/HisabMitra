import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/gujarati_input/domain/gujarati_keypad_logic.dart';

List<String> _labels(KeypadSuggestions s) => [for (final i in s.items) i.label];

void main() {
  group('trailingBareCluster', () {
    test('a single consonant', () {
      expect(GujaratiKeypadLogic.trailingBareCluster('ક'), 'ક');
      expect(GujaratiKeypadLogic.trailingBareCluster('રામ'), 'મ');
    });

    test('a conjunct made with the virama', () {
      expect(GujaratiKeypadLogic.trailingBareCluster('લક્ષ'), 'ક્ષ');
      expect(GujaratiKeypadLogic.trailingBareCluster('સ્ત્ર'), 'સ્ત્ર');
    });

    test(
      'nothing when the last letter already has a sign or is not a consonant',
      () {
        expect(GujaratiKeypadLogic.trailingBareCluster(''), isNull);
        expect(GujaratiKeypadLogic.trailingBareCluster('કા'), isNull);
        expect(GujaratiKeypadLogic.trailingBareCluster('ક્'), isNull);
        expect(GujaratiKeypadLogic.trailingBareCluster('અ'), isNull);
        expect(GujaratiKeypadLogic.trailingBareCluster('ક '), isNull);
        expect(GujaratiKeypadLogic.trailingBareCluster('abc'), isNull);
      },
    );
  });

  group('suggestionsFor', () {
    test('after a consonant: its barakhadi, half form and ra-conjunct', () {
      final s = GujaratiKeypadLogic.suggestionsFor('ક');
      expect(s.kind, SuggestionKind.barakhadi);
      expect(_labels(s), [
        'કા', 'કિ', 'કી', 'કુ', 'કૂ', 'કે', 'કૈ', 'કો', //
        'કૌ', 'કં', 'કઃ', 'ક્', 'ક્ર', 'કૃ', 'કૅ', 'કૉ',
      ]);
      // Tapping only adds the sign; the consonant is already typed.
      expect(s.items.first.insert, 'ા');
      expect(s.items[11].insert, '્');
      expect(s.items[12].insert, '્ર');
      expect(s.items.every((i) => i.enabled), isTrue);
    });

    test('barakhadi labels use the whole conjunct', () {
      final s = GujaratiKeypadLogic.suggestionsFor('લક્ષ');
      expect(s.items.first.label, 'ક્ષા');
      expect(s.items.first.insert, 'ા');
    });

    test('at the start, after a space or a sign: the vowels', () {
      for (final before in ['', 'ભા', 'હર ', 'ક્']) {
        final s = GujaratiKeypadLogic.suggestionsFor(before);
        expect(s.kind, SuggestionKind.vowels, reason: before);
        expect(_labels(s).take(15), [
          'અ', 'આ', 'ઇ', 'ઈ', 'ઉ', 'ઊ', 'એ', 'ઐ', //
          'ઓ', 'ઔ', 'અં', 'અઃ', 'ઋ', 'ઍ', 'ઑ',
        ]);
      }
    });

    test('vowels can be forced after a consonant (ગ + ઈ = ગઈ)', () {
      final s = GujaratiKeypadLogic.suggestionsFor('ગ', forceVowels: true);
      expect(s.kind, SuggestionKind.vowels);
      expect(s.items.firstWhere((i) => i.label == 'ઈ').insert, 'ઈ');
    });

    test('the last vowel key adds anusvara to the previous syllable', () {
      final afterMatra = GujaratiKeypadLogic.suggestionsFor('ગા').items.last;
      expect(afterMatra.label, 'ગાં');
      expect(afterMatra.insert, 'ં');
      expect(afterMatra.enabled, isTrue);

      final afterVowel = GujaratiKeypadLogic.suggestionsFor('અ').items.last;
      expect(afterVowel.label, 'અં');
      expect(afterVowel.enabled, isTrue);

      for (final before in ['', 'ક ', 'ક્', 'ગાં', '12']) {
        final s = GujaratiKeypadLogic.suggestionsFor(before);
        expect(s.items.last.enabled, isFalse, reason: before);
        expect(s.items.last.insert, 'ં');
      }
    });
  });

  group('typing whole words by tapping keys and suggestions', () {
    // Simulates the keypad: grid keys insert letters, suggestions insert
    // their sign — exactly what the widget does.
    String type(List<String> taps) {
      var text = '';
      for (final tap in taps) {
        final s = GujaratiKeypadLogic.suggestionsFor(text);
        final hit = s.items.where((i) => i.label == tap);
        text += hit.isEmpty ? tap : hit.first.insert;
      }
      return text;
    }

    test('પુણ્ય (punya) with a half ણ', () {
      expect(type(['પ', 'પુ', 'ણ', 'ણ્', 'ય']), 'પુણ્ય');
    });

    test('હર્ષ (harsh) with a half ર', () {
      expect(type(['હ', 'ર', 'ર્', 'ષ']), 'હર્ષ');
    });

    test('પ્રકાશ with the ra-conjunct shortcut', () {
      expect(type(['પ', 'પ્ર', 'ક', 'કા', 'શ']), 'પ્રકાશ');
    });

    test('ભાઈ and મેં', () {
      expect(type(['ભ', 'ભા', 'ઈ']), 'ભાઈ');
      expect(type(['મ', 'મે', 'મેં']), 'મેં');
    });
  });
}
