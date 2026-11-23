import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/domain/category_icons.dart';
import '../../../core/l10n/l10n_x.dart';

extension CategoryRowX on CategoryRow {
  /// Localised label for built-in categories; for custom ones the name in
  /// the app's language (Gujarati when given, otherwise the one name).
  String label(AppLocalizations l) => switch (systemKey) {
    'food' => l.catFood,
    'groceries' => l.catGroceries,
    'transport' => l.catTransport,
    'fuel' => l.catFuel,
    'shopping' => l.catShopping,
    'bills' => l.catBills,
    'rent' => l.catRent,
    'health' => l.catHealth,
    'education' => l.catEducation,
    'entertainment' => l.catEntertainment,
    'travel' => l.catTravel,
    'festivals' => l.catFestivals,
    'household' => l.catHousehold,
    'mobile' => l.catMobile,
    'personalCare' => l.catPersonalCare,
    'donation' => l.catDonation,
    'otherExpense' => l.catOtherExpense,
    'salary' => l.catSalary,
    'business' => l.catBusiness,
    'freelance' => l.catFreelance,
    'interest' => l.catInterest,
    'rentalIncome' => l.catRentalIncome,
    'giftsReceived' => l.catGiftsReceived,
    'refund' => l.catRefund,
    'otherIncome' => l.catOtherIncome,
    // A custom category: its Gujarati name when the app is in Gujarati and
    // one was given, otherwise its (only) name.
    _ when l.localeName == 'gu' && (nameGu?.trim().isNotEmpty ?? false) =>
      nameGu!,
    _ => name,
  };

  IconData get icon => CategoryIcons.of(iconKey);
  Color get color => Color(colorValue);
}
