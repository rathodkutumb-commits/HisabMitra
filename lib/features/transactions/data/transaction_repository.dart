import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/utils/date_range.dart';
import '../domain/transaction_models.dart';

/// Income/expense records. Personal data only — never synchronised.
class TransactionRepository {
  TransactionRepository(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  late final Expression<int> _attachmentCount = const CustomExpression<int>(
    '(SELECT COUNT(*) FROM attachments a WHERE a.transaction_id = "transactions"."id")',
  );

  JoinedSelectStatement<HasResultSet, dynamic> _joined() {
    final t = _db.transactions;
    return _db.select(t).join([
      innerJoin(_db.categories, _db.categories.id.equalsExp(t.categoryId)),
      leftOuterJoin(_db.persons, _db.persons.id.equalsExp(t.personId)),
    ])..addColumns([_attachmentCount]);
  }

  TransactionView _map(TypedResult r) => TransactionView(
    txn: r.readTable(_db.transactions),
    category: r.readTable(_db.categories),
    person: r.readTableOrNull(_db.persons),
    attachmentCount: r.read(_attachmentCount) ?? 0,
  );

  Stream<List<TransactionView>> watch(TransactionFilter f) {
    final t = _db.transactions;
    final q = _joined();
    if (f.range != null) {
      q.where(
        t.txnDate.isBiggerOrEqualValue(f.range!.start) &
            t.txnDate.isSmallerThanValue(f.range!.endExclusive),
      );
    }
    if (f.type != null) q.where(t.type.equalsValue(f.type));
    if (f.categoryId != null) q.where(t.categoryId.equals(f.categoryId!));
    if (f.paymentMethod != null) {
      q.where(t.paymentMethod.equalsValue(f.paymentMethod));
    }
    if (f.personId != null) q.where(t.personId.equals(f.personId!));
    final query = f.query.trim().toLowerCase();
    if (query.isNotEmpty) {
      final pattern = '%${_escapeLike(query)}%';
      Expression<bool> m(Expression<String> e) =>
          e.lower().like(pattern, escapeChar: r'\');
      q.where(
        m(t.description) |
            m(t.notes) |
            m(_db.categories.name) |
            m(_db.persons.name),
      );
    }
    q.orderBy([OrderingTerm.desc(t.txnDate), OrderingTerm.desc(t.createdAt)]);
    if (f.limit != null) q.limit(f.limit!);
    return q.watch().map((rows) => rows.map(_map).toList());
  }

  Stream<TransactionView?> watchById(String id) {
    final q = _joined()..where(_db.transactions.id.equals(id));
    return q.watchSingleOrNull().map((r) => r == null ? null : _map(r));
  }

  Future<TransactionView?> getById(String id) => watchById(id).first;

  Future<String> save(TransactionDraft d) async {
    if (d.amountPaise <= 0 || d.amountPaise > Money.maxPaise) {
      throw const ValidationFailure('amount_positive');
    }
    return _db.transaction(() async {
      final category = await (_db.select(
        _db.categories,
      )..where((c) => c.id.equals(d.categoryId))).getSingleOrNull();
      if (category == null || category.type != d.type) {
        throw const ValidationFailure('category_type');
      }
      final now = _clock.now();
      final date = DateRange.dateOnly(d.date);
      final description = d.description.trim();
      final notes = d.notes?.trim();
      if (d.id == null) {
        final id = _ids.newId();
        await _db
            .into(_db.transactions)
            .insert(
              TransactionsCompanion.insert(
                id: id,
                ownerId: localOwnerId,
                type: d.type,
                amountPaise: d.amountPaise,
                categoryId: d.categoryId,
                txnDate: date,
                paymentMethod: d.paymentMethod,
                personId: Value(d.personId),
                description: Value(description),
                notes: Value(notes == null || notes.isEmpty ? null : notes),
                createdAt: now,
                updatedAt: now,
              ),
            );
        return id;
      }
      final updated =
          await (_db.update(
            _db.transactions,
          )..where((t) => t.id.equals(d.id!))).write(
            TransactionsCompanion(
              type: Value(d.type),
              amountPaise: Value(d.amountPaise),
              categoryId: Value(d.categoryId),
              txnDate: Value(date),
              paymentMethod: Value(d.paymentMethod),
              personId: Value(d.personId),
              description: Value(description),
              notes: Value(notes == null || notes.isEmpty ? null : notes),
              updatedAt: Value(now),
            ),
          );
      if (updated == 0) throw const NotFoundFailure();
      return d.id!;
    });
  }

  /// Deletes the record (attachment rows cascade). Returns the stored file
  /// names of removed attachments so the caller can delete the files.
  Future<List<String>> delete(String id) => _db.transaction(() async {
    final files = await (_db.select(
      _db.attachments,
    )..where((a) => a.transactionId.equals(id))).map((a) => a.storedName).get();
    final count = await (_db.delete(
      _db.transactions,
    )..where((t) => t.id.equals(id))).go();
    if (count == 0) throw const NotFoundFailure();
    return files;
  });

  // ------------------------------------------------------------ aggregates

  Expression<bool> _inRange(DateRange r) =>
      _db.transactions.txnDate.isBiggerOrEqualValue(r.start) &
      _db.transactions.txnDate.isSmallerThanValue(r.endExclusive);

  Stream<PeriodSummary> watchSummary(DateRange range) {
    final t = _db.transactions;
    final sum = t.amountPaise.sum();
    final q = _db.selectOnly(t)
      ..addColumns([t.type, sum])
      ..where(_inRange(range))
      ..groupBy([t.type]);
    return q.watch().map((rows) {
      var income = 0;
      var expense = 0;
      for (final r in rows) {
        final type = t.type.converter.fromSql(r.read(t.type)!);
        if (type == TransactionType.income) income = r.read(sum) ?? 0;
        if (type == TransactionType.expense) expense = r.read(sum) ?? 0;
      }
      return PeriodSummary(incomePaise: income, expensePaise: expense);
    });
  }

  Stream<List<CategoryTotal>> watchCategoryTotals(
    DateRange range,
    TransactionType type,
  ) {
    final t = _db.transactions;
    final sum = t.amountPaise.sum();
    final count = t.id.count();
    final q =
        _db.select(t).join([
            innerJoin(
              _db.categories,
              _db.categories.id.equalsExp(t.categoryId),
            ),
          ])
          ..addColumns([sum, count])
          ..where(_inRange(range) & t.type.equalsValue(type))
          ..groupBy([t.categoryId])
          ..orderBy([OrderingTerm.desc(sum)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          CategoryTotal(
            category: r.readTable(_db.categories),
            totalPaise: r.read(sum) ?? 0,
            count: r.read(count) ?? 0,
          ),
      ],
    );
  }

  Stream<List<PaymentMethodTotal>> watchPaymentMethodTotals(
    DateRange range,
    TransactionType type,
  ) {
    final t = _db.transactions;
    final sum = t.amountPaise.sum();
    final count = t.id.count();
    final q = _db.selectOnly(t)
      ..addColumns([t.paymentMethod, sum, count])
      ..where(_inRange(range) & t.type.equalsValue(type))
      ..groupBy([t.paymentMethod])
      ..orderBy([OrderingTerm.desc(sum)]);
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          PaymentMethodTotal(
            method: t.paymentMethod.converter.fromSql(r.read(t.paymentMethod)!),
            totalPaise: r.read(sum) ?? 0,
            count: r.read(count) ?? 0,
          ),
      ],
    );
  }

