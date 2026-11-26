# PurgeSwipe — design checkpoint 1 of 2: aesthetic direction

Run dir: `/Users/lequangtrongtai/orca/PurgeSwipe/docs/design/`
Stitch: authenticated (api_key). No `PurgeSwipe` project exists yet; nothing has been generated.
Source of truth: `docs/product/SPEC.md` (6 screens, copy, free/Pro matrix) and
`docs/superpowers/specs/2026-11-25-purgeswipe-design.md` (honesty rule, builder-check resolutions).

## State

- Done: SPEC read, craft skill loaded, iOS 27 metrics kit located (`~/.claude/agents/assets/ios27/`), Stitch auth verified.
- Not done: DESIGN.md, screens.md, states.md, motion.md, strings.md, Stitch project, any render.
- Blocked on: the direction below. Accent hue and surface model are baked into DESIGN.md, so they must be
  chosen before the design system is bound and before the first generate call.

## Screen inventory (fixed by SPEC — exactly 6, no extra tabs)

| # | Screen | Route | Focal point | States in v1.0.0 mock |
|---|---|---|---|---|
| 1 | Onboarding | full-screen cover, first run | the permission offer | permission page (2 of 2) |
| 2 | Home "Cleanup" | root, single NavigationStack | library size | ready |
| 3 | Swipe deck | push from Home | the photo | mid-deck |
| 4 | Review and delete | push from deck | the marked grid | 18 marked |
| 5 | Paywall "PurgeSwipe Pro" | sheet, large detent | the plan choice | products loaded, yearly selected |
| 6 | Settings | push from Home toolbar | Pro status row | free plan |

No tab bar anywhere. No login, no cloud, no charts, no stats beyond real library numbers.
Sample data is fixed once and reused on every screen so screens never contradict
(128.4 GB · 18,432 items library; Screenshots 96 · 486 MB; Similar 312 · 1.9 GB; Blurry 48 · 214 MB;
Large videos 24 · 38.6 GB; deck 42 of 96, 18 to delete; review 18 photos · 128 MB).

## Three directions (pick one)

### A — "Clean Room" (recommended)

System-grouped neutral canvas, one indigo accent, numbers are the brand.

1. **Primary job:** turn a full photo library into a smaller one by swiping, and see the number move.
2. **Focal point:** Home = the library total "128.4 GB" at 34 pt bold tabular digits inside the library
   group; Deck = the photo, full bleed; Review = the thumbnail grid.
3. **Density:** balanced — 64 pt two-line deck rows, 52 pt settings rows, 24 pt section gap.
4. **Hierarchy ladder:** primary 34/41 bold label (large title + library value); secondary 17/22 semibold
   label (row titles, plan name); tertiary 15/20 secondaryLabel (counts, metadata) and 13/18 (footers).
5. **Accent budget:** iOS Indigo `#5E5CE6` light / `#7D7AFF` dark — primary action + selected plan only.
   Forbidden on deck-row symbols, section headers, chevrons, ad slot, paywall bullet checkmarks (those are
   secondaryLabel). Red is status (delete), green is status (success), never decoration.
6. **Signature element:** the right-aligned size console in tabular digits — "486 MB" over "96 items" —
   repeated on every deck row, the review header, and the success line.
7. **Motion character:** snappy — card throw `.snappy` + `.success` haptic on keep/delete, undo slides back
   in from the top edge, `.smooth` for state swaps.

Per screen: Home is one library group + one deck group + last-cleanup footer + banner slot below the list.
Deck is a photo with glass back/title/progress at the top and three glass circles (undo / keep / delete) plus
a glass "18 to delete" capsule at the bottom. Review is a 3-column grid under a count header, red capsule
primary in a bottom bar. Settings is a standard inset-grouped form with a segmented appearance row.
Reference: Apple Photos → Utilities, Settings → General → iPhone Storage.
Risk: the most "correct" and least distinctive of the three; relies on the numeric console for character.

### B — "Frame"

Plain white canvas, no grouped surfaces outside Settings/Review, monochrome plus system blue, oversized numbers.

1. **Primary job:** same.
2. **Focal point:** Home = the library total set at the top with no container around it, 34 pt bold, a
   hairline under it — the page is a typographic statement, not a card stack.
3. **Density:** airy — 72 pt rows, 32 pt section gap, no card backgrounds on Home.
4. **Hierarchy ladder:** primary 34 bold; secondary 17 regular label; tertiary 13/18 secondaryLabel.
5. **Accent budget:** system Blue `#007AFF` / `#0A84FF`, filled button backgrounds and the selected
   appearance segment only; never as text under 17 pt (3.0:1 on white).
6. **Signature element:** the hairline row rhythm with the value on its own line under the title — no right
   console anywhere, one left spine only.
7. **Motion character:** calm — `.smooth` everywhere, one `.selection` haptic, card throw still snappy
   because the gesture demands it.

Per screen: Home reads like Apple Health's summary (big number, hairline list). Deck over a white chrome bar
(glass still, but a light bar over the photo). Review grid edge-to-edge with 2 pt gaps, no inset.
Reference: Apple Health summary, Apple Wallet passes list.
Risk: the plain-list Home can look unfinished with only 4 rows; the photo hero is weaker on Home.

### C — "Warm Studio"

Warm off-white canvas, teal accent, SF Rounded for numeric values only.

1. **Primary job:** same.
2. **Focal point:** Home = the library total in SF Rounded semibold, 34 pt, in the library group.
3. **Density:** balanced — 64 pt rows, 22 pt group corners (vs the system 20).
4. **Hierarchy ladder:** primary 34 Rounded semibold; secondary 17 semibold; tertiary 15/20 warm secondary.
5. **Accent budget:** teal `#0B7C70` light / `#3AD6C0` dark (darker than system teal so text passes 4.5:1);
   primary action + selection only.
6. **Signature element:** Rounded numerals for every size string, SF Pro for everything else.
7. **Motion character:** light-playful — `.bouncy` on undo only, `.snappy` for the throw.

Per screen: same structure as A but warm canvas `#F7F5F2`, warm separators, Rounded numerals.
Reference: Things 3 / Bear warmth, kept flat and native.
Risk: a warm canvas is a deliberate deviation from `systemGroupedBackground`; Increase Contrast and dark
mode need hand-checked overrides, and it sits one step away from the banned cream-paper look.

## Decision needed

1. **Which direction** — A, B, or C (A recommended: best contrast behavior, clearest numeric focal point,
   zero risk of the warm-paper template look).
2. **Mock language** — English (recommended: matches the App Store primary locale and keeps row widths
   honest; Vietnamese copy is still delivered in `strings.md` and QA'd at +30 % length) or Vietnamese.

After the answer: DESIGN.md → design-system bind (full text) → 6 light screens → 6 dark screens →
QA + acceptance → handoff files.

CHECKPOINT: pick direction A, B, or C, and mock language (en recommended) before any Stitch generation.
