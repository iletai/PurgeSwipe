# PurgeSwipe — Screen inventory (Stitch run 2026-11-25)

Project: `9919244769472473050` "PurgeSwipe — 1.0" · deviceType **MOBILE** · colourMode **LIGHT**
Canvas: 780 × 1768 px = 390 × 884 pt @2x. All screens are iPhone only, portrait, fluid 390–440 pt.
Design system bound: Direction A "Clean Room" (`DESIGN.md`). Accent `#5E5CE6` (dark `#7D7AFF`).

## Navigation model
Single `NavigationStack`, **no tab bar**.
Onboarding (first run, full-screen) → Home (root) → Swipe deck (push) → Review and delete (push) → system confirm.
Settings (push from the Home toolbar gear). Paywall (sheet, large detent) from Home rows, Settings "View Plans".

## Accepted screens (light)
| # | Screen | Feature folder | Route | States designed | Stitch id | PNG | Gap to close in SwiftUI |
|---|---|---|---|---|---|---|---|
| 1 | Onboarding — permission step (page 2 of 2) | `Features/Onboarding` | `AppCover.onboarding` | content | `0881950dcef448708b197101e86a6fb2` | `qa/0881950dcef448708b197101e86a6fb2.png` | glyph is Material `photo_library`; use `photo.on.rectangle.angled`. Dots: 2 pages, second active — page 1 reuses the same layout. |
| 2 | Home "Cleanup" | `Features/Home` | root | content | `73bff53c2f354195aa72c827c3fbc572` | `qa/73bff53c2f354195aa72c827c3fbc572.png` | deck rows render ~52 pt; spec is 64 pt for two-line rows → `.listRowInsets` + 64 pt min height. Toolbar gear is an opaque white circle; use the system glass toolbar item. |
| 3 | Swipe deck | `Features/Deck` | `AppRoute.deck` | content (mid-session) | `c2eb0be4f87d4a6398f022bacf2aa6dd` | `qa/c2eb0be4f87d4a6398f022bacf2aa6dd.png` | photo is a stock lake; runtime uses the `PHAsset`. Glass fill 0.30 alpha → `.glassEffect` / `.ultraThinMaterial` over the image. |
| 4 | Review and delete | `Features/Review` | `AppRoute.review` | content | `dccedeb59db3473f82134392522be1a7` | `qa/dccedeb59db3473f82134392522be1a7.png` | grid 3 × 4 shows 12 of 18; runtime shows all in a `LazyVGrid` that scrolls under the bottom bar (`safeAreaBar`). Bottom bar must be `.glass`, not opaque. |
| 5 | Paywall "PurgeSwipe Pro" | `StoreKit` | `AppSheet.paywall` | products | `9c8c4174203146898cd0112d6545f6b0` | `qa/9c8c4174203146898cd0112d6545f6b0.png` | replace the hand-built plan rows with `SubscriptionStoreView` / `ProductView`; keep the benefit list, the terms line, Restore/Terms/Privacy. |
| 6 | Settings | `Features/Settings` | `AppRoute.settings` | content | `3737c7e41b034713857800a1488275b1` | `qa/3737c7e41b034713857800a1488275b1.png` | "Appearance" row pushes a picker (System / Light / Dark). Rows 52 pt, headers 17 pt semibold sentence case. |

Every accepted screen passed `stitch_qa.py` (content) **and** `stitch_geometry.mjs` (geometry) at 390/402/440 pt.
Rubric score per screen is in `acceptance.json` (all ≥ 20/24, no 0).

## Not yet designed (pending, next run)
- Dark variants of all six screens (`DESIGN.md` §2 carries the hex map; no dark screen exists yet).
- States matrix cells marked ✓ in `states.md` without an id (loading skeletons, empty library, permission denied, purchase error, restore).
- Settings — Appearance picker, Help/FAQ, About, Privacy Policy, Terms of Use detail screens.
- App icon (Icon Composer, 6 appearances) and App Store screenshots.

## Junk ledger (`garbage.md`)
Superseded / rejected Stitch ids stay in `garbage.md` only.
