import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_preferences.dart';
import '../domain/transliteration_formatter.dart';
import 'gujarati_keypad.dart';

/// Text field honouring the user's Gujarati typing preference:
///  * system — the phone keyboard (any language the user installed);
///  * transliteration — type phonetically in English, see Gujarati;
///  * keypad — HisabMitra's on-screen Gujarati keypad.
/// A small toggle lets the user switch this field back to the phone
/// keyboard at any time, so the system keyboard always remains available.
class GujaratiTextField extends ConsumerStatefulWidget {
  const GujaratiTextField({
    super.key,
    required this.controller,
    this.decoration = const InputDecoration(),
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction,
    this.onChanged,
    this.validator,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final InputDecoration decoration;
  final int maxLines;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool autofocus;

  @override
  ConsumerState<GujaratiTextField> createState() => _GujaratiTextFieldState();
}

class _GujaratiTextFieldState extends ConsumerState<GujaratiTextField> {
  final _focus = FocusNode();
  final _formatter = TransliterationFormatter();
  bool _forceSystem = false;
  PersistentBottomSheetController? _keypad;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  GujaratiInputMode get _mode => _forceSystem
      ? GujaratiInputMode.system
      : ref.read(settingsControllerProvider).gujaratiInputMode;

  void _onFocus() {
    if (_focus.hasFocus) {
      _formatter.reset();
      if (_mode == GujaratiInputMode.keypad) _openKeypad();
    } else {
      _closeKeypad();
    }
  }

  void _openKeypad() {
    if (_keypad != null) return;
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold == null) return;
    _keypad = scaffold.showBottomSheet(
      (ctx) => GujaratiKeypad(
        controller: widget.controller,
        onChanged: (v) => widget.onChanged?.call(v),
        onClose: () => _focus.unfocus(),
      ),
      enableDrag: false,
    );
    _keypad!.closed.then((_) => _keypad = null);
    // The keypad sheet overlays the bottom of the screen; move the field
    // near the top so it stays visible while typing.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.1,
        duration: const Duration(milliseconds: 200),
      );
    });
  }

  void _closeKeypad() {
    _keypad?.close();
    _keypad = null;
  }

  @override
  Widget build(BuildContext context) {
    final globalMode = ref.watch(settingsControllerProvider).gujaratiInputMode;
    final mode = _forceSystem ? GujaratiInputMode.system : globalMode;
    final transliterate = mode == GujaratiInputMode.transliteration;
    final keypad = mode == GujaratiInputMode.keypad;

    final toggle = globalMode == GujaratiInputMode.system
        ? null
        : IconButton(
            tooltip: _forceSystem ? 'ગુજરાતી' : 'ABC',
            icon: Text(
              _forceSystem ? 'અ' : 'A',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            onPressed: () {
              setState(() => _forceSystem = !_forceSystem);
              _formatter.reset();
              if (_forceSystem) {
                _closeKeypad();
              } else if (_focus.hasFocus &&
                  globalMode == GujaratiInputMode.keypad) {
                _openKeypad();
              }
            },
          );

    return TextFormField(
      controller: widget.controller,
      focusNode: _focus,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: 1,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      readOnly: keypad,
      showCursor: true,
      autocorrect: !transliterate,
      enableSuggestions: !transliterate,
      keyboardType: transliterate
          ? (widget.maxLines == 1
                ? TextInputType.visiblePassword
                : TextInputType.multiline)
          : (widget.maxLines == 1
                ? TextInputType.text
                : TextInputType.multiline),
      textCapitalization: TextCapitalization.none,
      inputFormatters: [
        if (transliterate) _formatter,
        if (widget.maxLength != null)
          LengthLimitingTextInputFormatter(widget.maxLength),
      ],
      decoration: widget.decoration.copyWith(
        suffixIcon: toggle ?? widget.decoration.suffixIcon,
      ),
      onTap: () {
        if (keypad) _openKeypad();
      },
      onChanged: widget.onChanged,
      validator: widget.validator,
    );
  }
}
