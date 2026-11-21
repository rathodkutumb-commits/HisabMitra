# HisabMitra Website Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A bilingual (English/Gujarati) HisabMitra website at `https://hisab-mitra-web.vercel.app`, built like the owner's Anuvaad site, that explains every feature and downloads the newest APK; then the app and its old pages point to it.

**Architecture:** New Next.js 16 project in a new repo `rathodkutumb-commits/HisabMitra-Web` (local folder `D:\Hemang\Work\Mine\HisabMitra-Web`), structured like `Hemang67/Anuvaad-Web` (read-only reference copy in the session scratchpad). English pages live in the `(en)` route group (`/…`), Gujarati in `(gu)/gu` (`/gu/…`), each group with its own root layout; all text comes from two typed dictionaries. Release data is read on the server from the public app repo's GitHub Releases and cached 5 minutes. Published only manually from this PC with the Vercel CLI after the owner's go-ahead.

**Tech Stack:** Next.js 16.4.5 (App Router, `cacheComponents`), React 19.3.0, TypeScript 5, Tailwind 4 (`@tailwindcss/turbopack`), Vitest 5, Playwright 1.64, Node 24; Flutter app repo for link changes.

**Spec:** `docs/superpowers/specs/2026-11-21-hisabmitra-website-design.md` (in the HisabMitra app repo)

## Global Constraints

