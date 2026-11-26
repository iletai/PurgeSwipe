# PurgeSwipe — DESIGN.md (v2, direction A "Clean Room")

Authoritative UI spec for the iPhone app. Renders: Stitch project `244497281594604385` (MOBILE, 780×1768 = 390×884 pt).
Deployment target iOS 18.0, iPhone only, portrait, fluid 390–440 pt. Designed for the iOS 27 look; every API newer than 18 has the stated fallback.
Product scope: `docs/product/SPEC.md`. Inventory and gap table: `docs/design/screens.md`. Motion: `docs/design/motion.md`. States: `docs/design/states.md`.

## 1. Design DNA (7 decisions)

| # | Decision |
|---|---|
| Primary job | Turn "my phone is full" into a finished cleanup: pick a deck, swipe, one system deletion, see the bytes leave the library. |
| Focal point | The library total, `128.4 GB` at 34 pt bold tabular — the number the user came to change. Every other number is quieter. |
| Density | Deck rows 64 pt (two lines: value over count), plain rows 52 pt, section gap 20–24 pt, screen margin 16 pt. Nothing tappable below 44 pt. |
| Hierarchy ladder | L1 `34/41 bold` label (library total, onboarding headline) · L2 `17/22 semibold` label (row titles, section headers 17 semibold secondary) · L3 `13/18 regular` secondary (counts, periods, captions). Three levels only. |
| Accent budget | One hue: indigo `#5E5CE6` light / `#7D7AFF` dark. Allowed on: the primary capsule fill, the selected plan circle, the segmented selection label, the progress fill, one text link row per screen, the only tinted bar item ("Done"). Forbidden on: row icons, section headers, values, chevrons, body copy, backgrounds. Destructive red `#D70015`/`#FF453A` and success green `#34C759`/`#30D158` are semantic, not accent. |
| Signature element | The **size console**: a right-aligned value (`17 pt semibold`, tabular) stacked over its count (`13 pt` secondary), aligned to one trailing spine across every deck row, with the chevron pinned 6 pt after it. Reads like a storage instrument, not a settings list. |
| Motion character | Physical and short: card 1:1 with the finger, `.snappy` 0.25 s commits, `.smooth` 0.3 s for state swaps, no bounce except undo. One haptic per gesture. Reduce Motion → cross-fade. |

Squint test: at 25 % the eye lands on `128.4 GB`, then the deck section, then the ad slot. The job (start cleaning) is obvious without reading any label.

## 2. Color roles

Semantic first, brand second. Every role has a light and a dark value; nothing is encoded by colour alone (the Pro lock pairs `lock.fill` with the word, the limit pairs `hourglass` with the sentence).

| Role | Light | Dark | Used for |
|---|---|---|---|
| `canvas` | `#F2F2F7` | `#000000` | grouped background, full-screen covers |
| `surface` | `#FFFFFF` | `#1C1C1E` | inset-grouped sections, sheet background |
| `fill` | `#EEEEEF` | `#2C2C2E` | segmented track, progress track, ad slot |
| `separator` | `#E3E3E8` | `#38383A` | 0.5 pt hairlines, inset 16/16 |
| `label` | `#000000` | `#FFFFFF` | titles, values, body |
| `secondaryLabel` | `#6C6C70` | `#AEAEB2` | captions, counts, section headers, reasons |
| `tertiaryLabel` | `#C4C4C7` | `#8E8E93` | chevrons, inactive dots, the `Ad` label at 11 pt |
| `accent` | `#5E5CE6` | `#7D7AFF` | primary capsule, selection, links, progress |
| `accentTint` | `#5E5CE6` @14 % | `#7D7AFF` @18 % | secondary capsule ("Reload", "Try Again") |
| `destructive` | `#D70015` | `#FF453A` | Delete CTA, trash glyph |
| `success` | `#34C759` | `#30D158` | deletion confirmed |
| `onAccent` | `#FFFFFF` | `#FFFFFF` | capsule labels |

Contrast: body 17 pt label on canvas 17.9:1 (light) / 19.6:1 (dark); secondary 13–15 pt `#6C6C70` on `#FFFFFF` 4.8:1 (meets 4.5); `#AEAEB2` on `#1C1C1E` 4.6:1. Apple's `secondaryLabel` (`#8E8E93`) is only 3.4:1 on white, so any secondary text below 15 pt uses `#6C6C70`, not the system semantic. Meaning never relies on colour alone.

## 3. Typography

SF Pro via Dynamic Type text styles only (`-apple-system`). No custom font, no mono except a code/debug value (none ships).

