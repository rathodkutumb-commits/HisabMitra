import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/widgets/dialogs.dart';
import '../../settings/application/settings_controller.dart';
import '../application/tour_controller.dart';
import '../data/sample_data_service.dart';

/// Placed on the dashboard: right after the first sign-up on this device,
/// offers the guided tour with sample data (once).
class TourPromptHost extends ConsumerStatefulWidget {
  const TourPromptHost({super.key});

  @override
  ConsumerState<TourPromptHost> createState() => _TourPromptHostState();
}

class _TourPromptHostState extends ConsumerState<TourPromptHost> {
  var _shown = false;

  Future<void> _offer() async {
    _shown = true;
    await markTourOffered(ref);
    if (!mounted) return;
    final l = context.l10n;
    final start = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.tour_rounded),
        title: Text(l.tourPromptTitle),
        content: Text(l.tourPromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.tourNotNow),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.tourStart),
          ),
        ],
      ),
    );
    if (start ?? false) {
      await ref.read(tourControllerProvider.notifier).start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(
      settingsControllerProvider.select((p) => p.tourPending),
    );
    if (pending && !_shown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_shown) _offer();
      });
    }
    return const SizedBox.shrink();
  }
}

/// Dashboard banner while the tour's sample data is in the app.
class SampleDataBanner extends ConsumerWidget {
  const SampleDataBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loaded = ref.watch(
      settingsControllerProvider.select((p) => p.sampleDataLoaded),
    );
    if (!loaded) return const SizedBox.shrink();
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        color: scheme.tertiaryContainer,
        child: ListTile(
          leading: Icon(
            Icons.science_rounded,
            color: scheme.onTertiaryContainer,
          ),
          title: Text(
            l.sampleBanner,
            style: TextStyle(color: scheme.onTertiaryContainer),
          ),
          trailing: TextButton(
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: l.sampleRemoveTitle,
                message: l.sampleRemoveBody,
                confirmLabel: l.sampleRemove,
                destructive: true,
              );
              if (!ok) return;
              await ref.read(sampleDataServiceProvider).remove();
              if (context.mounted) showAppSnack(context, l.sampleRemoved);
            },
            child: Text(l.sampleRemove),
          ),
        ),
      ),
    );
  }
}
