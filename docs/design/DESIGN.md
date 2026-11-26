# PurgeSwipe — DESIGN.md

Status: 2026-11-25, v1. Platform: iPhone only, portrait, iOS 18.0 deployment target, designed in the
iOS 26/27 look (system bars supply Liquid Glass; the app never draws opaque chrome).
Language: source `en`, localized `vi`. Copy lives in `strings.md`, one key per string in `Localizable.xcstrings`.
Direction: **A — Clean Room** (approved at checkpoint 1). Accent: indigo. Numeric console: tabular digits.

## 1. Design DNA and atmosphere

**Primary job:** decide one photo with one swipe — left to mark for deletion, right to keep — and watch the
library total come down.
**Focal point:** Home is the library total, "128.4 GB" at 34 pt bold tabular digits, the largest thing on the
screen and the number the user came to move. Elsewhere: the photo (deck), the marked grid (Review), the plan
choice (Paywall).
**Density:** balanced — 64 pt two-line deck rows, 52 pt settings rows, 24 pt section gap, 16 pt screen margin.
**Hierarchy ladder:** primary 34/41 bold `label` (large title, library total, empty-state titles);
secondary 17/22 semibold `label` (row titles, plan names, buttons) with 15/20 `secondaryLabel` metadata;
tertiary 13/18 `secondaryLabel` (footers, trial terms, version).
**Accent budget:** one hue, iOS indigo `#5E5CE6` light / `#7D7AFF` dark, used on (a) the primary filled
action, (b) selection (chosen plan, segmented selection), (c) inline link text on the paywall and legal rows.
Forbidden on deck-row symbols, section headers, chevrons, the ad slot, paywall bullets, badges, or any
decorative icon. Red is status (destructive), green is status (success), never brand.
**Signature element:** the size console — every quantity is set in tabular digits and right-aligned, size on
top (17 pt semibold), item count beneath (13 pt secondary). It appears on all four deck rows, the review
header and the success line, so the app reads as one instrument.
**Motion character:** snappy — `.snappy` card throw with `.success` / `.impact(light)` haptic per decision,
`.smooth` state swaps, undo re-enters from the top edge; `.smooth` where the user reads a result.

Atmosphere: a quiet measuring instrument, not a promo. Cool neutral system surfaces, photography supplies all
saturation, a single indigo marks the one thing to do next. Reference: Apple Photos → Utilities,
Settings → General → iPhone Storage.

Banned: gradients, glow, neon, glass on content, shadows on content groups, card-in-card, stacked identical
cards, uppercase eyebrows, emoji, sparkles, invented stats or claims, spec text leaking into the UI, red used
decoratively, blue used as decoration.

## 2. Color roles

Every role is a colorset with Any (light) + Dark. Semantic first; brand hex only where a role genuinely
differs. Contrast measured against the surface it sits on.

| Role | Token | Light | Dark | Use | Contrast |
|---|---|---|---|---|---|
| Canvas | `Theme.canvas` | `#F2F2F7` | `#000000` | Screen background (grouped) | — |
| Surface | `Theme.surface` | `#FFFFFF` | `#1C1C1E` | Grouped sections, sheet | — |
| Fill | `Theme.fill` | `#EEEEEF` | `#2C2C2E` | Segmented track, ad slot, skeleton | — |
| Separator | `Theme.separator` | `#E3E3E8` | `#38383A` | Hairlines, 0.5 pt | — |
| Primary label | `Theme.label` | `#000000` | `#FFFFFF` | Titles, body, values | 19.6:1 / 17.4:1 |
| Secondary label | `Theme.secondaryLabel` | `#6C6C70` | `#AEAEB2` | Metadata, footers, symbols | 4.97:1 / 7.4:1 |
| Tertiary label | `Theme.tertiaryLabel` | `#8A8A8E` | `#8E8E93` | Placeholders, disabled, "Ad" | 3.46:1 / 4.8:1 |
| Accent | `AccentColor` | `#5E5CE6` | `#7D7AFF` | Primary action fill, selection, links | 5.05:1 / 6.1:1 |
| On accent | `Theme.onAccent` | `#FFFFFF` | `#000000` | Label inside an accent fill | 5.05:1 / 6.1:1 |
| Destructive fill | `Theme.destructiveFill` | `#D70015` | `#FF453A` | Filled destructive action | 5.4:1 / 6.2:1 |
| On destructive | `Theme.onDestructive` | `#FFFFFF` | `#000000` | Label inside a destructive fill | 5.4:1 / 6.2:1 |
| Destructive icon | `Theme.destructive` | `#D70015` | `#FF453A` | Trash symbol in the deck | 5.4:1 / 4.9:1 |
| Success | system `green` | `#34C759` | `#30D158` | Success glyph only, always paired with text | — |
| Scroll edge | `Theme.edge` | `#F2F2F7` @ 94 % | `#000000` @ 94 % | Under-bar edge effect, never a stroke | — |

