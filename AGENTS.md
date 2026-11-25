# AGENTS.md

Single source of truth for AI coding agents (Claude Code, Codex, OpenCode, Cursor, Gemini CLI, Copilot). `CLAUDE.md`, `GEMINI.md`, `.cursor/rules/`, and `.github/copilot-instructions.md` point here; edit this file only.

## What this app is

PurgeSwipe is an on-device iPhone photo cleaner for people whose storage is full. They pick a deck (screenshots, similar shots, blurry photos, large videos), swipe left to trash and right to keep, then confirm one system deletion and see how many library bytes moved to Recently Deleted. No account, no cloud, no analytics; the free tier shows banner ads and caps deletions after the first cleanup, Pro removes both. Spec: `docs/superpowers/specs/2026-11-25-purgeswipe-design.md`.

## Architecture

- `App/` — SwiftUI app target.
  - `Features/<Name>/` — one folder per screen or feature.
  - `Infrastructure/` — configuration, logging, cross-cutting helpers.
  - `StoreKit/` — native StoreKit 2 (`--with storekit`).
- `Packages/` — local Swift packages (add to `project.yml` `packages:` + target `dependencies:`).
- Own libraries (navigation, update prompt, StoreKit): see skill `iletai-libs`.

## Build and test

| Intent | Command |
|---|---|
| Generate the project | `xcodegen generate` |
| Build | `xcodebuild -scheme PurgeSwipe-Dev -destination 'platform=iOS Simulator,name=iPhone 17' build` |
| Test | `xcodebuild -scheme PurgeSwipe-Dev -destination 'platform=iOS Simulator,name=iPhone 17' test` |
| Lint / format | `swiftlint --strict --quiet` · `swiftformat .` |

Heavy builds and screenshots run on GitHub Actions, not locally.

## Non-negotiables

- **Screens:** every app ships onboarding (first run, skippable, no login wall), settings, help/FAQ, about, and legal links (privacy policy + terms). Do not delete these screens.
- **Privacy policy in-app:** the policy must be reachable inside the app, not only in App Store Connect (Guideline 5.1.1(i)).
- **Purchases:** any restorable IAP or subscription needs a visible Restore Purchases action on the paywall and in Settings (Guideline 3.1.1). The paywall shows localized price, duration, renewal terms, and privacy/terms links (Guideline 3.1.2).
- **Accounts:** if the app supports account creation, Settings must offer in-app account deletion (Guideline 5.1.1(v)). Prefer guest access when the core function does not need an account.
- **Permissions:** request at the moment of use with a specific purpose string. A custom pre-permission screen has one button ("Continue"/"Next") and no cancel/close.
- **No placeholder content:** no Lorem Ipsum, "coming soon", dead links, or endless spinners in a submitted build (Guideline 2.1).
- **Accessibility:** Dynamic Type, VoiceOver labels on custom controls, 44×44 pt touch targets, contrast in light/dark/increase-contrast, Reduce Motion respected.
- **Localization:** all user-facing copy goes through `Localizable.xcstrings` (vi + en); permission strings through `InfoPlist.xcstrings`.
- **States:** every async screen has loading, empty, error, and offline states.

## Conventions

- iOS 18+, Swift 6 strict concurrency.
- `project.yml` is the source of truth; run `xcodegen generate` after editing it (`*.xcodeproj` is not committed).
- Environments Dev / Staging / Prod (Staging uses the Prod backend): schemes `PurgeSwipe-Dev`, `PurgeSwipe-Staging`, `PurgeSwipe`; configs `{Debug,Release}-{Dev,Staging,Prod}`; per-env values only in `Config/{Dev,Staging,Prod}.xcconfig` (+ `Backend-Prod.xcconfig`). Read the env via `AppConfiguration.environment`. Never add schemes/configs outside this set.
- Secrets only in `.env` (gitignored); non-secret fastlane values in `fastlane/.env.default` + `fastlane/.env.{dev,staging,prod}`.
- Build-time values: xcconfig variable → `project.yml` `info.properties` → `AppConfiguration`. Never `INFOPLIST_KEY_<custom>` (Xcode drops it).
- Log with `Log.<area>` (os.Logger), not `print`.
- Heavy builds/screenshots run on GitHub Actions, not locally.

## Release

Git Flow: `feature/*` → `develop` → `release/x.y.z` → `main` + annotated tag `x.y.z` (no `v`, never moved); `hotfix/x.y.z` from `main`; merge commits only; back-merge `main` into `develop` after every release. Push `develop` → Dev, `release/*`/`hotfix/*` → Staging, tag → Prod (never auto-submits). Build numbers are CI's; never edit them. Trigger table: README. Lanes come from `iletai/ios-shared` (`--env dev|staging|prod`). Workflows: `ci.yml`, `deploy-{dev,staging,prod}.yml`.
Release steps: skill `app-store-release`. Signing: skill `ios-cicd-signing`.
