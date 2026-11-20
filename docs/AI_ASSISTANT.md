# AI Financial Assistant

Code: `lib/features/ai_assistant/`. The on-phone assistant is on by default
(Settings → AI to turn it off); online answers stay off until enabled.

## Architecture (hybrid)

```
question ──► AiIntentParser (keywords, English + Gujarati, no model)
                 │ intent + period + person/group
                 ▼
            LocalAiEngine ──► repositories (SQLite) ──► exact figures in paise
                 │
                 ├─► local answer text (always available, offline)
                 │
                 └─► optional: Claude rephrases the computed facts
                       (only with online AI on + own API key + consent)
```

- **All numbers come from the app's own code** querying the local
  database with integer paise. The model never calculates and never sees
  raw transaction rows.
- Every answer states the period it covers (today, this month, last month,
  this year).

## What it answers (intents)

Spending, income, savings for a period; top category; top 5 expenses;
compare this month with last month; tips to reduce spending (marked as
suggestions, not data); total receivable / payable; balance with a person;
group trip total and my share; who owes whom in a group; help.

## Example questions

The empty chat shows example chips grouped as Spending, Income & savings,
Khata, Groups and Add an entry (15 fixed examples, plus up to three built
from the user's most recently changed person and active group, e.g. "What is
my balance with Rahul Shah?", "Who owes whom in Goa Trip?"). Every example is
checked by `ai_examples_test.dart` to reach its intended answer in English
and Gujarati. A floating AI button on the main pages opens the chat.

A request like "add 250 for groceries" produces a **draft** that opens the
normal transaction form pre-filled. Nothing is saved until the user taps
Save. The assistant never writes, edits or deletes records, and never
creates repayments, settlements or expenses on its own.

## Online model (optional)

| Item | Value |
|---|---|
| Provider | Anthropic Claude API, `POST https://api.anthropic.com/v1/messages` |
| Model | `claude-opus-5-5`, effort `low`, `max_tokens` 4096 |
| API version | `anthropic-version: 2026-10-21` |
| Refusals | server-side fallback (`fallbacks: "default"`, beta `server-side-fallback-2026-07-01`); on `stop_reason: refusal` the local answer is shown |
| Key | entered by the user, kept in secure storage, never logged, never in backups |
| Cost | billed to the user's own Anthropic account per request |

Requirements before any request is sent: assistant enabled, online engine
selected, API key entered, and explicit data-sharing consent. Without them
the local engine answers.

**Data sent:** the question, the answer language, and a small JSON of
already-computed figures for that question (e.g. totals, top categories).
Person and group names are included only if "share names" is enabled;
otherwise they are replaced with neutral labels. No phone numbers,
descriptions, notes or attachments are sent.

The model's reply is display text only. If it fails (offline, invalid key,
rate limit), the local answer is shown with a short notice.

## Tests

`local_ai_engine_test.dart` (intent parsing in both languages, figures
match repository totals, period wording, drafts never write),
`claude_answer_service_test.dart` (request shape, consent gating, error
mapping, refusal → null).
