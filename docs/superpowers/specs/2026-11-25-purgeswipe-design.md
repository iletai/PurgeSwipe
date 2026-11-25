# PurgeSwipe — Design

Date: 2026-11-25
Status: awaiting approval
Working name: PurgeSwipe (final store name verified at ASC step)
Bundle: `com.iletai.purgeswipe` (Dev `.dev`, Staging `.staging`)
Team: AP58YLHQ2S

## 1. Intent and why

iPhone users hit "Storage Almost Full" and want relief in one sitting. Existing cleaners monetize that panic with ~$9.99/week subscriptions, heavy ads, and cloud accounts. PurgeSwipe wins by making the first session fast, visual, and honest: swipe left to trash, right to keep, confirm one deletion, see how much left the library. Everything runs on-device with no account and no network calls outside StoreKit/AdMob.

**Honesty rule (decided after builder check):** PhotoKit deletion moves assets to Recently Deleted, so the app never claims device free space was freed. It reports bytes moved out of the library, then offers "Finish in Photos" to empty Recently Deleted, and shows a device free-space delta only when the system reports one.

Why now: research shows 55% of 3-day trial cancellations happen on day 0, Utilities lead 12-month trial LTV ($68.90), and low-priced annual plans retain 36% in year one. A cleaner that delivers the payoff in the first 60 seconds fits that evidence.

## 2. Goals

- A user with a full phone removes clutter in under two minutes without reading instructions.
- 100% on-device: no backend, no login, no analytics SDK.
- Hybrid monetization: free tier with ads, Pro subscription (3-day trial) and lifetime purchase.
- Ship 1.0.0 to App Store review with 3 environments, CI, IAP, TestFlight, screenshots, privacy labels.

## 3. Non-goals

- Video compression, cloud backup, cross-album duplicate detection, contact/calendar cleaning.
- Exact-duplicate hash matching. v1 ships visually similar groups; screenshot copy says "similar", never "duplicates".
- Android, iPad-specific layout, macOS.
- AI-generated captions or any cloud AI.
- Account system, sync, social features.

## 4. Anti-goals (failure even if it runs)

- Asking for full photo access before showing any value.
- A paywall that blocks the first cleanup.
- Ads inside the swipe deck or between swipes.
- Claiming "freed space" before PhotoKit confirms deletion.
- Shipping an empty screen with a "clean" button that does nothing (guideline 4.2).

## 5. Constraints

- Swift 6, SwiftUI, SwiftData, iOS 18.0+, iPhone portrait. Liquid Glass comes from system bars on iOS 26+; the app keeps deployment target 18.0 and never draws custom opaque chrome, so no availability-gated redesign is needed beyond the system fallback.
- Photos/PhotosUI, Vision, Core Image, StoreKit 2, Google Mobile Ads (test IDs for 1.0.0).
- House standard from `ios-new-app`: 3 envs, schemes `<App>-Dev` / `<App>-Staging` / `<App>`, fastlane, GitHub Actions, privacy manifest, vi + en localization.
- Public GitHub repo `iletai/PurgeSwipe`, `develop` default, secrets only in `.env`/GitHub secrets.

## 6. Approaches considered

Build:
- **A (chosen): native swipe deck on PhotoKit + Vision + SwiftData.** Fastest path to the emotional payoff, uses system photo deletion confirmation, works offline.
- B: smart-album list with checkboxes. Easier but less differentiated, weaker screenshots, more likely to look like every other cleaner.
- C: VisionKit document scanner. Wrong job; crowded; no storage-cleanup value.

Monetization:
- **A (chosen): hybrid — free with a daily deletion cap + banner ads, Pro unlocks unlimited deletion, smart groups, no ads.**
- B: hard paywall after onboarding. Converts better per benchmark but triggers the exact subscription backlash the research documents; higher refund risk.
- C: one-time purchase only. Friendly, but no recurring revenue and no trial; weaker LTV.

## 7. Product

### 7.1 Core loop
Storage warning -> open app -> pick a deck (Screenshots, Similar, Blurry, Large videos) -> swipe left/right -> summary -> confirm system delete -> freed space shown -> tomorrow, new photos accumulate.

### 7.2 Screens (5 + system)

1. **Onboarding (first run only, skippable).** Value line, privacy line, "Choose photos" permission CTA, limited-access fallback. No login. No carousel longer than 2 pages.
2. **Home.** Library headline (total photo/video size, item count), four deck rows with counts and estimated reclaimable size, last cleanup result card, settings toolbar item. Counts appear progressively while analysis runs ("Analyzing 42%") and never block the first deck. Banner ad sits below the deck list, never over it.
3. **Swipe deck.** Full-bleed photo, deck title and progress, Undo, "Keep" and "Delete" affordances plus swipe gestures, session counter. Haptics on decision. Exit asks to review the bin.
4. **Review and delete.** Grid of marked items, total count and estimated size, "Delete N photos" primary button, "Review each" secondary, cancel. Uses the system PhotoKit deletion confirmation. After success: "Moved N photos (X GB) to Recently Deleted", a "Finish in Photos" button, and a device free-space delta only when measurable.
5. **Paywall.** SubscriptionStoreView for the Pro group (yearly preselected, 3-day trial), lifetime product below, Restore Purchases, Privacy Policy and Terms (EULA) links. Dismissible.
6. **Settings.** Appearance (system/light/dark), Pro status, Restore Purchases, Manage Subscription, Help/FAQ, Privacy, Terms, About. Banner ad never in Settings.

### 7.3 Free vs Pro

| Capability | Free | Pro |
|---|---|---|
| Swipe and review | unlimited | unlimited |
| First cleanup | uncapped | uncapped |
| Delete after the first cleanup | 25 photos/day | unlimited |
| Large videos deck | see count/size, Pro to open | full |
| Similar and Blurry groups | 2 complete groups/day; rest locked | all groups |
| Banner ads | yes | no |
| Price | - | $4.99/mo, $19.99/yr (3-day trial), $29.99 lifetime |