Rules: one accent hue; red and green are status only; meaning is never carried by color alone (the trash
symbol, the word "Delete", the lock symbol, the plan checkmark all carry it); 60-30-10 (neutral canvas / text
and surface / accent); no gradients, no glow, no drop shadow on content. Destructive fill is deeper than
system red in light mode because white-on-`#FF3B30` is only 3.55:1; `Theme.onAccent` flips to black in dark
mode because the light indigo and the light red cannot hold white text.

## 3. Typography

SF Pro via Dynamic Type only. Maximum four styles per screen. Tabular digits (`.monospacedDigit()`) on every
quantity so numbers do not jitter while analysis fills them in.

| Style | Size/leading | Weight | Used for |
|---|---|---|---|
| Large Title | 34/41 | bold | Root titles ("Cleanup", "Settings") |
| Title 1 | 28/34 | bold | Review header, empty-state title, library total on compact height |
| Title 2 | 22/28 | bold | Sheet hero, section titles inside sheets |
| Title 3 | 20/25 | semibold | Paywall plan price |
| Headline | 17/22 | semibold | Row titles, button labels, plan names |
| Body | 17/22 | regular | Reading copy, settings rows |
| Callout | 16/21 | regular | Supporting copy under titles |
| Subheadline | 15/20 | regular | Deck-row metadata, plan period |
| Footnote | 13/18 | regular | Trial terms, legal links, version, count under a size |
| Caption 2 | 11/13 | regular | "Ad" placeholder only, never essential information |

Rules: sentence case; no uppercase eyebrows; static copy never truncates (row titles wrap to two lines
instead); Vietnamese runs ~30 % longer than English — every row is designed at the vi length and must hold
at AX3 with the same layout; at AX4+ `HStack` reflows to `VStack` via `ViewThatFits`. Value numbers are never
the element that shrinks.

## 4. Components (native mapping)

| Component | SwiftUI | States | Metrics |
|---|---|---|---|
| Root screen | `NavigationStack` + `.navigationTitle` large | — | status bar 62, nav 44, large title 34/41 at x=16 |
| Pushed screen | `.navigationBarTitleDisplayMode(.inline)` | — | inline title 17 semibold centered, back = `chevron.backward` alone in a 44 pt glass circle |
| Grouped list | `List` + `.listStyle(.insetGrouped)` / `Section` | default, pressed | 16 pt margins, 20 pt continuous corners, no stroke |
| Deck row | `NavigationLink` + custom `HStack` | default, pressed, disabled, locked | 64 pt two-line; symbol 22 pt `secondaryLabel` at x=32; title 17 semibold; metadata 15 secondary; right console 17/13 tabular; chevron `chevron.right` 13 pt tertiary |
| Library group | one `Section` row | — | 104 pt; eyebrow 15 secondary, value 34 bold tabular, footnote 15 secondary |
| Primary action | `.buttonStyle(.glassProminent)` → `.borderedProminent` on iOS 18 | default, pressed, disabled, loading | capsule 50 pt, full width minus 32, label 17 semibold `onAccent` |
| Destructive action | `.borderedProminent` + `.tint(.destructiveFill)` | default, pressed, disabled, loading | capsule 50 pt, label 17 semibold `onDestructive` |
| Secondary action | `.buttonStyle(.glass)` → `.bordered` on iOS 18 | default, pressed, disabled | capsule 34 pt, label 17 regular |
| Toolbar item | `.toolbar` | default, pressed, disabled | 44 pt glass circle, plain symbol, one tinted maximum |
| Floating deck control | `.buttonStyle(.glass)` + `.clipShape(.circle)` | default, pressed, disabled | Keep/Delete 60 pt circle, Undo 44 pt circle |
| Sheet | `.sheet` + `.presentationDetents([.large])` | — | grabber hidden, `xmark` glass circle leading |
| Segmented picker | `Picker` + `.pickerStyle(.segmented)` | selected, disabled | 32 pt track `Theme.fill` |
| Empty state | `ContentUnavailableView` | — | 48 pt symbol, Title 1, one capsule action |
| Grid | `LazyVGrid` 3 columns | — | 4 pt gaps, 16 pt margins, 4 pt continuous cell radius |
| Ad slot | `BannerViewRepresentable` | loading, loaded, failed (collapses to 0) | 320×50, centered, `Theme.fill`, never overlaps content |

Pressed: rows highlight `#D1D1D6` / `#3A3A3C` instantly and fade 250 ms; buttons scale .97 + opacity .85 in
120 ms; glass controls use `Glass.interactive()`; disabled opacity .3; loading replaces the label with an
inline `ProgressView` and keeps the width.

## 5. Layout and composition

- Spacing scale 4, 8, 12, 16, 20, 24, 32, 40. Screen margin 16 (text x=32 inside grouped rows). Section gap 24.
- One left spine at x=16 (x=32 inside a group). One right column for values and chevrons. No third alignment.
- Container budget: canvas + grouped surface. No card inside a card. No shadow on content; shadows only on
  floating glass.
