import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/config/app_config.dart';
import '../../../app/router/routes.dart';
import '../../../app/theme/hm_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/group_repository.dart';
import '../domain/group_models.dart';
import 'group_labels.dart';
import '../../ai_assistant/presentation/ai_fab.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({super.key});

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  var _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final groups = ref.watch(groupsProvider(_showArchived));
    return Scaffold(
      appBar: AppBar(
        title: Text(l.groupsTitle),
        actions: [
          if (AppConfig.isCloudConfigured)
            IconButton(
              tooltip: l.joinGroup,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              onPressed: () => context.push(Routes.joinGroup),
            ),
          PopupMenuButton<String>(
            onSelected: (_) => setState(() => _showArchived = !_showArchived),
            itemBuilder: (_) => [
              CheckedPopupMenuItem(
                value: 'archived',
                checked: _showArchived,
                child: Text(l.showArchived),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: AiFabStack(
        child: FloatingActionButton.extended(
          // Unique: the tab shell keeps several FAB screens alive.
          heroTag: 'fab-groups',
          onPressed: () => context.push(Routes.newGroup),
          icon: const Icon(Icons.group_add_rounded),
          label: Text(l.createGroup),
        ),
      ),
      body: AsyncValueView(
        value: groups,
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.groups_rounded,
                title: l.noGroupsTitle,
                message: l.noGroupsBody,
                actionLabel: l.createGroup,
                onAction: () => context.push(Routes.newGroup),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _GroupCard(item: items[i]),
              ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.item});

  final GroupListItem item;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final hm = HmColors.of(context);
    final g = item.group;
    final net = item.myNetPaise;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push(Routes.group(g.id)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBadge(
                    icon: g.groupType.icon,
                    color: theme.colorScheme.secondary,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${g.groupType.label(l)} · ${l.memberCount(item.memberCount)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    g.isShared
                        ? Icons.cloud_done_rounded
                        : Icons.smartphone_rounded,
                    size: 18,
                    color: theme.colorScheme.outline,
                    semanticLabel: g.isShared ? l.sharedGroup : l.localGroup,
                  ),
                  if (g.status == GroupStatus.archived)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Chip(
                        label: Text(l.archived),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.totalSpent, style: theme.textTheme.labelSmall),
                        AmountText(item.totalSpentPaise),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        net > 0
                            ? l.youAreOwed
                            : net < 0
                            ? l.youOwe
                            : l.settledUp,
                        style: theme.textTheme.labelSmall,
                      ),
                      AmountText(
                        net.abs(),
                        color: net > 0
                            ? hm.receivable
                            : net < 0
                            ? hm.payable
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
