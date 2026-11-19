/// Domain enums shared by the database layer and features. They are stored
/// in SQLite by `name` (Drift `textEnum`), so **never rename or reorder
/// existing values** without a migration.
library;

enum TransactionType { income, expense }

enum PaymentMethod { cash, upi, bankTransfer, creditCard, debitCard, other }

/// Personal ledger direction.
/// * [given] — I gave / lent money: the person owes me (receivable).
/// * [taken] — I received / borrowed money: I owe the person (payable).
enum LedgerDirection { given, taken }

enum GroupType { trip, family, friends, event, household, other }

enum GroupStatus { active, archived }

enum MemberRole { owner, admin, member }

enum MemberStatus { active, invited, removed }

/// Group expense split methods. Participant selection applies to all of them.
/// * [equal] — split equally among selected participants.
/// * [exact] — explicit amount per participant; must add up to the total.
/// * [percentage] — basis points per participant (100 = 1%); must total 10000.
/// * [ratio] — integer weights (shares); amounts proportional to weight.
/// * [adjustment] — "unequal": equal split plus/minus a per-person adjustment.
enum SplitMethod { equal, exact, percentage, ratio, adjustment }

/// Local copy state of a cloud-capable record.
/// * [localOnly] — group is not shared to cloud; nothing to sync.
/// * [pending] — local change waiting in the outbox.
/// * [synced] — matches the server revision.
/// * [conflict] — server rejected the change; awaiting user resolution.
enum SyncState { localOnly, pending, synced, conflict }

enum ReminderKind {
  repayment,
  collection,
  groupSettlement,
  custom,

  // Recurring payments with a fixed amount (money out).
  emi,
  sip,
  installment,
  maintenance,
  insurance,
  rent,
  subscription,
  bill;

  /// Recurring payment types: they always carry a fixed amount.
  bool get isPayment => index >= ReminderKind.emi.index;

  static List<ReminderKind> get payments =>
      values.where((k) => k.isPayment).toList();
}

enum ReminderRepeat {
  none,
  daily,
  weekly,
  monthly,
  quarterly,
  halfYearly,
  yearly;

  /// Calendar months between occurrences, or null for day-based repeats.
  int? get months => switch (this) {
    monthly => 1,
    quarterly => 3,
    halfYearly => 6,
    yearly => 12,
    _ => null,
  };
}

enum ReminderStatus { pending, done, cancelled }

enum OutboxStatus { pending, failed }

enum BackupKind { manual, automatic, safety }

enum AttachmentParent { transaction, ledgerEntry, groupExpense }
