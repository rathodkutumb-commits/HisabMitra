import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_x.dart';
import '../../../core/providers.dart';
import '../../../core/utils/date_range.dart';

@immutable
class PeriodSelection {
  const PeriodSelection(this.preset, this.range);

  final PeriodPreset preset;
  final DateRange range;
}

/// Reporting period shared by the dashboard and reports.
class PeriodController extends Notifier<PeriodSelection> {
  @override
  PeriodSelection build() {
    final now = ref.read(clockProvider).now();
    return PeriodSelection(
      PeriodPreset.thisMonth,
      DateRange.forPreset(PeriodPreset.thisMonth, now),
    );
  }

  void select(PeriodPreset preset, {DateRange? custom}) {
    final now = ref.read(clockProvider).now();
    state = PeriodSelection(
      preset,
      preset == PeriodPreset.custom && custom != null
          ? custom
          : DateRange.forPreset(preset, now),
    );
  }
}

final periodControllerProvider =
    NotifierProvider<PeriodController, PeriodSelection>(PeriodController.new);

String presetLabel(AppLocalizations l, PeriodPreset p) => switch (p) {
  PeriodPreset.thisMonth => l.periodThisMonth,
  PeriodPreset.lastMonth => l.periodLastMonth,
  PeriodPreset.thisYear => l.periodThisYear,
  PeriodPreset.custom => l.periodCustom,
};

/// Chip row for selecting a period; opens a range picker for "custom".
class PeriodChips extends ConsumerWidget {
  const PeriodChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final selection = ref.watch(periodControllerProvider);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final p in PeriodPreset.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(presetLabel(l, p)),
                selected: selection.preset == p,
                onSelected: (_) async {
                  final controller = ref.read(
                    periodControllerProvider.notifier,
                  );
                  if (p != PeriodPreset.custom) {
                    controller.select(p);
                    return;
                  }
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(now.year + 1, 12, 31),
                    initialDateRange: DateTimeRange(
                      start: selection.range.start,
                      end: selection.range.endInclusive,
                    ),
                  );
                  if (picked != null) {
                    controller.select(
                      PeriodPreset.custom,
                      custom: DateRange.custom(picked.start, picked.end),
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
