import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/hm_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/l10n/l10n_x.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../categories/presentation/category_labels.dart';
import '../../../settings/application/settings_controller.dart';
import '../../domain/transaction_models.dart';

class TransactionTile extends ConsumerWidget {
  const TransactionTile({super.key, required this.view, this.showDate = false});

  final TransactionView view;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final hm = HmColors.of(context);
    final t = view.txn;
    final isIncome = t.type == TransactionType.income;
    final title = t.description.isNotEmpty
        ? t.description
        : view.category.label(l);
    final subtitle = [
      if (t.description.isNotEmpty) view.category.label(l),
      t.paymentMethod.label(l),
      if (view.person != null) view.person!.name,
      if (showDate) ref.fmt.date(t.txnDate),
    ].join(' · ');

    return ListTile(
      onTap: () => context.push(Routes.transaction(t.id)),
      leading: IconBadge(icon: view.category.icon, color: view.category.color),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (view.attachmentCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.attach_file_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
                semanticLabel: 'Attachment',
              ),
            ),
          AmountText(
            isIncome ? t.amountPaise : -t.amountPaise,
            signed: true,
            color: isIncome ? hm.income : hm.expense,
          ),
        ],
      ),
    );
  }
}
