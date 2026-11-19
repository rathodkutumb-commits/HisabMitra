import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../settings/application/settings_controller.dart';
import '../domain/calculator_engine.dart';

/// Opens the calculator as a bottom sheet and returns the chosen amount in
/// paise (or null if dismissed).
Future<int?> showCalculatorSheet(BuildContext context, {int? initialPaise}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: CalculatorPanel(
        initialPaise: initialPaise,
        onUse: (paise) => Navigator.of(ctx).pop(paise),
      ),
    ),
  );
}

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.calculatorTitle)),
      body: const SafeArea(child: CalculatorPanel()),
    );
  }
}

class CalculatorPanel extends ConsumerStatefulWidget {
  const CalculatorPanel({super.key, this.initialPaise, this.onUse});

  final int? initialPaise;

  /// When provided a "Use amount" button returns the result to the caller.
  final ValueChanged<int>? onUse;

  @override
  ConsumerState<CalculatorPanel> createState() => _CalculatorPanelState();
}

class _CalculatorPanelState extends ConsumerState<CalculatorPanel> {
  var _expression = '';
  var _mode = 0; // 0 basic, 1 price × qty
  final _price = TextEditingController();
  final _qty = TextEditingController(text: '1');
  int? _unitResult;

  @override
  void initState() {
    super.initState();
    if (widget.initialPaise != null && widget.initialPaise! > 0) {
      _expression = Money.toEditable(widget.initialPaise!);
      _price.text = _expression;
      _recalcUnit();
    }
  }

  @override
  void dispose() {
    _price.dispose();
    _qty.dispose();
    super.dispose();
  }

  int? get _basicResult => CalculatorEngine.evaluateToPaise(_expression);

  void _press(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      switch (key) {
        case 'C':
          _expression = '';
        case '⌫':
          if (_expression.isNotEmpty) {
            _expression = _expression.substring(0, _expression.length - 1);
          }
        case '=':
          final r = _basicResult;
          if (r != null) _expression = Money.toEditable(r);
        default:
          if (_expression.length < 60) _expression += key;
      }
    });
  }

  void _recalcUnit() {
    final price = Money.tryParse(_price.text);
    setState(() {
      _unitResult = price == null
          ? null
          : CalculatorEngine.unitTotal(
              unitPricePaise: price,
              quantity: _qty.text,
            );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final autoCalc = ref.watch(settingsControllerProvider).calculatorAutoCalc;
    final result = _mode == 0 ? _basicResult : _unitResult;
    final resultText = result == null ? '—' : ref.fmt.money(result);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SegmentedButton<int>(
            segments: [
              ButtonSegment(
                value: 0,
                label: Text(l.calculatorBasic),
                icon: const Icon(Icons.calculate_outlined),
              ),
              ButtonSegment(
                value: 1,
                label: Text(l.calculatorUnit),
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            ],
            selected: {_mode},
            onSelectionChanged: (s) => setState(() => _mode = s.first),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_mode == 0)
                Text(
                  _expression.isEmpty ? '0' : _expression,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.end,
                ),
              const SizedBox(height: 4),
              Semantics(
                liveRegion: true,
                child: Text(
                  result == null && _expression.isNotEmpty && _mode == 0
                      ? l.calculatorInvalid
                      : resultText,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_mode == 0)
          _Keypad(onKey: _press)
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                TextField(
                  controller: _price,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l.unitPrice,
                    prefixText: '₹ ',
                  ),
                  onChanged: (_) => autoCalc ? _recalcUnit() : null,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _qty,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: l.quantity,
                    prefixIcon: const Icon(Icons.close_rounded),
                  ),
                  onChanged: (_) => autoCalc ? _recalcUnit() : null,
                ),
                if (!autoCalc) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _recalcUnit,
                    icon: const Icon(Icons.drag_handle_rounded),
                    label: const Text('='),
                  ),
                ],
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: result == null
                      ? null
                      : () {
                          Clipboard.setData(
                            ClipboardData(text: Money.toEditable(result)),
                          );
                          ScaffoldMessenger.maybeOf(context)
                              ?.showSnackBar(SnackBar(content: Text(l.copied)));
                        },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(l.calculatorCopy),
                ),
              ),
              if (widget.onUse != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: result == null || result <= 0
                        ? null
                        : () => widget.onUse!(result),
                    child: Text(
                      result == null
                          ? l.done
                          : l.calculatorUseAmount(
                              ref.fmt.money(result, compact: true),
                            ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _rows = [
    ['C', '(', ')', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
    ['%', '0', '.', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          for (final row in _rows)
            Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: SizedBox(
                        height: 52,
                        child: FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor: RegExp(r'[0-9.]').hasMatch(key)
                                ? scheme.surfaceContainerHighest
                                : key == 'C'
                                ? scheme.errorContainer
                                : scheme.secondaryContainer,
                            foregroundColor: key == 'C'
                                ? scheme.onErrorContainer
                                : scheme.onSurface,
                          ),
                          onPressed: () => onKey(key),
                          child: key == '⌫'
                              ? const Icon(
                                  Icons.backspace_outlined,
                                  semanticLabel: 'Backspace',
                                )
                              : Text(
                                  key,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: () => onKey('='),
                      child: const Text('=', style: TextStyle(fontSize: 22)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
