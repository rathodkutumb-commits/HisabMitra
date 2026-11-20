/// Kinds of personal records saved to the user's account, with their wire
/// names in `apply_personal_op` and `personal_sync_events`.
enum PersonalEntity {
  person('person', 'persons'),
  transaction('transaction', 'transactions'),
  ledgerEntry('ledger_entry', 'money_ledger'),
  repayment('ledger_repayment', 'money_settlements'),
  reminder('reminder', 'reminders'),
  attachment('attachment', 'attachments');

  const PersonalEntity(this.wire, this.localTable);

  /// Name used by the server.
  final String wire;

  /// Local SQLite table holding the phone's copy.
  final String localTable;

  static PersonalEntity? fromWire(String wire) {
    for (final e in values) {
      if (e.wire == wire) return e;
    }
    return null;
  }
}