The cap counts confirmed deletions, resets at local midnight, is global across decks, and never applies to the first cleanup session. Videos are Pro-only so one large item cannot bypass the photo cap. Paywall appears only when a locked action is tapped or the cap is hit, never before the first successful cleanup.

### 7.4 Smart groups

- **Screenshots:** `PHAssetMediaSubtype.photoScreenshot`.
- **Similar:** Vision feature prints compared only inside 30-day windows, up to 300 assets per window, distance threshold. The sharpest/highest-resolution item is auto-kept and shown as group context; the rest enter a flat swipe queue. Group membership is stored so Undo restores the item to its group.
- **Blurry:** Core Image Laplacian variance score below a tunable threshold; show a score bucket, never a fake percentage.
- **Large videos:** top N local videos by file size, sorted descending. Pro-only deck.
- **Scale target:** 3k-30k asset libraries on iPhone 12 or newer. First pass is incremental and cached in SwiftData keyed by asset local identifier + modification date; analysis is cancellable, runs in 60-second foreground slices, and never blocks opening a cached deck.
- **iCloud-only assets:** `isNetworkAccessAllowed = false`; assets that cannot be read locally are excluded from decks, counts, and byte estimates. The app reports library bytes, never device free space.

## 8. Architecture

- `PhotoLibraryService`: authorization, fetch, thumbnail loading (PHCachingImageManager), delete request.
- `AnalysisService`: actor; Vision feature prints, blur scoring; throttled, cancellable.
- `CleanupSession`: @Observable state machine for deck order, decisions, undo stack, bin.
- SwiftData: `CleanedSession` (date, count, bytes), `SmartGroupCache` (asset id, group kind, score, modification date). No image blobs in the store.
- Entitlement: StoreKit 2 `Transaction.currentEntitlements`, `.isPro` environment value, restore, offline grace from cached entitlement.
- Ads: `Ads.swift` from the template; banner on Home and Review only; ATT prompt after onboarding, before first ad load.
- Concurrency: UI `@MainActor`; analysis actor returns `Sendable` value types; cancellation checked per batch.
- Failure modes: permission denied -> explain + Settings deep link; limited access -> "Manage access"; deletion cancelled -> keep bin; disk full -> no special handling; purchase pending -> show pending state.

### Privacy and review

- Info.plist: `NSPhotoLibraryUsageDescription`, `NSPhotoLibraryAddUsageDescription` only if needed, `NSUserTrackingUsageDescription` for ATT, `ITSAppUsesNonExemptEncryption=false`.
- Privacy manifest: UserDefaults reason CA92.1, no tracking domains beyond AdMob's, collected data declared only if true.
- Age rating: advertising = true (AdMob linked).
- No account deletion flow needed (no accounts).
- Review notes explain on-device processing and that deletion uses the system confirmation.

## 9. Design direction

The expert-designer runs the aesthetic checkpoint with 2-3 directions before generating. Constraints from this doc: native iOS vocabulary, Liquid Glass bars, one accent hue, light and dark, no gradient soup, no card-in-card, photo content is the hero. Store screenshot story: "Swipe to clear space", "Find similar shots automatically", "Review before you delete", "No account. No cloud." Every screenshot claim must match what the build actually does.

## 10. Delivery plan

1. Create public repo `iletai/PurgeSwipe`, checkout in Orca, scaffold with `new_app.sh --with storekit,nav,update,ads`, merge into repo.
2. Design: expert-designer writes `docs/design/` from this doc, Stitch project + screens + acceptance receipt.
3. Implement: ios-engineer builds the 5 screens + services + tests on the house template.
4. Assets: icon, 6.9" screenshots composed, vi/en metadata, privacy/terms/support pages.
5. Signing + CI: bootstrap 3 bundle ids, match, repo secrets, `doctor.sh`, green CI + deploy-dev.
6. ASC: 3 app records, subscription group + 3 products + lifetime, age rating, privacy, review contact.
7. TestFlight, then submit 1.0.0 for review.

## 11. Open items for the builder

- Final store name and SKU (unique check in ASC).
- App Store category (Utilities) and availability (all territories except where required filings apply).
- Real AdMob IDs: deferred; 1.0.0 ships Google test IDs by decision.
- Support/privacy URLs come from the apps-site page for `purgeswipe`.

## 12. Builder-check resolutions (my calls)

1. **Freed space:** report bytes moved to Recently Deleted, plus a "Finish in Photos" link; device free-space delta only if `volumeAvailableCapacityForImportantUsage` actually changes. Screenshots and review notes use the same wording.
2. **Free cap collision:** first cleanup uncapped; afterwards 25 confirmed deletions per local day, global across decks. Videos Pro-only. Locked actions show the paywall; the cap never blocks the first success.
3. **Scale:** 3k-30k assets, 30-day comparison windows, progressive Home counts, cached incremental analysis, 60-second slices. No blocking first-run analysis.
4. **iCloud-only assets:** excluded from decks/counts/sizes via `isNetworkAccessAllowed = false`; copy says "library", never "device storage".
5. **Similar deck:** group context with the best shot auto-kept; remaining photos form a flat queue; Undo restores an item to its group.
6. **Free group preview:** two complete groups per day, all analysis runs for everyone (UI lock only), so counts never look broken.
7. **Deployment target:** stay on iOS 18.0; system bars provide Liquid Glass on iOS 26+, no custom opaque chrome, verify on both an iOS 18 runtime if available and iOS 26/27.
8. **Duplicates:** no exact-duplicate hash deck in v1; all copy says "similar", never "duplicate".
