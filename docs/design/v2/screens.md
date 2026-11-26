# PurgeSwipe — screen inventory and handoff (v2)

Stitch project **`244497281594604385`** ("PurgeSwipe — v2 2026-11-26") · `deviceType MOBILE` · canvas 780×1768 px = 390×884 pt · design system **PurgeSwipe Clean Room** (`#5E5CE6`, LIGHT, designMd = full `DESIGN.md`).
v1 project `9919244769472473050` and `docs/design/*` (v1) are untouched. Product scope: `docs/product/SPEC.md`.

## 1. Navigation model

One `NavigationStack`, **no tab bar anywhere**, one sheet.

```
RootView
└─ NavigationStack(path: AppRoute)
   ├─ HomeView                 root                     large title "Cleanup" + gearshape (settings)
   ├─ DeckView(deck:)          push AppRoute.deck       inline title + 13 pt subtitle "42 of 96"
   ├─ ReviewView(selection:)   push AppRoute.review     inline title "Review"
   ├─ SettingsView             push AppRoute.settings   inline title "Settings" + Done (only tinted bar item)
   ├─ HelpView                 push from Settings       inline title "Help"
   └─ AboutView                push from Settings       inline title "About"
sheet: PaywallView (.large detent, grabber, close circle) ← deck locked, review limit, Settings › PurgeSwipe Pro
```

Matches `App/Navigation/AppNavigation.swift` (`AppRoute{settings,deck,review}` + `AppSheet.paywall`). Back is always the system glass chevron with no previous-title text (iOS 26+). Onboarding is a `fullScreenCover` shown once. Launch screen = `home-analyzing` without data (no text, logo or animation).

## 2. Screens → code → states

| # | Screen | Feature folder | Route | States | Primary action |
|---|---|---|---|---|---|
| 1 | Onboarding p1 | `Features/Onboarding/` | cover | first run | Continue |
| 2 | Onboarding p2 | `Features/Onboarding/` | cover | priming, denied | Choose photos (one button + Skip) |
| 3 | Home "Cleanup" | `Features/Cleanup/` | root | ready, analyzing, empty, denied, analysis error | open a deck |
| 4 | Swipe deck | `Features/Deck/` | push | mid-session, similar set, finished | swipe left / right |
| 5 | Review | `Features/Review/` | push | marked, deleting, success, daily limit, failure | Delete N photos |
| 6 | Paywall | `StoreKit/` | sheet `.large` | loading, products, purchase, restore, error | Start free trial |
| 7 | Settings | `Features/Settings/` | push | free, Pro | change a setting |
| 8 | Help & FAQ | `Features/Help/` | push | one expanded answer | open support |
| 9 | About | `Features/About/` | push | content | open legal |

Documented as SwiftUI variants, no separate render: paywall loading / purchase-in-progress / restore result, review failure alert, "nothing marked", "analysis failed" row, limited photo access, offline, launch screen.

## 3. Unit inventory and acceptance

`ACCEPT` = both scripts PASS **and** the full-resolution PNG was read this run with no defect. `SCRIPT-PASS` = both scripts PASS, PNG not re-read (except `onboarding-2`, whose geometry FAIL is a false positive — the separator heuristic on a screen with no rows). `GAP` = usable reference, the listed defect is fixed numerically in code. `REJECT` = not usable.

