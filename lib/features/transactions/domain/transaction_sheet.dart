import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import 'transaction_models.dart';

/// One line of the spreadsheet (Excel-like) view of personal transactions.
@immutable
class TransactionSheetRow {
  const TransactionSheetRow({
    required this.view,
    required this.incomePaise,
    required this.expensePaise,
    required this.runningBalancePaise,
  });

  final TransactionView view;

  /// Amount in the Income column (0 for an expense).
  final int incomePaise;

  /// Amount in the Expense column (0 for an income).
  final int expensePaise;

  /// Income minus expense from the first row of the sheet up to this row.
  final int runningBalancePaise;
}

/// Spreadsheet view of personal income and expense, oldest first like a
/// paper khata, with a running balance and column totals. Money is integer
/// paise throughout. Loan principal is not included: it lives in the
/// personal ledger, not in transactions.
@immutable
class TransactionSheet {
  const TransactionSheet._(
    this.rows,
    this.totalIncomePaise,
    this.totalExpensePaise,
  );

  /// Builds the sheet from [items] in any order. Rows are sorted by date,
  /// then by entry time, then by id, so the result is deterministic.
  factory TransactionSheet.from(List<TransactionView> items) {
    final sorted = [...items]
      ..sort((a, b) {
        final byDate = a.txn.txnDate.compareTo(b.txn.txnDate);
        if (byDate != 0) return byDate;
        final byEntry = a.txn.createdAt.compareTo(b.txn.createdAt);
        if (byEntry != 0) return byEntry;
        return a.txn.id.compareTo(b.txn.id);
      });
    var income = 0;
    var expense = 0;
    final rows = <TransactionSheetRow>[];
    for (final v in sorted) {
      final isIncome = v.txn.type == TransactionType.income;
      final amount = v.txn.amountPaise;
      if (isIncome) {
        income += amount;
      } else {
        expense += amount;
      }
      rows.add(
        TransactionSheetRow(
          view: v,
          incomePaise: isIncome ? amount : 0,
          expensePaise: isIncome ? 0 : amount,
          runningBalancePaise: income - expense,
        ),
      );
    }
    return TransactionSheet._(List.unmodifiable(rows), income, expense);
  }

  final List<TransactionSheetRow> rows;
  final int totalIncomePaise;
  final int totalExpensePaise;

  int get netPaise => totalIncomePaise - totalExpensePaise;
}
