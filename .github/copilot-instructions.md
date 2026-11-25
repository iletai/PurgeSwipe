# GitHub Copilot instructions

Read `AGENTS.md` at the repository root before suggesting code. The short version:

- Keep the baseline screens: onboarding, settings, help/FAQ, about, in-app privacy/terms links.
- Restorable purchases need Restore Purchases on the paywall and in Settings; paywalls show price, duration, renewal terms, privacy, and terms.
- Account creation requires in-app account deletion.
- Request permissions at the moment of use with a specific purpose string.
- Dynamic Type, VoiceOver labels, 44×44 pt targets, light/dark contrast, Reduce Motion.
- User-facing copy lives in `Localizable.xcstrings` (vi + en).
- `project.yml` is the source of truth; run `xcodegen generate` after editing it.
- Build/test with the `PurgeSwipe-Dev` scheme.
