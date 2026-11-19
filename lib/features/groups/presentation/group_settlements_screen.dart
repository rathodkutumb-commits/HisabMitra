import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/hm_colors.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../data/group_repository.dart';

class GroupSettlementsScreen extends ConsumerWidget {
  const GroupSettlementsScreen({super.key, required this.groupId});

  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formattersProvider);
    final hm = HmColors.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settlementHistory)),
      body: AsyncValueView(
        value: ref.watch(groupDetailProvider(groupId)),
        data: (d) {
          if (d == null) {
            return EmptyState(
              icon: Icons.groups_rounded,
              title: l.errorNotFound,
            );
          }
          if (d.settlements.isEmpty) {
            return EmptyState(
              icon: Icons.handshake_rounded,
              title: l.noSettlements,
            );
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final s in d.settlements)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: hm.income.withValues(alpha: 0.15),
                    child: Icon(Icons.handshake_rounded, color: hm.income),
                  ),
                  title: Text(
                    l.timelineSettlement(
                      d.memberName(s.fromMemberId),
                      d.memberName(s.toMemberId),
                    ),
                  ),
                  subtitle: Text(
                    [
                      fmt.date(s.settledOn),
                      s.paymentMethod.label(l),
                      if (s.notes != null) s.notes!,
                    ].join(' · '),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AmountText(s.amountPaise),
                      IconButton(
                        tooltip: l.delete,
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: () async {
                          final ok = await confirmDelete(
                            context,
                            message: l.deleteSettlementConfirm,
                          );
                          if (!ok) return;
                          try {
                            await ref
                                .read(groupRepositoryProvider)
                                .deleteSettlement(s.id);
                          } catch (e) {
                            if (context.mounted) showFailure(context, e);
                          }
                        },
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
