import 'package:flutter/material.dart';

/// Icons selectable for categories. Stored by key (not code point) so that
/// icon tree-shaking and future icon changes never corrupt stored data.
abstract final class CategoryIcons {
  static const Map<String, IconData> all = {
    'restaurant': Icons.restaurant_rounded,
    'grocery': Icons.local_grocery_store_rounded,
    'bus': Icons.directions_bus_rounded,
    'fuel': Icons.local_gas_station_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'bill': Icons.receipt_long_rounded,
    'home': Icons.home_rounded,
    'health': Icons.medical_services_rounded,
    'school': Icons.school_rounded,
    'movie': Icons.movie_rounded,
    'flight': Icons.flight_rounded,
    'celebration': Icons.celebration_rounded,
    'chair': Icons.chair_rounded,
    'phone': Icons.smartphone_rounded,
    'spa': Icons.spa_rounded,
    'donation': Icons.volunteer_activism_rounded,
    'work': Icons.work_rounded,
    'store': Icons.storefront_rounded,
    'laptop': Icons.laptop_mac_rounded,
    'savings': Icons.savings_rounded,
    'apartment': Icons.apartment_rounded,
    'gift': Icons.redeem_rounded,
    'refund': Icons.replay_rounded,
    'more': Icons.more_horiz_rounded,
    'pets': Icons.pets_rounded,
    'child': Icons.child_care_rounded,
    'sports': Icons.sports_cricket_rounded,
    'coffee': Icons.local_cafe_rounded,
    'car': Icons.directions_car_rounded,
    'train': Icons.train_rounded,
    'electric': Icons.bolt_rounded,
    'water': Icons.water_drop_rounded,
    'temple': Icons.temple_hindu_rounded,
    'insurance': Icons.health_and_safety_rounded,
    'tax': Icons.account_balance_rounded,
    'investment': Icons.trending_up_rounded,
    'clothes': Icons.checkroom_rounded,
    'tools': Icons.build_rounded,
    'book': Icons.menu_book_rounded,
    'wallet': Icons.account_balance_wallet_rounded,
  };

  static IconData of(String key) => all[key] ?? Icons.category_rounded;

  /// Colours offered in the category editor.
  static const List<int> palette = [
    0xFF0F5C41,
    0xFF8B1E3F,
    0xFFE76F3C,
    0xFFD4A017,
    0xFF2F7FB5,
    0xFF7A5BA6,
    0xFF4E9A5F,
    0xFFC2577E,
    0xFF00897B,
    0xFF6D4C41,
    0xFF3F51B5,
    0xFF546E7A,
    0xFFAD1457,
    0xFFEF6C00,
    0xFF757575,
  ];
}
