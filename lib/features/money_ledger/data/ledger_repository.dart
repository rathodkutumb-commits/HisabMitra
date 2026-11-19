import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/money/money.dart';
import '../../../core/providers.dart';
import '../../../core/utils/stream_combine.dart' as combine;
import '../domain/ledger_calculator.dart';
import '../domain/ledger_models.dart';

/// Personal money given/taken ledger. Principal and repayments are kept
/// apart from income/expense so they are never double counted.
class LedgerRepository {
  LedgerRepository(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  late final Expression<int> _attachmentCount = const CustomExpression<int>(
    '(SELECT COUNT(*) FROM attachments a WHERE a.ledger_entry_id = "money_ledger"."id")',
  );

  /// Watches entries joined with person + repayments. Re-emits when any of
  /// the three tables change.
  Stream<List<LedgerEntryView>> watchEntries({
    String? personId,
    bool onlyOpen = false,
  }) {
    final l = _db.moneyLedger;
    final q =
        _db.select(l).join([
            innerJoin(_db.persons, _db.persons.id.equalsExp(l.personId)),
          ])
          ..addColumns([_attachmentCount])
          ..orderBy([
            OrderingTerm.desc(l.entryDate),
            OrderingTerm.desc(l.createdAt),
          ]);
    if (personId != null) q.where(l.personId.equals(personId));

    return combine.combineLatest2(
      q.watch(),
      _db.select(_db.moneySettlements).watch(),
      (rows, repayments) {
        final byLedger = <String, List<LedgerRepaymentRow>>{};
        for (final r in repayments) {
          byLedger.putIfAbsent(r.ledgerId, () => []).add(r);
        }
        for (final list in byLedger.values) {
          list.sort((a, b) {
            final c = a.settledOn.compareTo(b.settledOn);
            return c != 0 ? c : a.createdAt.compareTo(b.createdAt);
          });
        }
        final views = <LedgerEntryView>[];
        for (final row in rows) {
          final entry = row.readTable(l);
          final reps = byLedger[entry.id] ?? const <LedgerRepaymentRow>[];
          final summary = LedgerCalculator.summarize(
            principalPaise: entry.principalPaise,
            repaymentsPaise: [for (final r in reps) r.amountPaise],
          );
          if (onlyOpen && summary.status == LedgerStatus.settled) continue;
          views.add(
            LedgerEntryView(
              entry: entry,
              person: row.readTable(_db.persons),
              repayments: reps,
              summary: summary,
              attachmentCount: row.read(_attachmentCount) ?? 0,
            ),
          );
        }
        return views;
      },
    );
  }

  Stream<LedgerEntryView?> watchEntry(String id) => watchEntries().map(
    (all) => all.where((e) => e.entry.id == id).firstOrNull,
  );

  /// Open entries with a due date before [before] (exclusive), soonest first.
  Stream<List<LedgerEntryView>> watchDueBefore(DateTime before) =>
      watchEntries(onlyOpen: true).map((all) {
        final due =
            all
                .where(
                  (e) =>
                      e.entry.dueDate != null &&
                      e.entry.dueDate!.isBefore(before),
                )
                .toList()
              ..sort((a, b) => a.entry.dueDate!.compareTo(b.entry.dueDate!));
        return due;
      });

  Stream<PersonLedgerBalance> watchTotals() => watchEntries().map(
    (all) => LedgerCalculator.personBalance([
      for (final e in all)
        LedgerEntryAmounts(e.entry.direction, e.entry.principalPaise, [
          for (final r in e.repayments) r.amountPaise,
        ]),
    ]),
  );

  Stream<List<RepaymentHistoryItem>> watchRepaymentHistory({String? personId}) {
    final s = _db.moneySettlements;
    final q =
        _db.select(s).join([
          innerJoin(_db.moneyLedger, _db.moneyLedger.id.equalsExp(s.ledgerId)),
          innerJoin(
            _db.persons,
            _db.persons.id.equalsExp(_db.moneyLedger.personId),
          ),
        ])..orderBy([
          OrderingTerm.desc(s.settledOn),
          OrderingTerm.desc(s.createdAt),
        ]);
    if (personId != null) q.where(_db.moneyLedger.personId.equals(personId));
    return q.watch().map(
      (rows) => [
        for (final r in rows)
          RepaymentHistoryItem(
            repayment: r.readTable(s),
            entry: r.readTable(_db.moneyLedger),
            person: r.readTable(_db.persons),
          ),
      ],
    );
  }

  Future<String> saveEntry(LedgerDraft d) async {
    if (d.principalPaise <= 0 || d.principalPaise > Money.maxPaise) {
      throw const ValidationFailure('amount_positive');
    }
    return _db.transaction(() async {
      final now = _clock.now();
      String? clean(String? s) =>
          s == null || s.trim().isEmpty ? null : s.trim();
      if (d.id == null) {
        final id = _ids.newId();
        await _db
            .into(_db.moneyLedger)
            .insert(
              MoneyLedgerCompanion.insert(
                id: id,
                personId: d.personId,
                direction: d.direction,
                principalPaise: d.principalPaise,
                entryDate: d.date,
                dueDate: Value(d.dueDate),
                paymentMethod: d.paymentMethod,
                description: Value(d.description.trim()),
                notes: Value(clean(d.notes)),
                createdAt: now,
                updatedAt: now,
              ),
            );
        return id;
      }
      final repaid = await _repaidTotal(d.id!);
      if (d.principalPaise < repaid) {
        throw const ValidationFailure('principal_below_repaid');
      }
      final n =
          await (_db.update(
            _db.moneyLedger,
          )..where((l) => l.id.equals(d.id!))).write(
            MoneyLedgerCompanion(
              personId: Value(d.personId),
              direction: Value(d.direction),
              principalPaise: Value(d.principalPaise),
              entryDate: Value(d.date),
              dueDate: Value(d.dueDate),
              paymentMethod: Value(d.paymentMethod),
              description: Value(d.description.trim()),
              notes: Value(clean(d.notes)),
              updatedAt: Value(now),
            ),
          );
      if (n == 0) throw const NotFoundFailure();
      return d.id!;
    });
  }

  Future<int> _repaidTotal(String ledgerId) async {
    final sum = _db.moneySettlements.amountPaise.sum();
    final row =
        await (_db.selectOnly(_db.moneySettlements)
              ..addColumns([sum])
              ..where(_db.moneySettlements.ledgerId.equals(ledgerId)))
            .getSingle();
    return row.read(sum) ?? 0;
  }

  /// Records a repayment. If it exceeds the outstanding amount it is
  /// rejected with [RepaymentExceedsFailure], unless the user explicitly
  /// chose [recordExcessAsAdvance]: then the entry is settled in full and the
  /// excess becomes a new entry in the opposite direction — atomically.
  Future<String> addRepayment(
    RepaymentDraft d, {
    bool recordExcessAsAdvance = false,
    String advanceDescription = 'Advance / credit',
  }) => _db.transaction(() async {
    final entry = await (_db.select(
      _db.moneyLedger,
    )..where((l) => l.id.equals(d.ledgerId))).getSingleOrNull();
    if (entry == null) throw const NotFoundFailure();
    final outstanding = entry.principalPaise - await _repaidTotal(entry.id);
    final check = LedgerCalculator.validateRepayment(
      outstandingPaise: outstanding,
      amountPaise: d.amountPaise,
    );
    var amount = d.amountPaise;
    int? excess;
    switch (check) {
      case RepaymentOk():
        break;
      case RepaymentInvalidAmount():
        throw const ValidationFailure('amount_positive');
      case RepaymentExceedsOutstanding(:final excessPaise):
        if (!recordExcessAsAdvance) throw RepaymentExceedsFailure(excessPaise);
        amount = outstanding;
        excess = excessPaise;
    }
    final now = _clock.now();
    final notes = d.notes?.trim();
    final id = _ids.newId();
    if (amount > 0) {
      await _db
          .into(_db.moneySettlements)
          .insert(
            MoneySettlementsCompanion.insert(
              id: id,
              ledgerId: entry.id,
              amountPaise: amount,
              settledOn: d.date,
              paymentMethod: d.paymentMethod,
              notes: Value(notes == null || notes.isEmpty ? null : notes),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    if (excess != null && excess > 0) {
      await _db
          .into(_db.moneyLedger)
          .insert(
            MoneyLedgerCompanion.insert(
              id: _ids.newId(),
              personId: entry.personId,
              direction: entry.direction == LedgerDirection.given
                  ? LedgerDirection.taken
                  : LedgerDirection.given,
              principalPaise: excess,
              entryDate: d.date,
              paymentMethod: d.paymentMethod,
              description: Value(advanceDescription),
              createdAt: now,
              updatedAt: now,
            ),
          );
    }
    return id;
  });

  Future<void> deleteRepayment(String id) async {
    final n = await (_db.delete(
      _db.moneySettlements,
    )..where((s) => s.id.equals(id))).go();
    if (n == 0) throw const NotFoundFailure();
  }

  /// Deletes an entry with its repayment history. Returns attachment files.
  Future<List<String>> deleteEntry(String id) => _db.transaction(() async {
    final files = await (_db.select(
      _db.attachments,
    )..where((a) => a.ledgerEntryId.equals(id))).map((a) => a.storedName).get();
    final n = await (_db.delete(
      _db.moneyLedger,
    )..where((l) => l.id.equals(id))).go();
    if (n == 0) throw const NotFoundFailure();
    return files;
  });
}

final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => LedgerRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final ledgerEntriesProvider =
    StreamProvider.family<
      List<LedgerEntryView>,
      ({String? personId, bool onlyOpen})
    >(
      (ref, args) => ref
          .watch(ledgerRepositoryProvider)
          .watchEntries(personId: args.personId, onlyOpen: args.onlyOpen),
    );

final ledgerEntryProvider = StreamProvider.family<LedgerEntryView?, String>(
  (ref, id) => ref.watch(ledgerRepositoryProvider).watchEntry(id),
);

final ledgerTotalsProvider = StreamProvider<PersonLedgerBalance>(
  (ref) => ref.watch(ledgerRepositoryProvider).watchTotals(),
);

final repaymentHistoryProvider =
    StreamProvider.family<List<RepaymentHistoryItem>, String?>(
      (ref, personId) => ref
          .watch(ledgerRepositoryProvider)
          .watchRepaymentHistory(personId: personId),
    );
