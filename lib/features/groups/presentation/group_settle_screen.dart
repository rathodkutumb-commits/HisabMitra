import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/money/money.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../../core/widgets/form_fields.dart';
import '../../settings/application/settings_controller.dart';
import '../data/group_repository.dart';
import '../domain/group_models.dart';
import 'group_labels.dart';

class GroupSettleScreen extends ConsumerStatefulWidget {
  const GroupSettleScreen({
    super.key,
    required this.groupId,
    this.from,
    this.to,
    this.amount,
  });

  final String groupId;
  final String? from;
  final String? to;
  final int? amount;

  @override
  ConsumerState<GroupSettleScreen> createState() => _GroupSettleScreenState();
}

class _GroupSettleScreenState extends ConsumerState<GroupSettleScreen> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  late String? _from = widget.from;
  late String? _to = widget.to;
  DateTime _date = DateTime.now();
  PaymentMethod _method = PaymentMethod.upi;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.amount != null) _amount.text = Money.toEditable(widget.amount!);
  }

  @override
  void dispose() {
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  int _max(GroupDetail d) {
    if (_from == null || _to == null) return 0;
    final owes = -(d.netBalances[_from] ?? 0);
    final owed = d.netBalances[_to] ?? 0;
    final m = owes < owed ? owes : owed;
    return m < 0 ? 0 : m;
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(groupRepositoryProvider)
          .recordSettlement(
            SettlementDraft(
              groupId: widget.groupId,
              fromMemberId: _from!,
              toMemberId: _to!,
              amountPaise: Money.tryParse(_amount.text)!,
              date: _date,
              paymentMethod: _method,
              notes: _notes.text,
            ),
          );
      if (!mounted) return;
      showAppSnack(context, context.l10n.settlementSaved);
      Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        showFailure(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final hm = HmColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.recordSettlement)),
      body: AsyncValueView(
        value: ref.watch(groupDetailProvider(widget.groupId)),
        data: (d) {
          if (d == null) {
            return EmptyState(
              icon: Icons.groups_rounded,
              title: l.errorNotFound,
            );
          }
          final debtors = d.members
              .where((m) => (d.netBalances[m.id] ?? 0) < 0)
              .toList();
          final creditors = d.members
              .where((m) => (d.netBalances[m.id] ?? 0) > 0)
              .toList();
          if (debtors.isEmpty) {
            return EmptyState(
              icon: Icons.verified_rounded,
              title: l.groupAllSettled,
            );
          }
          if (_from != null && !debtors.any((m) => m.id == _from)) _from = null;
          if (_to != null && !creditors.any((m) => m.id == _to)) _to = null;
          final max = _max(d);
          DropdownMenuItem<String> item(GroupMemberRow m) {
            final net = d.netBalances[m.id] ?? 0;
            return DropdownMenuItem(
              value: m.id,
              child: Text(
                '${memberLabel(l, m)} (${fmt.money(net.abs(), compact: true)})',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }

          return Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _from,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.settlementFrom,
                    prefixIcon: Icon(
                      Icons.north_east_rounded,
                      color: hm.payable,
                    ),
                  ),
                  items: [for (final m in debtors) item(m)],
                  validator: (v) => v == null ? l.validationRequired : null,
                  onChanged: (v) => setState(() => _from = v),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _to,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: l.settlementTo,
                    prefixIcon: Icon(
                      Icons.south_west_rounded,
                      color: hm.receivable,
                    ),
                  ),
                  items: [for (final m in creditors) item(m)],
                  validator: (v) => v == null
                      ? l.validationRequired
                      : (v == _from ? l.errorSameMember : null),
                  onChanged: (v) => setState(() => _to = v),
                ),
                const SizedBox(height: 16),
                MoneyFormField(
                  controller: _amount,
                  large: true,
                  validator: (p) => p != null && max > 0 && p > max
                      ? l.errorSettlementExceeds
                      : null,
                ),
                if (max > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          setState(() => _amount.text = Money.toEditable(max)),
                      child: Text(l.maxSettlement(fmt.money(max))),
                    ),
                  ),
                const SizedBox(height: 8),
                DatePickerField(
                  value: _date,
                  onChanged: (v) => setState(() => _date = v ?? _date),
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
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: _saving ? null : _save,
            child: Text(l.recordSettlement),
          ),
        ),
      ),
    );
  }
}
