# Family hisab — the home budget (design)

Date: 2026-11-23. Decisions marked **owner** came from the owner; **my call**
were mine and can be corrected.

## Intent

The owner and his younger brother live together and run the home jointly.
Both earn; the owner mostly pays the big expenses and the brother the daily
ones. Nothing is split between them — it is one shared home purse. They
want to record both incomes and every home expense and, at the end of each
month, see one statement of money in (credit) and money out (debit).

The brother uses an iPhone and cannot install the app, so the owner enters
his entries; people are added by name and mobile number without signing
up. Members who do have the app can join and use the same Family hisab.

The feature is what the app is about — "HisabMitra · Smart Hisab, Happy
Family" — so it is easy to reach and counts as one of the user's accounts.

## Decisions

- **Owner:** a separate feature with its own screens and tables (not built
  on Groups): **Family hisab** (પરિવારનો હિસાબ) — name is my call, after the
  tagline; the budgets inside it are named by the user (e.g. "Home").
- **Owner:** nothing is split — no shares, no balances between people, no
  "who owes whom".
- **Owner:** people are added by name and mobile number, no sign-up; any
  number of people.
- **Owner:** money in is recorded per person: salary, extra income, or a
  contribution (money put into the home that isn't income).
- **Owner:** a monthly statement of credit and debit, carried forward like a
  bank passbook (each month opens with the last month's closing balance).
- **Owner:** the Home screen's income, expense and month-by-month chart
  **combine** personal figures with the Family hisab — it is a kind of
  account, so **no separate card**.
- **Owner:** shared **only with its members**: a member who has the app can
  be invited and then sees and uses it live; nobody else can see it.
- **Owner:** a person with entries can be renamed **and deleted**.
- **Owner:** bill photos, AI assistant questions and reminders are **in this
  version**.
- **Owner:** when adding (or editing) any income or expense category, the
  app asks for the name **in English and Gujarati** and shows the one for
  the app's language.
- **My call:** deleting a person keeps their past entries, shown as
  "Name (removed)", so old months and the passbook still add up.
- **My call:** roles as in groups — the creator (and anyone they make an
  admin) manages the Family hisab, its people and invitations; every joined
  member can add, edit and delete entries.
- **My call:** more than one Family hisab is allowed (e.g. "Home",
  "Village house"); with only one, it opens directly.
- **My call:** optional starting balance when one is created (default ₹0);
  only admins can change it.
- **My call:** balances are calculated from the entries, never stored, so
  editing or deleting an old entry updates every later month.
- **My call:** the statement and its shared text follow the app's language.
- **My call:** reminders stay personal (they notify only the person who set
  them), like the app's other reminders.

## Approaches considered

1. **Extend Groups** with a "split / joint" setting and income entries.
   Reuses everything, but mixes the feature into Groups. Not chosen.
2. **A separate Family hisab feature (chosen by the owner).** Own tables,
   screens, membership and invitations, built on the same proven patterns as
   groups (member-based access, invitation codes, change feed, live updates,
   bills bucket). Most work; clearest to use.
3. **Personal hisab with a "home" tag.** Can't be shared with members.
   Rejected.

## What the user sees

- **Entry points (my call):** the first quick action on the Home screen, a
  "Family" button in the Hisab tab's top bar, and an item at the top of
  More.
- **Create:** name (e.g. "Home"), optional starting balance, people (the
  user is always included as "You"; others from contacts or typed: name and
  mobile number).
- **Family hisab screen:** month switcher; a passbook card (opening
  balance, money in, money out, closing balance); the month's entries,
  newest first (person, kind or category, amount, bill icon); buttons
  "Money in" and "Money out".
- **Money in:** person, kind (salary / extra income / contribution), amount,
  date, note.
- **Money out:** amount, category, paid by, date, note, bill photos or PDF
  (camera, gallery, file).
- **People:** list with "has the app" / "not joined"; add (contacts or
  typed), rename, delete (entries kept, see above); **Invite** a person who
  has the app — the same invitation message and "Tap to join" link as
  groups, ending on the website's join page. Joining links that person's
  account to their name, so their earlier entries stay theirs.
- **Live:** members who joined see changes from other phones within
  seconds, like groups.
- **Statement** (per month):

  ```
  Home — November 2026
  Opening balance                         ₹12,000
  Money in (credit)
    You       Salary            ₹60,000
    Brother   Salary            ₹35,000
    You       Extra income       ₹5,000
    Brother   Contribution      ₹10,000   ₹1,10,000
  Money out (debit)
    Rent, groceries, bills …              ₹78,500
  Closing balance (saved)                 ₹43,500

  By person            Money in    Paid for home
  You                  ₹65,000     ₹52,000
  Brother              ₹45,000     ₹26,500
  ```

  "Share" sends a PDF (Gujarati prints correctly, like reports) and a short
  text; next to each person with a number, a WhatsApp button opens a chat
  with that number and the text summary.
- **Home screen (combined):** for the selected period, income, expense,
  savings and the month-by-month chart add every Family hisab the user is a
  member of (all its people) — no separate card. One small line under the
  figures says how much came from Family hisab ("Includes Family hisab: in
  ₹1,10,000 · out ₹78,500") so the totals can be checked. The Hisab tab's
  list and Reports stay personal.
- **Double counting:** the Money in form notes "Money here already counts
  on your Home screen — don't add your salary again in Hisab."
- **AI assistant:** answers about Family hisab from the phone's data, e.g.
  "How much did we spend on groceries at Home this month?", "What did
  Brother put in this month?", "What is the Home balance?" — with a new
  "Family" group of example questions.
- **Reminders:** a reminder can be linked to a Family hisab (e.g. rent on
  the 5th, every month); tapping the notification opens it.
- **Categories (whole app):** the category form has "Name (English)" and
  "નામ (ગુજરાતી)"; lists, pickers, reports and the statement show the name
  in the app's language. Built-in categories are already translated.
  Existing custom categories keep their one name for both languages until
  edited.

## Data

- **Server (Supabase)**, member-based like groups:
  - `family_hisabs` (id, owner_id, name, opening_balance_paise, revision,
    deleted_at, timestamps)
  - `family_members` (id, family_id, user_id nullable, name, phone, role
    owner/admin/member, status, sort_order, revision, deleted_at)
  - `family_entries` (id, family_id, member_id, kind `salary` /
    `extra_income` / `contribution` / `expense`, amount_paise > 0,
    entry_date, category snapshot incl. English and Gujarati names, note,
    revision, deleted_at)
  - `family_invitations` (single-use hashed codes, expiry, optional member)
  - `family_sync_events` change feed, in the Realtime publication
  - private storage bucket `family-attachments`, readable and writable by
    members
  - RLS: only members read; all writes through checked functions
    (`apply_family_op`, `get_family_snapshot`, create / cancel / accept
    invitation), with the same idempotency and revision checks as groups.
  - One invite link for both kinds: a single accept function finds the code
    among group or Family hisab invitations, so the website and the app's
    join flow stay as they are.
  - Account deletion: like groups — ownership passes to another member who
    has the app; with none left, the Family hisab is deleted.
  - Categories: `personal_transactions` gains the Gujarati category name in
    its snapshot.
  - Migrations tested in Docker first, applied live with the owner's
    go-ahead.
- **Phone (Drift, schema v5):** matching tables with sync columns; a third
  sync scope `family` next to `group` and `personal` (outbox, inbox, cursor,
  snapshot on join, conflicts "keep mine / keep theirs"); categories gain a
  Gujarati name.
- **Sign-out** removes Family hisab data from the phone (it stays in the
  account). **Backups** include it; **restoring a backup does not change**
  Family hisab (shared with others, like groups).

## Goals, non-goals, anti-goals

- Goals: record both incomes and every home expense in a minute; a monthly
  passbook statement that always adds up; members with the app see it live;
  share it with someone who doesn't have the app; the Home screen shows the
  household month by month; categories read naturally in both languages.
- Non-goals: splitting or settle-ups; push notifications (part C3, later);
  budgets or spending limits.
- Anti-goals: anyone outside the members seeing a Family hisab; balances
  that don't add up after editing or deleting; silent double counting on
  the Home screen.

## Order of work (one release, 1.3.0)

1. Bilingual categories (small, independent).
2. Family hisab on the phone and in the account: people, money in and out,
   passbook, statement and sharing, Home screen.
3. Sharing with members: invitations, joining, live updates.
4. Bill photos, AI assistant questions, reminders.
5. Screenshots for the owner, then release.

## Testing

- SQL (Docker): member-only reads; non-members rejected; every operation of
  `apply_family_op`; invitations (single use, expiry, linking to a named
  person); accept finds group and Family hisab codes; account deletion
  hand-over; storage policies; the feed is in the Realtime publication.
- Dart unit: passbook maths (carry-forward, old-month edit and delete,
  starting balance, removed person), by-person totals, statement text in
  both languages, category name by language.
- Dart sync: two members on one Family hisab see each other's entries;
  offline entries upload later; conflicts; joining loads the snapshot.
- Widget: create with a person added by number; money in and out; statement
  totals; Home screen totals, chart and "includes" line; category form with
  both names; joining from an invite link.
- Drift migration v4 → v5.
- Device: emulator run; screenshots shown to the owner before release.

## Left to the builder

- Layout and wording (both languages), icons for the three kinds of money
  in, statement PDF layout, AI question wording, file and class names.
