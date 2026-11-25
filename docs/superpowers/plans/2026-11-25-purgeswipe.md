# PurgeSwipe 1.0.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Ship PurgeSwipe 1.0.0 — an on-device photo cleaner with swipe decks, safe deletion, ads, and StoreKit — through App Store review.

**Architecture:** House template (`ios-new-app`) with 3 environments, SwiftUI + SwiftData, PhotoKit for library access, Vision/Core Image for analysis, StoreKit 2 for Pro, Google Mobile Ads for the free tier. One `PhotoLibraryService`, one `AnalysisService` actor, one `CleanupSession` state machine, and thin SwiftUI screens.

**Tech Stack:** Swift 6, SwiftUI, SwiftData, Photos, Vision, Core Image, StoreKit 2, GoogleMobileAds, XcodeGen, fastlane, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-11-25-purgeswipe-design.md`

## Global Constraints

- Deployment target iOS 18.0, iPhone only, portrait; Swift 6.
- Bundle ids: `com.iletai.purgeswipe`, `.dev`, `.staging`; team `AP58YLHQ2S`.
- No backend, no account, no analytics, no network outside StoreKit and AdMob.
- All user-facing copy in vi + en string catalogs; no raw keys in UI.
- Ads: Google test IDs for 1.0.0; banner only on Home and Review; Pro removes ads.
- Prices: $4.99/mo, $19.99/yr (3-day trial), $29.99 lifetime; product ids `<env bundle id>.pro.monthly|yearly|lifetime`.
- Never claim device free space was freed; report library bytes moved to Recently Deleted.
- Every task ends with `xcodebuild` build + tests passing on a simulator; commit with conventional message.

## Review Focus

- Permission denied or limited access: app explains and offers Settings/Manage access, never an empty deck.
- PhotoKit deletion cancelled or failed: bin preserved, no success number shown.
- iCloud-only asset: excluded from counts/decks; no download attempt.
- Empty library or empty deck: `ContentUnavailableView` with a next action, no crash.
- Free-cap boundary: first cleanup uncapped; 25/day afterwards; midnight reset; videos Pro-only.
- Restore purchases offline: cached entitlement keeps Pro until StoreKit answers.
- Ad load failure: layout keeps its height or collapses without jumping; no blank banner hole.
- 30k-asset library: analysis is chunked, cancellable, and does not block opening cached decks.
- Reduce Motion and VoiceOver: swipe alternatives exist; every icon-only control has a label.
- Recently Deleted: copy and screenshots match the actual behavior.

---

### Task 1: Scaffold the house project into the public repo

**Files:**
- Create: full scaffold under `/Users/lequangtrongtai/orca/PurgeSwipe`
- Modify: `.gitignore` (merge, never overwrite), `.env` (local only, gitignored)

**Interfaces:**
- Produces: working `PurgeSwipe` scheme, `PurgeSwipe-Dev`, `PurgeSwipe-Staging`; `scripts/doctor.sh`; `project.yml`.

- [ ] Scaffold to a temp dir: `APPLE_TEAM_ID=AP58YLHQ2S ~/.agents/skills/ios-new-app/scripts/new_app.sh PurgeSwipe com.iletai.purgeswipe /tmp/PurgeSwipe-scaffold --with storekit,nav,update,ads`
- [ ] Merge into the repo without touching `.git`: copy all files, merge `.gitignore`, never overwrite repo `.git`.
- [ ] Copy spec to `docs/superpowers/specs/2026-11-25-purgeswipe-design.md` and this plan to `docs/superpowers/plans/`.
- [ ] Run `xcodegen generate`; build `PurgeSwipe-Dev` for an iPhone 17 simulator.
- [ ] Run unit + UI tests on `PurgeSwipe-Dev`; both pass.
- [ ] Commit `chore: scaffold PurgeSwipe` and push `develop`.

**Verify:** `xcodebuild -list` shows 3 schemes; `git status` clean except `.env`; tests pass.

---

### Task 2: Design handoff (Stitch)

**Files:**
- Create: `docs/design/DESIGN.md`, `screens.md`, `states.md`, `motion.md`, `strings.md`, `acceptance.json`

**Interfaces:**
- Consumes: spec screens 1-6.
- Produces: exact copy, tokens, per-screen states; Stitch project id + screen ids.

- [ ] Dispatch `expert-designer` with the spec; require the aesthetic checkpoint (2-3 directions) before generation.
- [ ] At the checkpoint, ask the user; resume the agent with the choice.
- [ ] Verify acceptance receipt covers light + dark for all screens and no spec text leaks.
- [ ] Compare generated screens against the spec; reject any extra tab bar or screen.
- [ ] Commit `docs/design`.

**Verify:** `acceptance.json` has every screen, no unresolved FAIL; screenshots reviewed by eye.

---

### Task 3: Photo library access, local-asset filtering, deletion

**Files:**
- Create: `App/Infrastructure/Photos/PhotoLibraryService.swift`, `CleanupAsset.swift`, `PhotoAccess.swift`
- Test: `Tests/PhotoLibraryServiceTests.swift`

**Interfaces:**
- Produces: `protocol PhotoLibraryProviding: Sendable { func requestAccess() async -> PhotoAccess; func fetchLocalAssets() async -> [CleanupAsset]; func delete(ids: [String]) async throws -> DeletionOutcome }`
- `CleanupAsset: Sendable, Identifiable` with `id: String`, `byteCount: Int64`, `isVideo`, `isScreenshot`, `creationDate: Date`, `pixelWidth: Int`, `pixelHeight: Int`.
- `PhotoAccess` enum: `.full`, `.limited`, `.denied`, `.notDetermined`.
- `DeletionOutcome` struct: `deletedIDs: [String]`, `failedIDs: [String]`, `libraryBytes: Int64`.

- [ ] Test: denied access returns `.denied` and `fetchLocalAssets()` returns empty without throwing.
- [ ] Test: assets whose resource cannot be read locally are filtered out (`isNetworkAccessAllowed = false`).
- [ ] Test: `delete` maps PhotoKit failure to `failedIDs` and never counts failed bytes.
- [ ] Implement with a `PhotoKitProvider` wrapper so tests inject a fake.
- [ ] Commit `feat: photo library service`.

**Verify:** unit tests pass; no Photos API call on a background thread outside the wrapper.

---

### Task 4: Cleanup session state machine + free quota

**Files:**
- Create: `App/Features/Cleanup/CleanupSession.swift`, `App/Features/Cleanup/DeletionQuota.swift`
- Test: `Tests/CleanupSessionTests.swift`, `Tests/DeletionQuotaTests.swift`

**Interfaces:**
- Produces: `@Observable final class CleanupSession` with `items: [CleanupAsset]`, `currentIndex: Int`, `bin: [CleanupAsset]`, `func markDelete()`, `func keep()`, `func undo()`, `var isFinished: Bool`.
- `struct DeletionQuota` with `init(defaults: UserDefaults, calendar: Calendar, now: () -> Date)`; `func allowedCount(requested: Int, isPro: Bool) -> Int`; `mutating func record(_ count: Int)`; `var hasCompletedFirstCleanup: Bool`.

- [ ] Test: deleting then undo restores the exact item and index order.
- [ ] Test: first cleanup returns `requested` regardless of cap.
- [ ] Test: after first cleanup, cap returns `min(requested, remaining)` and resets at local midnight.
- [ ] Test: videos are never allowed for a free user (`allowedCount == 0`).
- [ ] Implement; keep all arithmetic in `Int64` for bytes.
- [ ] Commit `feat: cleanup session and quota`.

**Verify:** tests cover boundary 0, 1, 25, 26 and a midnight rollover.

---

### Task 5: On-device analysis (screenshots, similar, blurry) + cache

**Files:**
- Create: `App/Infrastructure/Analysis/AnalysisService.swift`, `SimilarityScorer.swift`, `BlurScorer.swift`, `App/Infrastructure/Analysis/AnalysisCache.swift`
- Test: `Tests/AnalysisServiceTests.swift`, `Tests/ScorersTests.swift`

**Interfaces:**
- Produces: `actor AnalysisService { func analyze(assets: [CleanupAsset], progress: @Sendable (Double) -> Void) async -> AnalysisSnapshot; func cancel() }`
- `AnalysisSnapshot: Sendable` with `screenshots: [CleanupAsset]`, `similarGroups: [[CleanupAsset]]`, `blurry: [CleanupAsset]`, `videos: [CleanupAsset]`.
- `SimilarityScorer.distance(_:_:) -> Float` and `BlurScorer.score(_:) -> Double` take pixel buffers so tests use fixtures.

- [ ] Test: identical feature prints score 0 distance; far prints exceed threshold.
- [ ] Test: a sharp fixture scores higher than a blurred fixture.
- [ ] Test: analysis over 400 assets yields deterministic groups and reports monotonic progress; cancel stops within one window.
- [ ] Test: cache hit returns snapshot without recomputation; modified date invalidates one asset only.
- [ ] Implement 30-day windows, max 300 assets per window, 60-second slices, `isNetworkAccessAllowed = false`.
- [ ] Commit `feat: on-device analysis`.

**Verify:** performance smoke on a 5k-asset fixture completes each slice under 60 s; memory stays bounded.

---

### Task 6: Screens (onboarding, home, swipe deck, review, settings)

**Files:**
- Create: `App/Features/Cleanup/HomeView.swift`, `SwipeDeckView.swift`, `ReviewDeleteView.swift`, `App/Features/Cleanup/DeckRow.swift`
- Modify: `App/RootView.swift`, `App/Features/Onboarding/OnboardingView.swift`, `App/Features/Settings/SettingsView.swift`
- Test: `Tests/HomeViewModelTests.swift`, `UITests/CleanupFlowUITests.swift`

**Interfaces:**
- Consumes: `PhotoLibraryProviding`, `CleanupSession`, `AnalysisService`, `DeletionQuota`.
- Produces: `HomeViewModel` with `load()`, `startDeck(_:)`, `state: HomeState`; navigation via `AppRoute`/`AppSheet`.

- [ ] Test: Home with zero local assets shows `.empty` with "Choose photos" action.
- [ ] Test: denied access shows `.denied`, never a spinner forever.
- [ ] Test: progressive counts update without reordering rows.
- [ ] UI test: onboarding -> permission stub -> home -> open Screenshots deck -> swipe delete one -> review -> cancel deletion -> bin intact.
- [ ] Implement screens 1-4 and 6 using the design handoff; keep the swipe deck full-bleed; add accessible Keep/Delete buttons for VoiceOver and Reduce Motion.
- [ ] Commit `feat: cleanup screens`.

**Verify:** UI test passes on iPhone 17; manual pass in light/dark and AX3 text size.

---

### Task 7: StoreKit Pro, paywall, ads, settings

**Files:**
- Modify: `App/StoreKit/Store.swift`, `App/StoreKit/PaywallView.swift`, `App/StoreKit/PaywallHostView.swift`, `App/Features/Settings/PurchasesSection.swift`, `App/Infrastructure/Ads/Ads.swift`
- Test: `Tests/EntitlementTests.swift`, `UITests/PaywallUITests.swift`

**Interfaces:**
- Consumes: template `\.isPro`, `Store.hasPro()`.
- Produces: `ProGate` enum (`.allowed`, `.paywall(reason)`), `func gate(for action: ProAction, isPro: Bool, quota: DeletionQuota) -> ProGate`.

- [ ] Test: first cleanup never returns `.paywall`.
- [ ] Test: quota exhausted returns `.paywall(.dailyLimit)`; videos return `.paywall(.videos)`.
- [ ] Test: cached entitlement keeps Pro while StoreKit is offline; restore refreshes it.
- [ ] Implement paywall with yearly preselected + 3-day trial, lifetime below, Restore, privacy/EULA links.
- [ ] Implement banner on Home and Review only; Pro removes it; ad failure collapses the slot without layout jump.
- [ ] Add Paywall UI test: open, dismiss, restore button visible.
- [ ] Commit `feat: pro and ads`.

**Verify:** StoreKit config runs locally; paywall shows products in Dev; no ad in swipe deck or Settings.

---

### Task 8: Icon, localization, metadata, screenshots, privacy

**Files:**
- Create: `docs/brand/app-icon.svg`, `fastlane/metadata/{vi,en-US}/*`, `fastlane/app_rating_config.json`, `docs/brand/screenshots-manifest.json`
- Modify: `App/PrivacyInfo.xcprivacy`, `App/Resources/Localizable.xcstrings`, `project.yml`

- [ ] Render icon master to 1024 RGB (no alpha) + Dev/Staging ribbons; verify mode is `RGB`.
- [ ] Fill vi + en metadata: name <= 30, subtitle <= 30, keywords <= 100, description ends with EULA + privacy links.
- [ ] Set age rating advertising = true; privacy labels match actual SDK behavior.
- [ ] Capture 6.9" screenshots with realistic demo data, compose them with the house script, inspect every image.
- [ ] Add privacy/terms/support URLs for `purgeswipe` to the apps-site.
- [ ] Commit `chore: store assets and metadata`.

**Verify:** `grep stdeula fastlane/metadata/*/description.txt` hits every locale; icon mode RGB; screenshots 1320x2868 or 1290x2796.

---

### Task 9: Signing, CI, ASC records, IAP, TestFlight, submit

**Files:**
- Modify: `fastlane/.env.default`, `Config/*.xcconfig`, `Config/Backend-Prod.xcconfig`
- Create: `scripts/asc/*` (copied from template), `.env` (local only)

- [ ] Fill `.env` from the shared ASC key + match; `scripts/doctor.sh` passes.
- [ ] `bundle exec fastlane bootstrap --env dev|staging|prod`; `sync_signing` each env.
- [ ] Push `develop`; CI + deploy-dev green; `gh secret set -f .env`.
- [ ] Create 3 ASC records; create Pro group + 3 products on each record; verify with `create_iaps.rb`/`verify_iaps.rb`.
- [ ] Age rating, App Privacy, pricing, availability, review contact.
- [ ] Upload TestFlight build; verify VALID via API.
- [ ] Attach build, add IAP to the same submission, submit 1.0.0 for review.
- [ ] Update the app registry in `app-store-release`.

**Verify:** ASC API reports version `WAITING_FOR_REVIEW`; all 3 records exist; IAP verified for price/territories/localizations.
