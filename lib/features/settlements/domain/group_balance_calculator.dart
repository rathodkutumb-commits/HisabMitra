import 'package:flutter/foundation.dart';

/// Minimal view of a group expense for balance maths.
@immutable
class BalanceExpense {
  const BalanceExpense({
    required this.paidBy,
    required this.amountPaise,
    required this.shares,
  });

  final String paidBy;
  final int amountPaise;

  /// memberId → share paise (sums to [amountPaise]).
  final Map<String, int> shares;
}

/// A recorded settlement: [from] paid [to].
@immutable
class BalanceSettlement {
  const BalanceSettlement({
    required this.from,
    required this.to,
    required this.amountPaise,
  });

  final String from;
  final String to;
  final int amountPaise;
}

@immutable
class SuggestedTransfer {
  const SuggestedTransfer({
    required this.from,
    required this.to,
    required this.amountPaise,
  });

  final String from;
  final String to;
  final int amountPaise;

  @override
  bool operator ==(Object other) =>
      other is SuggestedTransfer &&
      other.from == from &&
      other.to == to &&
      other.amountPaise == amountPaise;

  @override
  int get hashCode => Object.hash(from, to, amountPaise);

  @override
  String toString() => '$from → $to: $amountPaise';
}

@immutable
class MemberTotals {
  const MemberTotals({required this.paidPaise, required this.owedPaise});

  /// Total this member paid for group expenses.
  final int paidPaise;

  /// Total of this member's shares (their consumption).
  final int owedPaise;
}

/// Group balance rules (see docs/FINANCIAL_BUSINESS_RULES.md §Groups).
///
/// Net balance per member = paid − share + settlements paid − settlements
/// received. Positive → the member should receive money; negative → the
/// member owes money. Net balances always sum to zero. Historical expenses
/// are never modified by settlements; settlements are separate records.
abstract final class GroupBalanceCalculator {
  static Map<String, int> netBalances({
    required List<String> memberIds,
    required List<BalanceExpense> expenses,
    required List<BalanceSettlement> settlements,
  }) {
    final net = {for (final id in memberIds) id: 0};
    void add(String id, int delta) => net[id] = (net[id] ?? 0) + delta;

    for (final e in expenses) {
      add(e.paidBy, e.amountPaise);
      e.shares.forEach((member, share) => add(member, -share));
    }
    for (final s in settlements) {
      add(s.from, s.amountPaise);
      add(s.to, -s.amountPaise);
    }
    return net;
  }

  static Map<String, MemberTotals> memberTotals({
    required List<String> memberIds,
    required List<BalanceExpense> expenses,
  }) {
    final paid = {for (final id in memberIds) id: 0};
    final owed = {for (final id in memberIds) id: 0};
    for (final e in expenses) {
      paid[e.paidBy] = (paid[e.paidBy] ?? 0) + e.amountPaise;
      e.shares.forEach((m, s) => owed[m] = (owed[m] ?? 0) + s);
    }
    return {
      for (final id in {...paid.keys, ...owed.keys})
        id: MemberTotals(paidPaise: paid[id] ?? 0, owedPaise: owed[id] ?? 0),
    };
  }

  /// Deterministic greedy settlement plan: repeatedly the member who owes the
  /// most pays the member who is owed the most (ties broken by member id).
  /// Produces at most n−1 transfers.
  static List<SuggestedTransfer> suggestSettlements(Map<String, int> net) {
    final sum = net.values.fold<int>(0, (a, b) => a + b);
    if (sum != 0) {
      throw ArgumentError.value(net, 'net', 'Balances must sum to zero');
    }
    final credit = <String, int>{};
    final debt = <String, int>{};
    net.forEach((id, value) {
      if (value > 0) credit[id] = value;
      if (value < 0) debt[id] = -value;
    });

    String pickMax(Map<String, int> m) {
      String? best;
      for (final id in m.keys) {
        if (best == null ||
            m[id]! > m[best]! ||
            (m[id] == m[best] && id.compareTo(best) < 0)) {
          best = id;
        }
      }
      return best!;
    }

    final transfers = <SuggestedTransfer>[];
    while (credit.isNotEmpty && debt.isNotEmpty) {
      final creditor = pickMax(credit);
      final debtor = pickMax(debt);
      final amount = credit[creditor]! < debt[debtor]!
          ? credit[creditor]!
          : debt[debtor]!;
      transfers.add(
        SuggestedTransfer(from: debtor, to: creditor, amountPaise: amount),
      );
      credit[creditor] = credit[creditor]! - amount;
      debt[debtor] = debt[debtor]! - amount;
      if (credit[creditor] == 0) credit.remove(creditor);
      if (debt[debtor] == 0) debt.remove(debtor);
    }
    return transfers;
  }
}
