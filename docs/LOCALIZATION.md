# Localisation and Gujarati Input

## Languages

English (`en`) and Gujarati (`gu`), chosen at onboarding and in Settings →
Language; saved locally. Every visible string is localised (805 strings),
including validation, errors, notifications, reports, PDF/CSV headers and
AI answers.

## Pipeline

```
l10n/en/*.json ─┐  dart run tool/build_l10n.dart   lib/l10n/app_en.arb ─┐  flutter gen-l10n
l10n/gu/*.json ─┘  (merges, checks keys and        lib/l10n/app_gu.arb ─┘  → AppLocalizations
                    placeholders match)
```

- Strings are split by feature (`common`, `finance`, `groups`, `ledger`,
  `settings`, …). English files hold `@key` placeholder metadata.
- `build_l10n.dart` fails if a key is missing in either language, if a
  key is duplicated, or if placeholders differ.
- Widgets use `context.l10n.<key>`; no visible text is hard-coded.
- Dates and numbers are formatted with `intl` for the active locale; money
  keeps Latin digits for clarity in both languages.

## Gujarati text handling

- Text is stored as standard Unicode (NFC as typed). Search uses SQLite
  `LIKE` on the stored text, so Gujarati search works.
- PDF reports are drawn with Flutter's text engine (HarfBuzz shaping) and
  embedded as page images, because the `pdf` package cannot shape Gujarati
  conjuncts and matras (TD-09). CSV is UTF-8 with BOM so Excel shows
  Gujarati correctly (TD-10).

## Gujarati typing — three modes

Settings → Language → Gujarati typing. A small "A / અ" toggle on each text
field switches that field back to the phone keyboard at any time.

| Mode | How it works |
|---|---|
| Phone keyboard (default) | The system keyboard, e.g. Gboard Gujarati. |
| English → Gujarati (transliteration) | Type phonetically; the word being typed is converted syllable by syllable (`GujaratiTransliterator`, longest-match tokens, virama for conjuncts). `kem cho` → કેમ છો, `puNya` → પુણ્ય, `harSh` → હર્ષ (capital N/Sh/T/D for retroflex ણ ષ ટ ડ). |
| HisabMitra Gujarati keypad | On-screen keypad described below. |

### Gujarati keypad (redesigned 2026-11-19)

All letters on one page — no switching between a consonant page and a
matra page.

```
┌ suggestions row 1 ┐  after ક:  કા કિ કી કુ કૂ કે કૈ કો
└ suggestions row 2 ┘            કૌ કં કઃ ક્ ક્ર કૃ કૅ કૉ
  ક ખ ગ ઘ ઙ ચ છ જ ઝ ઞ
  ટ ઠ ડ ઢ ણ ત થ દ ધ ન
  પ ફ બ ભ મ ય ર લ વ શ
  ષ સ હ ળ ક્ષ જ્ઞ ત્ર શ્ર , .
  [૧૨૩] [અ આ] [ space ] [⌫] [hide]
```

- **After a consonant** (or conjunct) the two top rows show its barakhadi,
  the half form (ક્) for conjuncts, the ra-conjunct (ક્ર) and the
  loanword forms કૅ કૉ. Tapping inserts only the sign; the text engine
  composes the syllable.
- **Anywhere else** the top rows show the vowels અ આ ઇ ઈ ઉ ઊ એ ઐ ઓ ઔ અં અઃ
  ઋ ઍ ઑ and a key that adds anusvara to the previous syllable (e.g. ગાં).
- **અ આ** shows the vowels right after a consonant, for words like ગઈ,
  થઈ.
- **૧૨૩** switches the letter rows to Gujarati and Latin digits, ₹ and
  punctuation.
- Backspace removes one sign at a time (કા → ક, which brings the barakhadi
  back); hold to repeat. Suggestions follow the cursor.

Half letters: પુણ્ય = પ → પુ, ણ → ણ્, ય. હર્ષ = હ, ર → ર્, ષ.

Logic: `lib/features/gujarati_input/domain/gujarati_keypad_logic.dart`
(unit-tested); widget: `presentation/gujarati_keypad.dart` (widget-tested,
plus an app flow test that types પુણ્ય into an expense and checks the
saved text).