| Style | pt / line | Weight | Where |
|---|---|---|---|
| Large Title | 34 / 41 | bold | screen large titles, the library total, onboarding headline, paywall title 28 |
| Title 3 | 20 / 25 | semibold | plan price (20 pt), success line 28 is Title 1 |
| Headline | 17 / 22 | semibold | row titles, section headers (secondary colour), inline titles, counter pill |
| Body | 17 / 22 | regular | FAQ answers, body copy, settings rows |
| Subheadline | 15 / 20 | regular | metadata lines, reasons, legal 13 |
| Footnote | 13 / 18 | regular | counts, periods, the legal line, footers |
| Caption 2 | 11 / 13 | regular | the `Ad` label only |

Minimum 11 pt. Everything survives AX5 (rows grow, `ViewThatFits` turns price-under-title into stacked) and +30 % Vietnamese length (no fixed-width label in any row; the console truncates first, the title never).

## 4. Chrome and metrics (measured on iPhone 17 sim, iOS 27.2)

| Element | Value |
|---|---|
| Top safe area | 62 pt on 402/440 island models, 68 Air, 59 iPhone 16, 47 on the 17e notch. Read `safeAreaInsets`, never hard-code. |
| Status bar | 62 pt tall, `9:41` at **x=57**, 17 pt semibold, icons cellular 20.3×12 · Wi-Fi 19.3×14 · battery 29×13.7, 8.5 pt gaps, right edge 40 pt from the screen |
| Dynamic Island | 126×37.33 pt, centred, top y=11, radius 19, pure `#000000`, nothing inside |
| Home indicator | 134×5 pt, radius 2.5, 8 pt from the bottom; bottom safe area 34 pt |
| Nav bar | 44 pt under the safe area; back = `chevron.backward` in a 44 pt glass circle at x=16, no previous title (iOS 26+); text actions 44 pt glass capsules; inline title 17 pt semibold, ≤ 1 line |
| Large title | 34 pt bold, 16 pt leading, 3 pt under the nav row (it is the scroll content, not the bar) |
| List row | 52 pt single line, 64 pt two line; text at x=32; icon 22 pt at x=32, 12 pt gap |
| Separator | 0.5 pt `#E3E3E8`, inset 16 pt from the text start, 16 pt from the trailing edge, none after the last row |
| Section header | sentence case 17 pt semibold `secondaryLabel`, x=32, 10 pt above the group |
| Buttons | every bordered style is a capsule on iOS 26+; large 50 pt, regular 34 pt; filled buttons have no stroke |
| Toggle | 63×28 pt |
| Segmented control | 32 pt tall capsule, track `#EEEEEF`, selected white + soft shadow |
| Pressed | rows `#D1D1D6` / `#3A3A3C`; buttons scale .97 + opacity .85 in 120 ms; glass flexes |

## 5. Native component mapping (nothing custom unless listed)

| Screen element | SwiftUI |
|---|---|
| Root navigation | `NavigationStack(path:)` + `AppRoute`; no tab bar |
| Large title + gear | `.navigationTitle("Cleanup")` `.toolbarTitleDisplayMode(.large)` + `ToolbarItem(placement: .topBarTrailing) { Button { } label: { Image(systemName: "gearshape") } }` (system glass circle) |
| Back | automatic; never a custom back button |
| Done (Settings) | `ToolbarItem(placement: .confirmationAction) { Button("Done") }` `.buttonStyle(.glassProminent)` with `if #available(iOS 26, *)` fallback `.borderedProminent` |
| Library group / deck list / settings | `List { Section { … } }` `.listStyle(.insetGrouped)` |
| Deck row console | `HStack { Image; Text(title); Spacer(); VStack(alignment: .trailing) { Text(value).monospacedDigit(); Text(count) }; Image("chevron.right") }` |
| Progress scan | `ProgressView(value: scanned, total: total).progressViewStyle(.linear).tint(.accent)` |
| Empty / denied / finished | `ContentUnavailableView { Label } description: { Text } actions: { Button }` |
| Deck card | `Image` + `DragGesture` + `.offset`/`.rotationEffect`, `PHAsset` thumbnail via `PHImageManager` |
| Deck actions | `Button` `.buttonStyle(.glass)` 44/60 pt inside `GlassEffectContainer` |
| Counter pill | `Text` in `.glass` capsule via `safeAreaBar(edge: .bottom)` (fallback `safeAreaInset`) |
| Photo grid | `LazyVGrid(columns: 3, spacing: 4)` of `PhotoThumb` |
| Delete | `confirmationDialog` → `PHPhotoLibrary.shared().performChanges { PHAssetChangeRequest.deleteAssets(...) }` |
| Paywall rows | `Product` from StoreKit 2, prices `product.displayPrice`; selection `Button` + `Image(systemName: selected ? "checkmark.circle.fill" : "circle")` |
| Paywall sheet | `.sheet` + `.presentationDetents([.large])` + `.presentationDragIndicator(.visible)` |
| Settings appearance | `Picker("Appearance", selection: $appearance) { … }.pickerStyle(.segmented)` |
| FAQ | `DisclosureGroup` in a `List` |
| Links | `Link` / `openURL`; Restore → `AppStore.sync()`; Manage → `showManageSubscriptions(in:)` |
| Ads | `GADBannerView` 320×50 in a `UIViewRepresentable`, hidden for Pro |

