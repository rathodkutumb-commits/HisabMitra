import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/group_repository.dart';
import 'group_labels.dart';

/// "Group expense" quick action: goes straight to the only active group,
/// lets the user choose when there are several, or offers to create one.
Future<void> pickGroupForExpense(BuildContext context, WidgetRef ref) async {
  final groups = await ref.read(groupRepositoryProvider).watchGroups().first;
  if (!context.mounted) return;
  if (groups.isEmpty) {
    await context.push(Routes.newGroup);
    return;
  }
  if (groups.length == 1) {
    await context.push(Routes.newGroupExpense(groups.single.group.id));
    return;
  }
  final l = context.l10n;
  final id = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              l.pickGroup,
              style: Theme.of(ctx).textTheme.titleMedium,
            ),
          ),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final g in groups)
                  ListTile(
                    leading: IconBadge(
                      icon: g.group.groupType.icon,
                      color: Theme.of(ctx).colorScheme.secondary,
                    ),
                    title: Text(g.group.name),
                    subtitle: Text(l.memberCount(g.memberCount)),
                    onTap: () => Navigator.pop(ctx, g.group.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  if (id != null && context.mounted) {
    await context.push(Routes.newGroupExpense(id));
  }
}
