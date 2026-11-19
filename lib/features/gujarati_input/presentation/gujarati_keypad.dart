import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/gujarati_keypad_logic.dart';

/// On-screen Gujarati keypad.
///
/// Layout (one page for all letters — no switching between consonants and
/// matras):
///  * two suggestion rows that follow the cursor: after a consonant they show
///    its barakhadi (કા કિ કી … ક્ ક્ર), otherwise the vowels (અ આ ઇ …);
///  * four rows of consonants and conjuncts;
///  * a bottom row: symbols, vowels, space, backspace, hide.
///
/// Keys insert Unicode at the cursor; the text engine shapes matras and
/// conjuncts (consonant + ્ + consonant). See [GujaratiKeypadLogic].
class GujaratiKeypad extends StatefulWidget {
  const GujaratiKeypad({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClose,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClose;

  static const vowelsKey = ValueKey('hm-keypad-vowels');
  static const symbolsKey = ValueKey('hm-keypad-symbols');
  static const spaceKey = ValueKey('hm-keypad-space');
  static const backspaceKey = ValueKey('hm-keypad-backspace');
  static const closeKey = ValueKey('hm-keypad-close');

  static const letterRows = [
    ['ક', 'ખ', 'ગ', 'ઘ', 'ઙ', 'ચ', 'છ', 'જ', 'ઝ', 'ઞ'],
    ['ટ', 'ઠ', 'ડ', 'ઢ', 'ણ', 'ત', 'થ', 'દ', 'ધ', 'ન'],
    ['પ', 'ફ', 'બ', 'ભ', 'મ', 'ય', 'ર', 'લ', 'વ', 'શ'],
    ['ષ', 'સ', 'હ', 'ળ', 'ક્ષ', 'જ્ઞ', 'ત્ર', 'શ્ર', ',', '.'],
  ];

  static const symbolRows = [
    ['૧', '૨', '૩', '૪', '૫', '૬', '૭', '૮', '૯', '૦'],
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['₹', '-', '/', ':', ';', '(', ')', "'", '"', '!'],
    ['@', '#', '%', '&', '+', '=', '*', '?', '_', '।'],
  ];

  @override
  State<GujaratiKeypad> createState() => _GujaratiKeypadState();
}

class _GujaratiKeypadState extends State<GujaratiKeypad> {
  static const _suggestionHeight = 42.0;
  static const _keyHeight = 46.0;

  var _symbols = false;
  var _forceVowels = false;
  Timer? _repeat;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(GujaratiKeypad old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
    }
  }

  @override
  void dispose() {
    _repeat?.cancel();
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  // Rebuild when the text or cursor changes (also when the user moves the
  // cursor by tapping the field), so the suggestions follow the cursor.
  void _onText() {
    if (mounted) setState(() {});
  }

  TextSelection get _selection {
    final c = widget.controller;
    return c.selection.isValid
        ? c.selection
        : TextSelection.collapsed(offset: c.text.length);
  }

  String get _textBeforeCursor =>
      widget.controller.text.substring(0, _selection.start);

  void _insert(String s) {
    HapticFeedback.selectionClick();
    final c = widget.controller;
    final sel = _selection;
    final text = c.text.replaceRange(sel.start, sel.end, s);
    _forceVowels = false;
    c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: sel.start + s.length),
    );
    widget.onChanged?.call(text);
  }