  /// Income/expense per month bucket (buckets must be ascending).
  Stream<List<MonthTotals>> watchMonthly(List<DateRange> months) {
    if (months.isEmpty) return Stream.value(const []);
    final span = DateRange(months.first.start, months.last.endExclusive);
    final t = _db.transactions;
    final q = _db.selectOnly(t)
      ..addColumns([t.txnDate, t.type, t.amountPaise])
      ..where(_inRange(span));
    return q.watch().map((rows) {
      final income = List<int>.filled(months.length, 0);
      final expense = List<int>.filled(months.length, 0);
      for (final r in rows) {
        final date = r.read(t.txnDate)!;
        final index = months.indexWhere((m) => m.contains(date));
        if (index < 0) continue;
        final amount = r.read(t.amountPaise)!;
        if (t.type.converter.fromSql(r.read(t.type)!) ==
            TransactionType.income) {
          income[index] += amount;
        } else {
          expense[index] += amount;
        }
      }
      return [
        for (var i = 0; i < months.length; i++)
          MonthTotals(
            month: months[i],
            incomePaise: income[i],
            expensePaise: expense[i],
          ),
      ];
    });
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final transactionsProvider =
    StreamProvider.family<List<TransactionView>, TransactionFilter>(
      (ref, filter) => ref.watch(transactionRepositoryProvider).watch(filter),
    );

final transactionProvider = StreamProvider.family<TransactionView?, String>(
  (ref, id) => ref.watch(transactionRepositoryProvider).watchById(id),
);

final periodSummaryProvider = StreamProvider.family<PeriodSummary, DateRange>(
  (ref, range) => ref.watch(transactionRepositoryProvider).watchSummary(range),
);
