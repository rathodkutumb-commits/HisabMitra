/// Route paths. Keep in sync with docs/SCREEN_INVENTORY.md.
abstract final class Routes {
  static const splash = '/splash';
  static const language = '/welcome/language';
  static const intro = '/welcome/intro';
  static const profileSetup = '/welcome/profile';
  static const verifyEmail = '/welcome/verify';

  /// First sync of this phone with the account (upload / download).
  static const accountSync = '/welcome/sync';

  static const home = '/home';
  static const transactions = '/transactions';
  static const people = '/people';
  static const groups = '/groups';
  static const more = '/more';

  static String newTransaction({
    String type = 'expense',
    String? personId,
    int? amountPaise,
    String? categoryId,
    String? description,
  }) => Uri(
    path: '/transactions/new',
    queryParameters: {
      'type': type,
      'personId': ?personId,
      if (amountPaise != null) 'amount': '$amountPaise',
      'category': ?categoryId,
      'description': ?description,
    },
  ).toString();
  static String transaction(String id) => '/transactions/$id';
  static String editTransaction(String id) => '/transactions/$id/edit';

  static const categories = '/categories';
  static String newCategory(String type) => '/categories/new?type=$type';
  static String editCategory(String id) => '/categories/$id/edit';

  static const newPerson = '/people/new';
  static String person(String id) => '/people/$id';
  static String editPerson(String id) => '/people/$id/edit';

  static String newLedgerEntry({
    String? personId,
    String direction = 'given',
  }) =>
      '/ledger/new?direction=$direction${personId == null ? '' : '&personId=$personId'}';
  static String ledgerEntry(String id) => '/ledger/$id';
  static String editLedgerEntry(String id) => '/ledger/$id/edit';
  static String repayLedgerEntry(String id) => '/ledger/$id/repay';
  static String ledgerHistory({String? personId}) =>
      '/ledger/history${personId == null ? '' : '?personId=$personId'}';

  static const newGroup = '/groups/new';
  static String group(String id) => '/groups/$id';
  static String editGroup(String id) => '/groups/$id/edit';
  static String groupMembers(String id) => '/groups/$id/members';
  static String newGroupExpense(String id) => '/groups/$id/expenses/new';
  static String groupExpense(String id, String expenseId) =>
      '/groups/$id/expenses/$expenseId';
  static String editGroupExpense(String id, String expenseId) =>
      '/groups/$id/expenses/$expenseId/edit';
  static String groupSettle(
    String id, {
    String? from,
    String? to,
    int? amount,
  }) {
    final q = [
      if (from != null) 'from=$from',
      if (to != null) 'to=$to',
      if (amount != null) 'amount=$amount',
    ].join('&');
    return '/groups/$id/settle${q.isEmpty ? '' : '?$q'}';
  }

  static String groupSettlements(String id) => '/groups/$id/settlements';
  static String groupBalances(String id) => '/groups/$id/balances';
  static String groupInvite(String id) => '/groups/$id/invite';
  // Under the Groups tab, so back from it (or from the group it opens)
  // returns to Groups.
  static const joinGroup = '/groups/join';
  static String joinGroupWithCode(String code) =>
      '$joinGroup?code=${Uri.encodeQueryComponent(code)}';

  // Family hisab: one list, then one screen per Family hisab.
  static const family = '/family';
  static const newFamily = '/family/new';
  static String familyHome(String id) => '/family/$id';
  static String editFamily(String id) => '/family/$id/edit';
  static String familyPeople(String id) => '/family/$id/people';
  static String familyInvite(String id, {String? memberId}) =>
      '/family/$id/invite${memberId == null ? '' : '?member=$memberId'}';
  static String newFamilyEntry(String id, {required String kind}) =>
      '/family/$id/entries/new?kind=$kind';
  static String editFamilyEntry(String id, String entryId) =>
      '/family/$id/entries/$entryId/edit';
  static String familyStatement(
    String id, {
    required int year,
    required int month,
  }) => '/family/$id/statement?year=$year&month=$month';

  static const calculator = '/calculator';
  static const reports = '/reports';
  static String report(String kind) => '/reports/$kind';
  static const ai = '/ai';
  static const reminders = '/reminders';
  static String newReminder({
    String? ledgerId,
    String? groupId,
    String? personId,
    bool payment = false,
  }) {
    final q = [
      if (ledgerId != null) 'ledgerId=$ledgerId',
      if (groupId != null) 'groupId=$groupId',
      if (personId != null) 'personId=$personId',
      if (payment) 'payment=1',
    ].join('&');
    return '/reminders/new${q.isEmpty ? '' : '?$q'}';
  }

  static String editReminder(String id) => '/reminders/$id/edit';
  static String attachment(String id) => '/attachments/$id';
  static const backup = '/backup';
  static const sync = '/sync';
  static const settings = '/settings';
  static const profile = '/profile';
  static const about = '/about';
}
