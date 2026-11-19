import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/calculator/presentation/calculator_panel.dart';
import '../../features/gujarati_input/presentation/gujarati_text_field.dart';
import '../../features/settings/application/settings_controller.dart';
import '../domain/enums.dart';
import '../l10n/l10n_x.dart';
import '../money/money.dart';

/// Amount input in rupees with exact paise parsing and a calculator button.
class MoneyFormField extends StatelessWidget {
  const MoneyFormField({
    super.key,
    required this.controller,
    this.label,
    this.autofocus = false,
    this.allowZero = false,
    this.large = false,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String? label;
  final bool autofocus;
  final bool allowZero;
  final bool large;
  final ValueChanged<String>? onChanged;
  final String? Function(int? paise)? validator;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,૦-૯]')),
        LengthLimitingTextInputFormatter(15),
      ],
      style: large
          ? theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )
          : null,
      decoration: InputDecoration(
        labelText: label ?? l.amount,
        hintText: l.amountHint,
        prefixText: '${Money.rupeeSymbol} ',
        suffixIcon: IconButton(
          tooltip: l.openCalculator,
          icon: const Icon(Icons.calculate_rounded),
          onPressed: () async {
            final result = await showCalculatorSheet(
              context,
              initialPaise: Money.tryParse(controller.text),
            );
            if (result != null) {
              controller.text = Money.toEditable(result);
              onChanged?.call(controller.text);
            }
          },
        ),
      ),
      onChanged: onChanged,
      validator: (text) {
        final value = Money.tryParse(text ?? '');
        if (text == null || text.trim().isEmpty) {
          return allowZero ? null : l.validationRequired;
        }
        if (value == null) return l.validationAmount;
        if (!allowZero && value <= 0) return l.validationAmountPositive;
        return validator?.call(value);
      },
    );
  }
}

/// Read-only field that opens a date picker.
class DatePickerField extends ConsumerWidget {
  const DatePickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.firstDate,
    this.lastDate,
    this.clearable = false,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final String? label;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool clearable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: firstDate ?? DateTime(2000),
          lastDate: lastDate ?? DateTime(now.year + 10),
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label ?? l.date,
          prefixIcon: const Icon(Icons.event_rounded),
          suffixIcon: clearable && value != null
              ? IconButton(
                  tooltip: l.clear,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => onChanged(null),
                )
              : null,
        ),
        child: Text(value == null ? l.none : ref.fmt.date(value!)),
      ),
    );
  }
}

class PaymentMethodChips extends StatelessWidget {
  const PaymentMethodChips({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  static const icons = {
    PaymentMethod.cash: Icons.payments_rounded,
    PaymentMethod.upi: Icons.qr_code_2_rounded,
    PaymentMethod.bankTransfer: Icons.account_balance_rounded,
    PaymentMethod.creditCard: Icons.credit_card_rounded,
    PaymentMethod.debitCard: Icons.credit_card_outlined,
    PaymentMethod.other: Icons.more_horiz_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in PaymentMethod.values)
          ChoiceChip(
            avatar: Icon(icons[m], size: 18),
            label: Text(m.label(l)),
            selected: value == m,
            onSelected: (_) => onChanged(m),
          ),
      ],
    );
  }
}

/// Multiline/notes text field that supports the Gujarati input modes.
class HmTextField extends StatelessWidget {
  const HmTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.maxLength,
    this.required = false,
    this.textInputAction,
    this.onChanged,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final int maxLines;
  final int? maxLength;
  final bool required;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return GujaratiTextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        counterText: '',
      ),
      validator: (text) {
        final value = text?.trim() ?? '';
        if (required && value.isEmpty) return l.validationRequired;
        if (maxLength != null && value.length > maxLength!) {
          return l.validationTooLong(maxLength!);
        }
        return null;
      },
    );
  }
}
