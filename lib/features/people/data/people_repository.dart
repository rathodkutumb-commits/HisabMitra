import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/providers.dart';
import '../../../core/utils/phone.dart';
import '../../money_ledger/domain/ledger_calculator.dart';

@immutable
class PersonDraft {
  const PersonDraft({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.description,
    this.notes,
  });

  final String? id;
  final String name;
  final String? phone;
  final String? email;
  final String? description;
  final String? notes;
}

@immutable
class PersonSummary {
  const PersonSummary({required this.person, required this.balance});

  final PersonRow person;
  final PersonLedgerBalance balance;
}

final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

class PeopleRepository {
  PeopleRepository(this._db, this._clock, this._ids);

  final AppDatabase _db;
  final Clock _clock;
  final IdGenerator _ids;

  Stream<List<PersonRow>> watchAll() => (_db.select(
    _db.persons,
  )..orderBy([(p) => OrderingTerm.asc(p.name)])).watch();

  Stream<PersonRow?> watchById(String id) => (_db.select(
    _db.persons,
  )..where((p) => p.id.equals(id))).watchSingleOrNull();

  Future<PersonRow?> getById(String id) => watchById(id).first;

  /// People with their ledger balances, sorted by name.
  Stream<List<PersonSummary>> watchSummaries() {
    final entries = _db.select(_db.moneyLedger).watch();
    return entries.asyncMap((rows) async {
      final persons = await (_db.select(
        _db.persons,
      )..orderBy([(p) => OrderingTerm.asc(p.name)])).get();
      final repayments = await _db.select(_db.moneySettlements).get();
      final byLedger = <String, List<int>>{};
      for (final r in repayments) {
        byLedger.putIfAbsent(r.ledgerId, () => []).add(r.amountPaise);
      }
      final byPerson = <String, List<LedgerEntryAmounts>>{};
      for (final e in rows) {
        byPerson
            .putIfAbsent(e.personId, () => [])
            .add(
              LedgerEntryAmounts(
                e.direction,
                e.principalPaise,
                byLedger[e.id] ?? const [],
              ),
            );
      }
      return [
        for (final p in persons)
          PersonSummary(
            person: p,
            balance: LedgerCalculator.personBalance(byPerson[p.id] ?? const []),
          ),
      ];
    });
  }

  Stream<PersonLedgerBalance> watchBalance(String personId) {
    final q = _db.select(_db.moneyLedger)
      ..where((l) => l.personId.equals(personId));
    return q.watch().asyncMap((entries) async {
      if (entries.isEmpty) return PersonLedgerBalance.zero;
      final repayments = await (_db.select(
        _db.moneySettlements,
      )..where((s) => s.ledgerId.isIn(entries.map((e) => e.id)))).get();
      return LedgerCalculator.personBalance([
        for (final e in entries)
          LedgerEntryAmounts(e.direction, e.principalPaise, [
            for (final r in repayments)
              if (r.ledgerId == e.id) r.amountPaise,
          ]),
      ]);
    });
  }

  Future<String> save(PersonDraft d) async {
    final name = d.name.trim();
    if (name.isEmpty) throw const ValidationFailure('required');
    String? phone;
    if (d.phone != null && d.phone!.trim().isNotEmpty) {
      phone = PhoneNumbers.normalize(d.phone!);
      if (phone == null) throw const ValidationFailure('phone');
    }
    final email = d.email?.trim();
    if (email != null && email.isNotEmpty && !_emailPattern.hasMatch(email)) {
      throw const ValidationFailure('email');
    }
    String? clean(String? s) => s == null || s.trim().isEmpty ? null : s.trim();
    final now = _clock.now();
    if (d.id == null) {
      final id = _ids.newId();
      await _db
          .into(_db.persons)
          .insert(
            PersonsCompanion.insert(
              id: id,
              name: name,
              phone: Value(phone),
              email: Value(clean(email)),
              description: Value(clean(d.description)),
              notes: Value(clean(d.notes)),
              createdAt: now,
              updatedAt: now,
            ),
          );
      return id;
    }
    final n = await (_db.update(_db.persons)..where((p) => p.id.equals(d.id!)))
        .write(
          PersonsCompanion(
            name: Value(name),
            phone: Value(phone),
            email: Value(clean(email)),
            description: Value(clean(d.description)),
            notes: Value(clean(d.notes)),
            updatedAt: Value(now),
          ),
        );
    if (n == 0) throw const NotFoundFailure();
    return d.id!;
  }

  /// Deletes a person and their (fully settled) ledger history. Refused while
  /// any amount is outstanding. Returns attachment file names to remove.
  Future<List<String>> delete(String id) => _db.transaction(() async {
    final balance = await watchBalance(id).first;
    if (balance.receivablePaise != 0 || balance.payablePaise != 0) {
      throw const ValidationFailure('person_outstanding');
    }
    final ledgerIds = await (_db.select(
      _db.moneyLedger,
    )..where((l) => l.personId.equals(id))).map((l) => l.id).get();
    final files = ledgerIds.isEmpty
        ? <String>[]
        : await (_db.select(_db.attachments)
                ..where((a) => a.ledgerEntryId.isIn(ledgerIds)))
              .map((a) => a.storedName)
              .get();
    final n = await (_db.delete(
      _db.persons,
    )..where((p) => p.id.equals(id))).go();
    if (n == 0) throw const NotFoundFailure();
    return files;
  });
}

final peopleRepositoryProvider = Provider<PeopleRepository>(
  (ref) => PeopleRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(clockProvider),
    ref.watch(idGeneratorProvider),
  ),
);

final peopleProvider = StreamProvider<List<PersonRow>>(
  (ref) => ref.watch(peopleRepositoryProvider).watchAll(),
);

final peopleSummariesProvider = StreamProvider<List<PersonSummary>>(
  (ref) => ref.watch(peopleRepositoryProvider).watchSummaries(),
);

final personProvider = StreamProvider.family<PersonRow?, String>(
  (ref, id) => ref.watch(peopleRepositoryProvider).watchById(id),
);

final personBalanceProvider =
    StreamProvider.family<PersonLedgerBalance, String>(
      (ref, id) => ref.watch(peopleRepositoryProvider).watchBalance(id),
    );
