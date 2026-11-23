import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../../synchronization/data/personal_outbox.dart';
import '../../synchronization/domain/personal_entity.dart';

@immutable
class CategoryDraft {
  const CategoryDraft({
    this.id,
    required this.name,
    required this.nameGu,
    required this.type,
    required this.iconKey,
    required this.colorValue,
    this.keepSystemName = false,
  });

  final String? id;

  /// English name (also shown in Gujarati when no Gujarati name was given).
  final String name;

  /// Gujarati name, shown when the app is in Gujarati.
  final String nameGu;
  final TransactionType type;
  final String iconKey;
  final int colorValue;

  /// When editing a built-in category without changing its (localised)
  /// name, keep the system key so the label stays translated.
  final bool keepSystemName;
}

class CategoryRepository {
  CategoryRepository(this._db, this._clock, this._ids, {PersonalOutbox? outbox})
    : _outbox = outbox ?? PersonalOutbox(_db, _clock, _ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final PersonalOutbox _outbox;

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
    final nameGu = d.nameGu.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    if (nameGu.isEmpty && !d.keepSystemName) {
      throw const ValidationFailure('required');
    }
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
              nameGu: Value(nameGu),
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
    await _db.transaction(() async {
      await (_db.update(
        _db.categories,
      )..where((c) => c.id.equals(d.id!))).write(
        CategoriesCompanion(
          name: d.keepSystemName ? const Value.absent() : Value(name),
          nameGu: d.keepSystemName ? const Value.absent() : Value(nameGu),
          systemKey: d.keepSystemName
              ? const Value.absent()
              : const Value(null),
          iconKey: Value(d.iconKey),
          colorValue: Value(d.colorValue),
          updatedAt: Value(now),
        ),
      );
      // Categories stay on the phone, but saved entries carry a copy of the
      // name and look so a new phone shows them right: refresh those copies.
      await _requeueUsersOf(d.id!);
    });
    return d.id!;
  }

  Future<void> _requeueUsersOf(
    String categoryId, {
    Iterable<String> extraReminders = const [],
  }) async {
    final txnIds = await (_db.select(
      _db.transactions,
    )..where((t) => t.categoryId.equals(categoryId))).map((t) => t.id).get();
    for (final id in txnIds) {
      await _outbox.upsert(PersonalEntity.transaction, id);
    }
    final reminderIds = await (_db.select(
      _db.reminders,
    )..where((r) => r.categoryId.equals(categoryId))).map((r) => r.id).get();
    for (final id in {...reminderIds, ...extraReminders}) {
      await _outbox.upsert(PersonalEntity.reminder, id);
    }
  }

  /// Deletes a category. If transactions use it, [reassignTo] (same type)
  /// is required and all of them are moved inside one DB transaction.
  Future<void> delete(String id, {String? reassignTo}) async {
    await _db.transaction(() async {
      final category = await getById(id);
      if (category == null) throw const NotFoundFailure();
      // Reminders using it lose the category (foreign key sets it to null).
      final reminders = await (_db.select(
        _db.reminders,
      )..where((r) => r.categoryId.equals(id))).map((r) => r.id).get();
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
      if (reassignTo != null) await _requeueUsersOf(reassignTo);
      for (final r in reminders) {
        await _outbox.upsert(PersonalEntity.reminder, r);
      }
    });
  }
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
    outbox: ref.watch(personalOutboxProvider),
  ),
);

final categoriesProvider =
    StreamProvider.family<List<CategoryRow>, TransactionType?>(
      (ref, type) => ref.watch(categoryRepositoryProvider).watchAll(type),
    );
