# PurgeSwipe — Product Spec (screen inventory and copy)

Source of truth: `docs/superpowers/specs/2026-11-25-purgeswipe-design.md`.
Owner: controller. Consumers: expert-designer, ios-engineer, appstore-release.

## 1. Positioning

PurgeSwipe clears iPhone photo clutter on-device: swipe left to mark for deletion, right to keep, review, confirm with the system dialog, and see how much left the library. No account, no cloud, no analytics. Free with ads; Pro removes ads, unlocks unlimited deletion after the first cleanup, all similar/blurry groups, and the large-videos deck.

Honesty rule: deletion moves assets to Recently Deleted. Copy says "moved to Recently Deleted" and offers "Finish in Photos"; never claim device free space was freed.

## 2. Screens (exactly 6, plus system UI)

### Screen 1 — Onboarding (first run, skippable)
- Page 1: "Clear your photo library, one swipe at a time." Body: "Everything happens on your iPhone. No account. No cloud."
- Page 2: privacy line + photo permission CTA "Choose photos".
- Primary: "Choose photos" (requests full or limited access). Secondary: "Not now" (continues to Home in read-only/empty state).
- No login, no email, no carousel beyond 2 pages.

### Screen 2 — Home
- Large title "Cleanup".
- Headline card: "Photo library" + total local photo/video size + item count; secondary line "On this iPhone".
- Four deck rows, each with SF Symbol, title, count, estimated reclaimable size:
  - Screenshots — `rectangle.on.rectangle`
  - Similar shots — `square.on.square`
  - Blurry photos — `camera.filters`
  - Large videos — `film` (Pro lock for free users)
- Rows show progressive counts while analysis runs: "Analyzing 42%". Cached rows open immediately.
- Last cleanup card when data exists: "Last cleanup · 128 photos · 2.4 GB moved to Recently Deleted".
- Toolbar: settings (`gearshape`).
- Banner ad below the deck list, never over content.
- States: loading, empty library, denied permission with "Open Settings", limited access with "Manage access", ready, analyzing.

### Screen 3 — Swipe deck
- Full-bleed photo (or video poster frame).
- Top: back chevron, deck title, progress "12 of 240".
- Bottom controls: Undo (`arrow.uturn.backward`), Keep (`heart` or `checkmark`), Delete (`trash`). Swipe left = delete, right = keep.
- Session counter: "18 to delete".
- Haptics on decision. Reduce Motion: cards cross-fade instead of spring.
- At the end: sheet or push to Review.
- Empty deck: `ContentUnavailableView` "Nothing here" + "Back to Cleanup".
- Similar deck: header line "Similar set · best shot kept".

### Screen 4 — Review and delete
- Title "Review".
- Grid of marked items with count and estimated size.
- Primary "Delete N photos" -> system PhotoKit confirmation.
- Secondary "Review each" -> returns to deck at first marked item.
- After success: "Moved N photos (X GB) to Recently Deleted", "Finish in Photos" button, optional device free-space delta line.
- Cancelled/failed: bin preserved, inline message, no success number.
- Free cap reached: show "N of 25 left today" and paywall on locked action, never before the first cleanup.

### Screen 5 — Paywall
- Title "PurgeSwipe Pro".
- SubscriptionStoreView for the Pro group, yearly preselected, 3-day free trial.
- Lifetime product below: $29.99 one-time.
- Bullets: unlimited deletions, all similar and blurry groups, large videos, no ads.
- Restore Purchases, Privacy Policy, Terms of Use (EULA). Dismissible.
- Prices come from StoreKit, never hardcoded in UI.

### Screen 6 — Settings
- Appearance: System / Light / Dark.
- Pro status: "Pro active" or "Free plan", View Plans, Restore Purchases, Manage Subscription.
- Help / FAQ, Privacy Policy, Terms of Use, About.
- No ads here.

## 3. Free vs Pro

| Capability | Free | Pro |
|---|---|---|
| Swipe and review | unlimited | unlimited |
| First cleanup | uncapped | uncapped |
| Delete after first cleanup | 25 photos/day | unlimited |
| Large videos deck | locked | open |
| Similar and blurry groups | 2 complete groups/day | all |
| Banner ads | yes | no |

Prices: $4.99/mo, $19.99/yr with 3-day trial, $29.99 lifetime. Product ids: `<env bundle id>.pro.monthly`, `.yearly`, `.lifetime`.

## 4. Copy rules

- "Similar", never "duplicate".
- "Moved to Recently Deleted", never "freed".
- vi + en, every string in `Localizable.xcstrings`.
- No emoji, no superlatives, no fake stats.

## 5. Technical constraints

- iPhone portrait, iOS 18.0+, Swift 6, SwiftUI, SwiftData.
- Photos, Vision, Core Image, StoreKit 2, GoogleMobileAds (test IDs for 1.0.0).
- No backend, no account, no analytics, no network outside StoreKit/AdMob.
- Analysis in 30-day windows, max 300 assets/window, 60-second foreground slices, cancellable.
- iCloud-only assets excluded (`isNetworkAccessAllowed = false`).
