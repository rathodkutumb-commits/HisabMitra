import 'package:flutter/material.dart';

import '../../../core/domain/category_icons.dart';
import '../../../core/l10n/l10n_x.dart';
import '../domain/family_models.dart';

extension FamilyEntryKindX on FamilyEntryKind {
  String label(AppLocalizations l) => switch (this) {
    FamilyEntryKind.salary => l.familyKindSalary,
    FamilyEntryKind.extraIncome => l.familyKindExtraIncome,
    FamilyEntryKind.contribution => l.familyKindContribution,
    FamilyEntryKind.expense => l.familyMoneyOut,
  };
}

extension FamilyEntryX on FamilyEntry {
  /// Money out: its category in the app's language; money in: its kind.
  String title(AppLocalizations l) => kind.isMoneyIn
      ? kind.label(l)
      : categoryLabel(l.localeName) ?? kind.label(l);

  IconData get icon => kind.isMoneyIn
      ? Icons.south_west_rounded
      : CategoryIcons.of(categoryIcon ?? 'more');
}
