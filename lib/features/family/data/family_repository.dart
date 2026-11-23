import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/l10n/l10n_x.dart';
import '../../../core/providers.dart';
import '../../../core/utils/date_range.dart';
import '../../../core/utils/stream_combine.dart';
import '../../categories/presentation/category_labels.dart';
import '../../synchronization/application/sync_controller.dart';
import '../../transactions/domain/transaction_models.dart';
import '../domain/family_models.dart';
import '../domain/passbook.dart';

@immutable
class FamilyDraft {
  const FamilyDraft({
    this.id,
    required this.name,
    this.startingBalancePaise = 0,
  });

  final String? id;
  final String name;

  /// Money already in the home when the Family hisab starts.
  final int startingBalancePaise;
}

/// A person in a Family hisab: a name and, if known, a mobile number.
@immutable
class FamilyPersonDraft {
  const FamilyPersonDraft({
    this.id,
    this.familyId,
    required this.name,
    this.phone,
  });

  final String? id;

  /// Needed for [FamilyRepository.savePerson]; ignored when creating.
  final String? familyId;
  final String name;
  final String? phone;
}

@immutable
class FamilyEntryDraft {
  const FamilyEntryDraft({
    this.id,
    required this.familyId,
    required this.memberId,
    required this.kind,
    required this.amountPaise,
    required this.date,
    this.categoryId,
    this.note,
  });

  final String? id;
  final String familyId;
  final String memberId;
  final FamilyEntryKind kind;
  final int amountPaise;
  final DateTime date;

  /// Required for money out (an expense category).
  final String? categoryId;
  final String? note;
}

/// A Family hisab with its people (removed ones too, so old entries keep
/// their names) and its live entries.
@immutable
class FamilyDetail {
  const FamilyDetail({
    required this.family,
    required this.members,
    required this.entries,
  });

  final FamilyRow family;

  /// Active people first (in order), then removed people.
  final List<FamilyMemberRow> members;
  final List<FamilyEntry> entries;

  FamilyMemberRow? get self => members.where((m) => m.isSelf).firstOrNull;

  List<FamilyMemberRow> get activeMembers =>
      members.where((m) => m.status == 'active').toList();

  /// A person's name; removed people are marked "(removed)".
  String memberName(String id, AppLocalizations l) {
    final m = members.where((x) => x.id == id).firstOrNull;
    if (m == null) return '?';
    return m.status == 'removed' ? l.familyPersonRemoved(m.name) : m.name;
  }

  MonthStatement month(int year, int month) => passbookMonth(
    startingBalancePaise: family.openingBalancePaise,
    entries: entries,
    memberOrder: [for (final m in members) m.id],
    year: year,
    month: month,
  );
}

/// Family hisab on the phone. Every change is written together with its
/// upload (scope `family`) in one transaction; the account is the main copy.
class FamilyRepository {
  FamilyRepository(
    this._db,
    this._clock,
    this._ids, {
    String? Function()? currentUserId,
  }) : _currentUserId = currentUserId ?? (() => null);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;
  final String? Function() _currentUserId;

  // ----------------------------------------------------------------- reads

  Stream<List<FamilyRow>> watchFamilies() =>
      (_db.select(_db.familyHisabsCache)
            ..where((f) => f.deletedAt.isNull())
            ..orderBy([(f) => OrderingTerm.asc(f.createdAt)]))
          .watch();

  Stream<FamilyDetail?> watchFamily(String id) {
    final family =
        (_db.select(_db.familyHisabsCache)
              ..where((f) => f.id.equals(id) & f.deletedAt.isNull()))
            .watchSingleOrNull();
    final members =
        (_db.select(_db.familyMembersCache)
              ..where((m) => m.familyId.equals(id))
              ..orderBy([
                (m) => OrderingTerm.asc(m.status), // 'active' before 'removed'
                (m) => OrderingTerm.asc(m.sortOrder),
              ]))
            .watch();
    final entries = _entries(familyId: id).watch();
    return combineLatest3(
      family,
      members,
      entries,
      (f, ms, es) => f == null
          ? null
          : FamilyDetail(
              family: f,
              members: ms,
              entries: [for (final e in es) FamilyEntry.fromRow(e)],
            ),
    );
  }