No custom control ships. If one is ever proposed it needs: no system equivalent, a SwiftUI mapping, default/pressed/disabled/selected states, and a checkpoint.

## 6. Per-screen composition map

| Screen | Order top → bottom | Focal | Accent |
|---|---|---|---|
| Onboarding p1 | Skip · fanned card illustration · 34 pt headline · body · dots · Continue capsule | headline | Continue |
| Onboarding p2 | Skip · 56 pt glyph · 34 pt headline · body · dots · Choose photos capsule | headline | CTA |
| Home ready | 44 pt nav (gear) · large title · library group (104 pt) · `Decks` header · 4 deck rows · `Last cleanup` header · 1 row · ad slot | `128.4 GB` | none (gear untinted) |
| Home analyzing | same + 3 pt progress inside the group · consoles show % / Queued | `128.4 GB` + bar | progress fill |
| Home empty / denied | nav · large title · CUV centred · one action | CUV glyph | action |
| Deck | full-bleed photo · glass bar with title over subtitle · counter pill · 3 glass circles | the photo | none (trash red only) |
| Deck finished | nav · CUV centred · Review capsule | CUV glyph | CTA |
| Review marked | nav · `18 photos` + `128 MB` · 3-col grid · glass bar with red capsule + `Review each` | red CTA | link only |
| Review success | nav · check · 28 pt statement · reason · Finish in Photos · Back to Cleanup | statement | primary + link |
| Review cap | nav · count · hourglass block · See Pro plans · Back to Cleanup | the sentence | CTA |
| Paywall products | grabber + close · 28 pt title · benefits group · 2 plan rows · lifetime row · CTA · legal | selected plan row | CTA + selection |
| Paywall error | grabber + close · title · benefits · error block + Try Again · disabled CTA · legal | error block | Retry + legal links |
| Settings free/Pro | nav + Done · Appearance · Subscription · Support · Legal · About | Appearance control | Done only |
| Help | nav · Common questions (1 expanded) · Contact | the expanded answer | none |
| About | nav · name + version · description · Legal · Support · footer | description | none |

Dead-zone rule: no gap > 120 pt between content blocks; the CUV screens centre one block, they do not stack empty sections.

## 7. States, content rules, Stitch protocol

States matrix and SwiftUI mapping: `states.md`. Motion: `motion.md`. Copy per language: `strings.md`.

Content rules enforced in every prompt and every QA run:
- One state per screen; never rows plus an empty state.
- Only the listed strings may render; no invented stats, badges, quotes, dates, prices, URLs or claims.
- No spec words in the UI (no `SCREEN CONTENT`, `pt`, hex, `rgba`, token names).
- Static copy never truncates and never shows `...`.
- No claim that device free space increased: deletion moves photos to Recently Deleted.
- No account, no cloud, no analytics, no background access.

Stitch protocol:
- Project `244497281594604385`, `deviceType MOBILE`, one design system (`PurgeSwipe Clean Room`, LIGHT, `#5E5CE6`).
- Base screen `6b55e968533945238f17ed5832ca39ab` (Home ready) carries the measured chrome and component CSS. Every light unit is `stitch generate variant` from it; every dark unit from its accepted light screen with the explicit light→dark hex map.
- One render per call, max 2 refines per unit, then regenerate from the base with negative instructions.
- Acceptance = `stitch_qa.py` PASS + `stitch_geometry.mjs` PASS at 390/402/440 + rubric ≥ 20/24 with no 0 in hierarchy, native patterns, content or states. Receipt: `acceptance.json`.

## 8. API notes (newer than iOS 18)

| API | Use | Fallback (iOS 18) |
|---|---|---|
| Liquid Glass bar items / `.glass`, `.glassProminent`, `GlassEffectContainer` | bars, floating deck actions | system bar buttons + `.borderedProminent` / `.bordered` |
| `safeAreaBar(edge:)` | bottom CTA, counter pill | `safeAreaInset(edge:)` |
| `ConcentricRectangle` / `containerShape` | grouped corners | `RoundedRectangle(cornerRadius: 20, style: .continuous)` |
| `navigationSubtitle` | "42 of 96" under the inline title | `toolbar { ToolbarItem(placement: .principal) { VStack } }` |
| `tabBarMinimizeBehavior` | n/a (no tab bar) | — |
| `openNotificationSettingsURLString` | n/a (no notifications) | — |

Forbidden: `NavigationView`, `.foregroundColor`, `.cornerRadius`, `.tabItem`, `navigationBarTitle/Items/Hidden`, `toolbar(_:for:)`, `actionSheet`, `Alert`, `accentColor()`, `edgesIgnoringSafeArea`, `presentationMode`, `onChange(of:perform:)`, `NavigationLink(isActive:)`.
