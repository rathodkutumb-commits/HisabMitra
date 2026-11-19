# Entity Relationship Diagrams

Column details: `DATABASE_SCHEMA.md` (local, generated) and
`supabase/migrations/` (cloud).

## Local SQLite (Drift, schema v2)

```mermaid
erDiagram
  categories ||--o{ transactions : "category_id (restrict)"
  persons |o--o{ transactions : "person_id (set null)"
  persons ||--o{ money_ledger : "person_id (cascade)"
  money_ledger ||--o{ money_settlements : "ledger_id (cascade)"
  groups_cache ||--o{ group_members_cache : "group_id (cascade)"
  persons |o--o{ group_members_cache : "person_id (set null)"
  groups_cache ||--o{ group_expenses_cache : "group_id (cascade)"
  group_members_cache ||--o{ group_expenses_cache : "paid_by (restrict)"
  group_expenses_cache ||--|{ group_expense_splits_cache : "expense_id (cascade)"
  group_members_cache ||--o{ group_expense_splits_cache : "member_id (restrict)"
  groups_cache ||--o{ group_settlements_cache : "group_id (cascade)"
  group_members_cache ||--o{ group_settlements_cache : "from / to (restrict)"
  transactions |o--o{ attachments : "exactly one parent"
  money_ledger |o--o{ attachments : ""
  group_expenses_cache |o--o{ attachments : ""
  persons |o--o{ reminders : "person_id"
  money_ledger |o--o{ reminders : "ledger_entry_id"
  groups_cache |o--o{ reminders : "group_id"
  categories |o--o{ reminders : "category_id (recurring payments)"
```

Stand-alone tables: `local_user_profile`, `app_settings`, `backup_history`,
`sync_outbox`, `sync_inbox`, `sync_conflicts` (linked to groups by
`group_id` value, not by foreign key, so queued operations survive local
deletes).

## Cloud (Supabase PostgreSQL)

```mermaid
erDiagram
  auth_users ||--|| user_profiles : "id"
  auth_users ||--o{ user_devices : "user_id"
  auth_users |o--o{ groups : "owner_id"
  groups ||--o{ group_members : "group_id"
  auth_users |o--o{ group_members : "user_id (one per group)"
  groups ||--o{ group_expenses : "group_id"
  group_members ||--o{ group_expenses : "paid_by_member_id"
  group_expenses ||--|{ group_expense_splits : "expense_id"
  group_members ||--o{ group_expense_splits : "member_id"
  groups ||--o{ group_settlements : "group_id"
  group_members ||--o{ group_settlements : "from / to"
  group_expenses ||--o{ group_attachments : "expense_id"
  groups ||--o{ group_invitations : "group_id"
  group_members |o--o| group_invitations : "member_id (one pending)"
  groups ||--o{ sync_events : "group_id"
```

`processed_ops` (idempotency log) has no foreign keys and no client access.

Local ↔ cloud mapping: `groups_cache` ↔ `groups`, `group_members_cache` ↔
`group_members`, `group_expenses_cache` + `group_expense_splits_cache` ↔
`group_expenses` + `group_expense_splits`, `group_settlements_cache` ↔
`group_settlements`. Ids are identical on both sides (client UUIDs).
Personal tables have no cloud counterpart.
