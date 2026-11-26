# PurgeSwipe — States matrix (Stitch run 2026-11-25)

`✓` = designed and accepted · `—` = not applicable · `pending` = required, no Stitch screen yet (build from the SwiftUI spec below).
Stitch ids live in `screens.md`; the states kit is screen `4527846203814241743` ("iOS 27 Kit — States").

| Screen | Loading | Content | Empty / first run | No results | Error | Offline | Permission denied |
|---|---|---|---|---|---|---|---|
| Onboarding | — | ✓ `0881950d…` | — | — | — | — | pending: same layout, "Choose photos" → "Open Settings", body "PurgeSwipe can only read the photos you allow." |
| Home | pending: skeleton rows with `.redacted(reason: .placeholder)`, deck rows show "Analyzing 42%" | ✓ `73bff53c…` | pending: `ContentUnavailableView` "No photos yet" + "Choose photos" | — | pending: CUV "Could not read your library" + Retry | pending: cached counts + inline notice | pending: CUV + "Open Settings" |
| Swipe deck | pending: photo placeholder + `ProgressView` | ✓ `c2eb0be4…` | pending: CUV "Deck finished" + "Back to Cleanup" | — | pending: failure glyph + Retry | — | pending: CUV + Open Settings |
| Review and delete | — | ✓ `dccedeb5…` | pending: CUV "Nothing marked" | — | pending: alert with Retry (system delete fails) | — | — |
| Paywall | pending: `ProductView` skeleton | ✓ `9c8c4174…` (products) | — | — | pending: inline error + Retry | pending: "Connect to the internet to subscribe" | — |
| Settings | — | ✓ `3737c7e4…` | — | — | — | — | pending: notification row state |

## SwiftUI mapping
- Skeleton: `.redacted(reason: .placeholder)` on the real rows, cross-fade `.smooth`.
- Empty / error / no results: `ContentUnavailableView` — 48 pt hierarchical symbol, Title 2 bold, one Subheadline line, at most one regular capsule action. `ContentUnavailableView.search(text:)` for search (no search screen in v1).
- Progress: `ProgressView(value:total:)` for analysis ("Analyzing 42%"), `ProgressView()` inline in rows, never full-screen.
- Pull to refresh: `.refreshable` on Home.
- Images: `AsyncImage` phases — fixed 116 pt square placeholder, failure shows a `photo` symbol, never a broken-image glyph.
- Permission: `PHPhotoLibrary.requestAuthorization(for: .readWrite)` at the moment of "Choose photos"; denied → iOS Settings link via `openSettingsURLString`.
- Offline: StoreKit errors surface inline on the paywall; no network is required for cleanup.

## Notifications
PurgeSwipe sends **no** notifications in v1 (no push, no local notifications, no Live Activity). `notifications.md` is therefore N/A; if a "cleanup reminder" is added later, it needs a pre-permission screen plus a category table.
