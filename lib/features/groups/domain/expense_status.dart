enum ExpenseSettlement { pending, partlySettled, settled }

/// Settlement status of one group expense, derived from current balances.
///
/// Rule (docs/FINANCIAL_BUSINESS_RULES.md §Groups): look at the participants
/// other than the payer who have a non-zero share. The expense is
/// * settled — none of them owes anything in the group any more;
/// * partly settled — some of them still owe;
/// * pending — all of them still owe.
/// The expense record itself is never modified by settlements.
ExpenseSettlement expenseStatus({
  required String paidBy,
  required Map<String, int> shares,
  required Map<String, int> netBalances,
}) {
  final debtors = shares.entries
      .where((e) => e.key != paidBy && e.value > 0)
      .map((e) => e.key)
      .toList();
  if (debtors.isEmpty) return ExpenseSettlement.settled;
  final stillOwing = debtors.where((m) => (netBalances[m] ?? 0) < 0).length;
  if (stillOwing == 0) return ExpenseSettlement.settled;
  if (stillOwing == debtors.length) return ExpenseSettlement.pending;
  return ExpenseSettlement.partlySettled;
}
