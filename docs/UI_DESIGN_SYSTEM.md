# UI Design System

Code: `lib/app/theme/` (`palettes.dart`, `app_theme.dart`, `hm_colors.dart`,
`patterns.dart`), `lib/core/widgets/`.

## Direction

Gujarati cultural identity with a modern, clean fintech layout: rounded
cards, soft shadows, clear money figures. Decoration (Patola band, toran,
Bandhani dots) is used on the splash, onboarding, hero cards, section
headers and empty states — never inside forms or tables.

## Theme decision (TD-23)

- **Light mode only.** No dark mode and no "system" option (product owner
  decisions of 2026-11-18 and 2026-11-19). The master brief's green
  Theme A/B/C were replaced at the owner's request.
- Five selectable palettes (Settings → Appearance → Colour theme), each
  from a Gujarati craft or place; the choice is saved locally.
- Green is reserved for "money in" (income, to receive): `#1E7A55` in every
  palette. It is never a theme colour (tested).

| Palette | Story | Primary | Secondary / accent | Highlight | Background |
|---|---|---|---|---|---|
| **Rann Utsav** (default) | White salt desert of Kutch under a full moon | `#1D3557` navy | `#C0392B` red | `#C9CDD4` silver | `#F8F8F5` |
| Neel Gagan | Uttarayan kite sky | `#2F6DB5` sky blue | `#1B3A7A` indigo | `#D9A520` gold | `#F2F6FC` |
| Bandhani Lal | Bandhani odhni, red Diwali chopda | `#8B1E3F` maroon | `#B5501F` saffron | `#D4A017` kesar | `#FBF4EA` |
| Kesariyo | Navratri chaniya choli | `#C2410C` saffron | `#6B2D5C` plum | `#E3A21A` gold | `#FFF5EA` |
| Patola Rani | Patan Patola silk | `#B0175F` rani pink | `#3A1D4A` aubergine | `#E0A800` turmeric | `#FFF4F8` |

Saved values from removed palettes (Ajrakh Neel, Sindoor, Haldi) open as
Rann Utsav. Approved preview:
https://claude.ai/artifact/YUFbVDpbaSd9BYZ3TTepEk

## Colour roles

| Token | Use |
|---|---|
| `primary` / `primaryContainer` | app bar actions, buttons, selected chips, nav indicator, barakhadi row of the keypad |
| `secondary` | FAB, accent actions, Patola band |
| `tertiary` | group-split actions, reminders, "partly paid" |
| `HmColors.heroStart → heroEnd` | dashboard and group hero gradient (+ `onHero` text) |
| `HmColors.highlight` | decorative accents on hero cards and bands (not for text on light surfaces) |
| `HmColors.accentInk` | readable accent text on light surfaces (status pills); = `tertiary`, ≥ 4.5:1 |
| `HmColors.income` / `receivable` | money in (green) |
| `HmColors.expense` / `payable` | money out (palette red/maroon) |
| `HmColors.chartPalette` | 8 categorical chart colours |

Accessibility (tested in `test/app/palettes_test.dart` for every palette):
buttons, containers and body text ≥ 4.5:1; background text ≥ 7:1; money
colours ≥ 4.5:1; hero text ≥ 3:1 (large).

## Typography

- English: **Poppins** 400/500/600/700. Gujarati: **Noto Sans Gujarati**
  400–700. Both bundled (OFL), so text renders offline.
- The UI font follows the app language and falls back to the other font for
  mixed text. Amounts use tabular figures.

## Logo

Open chopda (ledger) with ₹ and three family figures (`HmLogoPainter`),
recoloured per palette. Launcher icon, adaptive icon (foreground +
monochrome), Android 12 splash and in-app logos are rendered from the same
painter by `flutter test tool/generate_brand_assets_test.dart` using the
default palette (Rann Utsav: navy tile, silver figures, red cover).

## Components

Cards (16 px radius, 1 dp shadow), inputs (12 px radius, filled), buttons
(52 px min height, 14 px radius), chips without check marks, bottom sheets
with drag handle, `EmptyState`, `SectionHeader` with Patola underline,
`IconBadge`, `AmountText`, confirmation dialogs for every destructive
action, `GujaratiKeypad` (see LOCALIZATION.md).

## Layout rules

Material 3; 48 dp minimum touch targets; 16 dp side padding; small screens
(≥ 320 dp) supported — quick actions wrap 3 per row under 340 dp; tables
scroll horizontally only where needed (group sheet, transactions sheet).