  Stream<MonthStatement> watchMonth(String id, int year, int month) =>
      watchFamily(id).where((d) => d != null).map((d) => d!.month(year, month));

  /// Money in and out of every Family hisab within [range].
  Stream<PeriodSummary> watchSummary(DateRange range) => _entries().watch().map(
    (rows) => familyPeriodSummary([
      for (final r in rows) FamilyEntry.fromRow(r),
    ], range),
  );

  /// Month-by-month money in and out of every Family hisab.
  Stream<List<MonthTotals>> watchMonthly({
    required DateTime from,
    required int months,
  }) => _entries().watch().map(
    (rows) => familyMonthlyTotals(
      [for (final r in rows) FamilyEntry.fromRow(r)],
      from: from,
      months: months,
    ),
  );

  /// Live entries (of one Family hisab, or of every live one).
  SimpleSelectStatement<$FamilyEntriesCacheTable, FamilyEntryRow> _entries({
    String? familyId,
  }) {
    final q = _db.select(_db.familyEntriesCache)
      ..where((e) => e.deletedAt.isNull());
    if (familyId != null) {
      q.where((e) => e.familyId.equals(familyId));
    } else {
      q.where(
        (e) => e.familyId.isInQuery(
          _db.selectOnly(_db.familyHisabsCache)
            ..addColumns([_db.familyHisabsCache.id])
            ..where(_db.familyHisabsCache.deletedAt.isNull()),
        ),
      );
    }
    return q;
  }

  // ---------------------------------------------------------------- writes

