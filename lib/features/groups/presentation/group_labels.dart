import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/l10n/l10n_x.dart';
import '../domain/expense_status.dart';

extension GroupTypeX on GroupType {
  String label(AppLocalizations l) => switch (this) {
    GroupType.trip => l.groupTypeTrip,
    GroupType.family => l.groupTypeFamily,
    GroupType.friends => l.groupTypeFriends,
    GroupType.event => l.groupTypeEvent,
    GroupType.household => l.groupTypeHousehold,
    GroupType.other => l.groupTypeOther,
  };

  IconData get icon => switch (this) {
    GroupType.trip => Icons.luggage_rounded,
    GroupType.family => Icons.family_restroom_rounded,
    GroupType.friends => Icons.diversity_3_rounded,
    GroupType.event => Icons.celebration_rounded,
    GroupType.household => Icons.house_rounded,
    GroupType.other => Icons.groups_rounded,
  };
}

extension SplitMethodX on SplitMethod {
  String label(AppLocalizations l) => switch (this) {
    SplitMethod.equal => l.splitEqual,
    SplitMethod.exact => l.splitExact,
    SplitMethod.percentage => l.splitPercentage,
    SplitMethod.ratio => l.splitRatio,
    SplitMethod.adjustment => l.splitAdjustment,
  };

  String help(AppLocalizations l) => switch (this) {
    SplitMethod.equal => l.splitEqualHelp,
    SplitMethod.exact => l.splitExactHelp,
    SplitMethod.percentage => l.splitPercentageHelp,
    SplitMethod.ratio => l.splitRatioHelp,
    SplitMethod.adjustment => l.splitAdjustmentHelp,
  };
}

extension MemberRoleX on MemberRole {
  String label(AppLocalizations l) => switch (this) {
    MemberRole.owner => l.roleOwner,
    MemberRole.admin => l.roleAdmin,
    MemberRole.member => l.roleMember,
  };
}

extension ExpenseSettlementX on ExpenseSettlement {
  String label(AppLocalizations l) => switch (this) {
    ExpenseSettlement.pending => l.statusPending,
    ExpenseSettlement.partlySettled => l.statusPartlySettled,
    ExpenseSettlement.settled => l.statusSettledShort,
  };
}

String groupCategoryLabel(AppLocalizations l, String key) => switch (key) {
  'food' => l.gcatFood,
  'travel' => l.gcatTravel,
  'stay' => l.gcatStay,
  'tickets' => l.gcatTickets,
  'shopping' => l.gcatShopping,
  'groceries' => l.gcatGroceries,
  'fuel' => l.gcatFuel,
  'entertainment' => l.gcatEntertainment,
  'gifts' => l.gcatGifts,
  'utilities' => l.gcatUtilities,
  'rent' => l.gcatRent,
  _ => l.gcatOther,
};

String memberLabel(AppLocalizations l, GroupMemberRow m) =>
    m.isSelf ? l.memberYou(m.displayName) : m.displayName;
