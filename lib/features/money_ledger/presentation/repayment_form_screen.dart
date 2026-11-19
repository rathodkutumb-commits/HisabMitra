import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../settings/application/settings_controller.dart';
import '../data/ledger_repository.dart';
import '../domain/ledger_models.dart';

class RepaymentFormScreen extends ConsumerStatefulWidget {
  const RepaymentFormScreen({super.key, required this.entryId});

  final String entryId;

  @override
  ConsumerState<RepaymentFormScreen> createState() =>
      _RepaymentFormScreenState();
}

class _RepaymentFormScreenState extends ConsumerState<RepaymentFormScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  DateTime _date = DateTime.now();
  PaymentMethod _method = PaymentMethod.cash;
  var _prefilled = false;
  var _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save(LedgerEntryView view) async {
    if (_saving || !_form.currentState!.validate()) return;
    final l = context.l10n;
    final fmt = ref.read(formattersProvider);
    final draft = RepaymentDraft(
      ledgerId: widget.entryId,
      amountPaise: Money.tryParse(_amount.text)!,
      date: _date,
      paymentMethod: _method,
      notes: _notes.text,
    );
    setState(() => _saving = true);
    final repo = ref.read(ledgerRepositoryProvider);
    try {
      await repo.addRepayment(draft);
    } on RepaymentExceedsFailure catch (f) {
      if (!mounted) return;
      final asAdvance = await confirmAction(
        context,
        title: l.repaymentExceedsTitle,
        message: l.repaymentExceedsBody(
          fmt.money(view.summary.outstandingPaise),
          fmt.money(f.excessPaise),
        ),
        confirmLabel: l.recordAsAdvance,
      );
      if (!asAdvance) {
        if (mounted) setState(() => _saving = false);
        return;
      }
      try {
        await repo.addRepayment(
          draft,
          recordExcessAsAdvance: true,
          advanceDescription: l.advanceCredit,
        );
      } catch (e) {
        if (mounted) {
          setState(() => _saving = false);
          showFailure(context, e);
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showFailure(context, e);
      }
      return;
    }
    if (!mounted) return;
    showAppSnack(context, l.repaymentSaved);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final value = ref.watch(ledgerEntryProvider(widget.entryId));
    return AsyncValueView(
      value: value,
      data: (view) {
        if (view == null) {
          return Scaffold(
            appBar: AppBar(),
            body: EmptyState(
              icon: Icons.menu_book_rounded,
              title: l.errorNotFound,
            ),
          );
        }
        if (!_prefilled) {
          _prefilled = true;
          _amount.text = Money.toEditable(view.summary.outstandingPaise);
          _method = view.entry.paymentMethod;
        }
        final given = view.entry.direction == LedgerDirection.given;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              given ? l.repaymentReceivedTitle : l.repaymentPaidTitle,
            ),
          ),
          body: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: InitialsAvatar(name: view.person.name),
                    title: Text(view.person.name),
                    subtitle: Text(
                      view.entry.description.isEmpty
                          ? (given ? l.ledgerGivenLong : l.ledgerTakenLong)
                          : l.repaymentFor(view.entry.description),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l.outstanding,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        AmountText(view.summary.outstandingPaise),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                MoneyFormField(
                  controller: _amount,
                  large: true,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                DatePickerField(
                  value: _date,
                  onChanged: (d) => setState(() => _date = d ?? _date),
                ),
                const SizedBox(height: 16),
                Text(
                  l.paymentMethod,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                PaymentMethodChips(
                  value: _method,
                  onChanged: (m) => setState(() => _method = m),
                ),
                const SizedBox(height: 16),
                HmTextField(
                  controller: _notes,
                  label: l.notes,
                  maxLines: 2,
                  maxLength: 300,
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                onPressed: _saving ? null : () => _save(view),
                child: Text(l.recordRepayment),
              ),
            ),
          ),
        );
      },
    );
  }
}
