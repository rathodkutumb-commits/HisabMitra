import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/errors/app_failure.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/features/categories/data/category_repository.dart';

import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late CategoryRepository categories;

  setUp(() {
    db = newTestDatabase();
    categories = CategoryRepository(db, const Clock(), const IdGenerator());
  });
  tearDown(() => db.close());

  test('a category keeps both names', () async {
    final id = await categories.save(
      const CategoryDraft(
        name: ' Pooja ',
        nameGu: ' પૂજા ',
        type: TransactionType.expense,
        iconKey: 'more',
        colorValue: 0xFF607D8B,
      ),
    );
    final c = (await categories.getById(id))!;
    expect(c.name, 'Pooja');
    expect(c.nameGu, 'પૂજા');
  });

  test('the Gujarati name is required', () async {
    await expectLater(
      categories.save(
        const CategoryDraft(
          name: 'Pooja',
          nameGu: '  ',
          type: TransactionType.expense,
          iconKey: 'more',
          colorValue: 0xFF607D8B,
        ),
      ),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('renaming a category changes both names', () async {
    final id = await categories.save(
      const CategoryDraft(
        name: 'Pooja',
        nameGu: 'પૂજા',
        type: TransactionType.expense,
        iconKey: 'more',
        colorValue: 0xFF607D8B,
      ),
    );
    await categories.save(
      CategoryDraft(
        id: id,
        name: 'Temple',
        nameGu: 'મંદિર',
        type: TransactionType.expense,
        iconKey: 'more',
        colorValue: 0xFF607D8B,
      ),
    );
    final c = (await categories.getById(id))!;
    expect((c.name, c.nameGu), ('Temple', 'મંદિર'));
  });
}
