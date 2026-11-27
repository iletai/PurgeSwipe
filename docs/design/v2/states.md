# PurgeSwipe v2 — states

Every cell marked ✓ has a render or a written variant note. Stitch ids are in `screens.md`; unverified items carry `[unverified]`.

## Matrix

| Screen | Loading | Content | Empty / first run | No results | Error | Offline | Permission denied |
|---|---|---|---|---|---|---|---|
| Onboarding | — | ✓ `onboarding-1`, `onboarding-2` | ✓ first run (the cover itself) | — | — | — | ✓ page 2 explains the ask before the system alert |
| Home | ✓ `home-analyzing` (determinate bar, 42 %) | ✓ `home-ready` | ✓ `home-empty` (CUV + Reload) | — | inline row: `exclamationmark.triangle` + "Analysis failed" + "Try Again" (variant of `home-empty`, no render) | cached decks stay tappable, progress caption reads "Waiting for connection" (variant note) | ✓ `home-denied` (CUV + Open Settings) |
| Deck | ✓ `.redacted` skeleton card + counter pill, 200 ms (no render) | ✓ `deck-mid`, `deck-similar` | ✓ `deck-finished` (CUV + Review N photos) | ✓ "Nothing to swipe here" CUV, when the deck is emptied by another app (no render) | alert "Could not load this photo" + Retry (no render) | on-device; n/a | falls back to `home-denied` |
| Review | ✓ button spinner inside the red capsule, label stays "Delete N photos" | ✓ `review-marked` | ✓ "Nothing marked" CUV (no render) | — | ✓ alert "Could not delete" + Try Again (no render) | on-device; n/a | falls back to `home-denied` |
| Result | — | ✓ `review-success` | — | — | same alert as Review | — | — |
| Free limit | — | ✓ `review-cap` | — | — | — | — | — |
| Paywall | ✓ `.redacted` plan rows + spinner under the CTA (no render) | ✓ `paywall-products` | — | — | ✓ `paywall-error` (Try Again + disabled CTA) | ✓ same screen, copy "Check your internet connection and try again." | — |
| Settings / Help / About | — | ✓ `settings-free`, `settings-pro`, `help`, `about` | — | — | — | — | — |
| Dark | — | ✓ `home-ready-dark`, `settings-free-dark`, `onboarding-2-dark` | — | — | — | — | — |

## SwiftUI mapping per state

| State | Implementation |
|---|---|
| Skeleton | `.redacted(reason: .placeholder)` on the real rows, never a full-screen spinner; cross-fade `.smooth` 0.3 s into content |
| Determinate scan | `ProgressView(value: scanned, total: total)` `.tint(Color("AccentColor"))` + caption `Text("Scanning \(pct)%")`; no spinner swap mid-task |
| Empty / denied / finished / nothing-marked | `ContentUnavailableView { Label(...) } description: { Text(...) } actions: { Button(...) }` — one 56 pt hierarchical symbol, one action |
| No results (search-free app, deck emptied elsewhere) | `ContentUnavailableView.search` equivalent: `ContentUnavailableView("Nothing to swipe here", systemImage: "rectangle.stack", description: Text("…"))` |
| Error needing a decision | `.alert` with ≤ 2 actions (Try Again / Cancel); never a toast, never a notification |
| Offline | inline notice row inside the affected group + Retry; cached content stays interactive |
| Permission denied | `ContentUnavailableView` + `Button("Open Settings")` → `UIApplication.openSettingsURLString`; never re-ask the system alert |
| Photo load failure | `AsyncImage`/`PHImageManager` phase → fixed-size placeholder, no layout shift |
| Purchase | `PurchaseState`: `.loading` (CTA shows `ProgressView`), `.purchasing`, `.success` (dismiss + `.sensoryFeedback(.success)`), `.cancelled` (silent), `.failed` (`.alert`) |
| Restore | `AppStore.sync()` with a 34 pt capsule spinner; result → `.alert("Purchases restored")` or an inline "No purchases found" |

## Notifications

None. The app never calls `UNUserNotificationCenter`, sends no push, runs no Live Activity, so `notifications.md` is intentionally absent. The only permission is Photos, requested from `onboarding-2` → `PHPhotoLibrary.requestAuthorization(for: .readWrite)`.
