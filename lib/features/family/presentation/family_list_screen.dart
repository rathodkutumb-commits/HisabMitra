import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/routes.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/common_widgets.dart';
import '../data/family_repository.dart';

/// Every Family hisab of the user. With exactly one, it opens that one
/// directly; with none, it explains the feature and offers to create one.
class FamilyListScreen extends ConsumerStatefulWidget {
  const FamilyListScreen({super.key});

  @override
  ConsumerState<FamilyListScreen> createState() => _FamilyListScreenState();
}

class _FamilyListScreenState extends ConsumerState<FamilyListScreen> {
  /// Only the first look opens the single Family hisab: coming back to this
  /// screen (or creating one from it) shows the list.
  var _firstLook = true;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final families = ref.watch(familiesProvider);
    if (_firstLook && families.hasValue) {
      _firstLook = false;
      final list = families.value!;
      if (list.length == 1) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            context.pushReplacement(Routes.familyHome(list.single.id));
          }
        });
        return const Scaffold(body: LoadingView());
      }
    }
    final hasAny = families.value?.isNotEmpty ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(l.familyHisabs)),
      floatingActionButton: hasAny
          ? FloatingActionButton.extended(
              heroTag: 'fab-family-list',
              onPressed: () => context.push(Routes.newFamily),
              icon: const Icon(Icons.add_rounded),
              label: Text(l.familyNew),
            )
          : null,
      body: AsyncValueView(
        value: families,
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.family_restroom_rounded,
              title: l.familyEmptyTitle,
              message: l.familyEmptyMessage,
              actionLabel: l.familyCreate,
              onAction: () => context.push(Routes.newFamily),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              for (final f in list)
                Card(
                  child: ListTile(
                    leading: IconBadge(
                      icon: Icons.family_restroom_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(f.name),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push(Routes.familyHome(f.id)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
