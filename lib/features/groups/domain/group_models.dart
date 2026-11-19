import 'dart:collection';

import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../settlements/domain/group_balance_calculator.dart';
import 'split_calculator.dart';

@immutable
class GroupDraft {
  const GroupDraft({
    this.id,
    required this.name,
    this.description,
    required this.groupType,
  });

  final String? id;
  final String name;
  final String? description;
  final GroupType groupType;
}

@immutable
class MemberDraft {
  const MemberDraft({this.id, required this.name, this.phone, this.personId});

  final String? id;
  final String name;
  final String? phone;
  final String? personId;
}

@immutable
class ExpenseDraft {
  const ExpenseDraft({
    this.id,
    required this.groupId,
    required this.description,
    required this.categoryKey,
    required this.amountPaise,
    required this.paidByMemberId,
    required this.date,
    required this.splitMethod,
    required this.participants,
    this.notes,
  });

  final String? id;
  final String groupId;
  final String description;
  final String categoryKey;
  final int amountPaise;
  final String paidByMemberId;
  final DateTime date;
  final SplitMethod splitMethod;
  final List<SplitParticipant> participants;
  final String? notes;

  ExpenseDraft copyWith({String? id}) => ExpenseDraft(
    id: id ?? this.id,
    groupId: groupId,
    description: description,
    categoryKey: categoryKey,
    amountPaise: amountPaise,
    paidByMemberId: paidByMemberId,
    date: date,
    splitMethod: splitMethod,
    participants: participants,
    notes: notes,
  );
}

@immutable
class SettlementDraft {
  const SettlementDraft({
    required this.groupId,
    required this.fromMemberId,
    required this.toMemberId,
    required this.amountPaise,
    required this.date,
    required this.paymentMethod,
    this.notes,
  });

  final String groupId;
  final String fromMemberId;
  final String toMemberId;
  final int amountPaise;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? notes;
}

@immutable
class ExpenseView {
  const ExpenseView({
    required this.expense,
    required this.splits,
    required this.splitInputs,
    this.attachmentCount = 0,
  });

  final GroupExpenseRow expense;

  /// memberId → share paise in member display order.
  final LinkedHashMap<String, int> splits;

  /// memberId → raw split input (for editing).
  final Map<String, int?> splitInputs;
  final int attachmentCount;
}

@immutable
class GroupDetail {
  const GroupDetail({
    required this.group,
    required this.members,
    required this.allMembers,
    required this.expenses,
    required this.settlements,
    required this.netBalances,
    required this.memberTotals,
    required this.suggestions,
  });

  final GroupRow group;

  /// Active members in display order.
  final List<GroupMemberRow> members;

  /// Including removed members (history still references them).
  final Map<String, GroupMemberRow> allMembers;

  /// Newest first.
  final List<ExpenseView> expenses;

  /// Newest first.
  final List<GroupSettlementRow> settlements;
  final Map<String, int> netBalances;
  final Map<String, MemberTotals> memberTotals;
  final List<SuggestedTransfer> suggestions;

  int get totalSpentPaise =>
      expenses.fold(0, (sum, e) => sum + e.expense.amountPaise);

  GroupMemberRow? get selfMember => members.where((m) => m.isSelf).firstOrNull;

  String memberName(String id) => allMembers[id]?.displayName ?? '—';

  bool get isSettled => netBalances.values.every((v) => v == 0);
}

@immutable
class GroupListItem {
  const GroupListItem({
    required this.group,
    required this.memberCount,
    required this.totalSpentPaise,
    required this.myNetPaise,
    required this.lastActivity,
  });

  final GroupRow group;
  final int memberCount;
  final int totalSpentPaise;

  /// Positive → the group owes me; negative → I owe.
  final int myNetPaise;
  final DateTime lastActivity;
}

@immutable
class MyGroupsSummary {
  const MyGroupsSummary({
    required this.activeGroups,
    required this.iOwePaise,
    required this.owedToMePaise,
  });

  final int activeGroups;
  final int iOwePaise;
  final int owedToMePaise;
}

/// Category keys available for group expenses.
abstract final class GroupExpenseCategories {
  static const Map<String, IconData> all = {
    'food': Icons.restaurant_rounded,
    'travel': Icons.directions_car_rounded,
    'stay': Icons.hotel_rounded,
    'tickets': Icons.confirmation_number_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'groceries': Icons.local_grocery_store_rounded,
    'fuel': Icons.local_gas_station_rounded,
    'entertainment': Icons.celebration_rounded,
    'gifts': Icons.redeem_rounded,
    'utilities': Icons.bolt_rounded,
    'rent': Icons.home_rounded,
    'other': Icons.more_horiz_rounded,
  };

  static IconData icon(String key) => all[key] ?? Icons.more_horiz_rounded;
}
