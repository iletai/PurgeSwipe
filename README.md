# PurgeSwipe

<!-- One line: what the app does. -->

## Setup

```bash
brew install xcodegen swiftlint
bundle install
cp .env.example .env && chmod 600 .env          # fill values, never commit
cp Config/Secrets.xcconfig.example Config/Secrets.xcconfig   # if the app has build-time secrets
xcodegen generate && open PurgeSwipe.xcodeproj
```

## Environments

| Scheme | Bundle id | Backend | Ships to |
|---|---|---|---|
| `PurgeSwipe-Dev` | `com.iletai.purgeswipe.dev` | Dev | TestFlight (on every push to `develop`) |
| `PurgeSwipe-Staging` | `com.iletai.purgeswipe.staging` | Prod | TestFlight (on push to `release/*`, `hotfix/*`) |
| `PurgeSwipe` | `com.iletai.purgeswipe` | Prod | App Store (on tag `x.y.z`) |

fastlane: `bundle exec fastlane <lane> --env dev|staging|prod` (lanes from [iletai/ios-shared](https://github.com/iletai/ios-shared)).

## Screens

Every app starts with the baseline screens in `App/Features/`: onboarding (first run, skippable), settings (appearance, support, legal, about), help/FAQ, and about. `RootView` gates onboarding with `@AppStorage("hasCompletedOnboarding")`; UI tests override it with `-hasCompletedOnboarding YES|NO`.

Replace the placeholder home copy before shipping, and keep the privacy policy and terms links working.

## AI agents

`AGENTS.md` is the single source of truth for Claude Code, Codex, OpenCode, Cursor, Gemini CLI, and Copilot. `CLAUDE.md` and `GEMINI.md` import it; `.cursor/rules/project.mdc` and `.github/copilot-instructions.md` summarize the non-negotiables. Edit `AGENTS.md` only.

## Branches, tags, deploys

| Event | Result |
|---|---|
| PR / push `feature/*` | CI (lint + test) |
| push `develop` | Dev → TestFlight |
| push `release/x.y.z`, `hotfix/x.y.z` | Staging → TestFlight (release candidate) |
| push annotated tag `x.y.z` (on `main`, no `v`) | Prod → App Store upload, owner approves; never auto-submits |

Flow: `feature/*` → PR into `develop` → `release/x.y.z` (version bump, CHANGELOG, notes) → PR into `main` (merge commit) → tag `x.y.z` on the merge commit → PR `main` into `develop`. Hotfix: `hotfix/x.y.z` from `main`, same ending. Merge commits only, conventional commits, tags never moved, one release/hotfix branch at a time, build numbers set by CI.
