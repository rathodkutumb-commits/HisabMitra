import 'package:drift/drift.dart';

import 'app_database.dart';

/// Built-in category definition. `systemKey` maps to a localised label.
class DefaultCategory {
  const DefaultCategory(this.systemKey, this.type, this.iconKey, this.color);

  final String systemKey;
  final TransactionType type;
  final String iconKey;
  final int color;

  /// Deterministic id so seeds are idempotent and restorable.
  String get id => 'cat_$systemKey';

  /// English fallback name stored in the `name` column.
  String get englishName => _english[systemKey] ?? systemKey;

  static const _english = {
    'food': 'Food & Dining',
    'groceries': 'Groceries',
    'transport': 'Transport',
    'fuel': 'Fuel',
    'shopping': 'Shopping',
    'bills': 'Bills & Utilities',
    'rent': 'Rent',
    'health': 'Health',
    'education': 'Education',
    'entertainment': 'Entertainment',
    'travel': 'Travel',
    'festivals': 'Festivals & Gifts',
    'household': 'Household',
    'mobile': 'Mobile & Internet',
    'personalCare': 'Personal Care',
    'donation': 'Donation',
    'otherExpense': 'Other Expense',
    'salary': 'Salary',
    'business': 'Business',
    'freelance': 'Freelance',
    'interest': 'Interest',
    'rentalIncome': 'Rental Income',
    'giftsReceived': 'Gifts Received',
    'refund': 'Refunds',
    'otherIncome': 'Other Income',
  };
}

const List<DefaultCategory> defaultCategories = [
  DefaultCategory('food', TransactionType.expense, 'restaurant', 0xFFE76F3C),
  DefaultCategory('groceries', TransactionType.expense, 'grocery', 0xFF4E9A5F),
  DefaultCategory('transport', TransactionType.expense, 'bus', 0xFF2F7FB5),
  DefaultCategory('fuel', TransactionType.expense, 'fuel', 0xFF6D4C41),
  DefaultCategory('shopping', TransactionType.expense, 'shopping', 0xFFC2577E),
  DefaultCategory('bills', TransactionType.expense, 'bill', 0xFF7A5BA6),
  DefaultCategory('rent', TransactionType.expense, 'home', 0xFF3C3F7A),
  DefaultCategory('health', TransactionType.expense, 'health', 0xFF8B1E3F),
  DefaultCategory('education', TransactionType.expense, 'school', 0xFF3F51B5),
  DefaultCategory(
    'entertainment',
    TransactionType.expense,
    'movie',
    0xFFD4A017,
  ),
  DefaultCategory('travel', TransactionType.expense, 'flight', 0xFF00897B),
  DefaultCategory(
    'festivals',
    TransactionType.expense,
    'celebration',
    0xFFAD1457,
  ),
  DefaultCategory('household', TransactionType.expense, 'chair', 0xFF546E7A),
  DefaultCategory('mobile', TransactionType.expense, 'phone', 0xFF2F7FB5),
  DefaultCategory('personalCare', TransactionType.expense, 'spa', 0xFFC2577E),
  DefaultCategory('donation', TransactionType.expense, 'donation', 0xFFEF6C00),
  DefaultCategory('otherExpense', TransactionType.expense, 'more', 0xFF757575),
  DefaultCategory('salary', TransactionType.income, 'work', 0xFF0F5C41),
  DefaultCategory('business', TransactionType.income, 'store', 0xFF2F7FB5),
  DefaultCategory('freelance', TransactionType.income, 'laptop', 0xFF7A5BA6),
  DefaultCategory('interest', TransactionType.income, 'savings', 0xFFD4A017),
  DefaultCategory(
    'rentalIncome',
    TransactionType.income,
    'apartment',
    0xFF6D4C41,
  ),
  DefaultCategory('giftsReceived', TransactionType.income, 'gift', 0xFFC2577E),
  DefaultCategory('refund', TransactionType.income, 'refund', 0xFF00897B),
  DefaultCategory('otherIncome', TransactionType.income, 'more', 0xFF757575),
];

/// Inserts built-in categories that are missing. Safe to run repeatedly.
Future<void> seedDefaultCategories(AppDatabase db, DateTime now) async {
  await db.batch((batch) {
    for (var i = 0; i < defaultCategories.length; i++) {
      final c = defaultCategories[i];
      batch.insert(
        db.categories,
        CategoriesCompanion.insert(
          id: c.id,
          systemKey: Value(c.systemKey),
          name: c.englishName,
          type: c.type,
          iconKey: c.iconKey,
          colorValue: c.color,
          sortOrder: Value(i),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  });
}
