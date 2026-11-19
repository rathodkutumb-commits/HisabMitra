import 'package:flutter_test/flutter_test.dart';
import 'package:hisabmitra/features/groups/domain/expense_status.dart';

void main() {
  const shares = {'A': 100, 'B': 100, 'C': 100};

  test('pending while every other participant still owes', () {
    expect(
      expenseStatus(
        paidBy: 'A',
        shares: shares,
        netBalances: const {'A': 200, 'B': -100, 'C': -100},
      ),
      ExpenseSettlement.pending,
    );
  });

  test('partly settled when some participants have cleared their dues', () {
    expect(
      expenseStatus(
        paidBy: 'A',
        shares: shares,
        netBalances: const {'A': 100, 'B': 0, 'C': -100},
      ),
      ExpenseSettlement.partlySettled,
    );
  });

  test('settled when no other participant owes', () {
    expect(
      expenseStatus(
        paidBy: 'A',
        shares: shares,
        netBalances: const {'A': 0, 'B': 0, 'C': 0},
      ),
      ExpenseSettlement.settled,
    );
  });

  test('payer-only expense is settled', () {
    expect(
      expenseStatus(
        paidBy: 'A',
        shares: const {'A': 300},
        netBalances: const {'A': 0},
      ),
      ExpenseSettlement.settled,
    );
  });

  test('zero-share participants are ignored', () {
    expect(
      expenseStatus(
        paidBy: 'A',
        shares: const {'A': 300, 'B': 0},
        netBalances: const {'A': 0, 'B': -50},
      ),
      ExpenseSettlement.settled,
    );
  });
}
