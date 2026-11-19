import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/gujarati_input/domain/gujarati_transliterator.dart';
import 'package:hisabmitra/features/gujarati_input/domain/transliteration_formatter.dart';

String t(String s) => GujaratiTransliterator.transliterate(s);

void main() {
  group('words', () {
    test('common greetings', () {
      expect(t('kem chho'), 'કેમ છો');
      expect(t('majaamaa'), 'મજામા');
      expect(t('namaste'), 'નમસ્તે');
    });

    test('long vowels and matras', () {
      expect(t('aavak'), 'આવક');
      expect(t('kharch'), 'ખર્ચ');
      expect(t('hisaab'), 'હિસાબ');
      expect(t('mitra'), 'મિત્ર');
      expect(t('doodh'), 'દૂધ');
      expect(t('teen'), 'તીન');
      expect(t('paisaa'), 'પૈસા');
    });

    test('independent vowels at word start', () {
      expect(t('ek'), 'એક');
      expect(t('aam'), 'આમ');
      expect(t('ichchha'), 'ઇચ્છ');
      expect(t('aisho'), 'ઐશો');
      expect(t('auShadh'), 'ઔષધ');
    });

    test('conjuncts use the virama', () {
      expect(t('krishna'), 'ક્રિશ્ન');
      expect(t('kRuShNa'), 'કૃષ્ણ');
      expect(t('pravaas'), 'પ્રવાસ');
      expect(t('kshamaa'), 'ક્ષમા');
      expect(t('gnaan'), 'ગ્નાન');
      expect(t('jnaan'), 'જ્ઞાન');
    });

    test('retroflex consonants with capitals', () {
      expect(t('Taka'), 'ટક');
      expect(t('paDosi'), 'પડોસિ');
      expect(t('paaNii'), 'પાણી');
      expect(t('vaaL'), 'વાળ');
    });

    test('anusvara and visarga', () {
      expect(t('aMbaa'), 'અંબા');
      expect(t('duHkh'), 'દુઃખ');
    });

    test('rupee amount text keeps digits and punctuation', () {
      expect(t('rs 500, rokaD'), 'ર્સ 500, રોકડ');
    });

    test('unknown capitals fall back to lowercase', () {
      expect(t('Kem'), 'કેમ');
    });
  });

  group('as-you-type formatter', () {
    TextEditingValue type(
      TransliterationFormatter f,
      TextEditingValue value,
      String chars,
    ) {
      var current = value;
      for (final ch in chars.split('')) {
        final pos = current.selection.baseOffset < 0
            ? current.text.length
            : current.selection.baseOffset;
        final next = TextEditingValue(
          text:
              current.text.substring(0, pos) + ch + current.text.substring(pos),
          selection: TextSelection.collapsed(offset: pos + 1),
        );
        current = f.formatEditUpdate(current, next);
      }
      return current;
    }

    TextEditingValue backspace(
      TransliterationFormatter f,
      TextEditingValue current,
    ) {
      final pos = current.selection.baseOffset;
      final next = TextEditingValue(
        text: current.text.substring(0, pos - 1) + current.text.substring(pos),
        selection: TextSelection.collapsed(offset: pos - 1),
      );
      return f.formatEditUpdate(current, next);
    }

    test('converts the word being typed', () {
      final f = TransliterationFormatter();
      final v = type(f, TextEditingValue.empty, 'kem chho');
      expect(v.text, 'કેમ છો');
      expect(v.selection.baseOffset, v.text.length);
    });

    test('backspace removes the last Latin letter of the composing word', () {
      final f = TransliterationFormatter();
      var v = type(f, TextEditingValue.empty, 'kaam');
      expect(v.text, 'કામ');
      v = backspace(f, v);
      expect(v.text, 'કા');
      v = type(f, v, 'r');
      expect(v.text, 'કાર');
    });

    test('typing in the middle of existing text starts a new word there', () {
      final f = TransliterationFormatter();
      var v = type(f, TextEditingValue.empty, 'ram ');
      v = v.copyWith(selection: const TextSelection.collapsed(offset: 0));
      f.reset();
      v = type(f, v, 'shree ');
      expect(v.text, 'શ્રી રમ ');
    });

    test('pasting text is left untouched', () {
      final f = TransliterationFormatter();
      const pasted = TextEditingValue(
        text: 'hello world',
        selection: TextSelection.collapsed(offset: 11),
      );
      expect(
        f.formatEditUpdate(TextEditingValue.empty, pasted).text,
        'hello world',
      );
    });

    test('Gujarati typed directly is preserved', () {
      final f = TransliterationFormatter();
      final v = type(f, TextEditingValue.empty, 'ગુજરાત');
      expect(v.text, 'ગુજરાત');
    });
  });
}
