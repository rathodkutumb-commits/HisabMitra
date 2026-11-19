import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/core/database/app_database.dart';
import 'package:hisabmitra/core/providers.dart';
import 'package:hisabmitra/core/utils/date_range.dart';
import 'package:hisabmitra/features/groups/data/group_repository.dart';
import 'package:hisabmitra/features/groups/domain/group_models.dart';
import 'package:hisabmitra/features/groups/domain/split_calculator.dart';
import 'package:hisabmitra/features/money_ledger/data/ledger_repository.dart';
import 'package:hisabmitra/features/money_ledger/domain/ledger_models.dart';
import 'package:hisabmitra/features/people/data/people_repository.dart';
import 'package:hisabmitra/features/reports/data/report_service.dart';
import 'package:hisabmitra/features/transactions/data/transaction_repository.dart';
import 'package:hisabmitra/features/transactions/domain/transaction_models.dart';

import '../../helpers/test_db.dart';

class _Fixed extends Clock {
  @override
  DateTime now() => DateTime(2026, 3, 20);
}

void main() {
  late AppDatabase db;
  late ReportService reports;
  final march = DateRange.month(2026, 3);

  setUp(() async {
    db = newTestDatabase();
    final clock = _Fixed();
    const ids = IdGenerator();
    final txns = TransactionRepository(db, clock, ids);
    final people = PeopleRepository(db, clock, ids);
    final ledger = LedgerRepository(db, clock, ids);
    final groups = GroupRepository(db, clock, ids);
    reports = ReportService(txns, ledger, groups);

    Future<void> txn(
      TransactionType type,
      int paise,
      String cat,
      int day, {
      PaymentMethod m = PaymentMethod.upi,
    }) => txns.save(
      TransactionDraft(
        type: type,
        amountPaise: paise,
        categoryId: cat,
        date: DateTime(2026, 3, day),
        paymentMethod: m,
        description: 'x$paise',
      ),
    );
    await txn(
      TransactionType.income,
      5000000,
      'cat_salary',
      1,
      m: PaymentMethod.bankTransfer,
    );
    await txn(
      TransactionType.expense,
      300000,
      'cat_rent',
      2,
      m: PaymentMethod.bankTransfer,
    );
    await txn(TransactionType.expense, 45000, 'cat_food', 5);
    await txn(
      TransactionType.expense,
      12000,
      'cat_food',
      6,
      m: PaymentMethod.cash,
    );

    final rahul = await people.save(const PersonDraft(name: 'Rahul'));
    final loan = await ledger.saveEntry(
      LedgerDraft(
        personId: rahul,
        direction: LedgerDirection.given,
        principalPaise: 500000,
        date: DateTime(2026, 3, 3),
        paymentMethod: PaymentMethod.cash,
      ),
    );
    await ledger.addRepayment(
      RepaymentDraft(
        ledgerId: loan,
        amountPaise: 200000,
        date: DateTime(2026, 3, 10),
        paymentMethod: PaymentMethod.upi,
      ),
    );

    final g = await groups.createGroup(
      const GroupDraft(name: 'Goa', groupType: GroupType.trip),
      selfName: 'Me',
      members: const [MemberDraft(name: 'Amit')],
    );
    final detail = await groups.watchGroup(g).first;
    final me = detail!.selfMember!.id;
    final amit = detail.members.last.id;
    await groups.saveExpense(
      ExpenseDraft(
        groupId: g,
        description: 'Hotel',
        categoryKey: 'stay',
        amountPaise: 800000,
        paidByMemberId: me,
        date: DateTime(2026, 3, 12),
        splitMethod: SplitMethod.equal,
        participants: [SplitParticipant(me, 0), SplitParticipant(amit, 0)],
      ),
    );
    await groups.recordSettlement(
      SettlementDraft(
        groupId: g,
        fromMemberId: amit,
        toMemberId: me,
        amountPaise: 100000,
        date: DateTime(2026, 3, 15),
        paymentMethod: PaymentMethod.upi,
      ),
    );
  });
  tearDown(() => db.close());

  test('income/expense exclude loan principal and repayments', () async {
    final r = await reports.load(march);
    expect(r.summary.incomePaise, 5000000);
    expect(r.summary.expensePaise, 357000);
    expect(r.summary.balancePaise, 4643000);
  });

  test('category and payment-method breakdowns', () async {
    final r = await reports.load(march);
    expect(r.expenseByCategory.first.category.id, 'cat_rent');
    expect(r.expenseByCategory.last.totalPaise, 57000);
    final upi = r.expenseByMethod.firstWhere(
      (m) => m.method == PaymentMethod.upi,
    );
    expect(upi.totalPaise, 45000);
  });

  test('person-wise lending in the period', () async {
    final r = await reports.load(march);
    final rahul = r.people.single;
    expect(rahul.givenPaise, 500000);
    expect(rahul.receivedBackPaise, 200000);
    expect(rahul.outstandingReceivablePaise, 300000);
    expect(r.loansGivenPaise, 500000);
    expect(r.repaymentsReceivedPaise, 200000);
  });

  test('group expenses and settlements in the period', () async {
    final r = await reports.load(march);
    final goa = r.groups.single;
    expect(goa.spentPaise, 800000);
    expect(goa.mySharePaise, 400000);
    expect(goa.myPaidPaise, 800000);
    expect(goa.settlementsPaise, 100000);
    expect(r.groupSettlementsPaise, 100000);
  });

  test('top expenses sorted by amount', () async {
    final r = await reports.load(march);
    expect(r.topExpenses.map((t) => t.txn.amountPaise).toList(), [
      300000,
      45000,
      12000,
    ]);
  });

  test('a period with no data is all zero', () async {
    final r = await reports.load(DateRange.month(2025, 1));
    expect(r.summary.incomePaise, 0);
    expect(r.people.single.givenPaise, 0);
    expect(r.groups, isEmpty);
  });
}
