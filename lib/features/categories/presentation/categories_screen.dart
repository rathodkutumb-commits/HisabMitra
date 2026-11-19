import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/widgets/dialogs.dart';
import '../data/category_repository.dart';
import 'category_labels.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(l.categoriesTitle),
            bottom: TabBar(
              tabs: [
                Tab(text: l.expense),
                Tab(text: l.income),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            // Unique: the tab shell keeps several FAB screens alive.
            heroTag: 'fab-categories',
            onPressed: () {
              final index = DefaultTabController.of(context).index;
              context.push(
                Routes.newCategory(index == 0 ? 'expense' : 'income'),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: Text(l.addCategory),
          ),
          body: const TabBarView(
            children: [
              _CategoryList(type: TransactionType.expense),
              _CategoryList(type: TransactionType.income),
            ],
          ),
        ),
      ),
    );
  }
}

final _usageProvider = FutureProvider.family<int, String>(
  (ref, id) => ref.watch(categoryRepositoryProvider).usageCount(id),
);

class _CategoryList extends ConsumerWidget {
  const _CategoryList({required this.type});

  final TransactionType type;

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    CategoryRow c,
    List<CategoryRow> all,
  ) async {
    final l = context.l10n;
    final repo = ref.read(categoryRepositoryProvider);
    try {
      final ok = await confirmDelete(context);
      if (!ok) return;
      await repo.delete(c.id);
    } on InUseFailure catch (f) {
      if (!context.mounted) return;
      final others = all.where((x) => x.id != c.id).toList();
      final target = await showDialog<String>(
        context: context,
        builder: (ctx) {
          String? selected = others.isEmpty ? null : others.first.id;
          return StatefulBuilder(
            builder: (ctx, setState) => AlertDialog(
              title: Text(l.categoryDeleteInUseTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.categoryDeleteInUseBody(f.count)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selected,
                    isExpanded: true,
                    items: [
                      for (final o in others)
                        DropdownMenuItem(
                          value: o.id,
                          child: Row(
                            children: [
                              Icon(o.icon, color: o.color, size: 18),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  o.label(l),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => selected = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l.cancel),
                ),
                FilledButton(
                  onPressed: selected == null
                      ? null
                      : () => Navigator.pop(ctx, selected),
                  child: Text(l.categoryMoveAndDelete),
                ),
              ],
            ),
          );
        },
      );
      if (target == null) return;
      try {
        await repo.delete(c.id, reassignTo: target);
      } catch (e) {
        if (context.mounted) showFailure(context, e);
        return;
      }
    } catch (e) {
      if (context.mounted) showFailure(context, e);
      return;
    }
    ref.invalidate(_usageProvider);
    if (context.mounted) showAppSnack(context, l.deletedMessage);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return AsyncValueView(
      value: ref.watch(categoriesProvider(type)),
      data: (list) => ListView.builder(
        padding: const EdgeInsets.only(bottom: 96, top: 8),
        itemCount: list.length,
        itemBuilder: (context, i) {
          final c = list[i];
          final usage = ref.watch(_usageProvider(c.id)).value;
          return ListTile(
            leading: IconBadge(icon: c.icon, color: c.color),
            title: Text(c.label(l)),
            subtitle: usage == null ? null : Text(l.categoryUsage(usage)),
            onTap: () => context.push(Routes.editCategory(c.id)),
            trailing: IconButton(
              tooltip: l.delete,
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _delete(context, ref, c, list),
            ),
          );
        },
      ),
    );
  }
}
