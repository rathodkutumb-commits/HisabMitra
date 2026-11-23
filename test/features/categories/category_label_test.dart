import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/features/categories/presentation/category_labels.dart';
import 'package:hisabmitra/l10n/app_localizations.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final gu = lookupAppLocalizations(const Locale('gu'));

  CategoryRow category({
    String id = 'cat_pooja',
    String? systemKey,
    String name = 'Pooja',
    String? nameGu,
  }) => CategoryRow(
    id: id,
    systemKey: systemKey,
    name: name,
    nameGu: nameGu,
    type: TransactionType.expense,
    iconKey: 'more',
    colorValue: 0xFF607D8B,
    sortOrder: 0,
    isArchived: false,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  test('a custom category shows its Gujarati name in Gujarati', () {
    final c = category(nameGu: 'પૂજા');
    expect(c.label(gu), 'પૂજા');
    expect(c.label(en), 'Pooja');
  });

  test('an old custom category shows its one name in both languages', () {
    final c = category();
    expect(c.label(gu), 'Pooja');
    expect(c.label(en), 'Pooja');
  });

  test('built-in categories stay translated', () {
    final c = category(
      id: 'cat_groceries',
      systemKey: 'groceries',
      name: 'Groceries',
    );
    expect(c.label(gu), gu.catGroceries);
    expect(c.label(en), en.catGroceries);
  });
}