| Unit | Kind | Verdict | Content / geometry | Note |
|---|---|---|---|---|
| `onboarding-1` | light | SCRIPT-PASS | PASS / PASS | Skip hit area now 44×44 |
| `onboarding-2` | light | SCRIPT-PASS | PASS / FAIL (false positive) | "list rows without separators" on a screen with 3 text nodes |
| `home-ready` | light | **ACCEPT** | PASS / PASS | focal 128.4 GB + 4 deck rows + ad slot; hairlines are drawn by `List` in code |
| `home-analyzing` | light | SCRIPT-PASS | PASS / PASS | 42 % determinate bar inside the library group |
| `home-empty` | light | SCRIPT-PASS | PASS / PASS | CUV + Reload |
| `home-denied` | light | GAP | PASS / FAIL | `lock.circle` drawn ~350 pt instead of 56 pt; CUV left-aligned at x=0; ~200 pt dead zone |
| `deck-mid` | light | GAP | PASS / PASS | photo is a 16 pt inset card, not full-bleed; second back chevron over the photo; invented caption "Moraine Lake, Banff" + heart baked into the stock photo |
| `deck-similar` | light | GAP | PASS / FAIL | badge pill overlaps the nav bar |
| `deck-finished` | light | GAP | PASS / FAIL | Arial fallback; CTA label 19 pt tall |
| `review-marked` | light | GAP | PASS / FAIL | island drawn 138–188 pt wide; grid + pinned red CTA correct |
| `review-success` | light | GAP | PASS / FAIL | home indicator drawn 19 pt up |
| `review-cap` | light | SCRIPT-PASS | PASS / PASS | — |
| `paywall-products` | light | REJECT | PASS / PASS | **serif (Times) type** on every heading, plan and price |
| `paywall-error` | light | GAP | PASS / PASS | correct and sans, but ~200 pt dead zone below the legal links |
| `settings-free` | light | **ACCEPT** | PASS / PASS | 780×2000 = scroll extension |
| `settings-pro` | light | SCRIPT-PASS | PASS / PASS | 780×2080 = scroll extension |
| `help` | light | SCRIPT-PASS | PASS / PASS | — |
| `about` | light | GAP | PASS / FAIL | home indicator 19 pt up |
| `onboarding-2-dark` | dark | SCRIPT-PASS | PASS / FAIL (false positive) | same heuristic |
| `home-ready-dark` | dark | SCRIPT-PASS | PASS / PASS | — |
| `deck-mid-dark` | dark | GAP | PASS / FAIL | inherits the light defect; the flagged "glass" is the counter pill (navigation layer) |
| `review-marked-dark` | dark | GAP | FAIL / FAIL | inherits the chrome defect; content gate flags "glow" |
| `paywall-products-dark` | dark | REJECT | PASS / PASS | serif type |
| `settings-free-dark` | dark | SCRIPT-PASS | PASS / PASS | — |

**2 ACCEPT · 10 SCRIPT-PASS · 10 GAP · 2 REJECT** out of 24. Receipt: `acceptance.json`.

## 4. Gap table (render → ship)

| Defect in the render | Ship as | SwiftUI value |
|---|---|---|
| Serif type on the paywall | never | `.font(.title.bold)` / `.headline` / `.title3.weight(.semibold)` — no family override anywhere |
| `Arial` fallback | never | system font only |
| CUV symbol ~350 pt | 56 pt | `Image(systemName:).font(.system(size: 56, weight: .regular)).symbolRenderingMode(.hierarchical).foregroundStyle(.secondary)` |
| CUV block left-aligned | centred | `ContentUnavailableView { … } description: { … } actions: { … }` centres itself; add `.padding(.horizontal, 16)` |
| CTA label 19 pt tall | 50 pt capsule | `.frame(maxWidth: .infinity, minHeight: 50)` + `.buttonStyle(.glassProminent)` (iOS 26) / `.borderedProminent` (18) |
| Home indicator 19 pt up / island 138 pt | system chrome | never drawn by the app; use `safeAreaInsets` |
| Photo as a 16 pt inset card with baked-in caption | full-bleed card | `Image(uiImage:).resizable().scaledToFill().ignoresSafeArea()` + own overlay only |
| Second back chevron over the photo | one bar only | `.toolbar { ToolbarItem(placement: .topBarLeading) { … } }` with `.navigationBarBackButtonHidden(true)` **only if** a custom leading item is truly needed |
| Badge pill under the bar | safe-area stack | `.safeAreaInset(edge: .top) { Badge().padding(.top, 16) }` |
| Dead zone ≥ 120 pt | pin the CTA | `.safeAreaBar(edge: .bottom) { CTA }` (fallback `safeAreaInset`) |
| Missing row hairlines | automatic | `List { … }.listStyle(.insetGrouped)` |
| Canvas taller than 1768 px | scroll | `List`/`ScrollView`; the device frame stays 874 pt |