- Next.js 16 differs from older versions: before writing Next code, read the relevant guide in `node_modules/next/dist/docs/` (as Anuvaad-Web's `AGENTS.md` says) and follow Anuvaad-Web's working patterns.
- Address `https://hisab-mitra-web.vercel.app`; Vercel project name `hisab-mitra-web` in `hemangrathod081-6794s-projects`, region `bom1`.
- Publishing: only `vercel deploy --prod` from this PC, only after the owner says go ahead. `vercel.json` has `"git": { "deploymentEnabled": false }`. No deploy step in GitHub Actions, no Vercel token anywhere.
- Repo `rathodkutumb-commits/HisabMitra-Web`, private; create with `gh` as `rathodkutumb-commits`, then `gh auth switch -u Hemang67`.
- Every visible text exists in both `en` and `gu` dictionaries; English at `/…`, Gujarati at `/gu/…`; an `EN | ગુ` switch keeps the current page.
- Look: light only. Colours `--bg #F8F8F5`, `--card #FFFFFF`, `--ink #152033`, `--muted #5D6778`, `--line #DFE3E8`, `--navy #1D3557`, `--navy-soft #DCE6F2`, `--red #C0392B`, `--red-soft #F6DAD6`, `--gold #8A5A00`, `--gold-soft #FBEACB`; fonts Poppins (latin) and Noto Sans Gujarati via `next/font/google`.
- Facts: app id `com.hisabmitra.app`; Android 7 or newer; releases repo `rathodkutumb-commits/HisabMitra`; APK asset `hisabmitra-<version>.apk` (SHA-256 from the asset's `digest` field `sha256:<hex>`); release notes = release body above the line `### Install`.
- No analytics, tracking, cookies or third-party scripts; nothing collects visitor data.
- No commits or pushes to the **app** repo, no app release and no change to GitHub Pages until the website is live and the owner approves. Test/demo names: Hemang, Rahul Patel (never Asha).

## Review Focus

1. GitHub API unreachable or rate-limited from Vercel's shared IPs (no token): pages must still render and "Download" must still download (cached data, then the fixed-name `hisabmitra.apk` fallback). Unit test in Task 3.
2. Long Gujarati words on a 360 px phone: no sideways scrolling. Checked in the Task 9 screenshots at 360 px.
3. WhatsApp link preview: `og:image` must be an absolute `https://hisab-mitra-web.vercel.app/…` URL in both languages. E2E assertion in Task 2.
4. The join page on iPhone/desktop: no Android intent and no redirect loop; code and manual steps visible. E2E in Task 7.
5. Invite links shared from app v1.2.0 (`…github.io/HisabMitra/join?code=X`) keep working after GitHub Pages turns into redirects (query kept). Check in Task 8 and with `curl` after publishing.

---

### Task 1: Repository and project skeleton

**Files:**
- Create in `D:\Hemang\Work\Mine\HisabMitra-Web`: `package.json` (name `hisabmitra-web`, scripts and dependency versions as Anuvaad-Web minus `cobe` and `zod`), `next.config.ts` (`cacheComponents: true`, the Tailwind turbopack rule; no host redirect), `tsconfig.json`, `eslint.config.mjs`, `vitest.config.ts`, `playwright.config.ts` (port 3100, health URL `/api/v1/health`), `vercel.json`, `.gitignore`, `.env.example` (`RELEASES_REPO`, optional `GITHUB_TOKEN`, `GITHUB_API_BASE_URL`), `AGENTS.md`, `README.md` (what it is, scripts, **manual publishing from this PC only**), `.github/workflows/ci.yml` (lint, typecheck, unit, e2e — no deploy), `lib/site.ts`, `app/api/v1/health/route.ts`, `public/brand/logo.png` (from the app's `assets/images/logo_tile.png`), `app/icon.png`, `app/apple-icon.png`, `public/screenshots/*` (from the app's `docs/screenshots`).
- Test: `tests/unit/site.test.ts`

**Interfaces:**
- Produces: `siteConfig = { name: 'HisabMitra', nameGu: 'હિસાબમિત્ર', url: 'https://hisab-mitra-web.vercel.app', releasesRepo: 'rathodkutumb-commits/HisabMitra', appPackage: 'com.hisabmitra.app', minAndroid: '7' } as const`; `GET /api/v1/health` → `200 {"ok":true}`.

- [ ] **Step 1:** Create the private repo (`gh repo create rathodkutumb-commits/HisabMitra-Web --private`, as `rathodkutumb-commits`, then switch back), `git init` locally with remote `origin`, `npm install`.
- [ ] **Step 2: Failing test** `tests/unit/site.test.ts`: `expect(siteConfig.url).toBe('https://hisab-mitra-web.vercel.app')`, `expect(siteConfig.releasesRepo).toBe('rathodkutumb-commits/HisabMitra')`, and `vercel.json` parsed has `regions: ['bom1']` and `git.deploymentEnabled === false`.
- [ ] **Step 3:** Run `npm test` → FAIL (module not found).
- [ ] **Step 4:** Write the files above.
- [ ] **Step 5:** Run `npm test && npm run lint && npm run typecheck` → all pass. Commit locally ("Project skeleton").

---

### Task 2: Languages, layouts, header and footer

**Files:**
- Create: `lib/i18n/locales.ts`, `lib/i18n/dictionaries/en.ts`, `lib/i18n/dictionaries/gu.ts`, `lib/i18n/index.ts`, `app/globals.css`, `app/(en)/layout.tsx`, `app/(gu)/gu/layout.tsx`, `components/site/site-shell.tsx` (header + footer + skip link), `components/site/language-switch.tsx`, `tests/e2e/mock-github.mjs`, `tests/e2e/serve.mjs`, `tests/fixtures/github-releases.json` (the real `GET /repos/rathodkutumb-commits/HisabMitra/releases` output for v1.0.0–v1.2.0, URLs rewritten by the mock as in Anuvaad-Web)
- Test: `tests/unit/i18n.test.ts`, `tests/e2e/site.spec.ts`

**Interfaces:**
- Produces: `type Locale = 'en' | 'gu'`; `locales: readonly Locale[]`; `type PageKey = 'home' | 'download' | 'guide' | 'privacy' | 'join'`; `pagePath(locale: Locale, page: PageKey): string` (`('en','home')→'/'`, `('gu','home')→'/gu'`, `('en','download')→'/download'`, `('gu','join')→'/gu/join'`); `getDictionary(locale: Locale): Dictionary` where `Dictionary` is the shape of `en` with every leaf a `string` (or `string[]`), and `gu` is typed `Dictionary` so a missing key fails `typecheck`; `<SiteShell locale page>`; `pageMetadata(locale, page): Metadata` (title, description, Open Graph with `metadataBase` = `siteConfig.url`, image `/brand/logo.png`, `alternates.languages` en/gu).

- [ ] **Step 1: Failing tests** — unit: `pagePath` cases above; every leaf in `gu` and `en` is a non-empty string; both dictionaries have identical key sets (deep compare). E2E (needs the Task 3 placeholder pages; until then a minimal home page per group): `/` has `<html lang="en">`, `/gu` has `lang="gu"`; clicking `ગુ` on `/` lands on `/gu` and `EN` on `/gu` lands on `/`; `meta[property="og:image"]` content starts with `https://hisab-mitra-web.vercel.app/` on `/` and `/gu`.
- [ ] **Step 2:** Run `npm test` → FAIL; `npm run test:e2e` → FAIL.
- [ ] **Step 3:** Implement. Header: logo + name (`HisabMitra` / `હિસાબમિત્ર`), nav Home · Download · Guide · Privacy, `EN | ગુ` (current one marked `aria-current`), "Get the app" button; footer: tagline, links, "Made for Gujarati families", latest version line (Task 3 data, inside `Suspense`).
- [ ] **Step 4:** Run `npm test && npm run test:e2e` → pass. Commit.

---

### Task 3: Release data and the latest-APK link

**Files:**
- Create: `lib/releases/types.ts`, `lib/releases/github.ts`, `lib/releases/notes.ts`, `lib/releases/display.ts`, `lib/releases/cached.ts`, `app/(en)/download/latest/route.ts`
- Test: `tests/unit/releases.test.ts`, `tests/unit/notes.test.ts`, `tests/unit/display.test.ts`, `tests/unit/latest-route.test.ts`

**Interfaces:**
- Produces:
  - `interface ReleaseNotes { title: string; sections: { heading: string | null; items: string[] }[] }`
  - `interface ReleaseInfo { version: string; tag: string; publishedAt: string; notes: ReleaseNotes; apk: { name: string; url: string; size: number; sha256: string | null } }`
  - `fetchReleases(cfg: { apiBaseUrl: string; repo: string; token?: string }): Promise<ReleaseInfo[]>` — newest version first (numeric semver compare); skips drafts, prereleases and releases without `hisabmitra-*.apk`; throws `ReleaseSourceError` on network/HTTP errors; retries once without a token on 401 (like Anuvaad).
  - `parseReleaseNotes(body: string): ReleaseNotes` — text above `### Install`; first `### …` line is the title; a line `**Heading**` starts a section; `- ` starts an item, indented lines continue it (joined with a space); bullets before any heading go in a `heading: null` section.
  - `formatSize(bytes: number): string` → `'86.4 MB'` for 90615455 (bytes ÷ 1,048,576, one decimal); `formatDate(iso: string, locale: Locale): string` → `'21 November 2026'` / `'21 નવેમ્બર 2026'` (`Intl.DateTimeFormat` `en-IN` / `gu-IN`, day month year).
  - `getReleases(): Promise<ReleaseInfo[]>` with `'use cache'`, `cacheLife({ stale: 300, revalidate: 300, expire: 86400 })`; config from env (`RELEASES_REPO` default `siteConfig.releasesRepo`).
  - `GET /download/latest` → `302` to the newest `apk.url`; if `getReleases()` throws or is empty → `302` to `https://github.com/rathodkutumb-commits/HisabMitra/releases/latest/download/hisabmitra.apk`.
- [ ] **Step 1: Failing tests** — with the fixture: 4 releases, `[0].version === '1.2.0'`, `[0].apk.size === 90615455`, `[0].apk.sha256 === 'd8bd92c8a40d9890e203238f7b18a2fb03d91aac6289b40e273f36d4a76139ed'`, `[0].publishedAt === '2026-11-21T07:32:03Z'`; a draft, a prerelease and a release with no APK are dropped; HTTP 500 → `ReleaseSourceError`; 401 with token → retried without. Notes for v1.2.0: title `'HisabMitra 1.2.0 — invite links and live updates'`, sections `['Join a group with one tap', 'Group changes appear by themselves']`, first item starts `'A shared group invitation now has a "Tap to join" link.'` and contains no line break; v1.0.1: one `heading: null` section with 2 items, first starts `'**Gujarati keypad:**'`. `formatSize(90615455) === '86.4 MB'`. Latest route: newest URL with fixture; fallback URL when the source throws.
- [ ] **Step 2:** `npm test` → FAIL.
- [ ] **Step 3:** Implement (Anuvaad-Web's `lib/releases/github.ts` is the pattern; no `release.json`).
- [ ] **Step 4:** `npm test` → pass. Commit.

---

### Task 4: Home page

**Files:**
- Create: `components/home/*` (hero, download button, feature grid, screenshot strip, gujarati section, privacy summary, closing call), `app/(en)/page.tsx`, `app/(gu)/gu/page.tsx`; extend both dictionaries (`home.*`)
- Test: `tests/e2e/site.spec.ts` (home cases)

**Interfaces:** Consumes `getDictionary`, `pagePath`, `pageMetadata` (Task 2), `getReleases`, `formatSize` (Task 3). Download buttons link to `/download/latest`.

Content (both languages, wording left to the builder, every item from the app's README feature list): hero (logo, `Smart Hisab, Happy Family` / `સ્માર્ટ હિસાબ, ખુશ પરિવાર`, one-line description, Download button with `v1.2.0 · 86.4 MB` when release data is available, "Android 7 or newer", secondary link to the guide); feature groups — Daily hisab (categories, sheet view, search/filters, calculator, bill photos), Khata (given/taken, partial repayments, due dates), Groups (5 split methods, balances, settle-up, invite link, live updates), Reports (charts, PDF/CSV), Reminders (repayments, recurring EMI/SIP/rent), Your account (saved to your account, works offline, second phone), Backup and restore, AI assistant, Made for Gujarati families (English/Gujarati app, Gujarati keypad, 5 colour themes, guided tour); screenshots with captions; privacy in three lines; closing Download button.

- [ ] **Step 1: Failing e2e:** `/` has `h1` containing `HisabMitra`, a link to `/download/latest` whose text contains `1.2.0` and `86.4 MB`; `/gu` `h1` contains `હિસાબમિત્ર`; both pages show 9 feature-group headings; every `img` has an `alt`.
- [ ] **Step 2:** `npm run test:e2e` → FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** `npm run test:e2e` → pass. Commit.

---

### Task 5: Download page

**Files:**
- Create: `components/releases/release-card.tsx`, `components/releases/release-history.tsx`, `app/(en)/download/page.tsx`, `app/(gu)/gu/download/page.tsx`; dictionaries (`download.*`)
- Test: `tests/e2e/site.spec.ts` (download cases)

**Interfaces:** Consumes Task 3 (`getReleases`, `formatSize`, `formatDate`, `ReleaseInfo`).

Content: latest release card (version, date, size, SHA-256 in monospace, big Download button → `apk.url`), install steps (download; allow the browser to install apps; tap Install; Play Protect may warn because it is installed from this website, choose "Install anyway"), "Already using HisabMitra? More → About → Check for updates", "What's new" from `notes`, then all earlier releases with their notes. On Gujarati pages the notes are shown as published (English) under a line saying so. If release data fails: a card saying the list is unavailable plus a Download button to `/download/latest`.

- [ ] **Step 1: Failing e2e:** `/download` shows `1.2.0`, `1.1.0`, `1.0.1`, `1.0.0`; the latest card shows `d8bd92c8…39ed` and links to the mock URL of `hisabmitra-1.2.0.apk`; `/gu/download` shows the Gujarati heading and the same versions; with the mock returning 500 (`MOCK_GITHUB_FAIL=1` env in `serve.mjs`), `/download` still renders and links to `/download/latest`.
- [ ] **Step 2:** `npm run test:e2e` → FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** `npm run test:e2e` → pass. Commit.

---

### Task 6: Guide and Privacy pages

**Files:**
- Create: `app/(en)/guide/page.tsx`, `app/(gu)/gu/guide/page.tsx`, `app/(en)/privacy/page.tsx`, `app/(gu)/gu/privacy/page.tsx`, `components/site/page-header.tsx`; dictionaries (`guide.*`, `privacy.*`)
- Test: `tests/e2e/site.spec.ts` (guide/privacy cases)

Content: Guide with a table of contents — Install, First launch and your account (email code), Daily hisab, Khata, Groups and invitations, Reports, Reminders, Backup and restore, Updates, Troubleshooting ("App not installed", Play Protect warning, the email code did not arrive, invite link says not valid). Privacy in plain words from the app repo's `docs/PRIVACY_AND_SECURITY.md` (what is stored in your account and who can see it, what stays on the phone, AI assistant, deleting your account, this website collects nothing).

- [ ] **Step 1: Failing e2e:** `/guide` and `/gu/guide` have 10 table-of-contents links whose targets exist on the page; `/privacy` and `/gu/privacy` have `h1` and the line that the website collects no data.
- [ ] **Step 2:** `npm run test:e2e` → FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** `npm run test:e2e` → pass. Commit.

---

### Task 7: Join page (invitation links)

**Files:**
- Create: `lib/invite.ts`, `components/join/join-card.tsx` (client), `app/(en)/join/page.tsx`, `app/(gu)/gu/join/page.tsx`; dictionaries (`join.*`)
- Test: `tests/unit/invite.test.ts`, `tests/e2e/site.spec.ts` (join cases)

**Interfaces:**
- Produces: `normalizeInviteCode(raw: string | null): string | null` (trim, upper-case, `^[A-Z0-9]{6,12}$`); `appLink(code: string, opts: { android: boolean; pageUrl: string; noApp: boolean }): string` — Android: `intent://join?code=<CODE>#Intent;scheme=hisabmitra;package=com.hisabmitra.app;S.browser_fallback_url=<encoded fallback>;end` where fallback is `pageUrl` plus `&noapp=1` unless already `noApp`; otherwise `hisabmitra://join?code=<CODE>`.

Behaviour as the current `site/join.js` in the app repo: valid code → code shown, "Open in HisabMitra", "Copy code", Download (`/download/latest`), manual steps; on Android without `noapp` it tries the app link once on load; `noapp=1` shows the "didn't open?" note and makes Download the main button; invalid/missing code → "This invitation link is not valid" and Download.

- [ ] **Step 1: Failing tests** — unit: normalize cases (`' hsqpp7g9vd '`→`'HSQPP7G9VD'`; `'AB12'`, `'ABCDEFGHIJKLM'`, `'AB-123'`, `null` → `null`); `appLink` Android with and without `noApp`, non-Android. E2E (desktop Chrome): `/join?code=code0001` shows `CODE0001` and the Open link `href` is `hisabmitra://join?code=CODE0001`; `/gu/join?code=CODE0001` shows the Gujarati heading; `/join?code=ab` shows the invalid message; `/join?code=CODE0001&noapp=1` shows the note; the page URL does not change after 2 s (no redirect loop).
- [ ] **Step 2:** `npm test && npm run test:e2e` → FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** `npm test && npm run test:e2e` → pass. Commit.

---

### Task 8: App repo — links point to the website (prepared, not pushed)

**Files (app repo `D:\Hemang\Work\Mine\HisabMitra`):**
- Modify: `lib/app/config/app_config.dart` (`websiteUrl` from `WEBSITE_URL`), `lib/core/share/share_messages.dart`, `lib/features/about/presentation/about_screen.dart`, `lib/features/groups/presentation/group_cloud_screens.dart`, `.github/workflows/release.yml`, `site/index.html`, `site/join.html` (+ remove `site/join.js`, `site/style.css` no longer needed), `README.md`, `test/core/share/share_messages_test.dart`, local `dart_defines.json` (git-ignored; add `WEBSITE_URL`)
- Test: `test/core/share/share_messages_test.dart`

**Interfaces:**
- Produces: `String? websitePage(String page, {required String languageCode, String base = AppConfig.websiteUrl})` → `null` when `base` is empty; else `base` + (`/gu` when `languageCode == 'gu'`) + page (`''`, `/download`, `/join?code=X`). `appDownloadUrl({required String languageCode})` → `websitePage('', …)` ("Share HisabMitra" → home; callers pass `l.localeName`); invite download line → `websitePage('/download')`; `inviteLinkUrl(code)` → `websitePage('/join?code=$code')`; About "Release page" → `websitePage('/download')` (hidden when null).
- Release workflow: passes `WEBSITE_URL=https://hisab-mitra-web.vercel.app` in `dart_defines.json`; also uploads a copy named `hisabmitra.apk` (for `/download/latest`'s fallback); the release text no longer says "Your personal records stay on your phone" and points to the website for installing.
- GitHub Pages `site/`: `index.html` and `join.html` only redirect (`location.replace`, plus `<meta http-equiv="refresh">` and a plain link) to `https://hisab-mitra-web.vercel.app` + same path + same query (`/join` keeps `?code=…`).

- [ ] **Step 1: Failing tests:** `websitePage('', languageCode: 'en', base: 'https://w.example')` → `'https://w.example'`; `('/download', 'gu')` → `'https://w.example/gu/download'`; `('/join?code=HSQPP7G9VD', 'en')` → `'https://w.example/join?code=HSQPP7G9VD'`; `base: ''` → `null`; invite message with `link: websitePage(...)` has the website join URL; existing cases stay.
- [ ] **Step 2:** `flutter test test/core/share/share_messages_test.dart` → FAIL.
- [ ] **Step 3:** Implement; `site/` redirects; README links; release workflow.
- [ ] **Step 4:** `flutter test`, `flutter analyze`, `dart format --set-exit-if-changed lib test` → all pass. **Do not commit/push yet** (owner's go-ahead after the website is live).

---

### Task 9: Preview, publish (on go-ahead), hand-over

- [ ] **Step 1:** Full checks in the web repo: `npm run lint && npm run typecheck && npm test && npm run test:e2e` → all pass.
- [ ] **Step 2:** `npm run build && npm start` locally against the real GitHub API; Playwright screenshots of every page in both languages at 390 px and 360 px (full page) plus the home page at 1280 px, into the scratchpad; check: no sideways scrolling at 360 px, version `1.2.0` shown. Show the owner.
- [ ] **Step 3:** Push the web repo `main` (private repo; CI checks only).
- [ ] **Step 4 (owner's go-ahead):** `vercel link --yes --project hisab-mitra-web` (scope `hemangrathod081-6794s-projects`), set env `RELEASES_REPO`, `vercel deploy --prod`; confirm `https://hisab-mitra-web.vercel.app` serves `/`, `/gu`, `/download`, `/download/latest` (302 to the APK), `/join?code=CODE0001`.
- [ ] **Step 5 (owner's go-ahead):** commit + push the app repo (Task 8), check `…github.io/HisabMitra/join?code=X` lands on the website join page with the code, then release **1.2.1** (version `1.2.1+5`, notes "Links now open the HisabMitra website") and verify as in v1.2.0.