- No dead zone over 120 pt without content or an action.
- Fluid 390–440 pt: margins constant, rows full width, no fixed frame, no phone mockup.
- Safe areas: top 62 pt (status bar), nav 44 pt, bottom 34 pt home indicator. Content scrolls under glass
  bars with the scroll edge effect but never starts under them.
- The deck photo is the one intentional full-bleed surface: it runs under the glass bar and under the
  controls, at `aspectRatio(contentMode: .fill)`.
- Bottom actions live in `safeAreaBar`; the last row clears the bar by 16 pt.

**Per-screen composition map**

| Screen | Focal point | Blocks top → bottom | Reading order | Density |
|---|---|---|---|---|
| Onboarding | "Choose photos" capsule | status, symbol-free hero title, privacy line, page dots, primary, "Not now" | title → why → act | airy |
| Home | library total | large title + gear, library group, "Decks" header, 4 rows, last-cleaned group, ad slot | total → decks → last cleanup | 4 rows, 64 pt |
| Swipe deck | the photo | photo full bleed, glass bar (back, title, progress), glass "18 to delete" capsule, 3 glass circles | photo → decision → counter | one photo per viewport |
| Review | the 3-col grid | inline bar, "18 photos · 128 MB", grid, ad slot, bottom bar (delete, review each) | count → grid → delete | 6 rows × 3 |
| Paywall | the plan choice | `xmark` bar, hero title, 4 benefits, yearly/monthly, trial terms, lifetime, restore, legal | promise → plan → price → act | scannable, 3 surfaces |
| Settings | Pro status row | large title, appearance, subscription group, help group | group → row | 52 pt rows |

## 6. Content, states, and copy

**Screen inventory:** Onboarding (full-screen cover, first run), Home (root, single NavigationStack; no tab
bar), Swipe deck (push), Review and delete (push), Paywall (sheet, large detent), Settings (push). States per
screen in `states.md`; motion in `motion.md`.

**Copy rules:** only `strings.md` keys render; sentence case; no emoji; no superlatives; "Similar" never
"duplicate"; "Moved to Recently Deleted" never "freed"; no claims about device storage, freed space, privacy
certifications, encryption, or speed; prices always come from StoreKit and are shown in the mock only to
verify layout.

**Sample data (single source, reused so screens never contradict):** library 128.4 GB · 18,432 items;
Screenshots 96 items · 486 MB; Similar shots 312 items · 1.9 GB; Blurry photos 48 items · 214 MB;
Large videos 24 items · 38.6 GB; deck "Screenshots", progress "42 of 96", counter "18 to delete";
review "18 photos · 128 MB"; last cleanup "96 photos · 1.8 GB moved to Recently Deleted"; settings version
1.0.0. These are sample values, not claims.

**Paywall:** yearly preselected, "$19.99/year" with "3-day free trial", monthly "$4.99/month", lifetime
"$29.99 one-time", renewal copy "3-day free trial, then $19.99/year. Cancel anytime.", Restore Purchases,
Privacy Policy, Terms of Use (EULA), `xmark` close, dismissible by swipe. No fake urgency, no countdown, no
"most popular" badge.

**Notifications:** none in 1.0.0. The app sends no push, no local notification, no Live Activity. No
permission prompt except PhotoKit, requested on the onboarding CTA and never at launch.

**Ads:** banner on Home and Review only, below content, never over it, never inside the deck or Settings;
collapses to zero height when no fill; ATT prompt after onboarding completes, before the first ad request.

## 7. Stitch generation notes

**Canonical colors:** canvas `#F2F2F7` / `#000000`; surface `#FFFFFF` / `#1C1C1E`; fill `#EEEEEF` / `#2C2C2E`;
label `#000000` / `#FFFFFF`; secondary `#6C6C70` / `#AEAEB2`; separator `#E3E3E8` / `#38383A`;
accent `#5E5CE6` / `#7D7AFF`; destructive `#D70015` / `#FF453A`.

**Canonical metrics:** 62 pt status bar, 44 pt nav bar, 34 pt large title, 16 pt margins, 20 pt group corners,
0.5 pt hairline separators inset to the text and 16 pt from the trailing edge, 64 pt two-line rows, 52 pt
settings rows, sentence-case 17 pt semibold section headers, capsule buttons (50 / 34 / 28), glass bar items
with a rim highlight and no border, `-apple-system` on every element.

Every prompt separates two blocks:

```
SCREEN CONTENT (the only text allowed to render):
- <exact strings and numbers>

RENDER SPEC (never render this text):
- <metrics, roles, component names, glass instructions>
```

**NO:** gradients, glow, drop shadows on content, glass on rows, stacked identical cards, FAB, tab bar,
uppercase headers, Material icons, emoji, invented stats, spec text, phone mockups, fixed-width frames.

**Navigation sentence (verbatim on siblings):** "NO tab bar. Root of a single NavigationStack. Large title
'Cleanup' 34 pt bold, trailing toolbar item gearshape in a 44 pt glass circle."

**Motion is not in the render:** `motion.md` is the only motion source; the HTML only carries `:active`
states and 120/250 ms transitions.
