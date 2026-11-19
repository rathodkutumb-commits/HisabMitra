# Financial Business Rules

Every rule here is implemented in pure-Dart domain code and covered by unit
tests. Widgets never compute money.

## 1. Money representation

- All amounts are `int` **paise** (₹10.25 = 1025). No `double` is used for
  money anywhere — parsing is string-based (`core/money/money.dart`).
- Amounts must be > 0 (DB `CHECK` + form validation). Upper limit
  ₹99,99,99,999.99 (cloud `CHECK`).
- Display uses Indian grouping (₹12,34,567.89) or international grouping
  by setting, both with integer arithmetic.
- Calculator (`calculator_engine.dart`) evaluates with exact rational
  arithmetic (so 0.1 + 0.2 is exactly 0.3) and returns paise; results are
  rounded half away from zero to the paisa, and the UI shows the rounded
  value before it is used.

## 2. Income and expense

- `transactions` holds only income and expense.
- Period summary: income = Σ income, expense = Σ expense, savings =
  income − expense, over the selected period (inclusive dates).
- The Excel-like sheet lists the same rows oldest-first with a running
  balance; its last running balance always equals the period's savings
  (`TransactionSheet`, tested).
- Categories in use cannot be deleted without reassigning their
  transactions (FK `restrict` + reassignment dialog).

## 3. Personal ledger (lending and borrowing)

- An entry is **given** (I lent → receivable) or **taken** (I borrowed →
  payable). Principal and repayments are **never** income or expense and
  never appear in income/expense reports — no double counting.
- Repayments are separate rows with full history; outstanding = principal −
  Σ repayments.
- A repayment larger than the outstanding amount is rejected. The UI offers
  to record the excess as a separate entry in the opposite direction
  (advance / credit) — never a silent over-payment (TD-12).
- Status: open (nothing repaid), partial, settled (outstanding = 0);
  overdue when a due date has passed and outstanding > 0.
- Person balance: positive → they owe me; negative → I owe them.

## 4. Group expense splitting (`SplitCalculator`)

| Method | Input per participant | Validation |
|---|---|---|
| Equal | — | at least one participant |
| Exact | share in paise | Σ shares = total (difference shown) |
| Percentage | basis points (1% = 100) | Σ = 10 000 (100%) |
| Ratio | integer weight | Σ weights > 0 |
| Adjustment ("unequal") | ± paise on top of the equal share | no share below 0 |

- "Selected participants only" applies to every method: only selected
  members get a share.
- **Remainder rule (deterministic):** leftover paise are handed out one at
  a time — for proportional methods to the largest fractional remainder
  first, ties (and the equal split) in participant display order.
- The shares **always add up exactly** to the expense; the server re-checks
  this (`split_mismatch`).
- A split preview is shown before saving.

Example: ₹1,000 equally among A, B, C → 33 334 + 33 333 + 33 333 paise.

## 5. Group balances and settlements

- Net balance per member = paid − own shares + settlements paid −
  settlements received. Net balances always sum to zero.
- Suggested settlements: greedy match of the largest creditor with the
  largest debtor, ties by member id → deterministic, at most n − 1
  transfers (TD-15).
- Settlements (full or partial) are separate records with date, method and
  notes. Recording a settlement never changes historical expenses.
- A settlement cannot exceed what the payer owes or the receiver is owed,
  and payer ≠ receiver.

## 6. Reports

Reports clearly separate income, expenses, loan principal / repayments
(ledger) and group settlement movements. All figures come from database
queries at report time; nothing is estimated.

## 7. Consistency

- Related financial writes (expense + splits + outbox op, repayment +
  status) happen in one DB transaction.
- Group records are synced with revisions; conflicting financial changes
  are never merged silently (see SYNC_ARCHITECTURE.md).
