// Drift CHECK constraints reference the column getter itself
// (e.g. `amountPaise.isBiggerThanValue(0)`); that is the documented API.
// ignore_for_file: recursive_getters

import 'package:drift/drift.dart';

import '../domain/enums.dart';

// ---------------------------------------------------------------------------
// Conventions
//  * Primary keys are client-generated UUID v4 strings (TD-02).
//  * Money columns are INTEGER paise and named *_paise (TD-01).
//  * DateTimes are stored as unix seconds (Drift default).
//  * Local-only personal tables are hard-deleted. Cloud-capable group tables
//    carry `deletedAt` tombstones, `revision` and `syncState` (see
//    docs/SYNC_ARCHITECTURE.md).
// ---------------------------------------------------------------------------

mixin Timestamps on Table {
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Columns for rows that can be synchronised with Supabase.
mixin SyncColumns on Table {
  /// Server revision this local row is based on (0 = never synced).
  IntColumn get revision => integer().withDefault(const Constant(0))();
  TextColumn get syncState =>
      textEnum<SyncState>().withDefault(const Constant('localOnly'))();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// Upload state of a personal record (schema v4). Personal records are saved
/// to the user's account; the phone keeps a working copy.
mixin PersonalSyncColumns on Table {
  /// Server revision this local row is based on (0 = never uploaded).
  IntColumn get revision => integer().withDefault(const Constant(0))();
  TextColumn get syncState =>
      textEnum<SyncState>().withDefault(const Constant('localOnly'))();
}

// ----------------------------------------------------------- user & settings

@DataClassName('LocalUserProfileRow')
class LocalUserProfile extends Table with Timestamps {
  @override
  String get tableName => 'local_user_profile';

  /// Always `self` — single row table.
  TextColumn get id => text()();
  TextColumn get displayName => text().withLength(min: 1, max: 80)();

  /// Mobile number in E.164 (compulsory at sign-up; not SMS-verified).
  TextColumn get phone => text().nullable()();

  /// Email address, verified by a code or link at sign-up (schema v3).
  TextColumn get email => text().nullable()();

  /// Supabase auth user id once the user has signed in.
  TextColumn get remoteUserId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Non-sensitive key/value preferences (theme, language, …). Secrets are
/// never stored here (TD-16).
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  @override
  String get tableName => 'app_settings';

  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('BackupHistoryRow')
@TableIndex(name: 'idx_backup_history_created', columns: {#createdAt})
class BackupHistory extends Table {
  @override
  String get tableName => 'backup_history';

  TextColumn get id => text()();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get sha256 => text()();
  BoolColumn get encrypted => boolean().withDefault(const Constant(false))();
  TextColumn get kind => textEnum<BackupKind>()();
  IntColumn get schemaVersion => integer()();
  TextColumn get appVersion => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ------------------------------------------------------- personal finance

@DataClassName('CategoryRow')
@TableIndex(name: 'idx_categories_type', columns: {#type, #sortOrder})
class Categories extends Table with Timestamps {
  @override
  String get tableName => 'categories';

  TextColumn get id => text()();

  /// Stable key of a built-in category (localised name in the UI). `null`
  /// for user-created categories or once a built-in one is renamed.
  TextColumn get systemKey => text().nullable().unique()();
  TextColumn get name => text().withLength(min: 1, max: 60)();

  /// Gujarati name of a custom category (shown when the app is in Gujarati).
  /// Null for built-in categories and for custom ones made before 1.3.0.
  TextColumn get nameGu => text().withLength(min: 1, max: 60).nullable()();
  TextColumn get type => textEnum<TransactionType>()();
  TextColumn get iconKey => text()();
  IntColumn get colorValue => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PersonRow')
@TableIndex(name: 'idx_persons_name', columns: {#name})
class Persons extends Table with Timestamps, PersonalSyncColumns {
  @override
  String get tableName => 'persons';

  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TransactionRow')
@TableIndex(name: 'idx_transactions_date', columns: {#txnDate})
@TableIndex(name: 'idx_transactions_category', columns: {#categoryId})
@TableIndex(name: 'idx_transactions_person', columns: {#personId})
class Transactions extends Table with Timestamps, PersonalSyncColumns {
  @override
  String get tableName => 'transactions';

  TextColumn get id => text()();

  /// `self` locally, or the Supabase user id once signed in.
  TextColumn get ownerId => text()();
  TextColumn get type => textEnum<TransactionType>()();
  IntColumn get amountPaise =>
      integer().check(amountPaise.isBiggerThanValue(0))();
  TextColumn get categoryId =>
      text().references(Categories, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get txnDate => dateTime()();
  TextColumn get paymentMethod => textEnum<PaymentMethod>()();
  TextColumn get personId =>
      text().nullable().references(Persons, #id, onDelete: KeyAction.setNull)();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ------------------------------------------------------- personal ledger

@DataClassName('LedgerEntryRow')
@TableIndex(name: 'idx_ledger_person', columns: {#personId})
@TableIndex(name: 'idx_ledger_due', columns: {#dueDate})
class MoneyLedger extends Table with Timestamps, PersonalSyncColumns {
  @override
  String get tableName => 'money_ledger';

  TextColumn get id => text()();
  TextColumn get personId =>
      text().references(Persons, #id, onDelete: KeyAction.cascade)();
  TextColumn get direction => textEnum<LedgerDirection>()();
  IntColumn get principalPaise =>
      integer().check(principalPaise.isBiggerThanValue(0))();
  DateTimeColumn get entryDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get paymentMethod => textEnum<PaymentMethod>()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Repayments against a ledger entry. Never edited silently: amounts can be
/// corrected only through an explicit edit that keeps `updatedAt`.
@DataClassName('LedgerRepaymentRow')
@TableIndex(name: 'idx_settlements_ledger', columns: {#ledgerId})
class MoneySettlements extends Table with Timestamps, PersonalSyncColumns {
  @override
  String get tableName => 'money_settlements';

  TextColumn get id => text()();
  TextColumn get ledgerId =>
      text().references(MoneyLedger, #id, onDelete: KeyAction.cascade)();
  IntColumn get amountPaise =>
      integer().check(amountPaise.isBiggerThanValue(0))();
  DateTimeColumn get settledOn => dateTime()();
  TextColumn get paymentMethod => textEnum<PaymentMethod>()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ------------------------------------------------------------------ groups

@DataClassName('GroupRow')
class GroupsCache extends Table with Timestamps, SyncColumns {
  @override
  String get tableName => 'groups_cache';

  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get description => text().nullable()();
  TextColumn get groupType => textEnum<GroupType>()();

  /// Local member id (or Supabase user id for shared groups) of the creator.
  TextColumn get createdBy => text()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  TextColumn get status =>
      textEnum<GroupStatus>().withDefault(const Constant('active'))();

  /// True once the owner shared the group to the cloud (TD-06).
  BoolColumn get isShared => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GroupMemberRow')
@TableIndex(name: 'idx_members_group', columns: {#groupId})
class GroupMembersCache extends Table with Timestamps, SyncColumns {
  @override
  String get tableName => 'group_members_cache';

  TextColumn get id => text()();
  TextColumn get groupId =>
      text().references(GroupsCache, #id, onDelete: KeyAction.cascade)();

  /// Supabase auth user id for authenticated members; null for local-only
  /// participants (who never get cloud access).
  TextColumn get userId => text().nullable()();
  TextColumn get displayName => text().withLength(min: 1, max: 80)();
  TextColumn get phone => text().nullable()();
  TextColumn get personId =>
      text().nullable().references(Persons, #id, onDelete: KeyAction.setNull)();
  TextColumn get role =>
      textEnum<MemberRole>().withDefault(const Constant('member'))();
  TextColumn get status =>
      textEnum<MemberStatus>().withDefault(const Constant('active'))();

  /// The member representing the device owner.
  BoolColumn get isSelf => boolean().withDefault(const Constant(false))();
  DateTimeColumn get joinedAt => dateTime()();

  /// Stable display order — also used for deterministic remainder
  /// distribution in splits.
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GroupExpenseRow')
@TableIndex(name: 'idx_gexp_group_date', columns: {#groupId, #expenseDate})
class GroupExpensesCache extends Table with Timestamps, SyncColumns {
  @override
  String get tableName => 'group_expenses_cache';

  TextColumn get id => text()();
  TextColumn get groupId =>
      text().references(GroupsCache, #id, onDelete: KeyAction.cascade)();
  TextColumn get description => text().withLength(min: 1, max: 120)();

  /// Category key from the group category list (food, travel, stay, …).
  TextColumn get categoryKey => text()();
  IntColumn get amountPaise =>
      integer().check(amountPaise.isBiggerThanValue(0))();
  TextColumn get paidByMemberId =>
      text().references(GroupMembersCache, #id, onDelete: KeyAction.restrict)();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get splitMethod => textEnum<SplitMethod>()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('GroupSplitRow')
@TableIndex(name: 'idx_gsplit_expense', columns: {#expenseId})
class GroupExpenseSplitsCache extends Table {
  @override
  String get tableName => 'group_expense_splits_cache';

  TextColumn get id => text()();
  TextColumn get expenseId =>
      text().references(GroupExpensesCache, #id, onDelete: KeyAction.cascade)();
  TextColumn get memberId =>
      text().references(GroupMembersCache, #id, onDelete: KeyAction.restrict)();
  IntColumn get sharePaise =>
      integer().check(sharePaise.isBiggerOrEqualValue(0))();

  /// Raw user input for the split method: exact paise, basis points, weight
  /// or adjustment paise. Kept so the split can be edited faithfully.
  IntColumn get inputValue => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {expenseId, memberId},
  ];
}

@DataClassName('GroupSettlementRow')
@TableIndex(name: 'idx_gsettle_group', columns: {#groupId, #settledOn})
class GroupSettlementsCache extends Table with Timestamps, SyncColumns {
  @override
  String get tableName => 'group_settlements_cache';

  TextColumn get id => text()();
  TextColumn get groupId =>
      text().references(GroupsCache, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('settlementsPaid')
  TextColumn get fromMemberId =>
      text().references(GroupMembersCache, #id, onDelete: KeyAction.restrict)();
  @ReferenceName('settlementsReceived')
  TextColumn get toMemberId =>
      text().references(GroupMembersCache, #id, onDelete: KeyAction.restrict)();
  IntColumn get amountPaise =>
      integer().check(amountPaise.isBiggerThanValue(0))();
  DateTimeColumn get settledOn => dateTime()();
  TextColumn get paymentMethod => textEnum<PaymentMethod>()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK (from_member_id <> to_member_id)',
  ];
}

// ------------------------------------------------------------- attachments

/// Files stored in app-private storage. Exactly one parent column is set.
/// Group-expense attachments may additionally be shared to cloud storage
/// (`remotePath`) — only when the user explicitly shares them.
@DataClassName('AttachmentRow')
@TableIndex(name: 'idx_att_txn', columns: {#transactionId})
@TableIndex(name: 'idx_att_ledger', columns: {#ledgerEntryId})
@TableIndex(name: 'idx_att_gexp', columns: {#groupExpenseId})
class Attachments extends Table with PersonalSyncColumns {
  @override
  String get tableName => 'attachments';

  TextColumn get id => text()();
  TextColumn get transactionId => text().nullable().references(
    Transactions,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get ledgerEntryId => text().nullable().references(
    MoneyLedger,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get groupExpenseId => text().nullable().references(
    GroupExpensesCache,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Path relative to the app attachments directory.
  TextColumn get storedName => text()();
  TextColumn get originalName => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get sha256 => text()();
  TextColumn get remotePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'CHECK ((transaction_id IS NOT NULL) + (ledger_entry_id IS NOT NULL) '
        '+ (group_expense_id IS NOT NULL) = 1)',
  ];
}

// --------------------------------------------------------------- reminders

@DataClassName('ReminderRow')
@TableIndex(name: 'idx_reminders_due', columns: {#status, #dueAt})
class Reminders extends Table with Timestamps, PersonalSyncColumns {
  @override
  String get tableName => 'reminders';

  TextColumn get id => text()();
  TextColumn get kind => textEnum<ReminderKind>()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get dueAt => dateTime()();
  TextColumn get repeat =>
      textEnum<ReminderRepeat>().withDefault(const Constant('none'))();
  TextColumn get personId =>
      text().nullable().references(Persons, #id, onDelete: KeyAction.setNull)();
  TextColumn get ledgerEntryId => text().nullable().references(
    MoneyLedger,
    #id,
    onDelete: KeyAction.cascade,
  )();
  TextColumn get groupId => text().nullable().references(
    GroupsCache,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Fixed amount for recurring payments (EMI, SIP, maintenance, …). (v2)
  IntColumn get amountPaise =>
      integer().nullable().check(amountPaise.isBiggerThanValue(0))();

  /// Expense category used when the payment is recorded. (v2)
  TextColumn get categoryId => text().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// Day of month the schedule is anchored to, so a payment due on the 31st
  /// returns to the 31st after a short month. Null → day of [dueAt]. (v2)
  IntColumn get anchorDay =>
      integer().nullable().check(anchorDay.isBetweenValues(1, 31))();

  /// Number of payments in the series (e.g. 24 EMIs); null = no end. (v2)
  IntColumn get totalOccurrences =>
      integer().nullable().check(totalOccurrences.isBiggerOrEqualValue(1))();

  /// How many occurrences have been completed (paid). (v2)
  IntColumn get completedOccurrences => integer()
      .withDefault(const Constant(0))
      .check(completedOccurrences.isBiggerOrEqualValue(0))();

  /// 31-bit id used by the Android notification scheduler.
  IntColumn get notificationId => integer().unique()();
  TextColumn get status =>
      textEnum<ReminderStatus>().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

// --------------------------------------------------------- synchronisation

/// Local operations waiting to be pushed to the server. Written in the same
/// DB transaction as the change itself.
@DataClassName('OutboxRow')
@TableIndex(name: 'idx_outbox_status', columns: {#status, #createdAt})
class SyncOutbox extends Table {
  @override
  String get tableName => 'sync_outbox';

  /// Idempotency key sent to the server.
  TextColumn get opId => text()();

  /// `group` or `personal` (v4). Personal rows use an empty [groupId].
  TextColumn get scope => text().withDefault(const Constant('group'))();
  TextColumn get groupId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  /// `upsert` or `delete`.
  TextColumn get opType => text()();
  TextColumn get payload => text()();
  IntColumn get baseRevision => integer()();
  TextColumn get status =>
      textEnum<OutboxStatus>().withDefault(const Constant('pending'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {opId};
}

/// Server change events received but not yet applied (or kept for audit).
@DataClassName('InboxRow')
class SyncInbox extends Table {
  @override
  String get tableName => 'sync_inbox';

  /// Server event sequence number (monotonic).
  IntColumn get seq => integer()();

  /// `group` or `personal` (v4). Personal rows use an empty [groupId].
  TextColumn get scope => text().withDefault(const Constant('group'))();
  TextColumn get groupId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get opType => text()();
  TextColumn get payload => text()();
  IntColumn get remoteRevision => integer()();
  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get appliedAt => dateTime().nullable()();
  TextColumn get error => text().nullable()();

  /// Operation that caused the event (personal feed; v4).
  TextColumn get opId => text().nullable()();

  /// Group and personal feeds number their events separately (v4).
  @override
  Set<Column> get primaryKey => {scope, seq};
}

@DataClassName('ConflictRow')
@TableIndex(name: 'idx_conflicts_open', columns: {#resolvedAt})
class SyncConflicts extends Table {
  @override
  String get tableName => 'sync_conflicts';

  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get opId => text().nullable()();

  /// `group` or `personal` (v4). Personal rows use an empty [groupId].
  TextColumn get scope => text().withDefault(const Constant('group'))();
  TextColumn get localPayload => text()();
  TextColumn get remotePayload => text().nullable()();
  IntColumn get remoteRevision => integer()();
  DateTimeColumn get detectedAt => dateTime()();
  DateTimeColumn get resolvedAt => dateTime().nullable()();

  /// `keepLocal` / `keepRemote`.
  TextColumn get resolution => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
