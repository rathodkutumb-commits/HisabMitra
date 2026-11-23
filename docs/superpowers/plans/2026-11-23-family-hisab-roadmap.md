# Family hisab and bilingual categories — roadmap (release 1.3.0)

**Spec:** `docs/superpowers/specs/2026-11-23-home-budget-design.md`

The spec covers five separable pieces. Each gets its own plan, written when
its phase starts so it argues from the code as it then stands. Each phase
ends with the whole test suite green and leaves the app releasable.

| Phase | Plan | Delivers |
|---|---|---|
| 1 | `2026-11-23-bilingual-categories.md` | Category form asks for English and Gujarati names; the app shows the one for its language everywhere (lists, pickers, search, AI, exports); names sync between phones; server snapshot column. |
| 2 | `…-family-hisab-core.md` | Family hisab on the phone and in the account for its creator: create, people (name + number, no sign-up, rename/delete keeping entries), money in (salary / extra income / contribution) and money out, passbook with carry-forward, statement + PDF + WhatsApp share, Home screen totals and chart combined with the "includes" line, entry points. Server tables, `apply_family_op`, snapshot, feed; phone schema, third sync scope `family`. |
| 3 | `…-family-hisab-sharing.md` | Invitations (one accept for group and Family hisab codes, linking to a named person), joining from the website link, roles (admins manage, members add entries), live updates, account-deletion hand-over, sign-out wipe. |
| 4 | `…-family-hisab-extras.md` | Bill photos on money out (`family-attachments` bucket, member-only), AI assistant answers and a "Family" example group, reminders linked to a Family hisab. |
| 5 | `…-release-1-3-0.md` | Emulator run, screenshots of the new screens for the owner, release 1.3.0 (`1.3.0+6`), then the website: Family hisab in the features (both languages), new screenshots, published from this PC (the newest APK appears on the site by itself). |

**Owner's standing go-aheads (2026-11-23):** build all phases; after the
release, update the website with the new feature and screenshots and
publish it. **Still asked each time:** applying migrations to the live
database (password or token needed), commits/pushes, and the release tag.
