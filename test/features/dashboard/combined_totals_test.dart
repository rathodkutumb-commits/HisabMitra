import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/core/utils/date_range.dart';
import 'package:hisabmitra/features/dashboard/application/combined_totals.dart';
import 'package:hisabmitra/features/family/data/family_repository.dart';
import 'package:hisabmitra/features/family/domain/family_models.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/test_db.dart';

/// Personal ₹50,000 in / ₹20,000 out and Family hisab ₹1,10,000 in /
/// ₹78,500 out, all this month.
Future<void> seedNovember(AppDatabase db, {bool family = true}) async {
  const clock = Clock();
  const ids = IdGenerator();
  final now = clock.now();
  final txns = TransactionRepository(db, clock, ids);
  for (final (type, paise, category) in [
    (TransactionType.income, 5000000, 'cat_salary'),
    (TransactionType.expense, 2000000, 'cat_groceries'),
  ]) {
    await txns.save(
      TransactionDraft(
        type: type,
        amountPaise: paise,
        categoryId: category,
        date: now,
        paymentMethod: PaymentMethod.upi,
      ),
    );
  }
  if (!family) return;
  final repo = FamilyRepository(db, clock, ids);
  final id = await repo.createFamily(
    const FamilyDraft(name: 'Home'),
    selfName: 'Hemang',
  );
  final me = (await repo.watchFamily(id).first)!.self!.id;
  for (final (kind, paise) in [
    (FamilyEntryKind.salary, 11000000),
    (FamilyEntryKind.expense, 7850000),
  ]) {
    await repo.saveEntry(
      FamilyEntryDraft(
        familyId: id,
        memberId: me,
        kind: kind,
        amountPaise: paise,
        date: now,
        categoryId: kind == FamilyEntryKind.expense ? 'cat_rent' : null,
      ),
    );
  }
}

void main() {
  late AppDatabase db;
  late ProviderContainer c;
  final now = DateTime.now();
  final month = DateRange.month(now.year, now.month);

  setUp(() {
    db = newTestDatabase();
    c = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() async {
    c.dispose();
    await db.close();
  });

  test('the Home totals add personal and Family hisab money', () async {
    await seedNovember(db);
    final (total, family) = await c
        .listen(combinedSummaryProvider(month).future, (_, _) {})
        .read();
    expect((total.incomePaise, total.expensePaise), (16000000, 9850000));
    expect(total.balancePaise, 6150000);
    expect((family.incomePaise, family.expensePaise), (11000000, 7850000));
  });

  test('the chart months add both too', () async {
    await seedNovember(db);
    final months = await c
        .listen(combinedMonthlyProvider.future, (_, _) {})
        .read();
    expect(months, hasLength(6));
    expect(months.last.month.start, month.start);
    expect(
      (months.last.incomePaise, months.last.expensePaise),
      (16000000, 9850000),
    );
    expect(months.first.incomePaise, 0);
  });

  test('without a Family hisab the totals are the personal ones', () async {
    await seedNovember(db, family: false);
    final (total, family) = await c
        .listen(combinedSummaryProvider(month).future, (_, _) {})
        .read();
    expect((total.incomePaise, total.expensePaise), (5000000, 2000000));
    expect((family.incomePaise, family.expensePaise), (0, 0));
  });
}
