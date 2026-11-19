# HisabMitra — Architecture

## 1. Principles

1. **Local-first, offline-first.** SQLite (Drift) is the system of record for all personal data. Every core feature works with no network.
2. **Private by default.** Personal transactions, people, ledger, attachments and reminders never leave the device unless the user exports or backs them up. Only groups the user explicitly *shares to cloud* are synchronised.
3. **Deterministic money.** All amounts are `int` paise. Business rules live in pure-Dart domain services with unit tests. Widgets never compute money.
4. **Layered, feature-first.** Each feature owns its presentation, application (providers/controllers), domain and data code. UI never talks to Drift or Supabase directly.
5. **Honest integrations.** External services (Supabase, AI provider, GitHub) sit behind interfaces. When not configured they report "not configured" — no fake responses in production paths.

## 2. Layers

```
Presentation   Widgets/screens (features/*/presentation)
     │  watches / calls
Application    Riverpod providers & Notifiers (features/*/application)
     │  uses
Domain         Entities, value types, pure services (features/*/domain, core/money)
     │  implemented by
Data           Repositories over Drift DAOs, CloudGateway, file stores (features/*/data)
     │
Infrastructure Drift database, Supabase client, secure storage, notifications, file system (core/*)
```

Dependency rule: arrows point downward only. Domain has no Flutter imports.

## 3. Folder structure

```
lib/
  main.dart                 bootstrap (DB open, services, ProviderScope)
  app/
    app.dart                MaterialApp.router, theme + locale wiring
    router/                 GoRouter config, route names, shell scaffold
    theme/                  palettes, ThemeData builders, ThemeExtension, patterns
    config/                 AppConfig from --dart-define (Supabase, GitHub, AI)
  l10n/                     ARB files (en, gu) → generated AppLocalizations
  core/
    database/               Drift AppDatabase, tables, migrations, DAOs
    money/                  Paise formatting/parsing, MoneyMath
    errors/                 AppFailure hierarchy, error → localized message mapping
    security/               SafeLogger, secure storage wrapper
    services/               clock, id generator, file storage, notifications, share
    widgets/                reusable branded components
    utils/                  date ranges, validators
  features/
    onboarding/ authentication/ dashboard/ transactions/ categories/
    people/ money_ledger/ groups/ settlements/ reports/ calculator/
    attachments/ reminders/ ai_assistant/ backup/ synchronization/
    settings/ profile/ gujarati_input/ about/
assets/ fonts/ images/ patterns/
supabase/ migrations/ functions/ tests/
test/ integration_test/ docs/ tool/
```

## 4. State management (Riverpod)

- `appDatabaseProvider` — single `AppDatabase` instance (overridden in tests with an in-memory DB).
- Repository providers (`transactionRepositoryProvider`, …) depend on the database provider.
- Read models are exposed as `StreamProvider`s driven by Drift `watch()` queries, so every screen updates live after writes.
- Mutations go through Notifier/controller classes that validate input, call repositories inside DB transactions, and surface `AppFailure`s.
- Settings (`settingsControllerProvider`) hold theme, locale, finance and privacy preferences persisted in the `app_settings` table.

## 5. Navigation (GoRouter)

- `StatefulShellRoute.indexedStack` with five branches: **Home**, **Transactions**, **People** (ledger), **Groups**, **More**.
- Full-screen routes (forms, details, calculator, reports, AI, backup, settings…) are pushed above the shell.
- A redirect guard sends first-run users to onboarding (splash → language → intro). Authentication is **not** a global gate; cloud screens check session state themselves.

## 6. Data flow examples

**Add expense:** Form → `TransactionFormController.save()` → validates (amount > 0, category of matching type) → `TransactionRepository.upsert()` inside a Drift transaction (row + attachment rows) → Drift stream emits → Dashboard & list rebuild.

**Group expense on a shared group:** `GroupRepository.addExpense()` writes expense + splits locally **and** an outbox operation in the same DB transaction → `SyncService` (when online and signed in) pushes the op to the `apply_group_op` RPC → server checks membership + revision → on success the local row's `syncState` becomes `synced` with the server revision; on conflict a `sync_conflicts` row is created for user resolution.

## 7. Cloud architecture (Supabase)

- **Auth:** phone + OTP. Identity = `auth.users.id`.
- **Tables:** `user_profiles`, `user_devices`, `groups`, `group_members`, `group_expenses`, `group_expense_splits`, `group_settlements`, `group_attachments`, `group_invitations`, `sync_events`, `processed_ops`.
- **RLS:** enabled on every table. Access is derived from `is_group_member(group_id)` (SECURITY DEFINER, `search_path` pinned).
- **Writes:** clients never write group tables directly. All mutations go through `apply_group_op(op jsonb)` which enforces idempotency (op id), authorisation, and optimistic concurrency (`revision`).
- **Reads/sync:** clients read `sync_events` after a cursor (`seq`); RLS returns only events of groups the caller belongs to. `get_group_snapshot` loads a whole group after joining.
- **Invitations:** `create_group_invitation`, `accept_group_invitation`, `cancel_group_invitation` RPCs with hashed codes and expiry.
- **Edge Function:** `delete-account` (needs service role to remove `auth.users`).

See `SYNC_ARCHITECTURE.md` and `RLS_SECURITY.md`.

## 8. Platform integration

| Need | Approach |
|---|---|
| Contacts | Android system contact picker intent via a small method channel — **no READ_CONTACTS permission needed**. |
| Attachments | `image_picker` (camera/gallery), `file_picker` (PDF); copied into app-private `files/attachments/`. |
| Notifications | `flutter_local_notifications` + timezone; permission requested when the first reminder is created. |
| Share/export | `share_plus`; PDFs via `pdf` with Flutter-rendered pages. |
| Updates | GitHub Releases API → download APK to app cache → SHA-256 verify → hand to Android package installer (user confirms). |
