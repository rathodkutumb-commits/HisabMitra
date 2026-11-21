# HisabMitra website (design)

Date: 2026-11-21. Requested by the owner; decisions marked **owner** were
theirs, **my call** were mine and can be corrected.

## Intent

A public website for HisabMitra that people share on WhatsApp and
elsewhere: it explains the app and **all** its features and lets anyone
download the latest APK. Once it is live, every "download" link the app or
its pages show points to this website instead of GitHub releases.

Model: the owner's Anuvaad site (https://anuvaad-app.vercel.app, repo
`Hemang67/Anuvaad-Web`) — **owner**: "similar type of web app".

## Decisions

- **Owner:** new repository on the GitHub account that owns the app
  (`rathodkutumb-commits`); Vercel project in
  `hemangrathod081-6794s-projects`.
- **Owner:** address `https://hisab-mitra-web.vercel.app`
  (`hisab-mitra.vercel.app` and `hisabmitra.vercel.app` belong to other
  Vercel users).
- **Owner:** English and Gujarati, with an `EN | ગુ` switch on every page.
- **Owner:** the GitHub account and the Vercel account use different emails;
  publishing must never be blocked by that, now or later.
- **Owner:** no CI/CD deployments. The site is published manually from this
  PC, and only when the owner gives the go-ahead — now and in future.
- **My call:** repository `rathodkutumb-commits/HisabMitra-Web`, private
  (like `Anuvaad-Web`).
- **My call:** same stack as Anuvaad-Web — Next.js 16 (App Router),
  TypeScript, Tailwind 4, Vitest, Playwright, Vercel region `bom1`.
- **My call:** light only, Rann Utsav colours (navy `#1D3557`, red
  `#C0392B`, background `#F8F8F5`, gold `#8A5A00`), fonts Poppins and Noto
  Sans Gujarati — the app's own look (the app is light-only by product
  decision), not Anuvaad's blue/dark theme.

## Approaches considered

1. **Next.js site like Anuvaad-Web, release data read from GitHub
   (chosen).** Same structure the owner already knows; the download page
   always shows the newest release without editing the site.
2. Static pages (plain HTML on Vercel or GitHub Pages): simpler, but the
   version, size and release notes would need a rebuild per release, and it
   would not be "similar" to Anuvaad.
3. Publishing via Vercel's own Git connection (deploy on every push):
   simplest, but on the free plan Vercel blocks deployments whose commit
   author is not the Vercel account — exactly the email conflict the owner
   wants to avoid. Rejected.
4. Publishing from GitHub Actions with a Vercel token: avoids the email
   problem, but the owner does not want CI/CD deployments. Rejected.

## Publishing (manual, from this PC, on the owner's go-ahead)

- Deployed only with the Vercel CLI already signed in on this PC
  (`vercel deploy --prod`), and only after the owner says go ahead. The
  deployment belongs to the Vercel account, so the commit email never
  matters.
- Vercel's Git connection never deploys (`vercel.json`:
  `git.deploymentEnabled: false`); no Vercel token is stored anywhere.
- GitHub Actions in `HisabMitra-Web` only runs the checks (lint, type
  check, unit and browser tests) — **my call**; it never deploys.
- The first deployment creates the Vercel project and the
  `hisab-mitra-web.vercel.app` address.

## Pages (both languages; English at `/…`, Gujarati at `/gu/…`)

- **Home:** hero (logo, "Smart Hisab, Happy Family", Download button with
  version and size, "Android 7 or newer" — the app's minSdk is 24), what
  HisabMitra is, feature sections with screenshots (daily hisab and sheet
  view, khata with partial repayments, groups with 5 split methods,
  balances and settle-ups, invite link and live updates, reports with
  PDF/CSV, reminders and recurring payments, saved to your account and
  works offline, backup and restore, AI assistant, Gujarati keypad, five
  colour themes, guided tour), "Made for Gujarati families", privacy in
  plain words, closing Download button.
- **Download:** latest version, date, size, SHA-256, install steps (allow
  installing from the browser, Play Protect note), "What's new", and every
  earlier release with its notes.
- **Guide:** first launch and account (email code), daily hisab, khata,
  groups and invitations, reports, reminders, backup and restore, updates,
  troubleshooting ("App not installed", Play Protect, no email code).
- **Privacy:** plain-words version of `docs/PRIVACY_AND_SECURITY.md`.
- **Join** (`/join?code=…`): the invitation page, moved here from GitHub
  Pages with the same behaviour (code check `[A-Z0-9]{6,12}`, opens
  `hisabmitra://join?code=…` via an Android intent with a `noapp=1`
  fallback, copy code, download).
- Header: logo, Home · Download · Guide · Privacy, `EN | ગુ`; footer: tagline,
  links, current version.
- Share previews (Open Graph title, description, image) in both languages,
  so a WhatsApp link shows the logo and tagline.

## Releases and downloads

- Release data comes from `rathodkutumb-commits/HisabMitra` GitHub Releases
  (public, read through the GitHub API on the server, cached 5 minutes);
  the APK asset `hisabmitra-<version>.apk` and its `.sha256`.
- `/download/latest` redirects to the newest APK file, so a button or link
  downloads it in one tap; visitors never see a GitHub page.
- A new release appears on the site within 5 minutes (cache), with no
  redeploy and no extra secrets — **my call** (Anuvaad's instant-refresh
  hook is left out).
- If GitHub cannot be reached, pages still render with a "try again later"
  download note (failures are not cached).

## Changes in the app repo (`HisabMitra`)

- New build setting `WEBSITE_URL` (release workflow passes
  `https://hisab-mitra-web.vercel.app`). Without it, messages leave the link
  lines out (as today without a repo).
- "Share HisabMitra" → website home (`/gu` when the app is in Gujarati);
  invite message download line → `/download`; invite link →
  `<website>/join?code=…`; About → "Release page" opens `/download`.
- README download links → the website.
- GitHub Pages (`site/`) becomes redirects to the website, keeping the query
  (`/join?code=…` keeps working for links shared from v1.2.0).
- In-app update check stays on the GitHub API (never shown to people).
- These reach phones only in a new app release (1.2.1) — asked separately.

## Goals / non-goals / anti-goals

- Goals: every feature of the app described in both languages; one-tap
  download of the newest APK; good WhatsApp previews; fast on phones.
- Non-goals: the app itself in a browser; accounts or sign-in on the site;
  Play Store.
- Anti-goals: tracking, analytics or third-party scripts; any personal data
  collected by the site; a publishing setup that breaks because of the
  commit email.

## Testing

- Unit (Vitest): release parsing and sorting, size/date formatting, the
  latest-APK redirect, invite code check, both languages have the same text
  keys.
- Browser (Playwright, against a local GitHub mock like Anuvaad-Web): home
  and download in English and Gujarati, the language switch keeps the page,
  `/join` valid / invalid / `noapp=1`, `/download/latest` redirect.
- Before going live: screenshots of each page at phone width in both
  languages for the owner's approval (look changes need approval).

## Left to the builder

- Exact page copy (both languages), section order within Home, which
  screenshots go where, component structure, cache details.
- **My call:** screenshots come from `docs/screenshots` (9 screens + colour
  themes); screens added since (floating AI button, invite link) may be
  captured fresh on the emulator if time allows.
- **My call:** no `GITHUB_TOKEN` at first — the app repo is public and
  the 5-minute cache keeps GitHub calls far below the 60-per-hour limit; a
  read-only token can be added in Vercel later.