  Future<String> createFamily(
    FamilyDraft d, {
    required String selfName,
    List<FamilyPersonDraft> people = const [],
  }) async {
    final name = d.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    return _db.transaction(() async {
      final now = _clock.now();
      final id = _ids.newId();
      final selfId = _ids.newId();
      final me = selfName.trim().isEmpty ? 'Me' : selfName.trim();
      await _db
          .into(_db.familyHisabsCache)
          .insert(
            FamilyHisabsCacheCompanion.insert(
              id: id,
              name: name,
              openingBalancePaise: Value(d.startingBalancePaise),
              ownerUserId: Value(_currentUserId()),
              syncState: const Value(SyncState.pending),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _db
          .into(_db.familyMembersCache)
          .insert(
            FamilyMembersCacheCompanion.insert(
              id: selfId,
              familyId: id,
              userId: Value(_currentUserId()),
              name: me,
              role: const Value('owner'),
              isSelf: const Value(true),
              syncState: const Value(SyncState.pending),
              createdAt: now,
              updatedAt: now,
            ),
          );
      await _enqueue(id, 'family', id, false, 0, {
        'name': name,
        'opening_balance_paise': d.startingBalancePaise,
        'owner_member_id': selfId,
        'owner_display_name': me,
      }, now);
      var order = 1;
      for (final p in people) {
        await _insertPerson(id, p, order++, now);
      }
      return id;
    });
  }

  Future<void> updateFamily(FamilyDraft d) async {
    final name = d.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    return _db.transaction(() async {
      final f = await _family(d.id!);
      final now = _clock.now();
      await (_db.update(
        _db.familyHisabsCache,
      )..where((x) => x.id.equals(f.id))).write(
        FamilyHisabsCacheCompanion(
          name: Value(name),
          openingBalancePaise: Value(d.startingBalancePaise),
          syncState: const Value(SyncState.pending),
          updatedAt: Value(now),
        ),
      );
      await _enqueue(f.id, 'family', f.id, false, f.revision, {
        'name': name,
        'opening_balance_paise': d.startingBalancePaise,
      }, now);
    });
  }

  Future<void> deleteFamily(String id) => _db.transaction(() async {
    final f = await _family(id);
    final now = _clock.now();
    await (_db.update(
      _db.familyHisabsCache,
    )..where((x) => x.id.equals(id))).write(
      FamilyHisabsCacheCompanion(
        deletedAt: Value(now),
        syncState: const Value(SyncState.pending),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(id, 'family', id, true, f.revision, const {}, now);
  });

  Future<String> savePerson(FamilyPersonDraft d) => _db.transaction(() async {
    final now = _clock.now();
    if (d.id == null) {
      final familyId = d.familyId;
      if (familyId == null) throw const ValidationFailure('required');
      final count = await _db
          .select(_db.familyMembersCache)
          .get()
          .then((ms) => ms.where((m) => m.familyId == familyId).length);
      return _insertPerson(familyId, d, count, now);
    }
    final m = await (_db.select(
      _db.familyMembersCache,
    )..where((x) => x.id.equals(d.id!))).getSingle();
    final name = d.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    final phone = _clean(d.phone);
    await (_db.update(
      _db.familyMembersCache,
    )..where((x) => x.id.equals(m.id))).write(
      FamilyMembersCacheCompanion(
        name: Value(name),
        phone: Value(phone),
        syncState: const Value(SyncState.pending),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(m.familyId, 'member', m.id, false, m.revision, {
      'name': name,
      'phone': phone,
      'sort_order': m.sortOrder,
    }, now);
    return m.id;
  });

  /// Removes a person; their entries stay (shown as "Name (removed)").
  Future<void> deletePerson(String id) => _db.transaction(() async {
    final m = await (_db.select(
      _db.familyMembersCache,
    )..where((x) => x.id.equals(id))).getSingle();
    if (m.role == 'owner') throw const ValidationFailure('forbidden');
    final now = _clock.now();
    await (_db.update(
      _db.familyMembersCache,
    )..where((x) => x.id.equals(id))).write(
      FamilyMembersCacheCompanion(
        status: const Value('removed'),
        deletedAt: Value(now),
        syncState: const Value(SyncState.pending),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(m.familyId, 'member', id, true, m.revision, const {}, now);
  });

  Future<String> saveEntry(FamilyEntryDraft d) async {
    if (d.amountPaise <= 0) throw const ValidationFailure('amount');
    final isExpense = d.kind == FamilyEntryKind.expense;
    if (isExpense && d.categoryId == null) {
      throw const ValidationFailure('category');
    }
    return _db.transaction(() async {
      final now = _clock.now();
      final category = isExpense
          ? await (_db.select(
              _db.categories,
            )..where((c) => c.id.equals(d.categoryId!))).getSingleOrNull()
          : null;
      if (isExpense && category == null) {
        throw const ValidationFailure('category');
      }
      final names = category == null ? null : _categoryNames(category);
      final existing = d.id == null
          ? null
          : await (_db.select(
              _db.familyEntriesCache,
            )..where((e) => e.id.equals(d.id!))).getSingleOrNull();
      final id = existing?.id ?? d.id ?? _ids.newId();
      final row = FamilyEntriesCacheCompanion(
        id: Value(id),
        familyId: Value(d.familyId),
        memberId: Value(d.memberId),
        kind: Value(d.kind.wire),
        amountPaise: Value(d.amountPaise),
        entryDate: Value(DateTime(d.date.year, d.date.month, d.date.day)),
        // Money out keeps a copy of its category (the category itself stays
        // on this phone only).
        categoryId: Value(category?.id),
        categoryName: Value(names?.$1),
        categoryNameGu: Value(names?.$2),
        categoryIcon: Value(category?.iconKey),
        categoryColor: Value(category?.colorValue),
        note: Value(_clean(d.note)),
        syncState: const Value(SyncState.pending),
        updatedAt: Value(now),
      );
      if (existing == null) {
        await _db
            .into(_db.familyEntriesCache)
            .insert(row.copyWith(createdAt: Value(now)));
      } else {
        await (_db.update(
          _db.familyEntriesCache,
        )..where((e) => e.id.equals(id))).write(row);
      }
      await _enqueue(d.familyId, 'entry', id, false, existing?.revision ?? 0, {
        'member_id': d.memberId,
        'kind': d.kind.wire,
        'amount_paise': d.amountPaise,
        'entry_date': _date(d.date),
        'category_id': category?.id,
        'category_name': names?.$1,
        'category_name_gu': names?.$2,
        'category_icon': category?.iconKey,
        'category_color': category?.colorValue,
        'note': _clean(d.note),
      }, now);
      return id;
    });
  }

  Future<void> deleteEntry(String id) => _db.transaction(() async {
    final e = await (_db.select(
      _db.familyEntriesCache,
    )..where((x) => x.id.equals(id))).getSingle();
    final now = _clock.now();
    await (_db.update(
      _db.familyEntriesCache,
    )..where((x) => x.id.equals(id))).write(
      FamilyEntriesCacheCompanion(
        deletedAt: Value(now),
        syncState: const Value(SyncState.pending),
        updatedAt: Value(now),
      ),
    );
    await _enqueue(e.familyId, 'entry', id, true, e.revision, const {}, now);
  });

  // --------------------------------------------------------------- helpers

  Future<FamilyRow> _family(String id) async {
    final f = await (_db.select(
      _db.familyHisabsCache,
    )..where((x) => x.id.equals(id))).getSingleOrNull();
    if (f == null) throw const NotFoundFailure();
    return f;
  }

  Future<String> _insertPerson(
    String familyId,
    FamilyPersonDraft p,
    int order,
    DateTime now,
  ) async {
    final name = p.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    final id = p.id ?? _ids.newId();
    final phone = _clean(p.phone);
    await _db
        .into(_db.familyMembersCache)
        .insert(
          FamilyMembersCacheCompanion.insert(
            id: id,
            familyId: familyId,
            name: name,
            phone: Value(phone),
            sortOrder: Value(order),
            syncState: const Value(SyncState.pending),
            createdAt: now,
            updatedAt: now,
          ),
        );
    await _enqueue(familyId, 'member', id, false, 0, {
      'name': name,
      'phone': phone,
      'sort_order': order,
    }, now);
    return id;
  }

  /// A category's English and Gujarati names: built-in ones by their
  /// translations, custom ones as typed (Gujarati may be missing).
  static (String, String?) _categoryNames(CategoryRow c) => c.systemKey == null
      ? (c.name, c.nameGu)
      : (
          c.label(lookupAppLocalizations(const Locale('en'))),
          c.label(lookupAppLocalizations(const Locale('gu'))),
        );

  Future<void> _enqueue(
    String familyId,
    String entityType,
    String entityId,
    bool delete,
    int baseRevision,
    Map<String, Object?> payload,
    DateTime now,
  ) => _db
      .into(_db.syncOutbox)
      .insert(
        SyncOutboxCompanion.insert(
          opId: _ids.newId(),
          scope: const Value('family'),
          groupId: familyId,
          entityType: entityType,
          entityId: entityId,
          opType: delete ? 'delete' : 'upsert',
          payload: jsonEncode(payload),
          baseRevision: baseRevision,
          createdAt: now,
        ),
      );

  static String? _clean(String? s) =>
      s == null || s.trim().isEmpty ? null : s.trim();

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

final familyRepositoryProvider = Provider<FamilyRepository>(
  (ref) => FamilyRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
    currentUserId: () => ref.read(cloudGatewayProvider).currentSession?.userId,
  ),
);

final familiesProvider = StreamProvider<List<FamilyRow>>(
  (ref) => ref.watch(familyRepositoryProvider).watchFamilies(),
);

final familyDetailProvider = StreamProvider.family<FamilyDetail?, String>(
  (ref, id) => ref.watch(familyRepositoryProvider).watchFamily(id),
);

final familySummaryProvider = StreamProvider.family<PeriodSummary, DateRange>(
  (ref, range) => ref.watch(familyRepositoryProvider).watchSummary(range),
);