## 5. States matrix

See `states.md` (every cell mapped to a render id or a written variant + the SwiftUI API).

## 6. Motion

See `motion.md` — 30 rows: trigger · property · from→to · SwiftUI animation · timing · interruptible · haptic · Reduce Motion fallback.

## 7. API notes (newer than iOS 18)

| API | Use | Fallback (iOS 18) |
|---|---|---|
| `.glass`, `.glassProminent`, `GlassEffectContainer` | bars, deck actions | `.bordered` / `.borderedProminent` |
| `safeAreaBar(edge:)` | bottom CTA, counter pill, badge | `safeAreaInset(edge:)` |
| `ConcentricRectangle` / `containerShape` | grouped corners | `RoundedRectangle(cornerRadius: 20, style: .continuous)` |
| `navigationSubtitle` | "42 of 96" | `ToolbarItem(placement: .principal) { VStack }` |

Forbidden: `NavigationView`, `.foregroundColor`, `.cornerRadius`, `.tabItem`, `navigationBarTitle/Items/Hidden`, `toolbar(_:for:)`, `actionSheet`, `Alert`, `accentColor()`, `edgesIgnoringSafeArea`, `presentationMode`, `onChange(of:perform:)`, `NavigationLink(isActive:)`.

## 8. Accepted Stitch screen ids

| Unit | id | Verdict |
|---|---|---|
| onboarding-1 | `2bb9df04dbab4d5e8114c1caa8006664` | SCRIPT-PASS |
| onboarding-2 | `7dbc13abc8124f0aa36256a4cd51e1fb` | SCRIPT-PASS |
| home-ready | `6b55e968533945238f17ed5832ca39ab` | ACCEPT (base for every variant) |
| home-analyzing | `4b214bc63f6e40c58c385ee0e91bad31` | SCRIPT-PASS |
| home-empty | `aa681b1b178a4ff8b386665836ecbde3` | SCRIPT-PASS |
| home-denied | `fb2964e3a63b440a8a59a9b9153ad08d` | GAP |
| deck-mid | `207285d9bb064cfc92b3a018c30aa75d` | GAP |
| deck-similar | `c6e9b2a0eb7242dc88bf44ef5b2cdce4` | GAP |
| deck-finished | `8e96bcbb10e847328538392ac5b6c441` | GAP |
| review-marked | `701a33e434d14f2b816c6c18f4f0e0ab` | GAP |
| review-success | `7bce18ff374a46f3b2d8b4cce7e08e9a` | GAP |
| review-cap | `8ec8a233076a4879a3a3008e7fd77407` | SCRIPT-PASS |
| paywall-products | `5e42463a25f74d9e9dd9f8be3b7966aa` | REJECT |
| paywall-error | `d4b7d58f39994c95a91d93f043cb3173` | GAP |
| settings-free | `3254e8ec310a483394e4b36bc0d099b1` | ACCEPT |
| settings-pro | `b47109accd7f40c1afefa488776d0d33` | SCRIPT-PASS |
| help | `87fccdbc0d17463f8fe31e6f619bb297` | SCRIPT-PASS |
| about | `f4cc162def3a4bf2b8279f5bb41bbfb9` | GAP |
| onboarding-2-dark | `95a8186fcc3444fbb43d4374bc9c8c2b` | SCRIPT-PASS |
| home-ready-dark | `1f589fe765714f9f940d3aebc39c7fc5` | SCRIPT-PASS |
| deck-mid-dark | `4bbc12379ff1498aadb267ca302b75ce` | GAP |
| review-marked-dark | `7b81174b05f043ae9c8bf14c9b783a0f` | GAP |
| paywall-products-dark | `b44a1d8a70354c18bd6edf09cbc4b314` | REJECT |
| settings-free-dark | `ac70c0cb7dcf4261b44d8d6d3b76f40d` | SCRIPT-PASS |

Superseded / rejected ids live only in `garbage.md`.
