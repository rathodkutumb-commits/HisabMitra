# Bilingual Categories Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Every income and expense category has an English and a Gujarati name, entered in the category form, and the app shows the one for its current language everywhere.

**Architecture:** Built-in categories are already translated through `systemKey`. Custom categories gain a nullable `nameGu` column (phone schema v5) and the server's transaction snapshot gains `category_name_gu`. The single display helper `CategoryRowX.label(l)` picks the name by language, so screens, reports and exports follow automatically; search and the AI assistant also match the Gujarati name.

**Tech Stack:** Flutter/Dart, Drift (stepByStep migrations, `drift_dev make-migrations`), Riverpod 3, Supabase Postgres (generic `apply_personal_op`), SQL tests in Docker.

**Spec:** `docs/superpowers/specs/2026-11-23-home-budget-design.md` (section "Categories (whole app)"); roadmap `docs/superpowers/plans/2026-11-23-family-hisab-roadmap.md`.

## Global Constraints

- Category form: "Name (English)" and "નામ (ગુજરાતી)", **both required**, 1–60 characters each; the Gujarati field uses `GujaratiTextField` (the app's Gujarati input).
- Display: app language `gu` → `nameGu` when set, otherwise `name`; `en` → `name`. Built-in categories keep their translated labels.
- Existing custom categories keep their one name for both languages until edited (`nameGu` stays null).
- Every new visible text in `l10n/en/*.json` and `l10n/gu/*.json`; rebuild with `dart run tool/build_l10n.dart && flutter gen-l10n`.
- Server change only as a new migration, tested with `bash tool/run_supabase_tests.sh`; applied live only with the owner's go-ahead (never store the database password).
- Test data names: Hemang, Rahul Patel; never Asha.
- No commits or pushes without the owner's go-ahead.

## Review Focus

1. An old custom category (no Gujarati name) viewed with the app in Gujarati: shows its one name, never an empty label. Test in Task 3.
2. Editing only the icon or colour of a built-in category keeps it built-in (still translated in both languages). Test in Task 4.
3. A phone on app 1.2.1 sends a transaction without `category_name_gu`; the server and newer phones still accept it. Test in Task 5 and SQL in Task 1.
4. Searching the Hisab list with the Gujarati name of a custom category finds its entries. Test in Task 3.
5. The AI assistant understands a question naming a custom category in Gujarati. Test in Task 3.

---

### Task 1: Server — Gujarati name in the transaction snapshot

**Files:**
- Create: `supabase/migrations/20261123000000_category_gujarati_name.sql`
- Modify: `supabase/tests/20_personal_data_test.sql` (append checks)

**Interfaces:**
- Produces: column `public.personal_transactions.category_name_gu text null check (char_length(category_name_gu) between 1 and 60)`; `apply_personal_op` stores it and `get_personal_snapshot` returns it (both are generic over the table's columns).

- [ ] **Step 1: Failing SQL checks** — in `20_personal_data_test.sql`, as an existing test user: upsert a `transaction` whose payload has `category_name_gu = 'કરિયાણું'` → `ok((select category_name_gu from public.personal_transactions where id = …) = 'કરિયાણું', 'the Gujarati category name is saved')`; the snapshot's transaction has `category_name_gu = 'કરિયાણું'`; an upsert **without** the key stores `null` (`'an older app without the Gujarati name still saves'`); `fails(<upsert with 61-character category_name_gu>, 'invalid_data' or check violation text, 'a Gujarati name over 60 characters is refused')`.
- [ ] **Step 2:** `bash tool/run_supabase_tests.sh` → `ASSERTION FAILED: the Gujarati category name is saved` (or the column-missing error).
- [ ] **Step 3:** Write the migration (header comment: why).
- [ ] **Step 4:** `bash tool/run_supabase_tests.sh` → no `FAILED`, new `ok -` lines present.

---

### Task 2: Phone schema v5 — `categories.nameGu`

**Files:**
- Modify: `lib/core/database/tables.dart` (`Categories`), `lib/core/database/app_database.dart` (`currentSchemaVersion = 5`, `from4To5`)
- Generated: `drift_schemas/hisabmitra/drift_schema_v5.json`, `test/drift/hisabmitra/generated/schema_v5.dart` (and `schema.dart` index) via `dart run drift_dev make-migrations`; `lib/core/database/app_database.steps.dart`, `*.g.dart` via `dart run build_runner build --delete-conflicting-outputs`
- Test: `test/drift/hisabmitra/migration_test.dart`

**Interfaces:**
- Produces: `CategoryRow.nameGu` (`String?`), `CategoriesCompanion.nameGu`; column `TextColumn get nameGu => text().withLength(min: 1, max: 60).nullable()();`.

- [ ] **Step 1: Failing migration test** `'v4 → v5 keeps every category and adds an empty Gujarati name'`: a v4 database with a built-in category (`cat_groceries`) and a custom one (`name: 'Pooja'`) migrates to v5; both rows keep id, name, type, icon, colour; `nameGu` is null for both. Keep the generic "upgrade to every version" loop passing.
- [ ] **Step 2:** `flutter test test/drift/hisabmitra/migration_test.dart` → fails (no v5 schema).
- [ ] **Step 3:** Add the column; `from4To5`: `await m.addColumn(schema.categories, schema.categories.nameGu);`; regenerate as listed.
- [ ] **Step 4:** `flutter test test/drift` → all pass.

---

### Task 3: Showing and finding categories by language

**Files:**
- Modify: `lib/features/categories/presentation/category_labels.dart` (`label`), `lib/features/transactions/data/transaction_repository.dart` (search, line ~72), `lib/features/ai_assistant/domain/local_ai_engine.dart` (category `names`, line ~93)
- Test: `test/features/categories/category_label_test.dart` (new), `test/features/transactions/transaction_repository_test.dart` (add), `test/features/ai_assistant/local_ai_engine_test.dart` (add)

**Interfaces:**
- Consumes: `CategoryRow.nameGu` (Task 2).
- Produces: `CategoryRowX.label(AppLocalizations l)` — built-in → translated label (unchanged); custom → `l.localeName == 'gu' && (nameGu?.trim().isNotEmpty ?? false) ? nameGu! : name`.

- [ ] **Step 1: Failing tests**
  - `'a custom category shows its Gujarati name in Gujarati'`: `CategoryRow(name: 'Pooja', nameGu: 'પૂજા', systemKey: null, …).label(gu) == 'પૂજા'` and `.label(en) == 'Pooja'`.
  - `'an old custom category shows its one name in both languages'`: `nameGu: null` → `label(gu) == 'Pooja'`.
  - `'built-in categories stay translated'`: `cat_groceries` → `label(gu) == gu.catGroceries`, `label(en) == en.catGroceries`.
  - Repository: an expense in custom category `Pooja`/`પૂજા`; searching `'પૂજા'` returns it; searching `'Pooja'` still does.
  - AI engine: with the app in Gujarati, `'આ મહિને પૂજા માં કેટલો ખર્ચ થયો?'` (and the English `'How much did I spend on Pooja this month?'`) answers with that category's total.
- [ ] **Step 2:** run those test files → FAIL.
- [ ] **Step 3:** Implement (`label` rule above; search adds `m(_db.categories.nameGu)`; AI `names` adds `c.nameGu` when set).
- [ ] **Step 4:** run the same files → pass.

---

### Task 4: Category form with both names

**Files:**
- Modify: `lib/features/categories/data/category_repository.dart` (`CategoryDraft`, `save`), `lib/features/categories/presentation/category_form_screen.dart`, `l10n/en|gu/*.json` (keys `categoryNameEnglish` = "Name (English)" / "નામ (અંગ્રેજી)", `categoryNameGujarati` = "Name (Gujarati)" / "નામ (ગુજરાતી)")
- Test: `test/features/categories/category_repository_test.dart` (add), `test/widget/category_form_test.dart` (new)

**Interfaces:**
- Produces: `CategoryDraft({String? id, required String name, required String nameGu, required TransactionType type, required String iconKey, required int colorValue, bool keepSystemName = false})`; `save` writes `name` and `nameGu`; with `keepSystemName` it keeps `systemKey` and does not store the names (unchanged behaviour).
- Form rules: new category → both fields empty, both required. Editing a custom category → fields prefilled with `name` and `nameGu ?? name`. Editing a built-in category → fields prefilled with `lookupAppLocalizations(Locale('en'))` and `lookupAppLocalizations(Locale('gu'))` labels; if **both** are unchanged on save → `keepSystemName: true`, else it becomes custom with the two typed names.

- [ ] **Step 1: Failing tests**
  - Repository `'a category keeps both names'`: save `CategoryDraft(name: 'Pooja', nameGu: 'પૂજા', …)` → row has both.
  - Widget `'new category asks for both names'`: open new-category form; tap Save with only English filled → the Gujarati field shows the required error and nothing is saved; fill both → saved row has both names; the categories list in Gujarati shows `પૂજા`.
  - Widget `'changing only the colour keeps a built-in category translated'`: edit `cat_groceries`, change colour, save → row still has `systemKey == 'groceries'`, label in Gujarati is `gu.catGroceries`.
- [ ] **Step 2:** run those files → FAIL.
- [ ] **Step 3:** Implement form and draft; add the two strings in both languages; rebuild l10n. Update every other `CategoryDraft(` caller (seed/tour sample data, tests) to pass `nameGu` (search the code).
- [ ] **Step 4:** run those files → pass; `flutter test test/widget` → pass.

---

### Task 5: Gujarati names travel with your records

**Files:**
- Modify: `lib/features/synchronization/data/personal_outbox.dart` (category snapshot, ~line 225), `lib/features/synchronization/data/personal_rows.dart` (re-create missing category, ~line 333)
- Test: `test/features/synchronization/personal_sync_test.dart` (add)

**Interfaces:**
- Consumes: Task 1 column, Task 2 field.
- Produces: transaction payload key `'category_name_gu'` (= `nameGu`, omitted when null); the applier sets `nameGu` from it when it re-creates a missing category.

- [ ] **Step 1: Failing tests** (two phones of `hemang` on the fake cloud, as in the existing personal sync tests)
  - `'a custom category reaches the other phone with both names'`: phone 1 creates category `Pooja`/`પૂજા`, an expense in it, syncs; phone 2 syncs → its category `nameGu == 'પૂજા'`.
  - `'an entry from an older app without the Gujarati name still applies'`: a server row without `category_name_gu` → phone 2 creates the category with `nameGu == null`.
- [ ] **Step 2:** `flutter test test/features/synchronization/personal_sync_test.dart` → FAIL.
- [ ] **Step 3:** Implement; the fake personal store needs no change (it stores the payload map).
- [ ] **Step 4:** same command → pass.

---

### Task 6: Whole-change checks

- [ ] **Step 1:** `flutter analyze` → `No issues found!`; `dart format --output=none --set-exit-if-changed lib test` → exit 0; `flutter test` → all pass; `bash tool/run_supabase_tests.sh` → no `FAILED`.
- [ ] **Step 2:** Ask the owner before applying `20261123000000_category_gujarati_name.sql` live (it is additive and harmless for 1.2.1 phones); record it in `supabase_migrations.schema_migrations` like the others.