  void _backspace() {
    final c = widget.controller;
    final sel = _selection;
    if (!sel.isCollapsed) {
      _insert('');
      return;
    }
    if (sel.start == 0) return;
    HapticFeedback.selectionClick();
    // Remove one code unit: in Gujarati each matra/virama is its own code
    // point, so the user can correct a single sign (કા → ક).
    final text = c.text.replaceRange(sel.start - 1, sel.start, '');
    _forceVowels = false;
    c.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: sel.start - 1),
    );
    widget.onChanged?.call(text);
  }

  void _startRepeat() {
    _repeat?.cancel();
    _repeat = Timer.periodic(
      const Duration(milliseconds: 80),
      (_) => _backspace(),
    );
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final suggestions = GujaratiKeypadLogic.suggestionsFor(
      _textBeforeCursor,
      forceVowels: _forceVowels,
    );
    final canShowVowels =
        suggestions.kind == SuggestionKind.barakhadi || _forceVowels;
    final rows = _symbols
        ? GujaratiKeypad.symbolRows
        : GujaratiKeypad.letterRows;

    return Material(
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SuggestionRows(
                suggestions: suggestions,
                height: _suggestionHeight,
                onTap: (s) => _insert(s.insert),
              ),
              const SizedBox(height: 4),
              for (final row in rows)
                SizedBox(
                  height: _keyHeight,
                  child: Row(
                    children: [
                      for (final k in row)
                        Expanded(
                          child: _Key(
                            label: k,
                            semanticLabel: k,
                            onTap: () => _insert(k),
                          ),
                        ),
                    ],
                  ),
                ),
              SizedBox(
                height: _keyHeight,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _Key(
                        key: GujaratiKeypad.symbolsKey,
                        label: _symbols ? 'કખગ' : '૧૨૩',
                        semanticLabel: _symbols ? 'કખગ' : '૧૨૩ ₹',
                        tonal: true,
                        fontSize: 15,
                        onTap: () => setState(() => _symbols = !_symbols),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _Key(
                        key: GujaratiKeypad.vowelsKey,
                        label: _forceVowels ? 'કા કિ' : 'અ આ',
                        semanticLabel: _forceVowels ? 'કા કિ' : 'અ આ',
                        tonal: true,
                        fontSize: 15,
                        onTap: canShowVowels
                            ? () => setState(() => _forceVowels = !_forceVowels)
                            : null,
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: _Key(
                        key: GujaratiKeypad.spaceKey,
                        icon: Icons.space_bar_rounded,
                        semanticLabel: 'Space',
                        tonal: true,
                        onTap: () => _insert(' '),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onLongPressStart: (_) => _startRepeat(),
                        onLongPressEnd: (_) => _stopRepeat(),
                        onLongPressCancel: _stopRepeat,
                        child: _Key(
                          key: GujaratiKeypad.backspaceKey,
                          icon: Icons.backspace_outlined,
                          semanticLabel: 'Backspace',
                          tonal: true,
                          onTap: _backspace,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _Key(
                        key: GujaratiKeypad.closeKey,
                        icon: Icons.keyboard_hide_rounded,
                        semanticLabel: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        tonal: true,
                        onTap: widget.onClose,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two rows of eight suggestion chips.
class _SuggestionRows extends StatelessWidget {
  const _SuggestionRows({
    required this.suggestions,
    required this.height,
    required this.onTap,
  });

  final KeypadSuggestions suggestions;
  final double height;
  final ValueChanged<KeypadSuggestion> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final barakhadi = suggestions.kind == SuggestionKind.barakhadi;
    final items = suggestions.items;
    final perRow = (items.length / 2).ceil();
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: barakhadi ? scheme.primaryContainer : scheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          for (var r = 0; r < 2; r++)
            SizedBox(
              height: height,
              child: Row(
                children: [
                  for (var i = r * perRow; i < (r + 1) * perRow; i++)
                    Expanded(
                      child: i < items.length
                          ? _Key(
                              label: items[i].label,
                              semanticLabel: items[i].label,
                              fontSize: 19,
                              emphasis: barakhadi,
                              onTap: items[i].enabled
                                  ? () => onTap(items[i])
                                  : null,
                            )
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    super.key,
    this.label,
    this.icon,
    required this.semanticLabel,
    required this.onTap,
    this.tonal = false,
    this.emphasis = false,
    this.fontSize = 20,
  });

  final String? label;
  final IconData? icon;
  final String semanticLabel;
  final VoidCallback? onTap;
  final bool tonal;
  final bool emphasis;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    final fg = !enabled
        ? scheme.onSurface.withValues(alpha: 0.3)
        : emphasis
        ? scheme.onPrimaryContainer
        : scheme.onSurface;
    final bg = tonal ? scheme.secondaryContainer : scheme.surface;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: semanticLabel,
        excludeSemantics: true,
        child: Material(
          color: emphasis ? scheme.surface.withValues(alpha: 0.85) : bg,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Center(
              child: icon != null
                  ? Icon(icon, size: 22, color: fg)
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          label!,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: fontSize,
                            height: 1.2,
                            fontFamily: 'NotoSansGujarati',
                            fontWeight: emphasis
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: fg,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
