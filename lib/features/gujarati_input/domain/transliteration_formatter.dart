import 'package:flutter/services.dart';

import 'gujarati_transliterator.dart';

/// As-you-type transliteration.
///
/// Keeps the Latin letters of the word currently being typed (the
/// "composing word") and re-renders that word in Gujarati on every
/// keystroke, so that multi-letter tokens like `kh`, `aa` or conjuncts form
/// correctly. Any other edit (space, punctuation, cursor move, paste,
/// Gujarati text) ends the composing word and is passed through unchanged.
class TransliterationFormatter extends TextInputFormatter {
  String _latin = '';
  int _start = 0;
  int _length = 0;

  void reset() {
    _latin = '';
    _length = 0;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // An empty field that was never focused reports offset -1.
    final oldCursor = oldValue.selection.baseOffset < 0 && oldValue.text.isEmpty
        ? 0
        : oldValue.selection.baseOffset;
    final newCursor = newValue.selection.baseOffset;
    final collapsed =
        (oldValue.selection.isCollapsed || oldValue.text.isEmpty) &&
        newValue.selection.isCollapsed;
    if (!collapsed || oldCursor < 0 || newCursor < 0) {
      reset();
      return newValue;
    }

    final atComposingEnd = _latin.isNotEmpty && oldCursor == _start + _length;

    // Single character inserted at the cursor.
    if (newValue.text.length == oldValue.text.length + 1 &&
        newCursor == oldCursor + 1) {
      final inserted = newValue.text.substring(oldCursor, newCursor);
      final continuesDotN = inserted == 'n' && _latin.endsWith('.');
      if (!GujaratiTransliterator.isLatinLetter(inserted) &&
          !(inserted == '.' && atComposingEnd)) {
        reset();
        return newValue;
      }
      if (!atComposingEnd && !continuesDotN) {
        _latin = '';
        _start = oldCursor;
        _length = 0;
      }
      _latin += inserted;
      return _render(oldValue.text);
    }

    // Backspace at the end of the composing word.
    if (atComposingEnd &&
        newValue.text.length < oldValue.text.length &&
        newCursor < oldCursor &&
        newCursor >= _start) {
      _latin = _latin.substring(0, _latin.length - 1);
      if (_latin.isEmpty) {
        final text = oldValue.text.replaceRange(_start, _start + _length, '');
        reset();
        return TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: _start),
        );
      }
      return _render(oldValue.text);
    }

    reset();
    return newValue;
  }

  TextEditingValue _render(String baseText) {
    final gujarati = GujaratiTransliterator.transliterate(_latin);
    final text = baseText.replaceRange(_start, _start + _length, gujarati);
    _length = gujarati.length;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: _start + _length),
    );
  }
}
