import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';

@immutable
class CategoryDraft {
  const CategoryDraft({
    this.id,
    required this.name,
    required this.type,
    required this.iconKey,
    required this.colorValue,
    this.keepSystemName = false,
  });

  final String? id;
  final String name;
  final TransactionType type;
  final String iconKey;
  final int colorValue;

  /// When editing a built-in category without changing its (localised)
  /// name, keep the system key so the label stays translated.
  final bool keepSystemName;
}

class CategoryRepository {
  CategoryRepository(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  Stream<List<CategoryRow>> watchAll([TransactionType? type]) {
    final q = _db.select(_db.categories)
      ..where((c) => c.isArchived.equals(false))
      ..orderBy([
        (c) => OrderingTerm.asc(c.sortOrder),
        (c) => OrderingTerm.asc(c.name),
      ]);
    if (type != null) q.where((c) => c.type.equalsValue(type));
    return q.watch();
  }

  Future<CategoryRow?> getById(String id) => (_db.select(
    _db.categories,
  )..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> usageCount(String id) async {
    final count = _db.transactions.id.count();
    final row =
        await (_db.selectOnly(_db.transactions)
              ..addColumns([count])
              ..where(_db.transactions.categoryId.equals(id)))
            .getSingle();
    return row.read(count) ?? 0;
  }

  Future<String> save(CategoryDraft d) async {
    final name = d.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    final now = _clock.now();
    if (d.id == null) {
      final id = _ids.newId();
      final maxOrder = _db.categories.sortOrder.max();
      final row = await (_db.selectOnly(
        _db.categories,
      )..addColumns([maxOrder])).getSingle();
      await _db
          .into(_db.categories)
          .insert(
            CategoriesCompanion.insert(
              id: id,
              name: name,
              type: d.type,
              iconKey: d.iconKey,
              colorValue: d.colorValue,
              sortOrder: Value((row.read(maxOrder) ?? 0) + 1),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return id;
    }
    final existing = await getById(d.id!);
    if (existing == null) throw const NotFoundFailure();
    await (_db.update(_db.categories)..where((c) => c.id.equals(d.id!))).write(
      CategoriesCompanion(
        name: d.keepSystemName ? const Value.absent() : Value(name),
        systemKey: d.keepSystemName ? const Value.absent() : const Value(null),
        iconKey: Value(d.iconKey),
        colorValue: Value(d.colorValue),
        updatedAt: Value(now),
      ),
    );
    return d.id!;
  }

  /// Deletes a category. If transactions use it, [reassignTo] (same type)
  /// is required and all of them are moved inside one DB transaction.
  Future<void> delete(String id, {String? reassignTo}) async {
    await _db.transaction(() async {
      final category = await getById(id);
      if (category == null) throw const NotFoundFailure();
      final used = await usageCount(id);
      if (used > 0) {
        if (reassignTo == null) throw InUseFailure(used);
        final target = await getById(reassignTo);
        if (target == null || target.id == id || target.type != category.type) {
          throw const ValidationFailure('category_type');
        }
        await (_db.update(
          _db.transactions,
        )..where((t) => t.categoryId.equals(id))).write(
          TransactionsCompanion(
            categoryId: Value(reassignTo),
            updatedAt: Value(_clock.now()),
          ),
        );
      }
      await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    });
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final categoriesProvider =
    StreamProvider.family<List<CategoryRow>, TransactionType?>(
      (ref, type) => ref.watch(categoryRepositoryProvider).watchAll(type),
    );
