# PurgeSwipe — Screenshot Inbox (design brief)

Date: 2026-11-28
Supersedes: general photo cleaner positioning in `docs/superpowers/specs/2026-11-25-purgeswipe-design.md`

## Why the niche changed

Deep research (`docs/product/viability/REPORT.md`) killed the general photo cleaner:

- Swipe is not differentiation. Native Photos already merges exact duplicates, has albums, search, multi-select delete, Recently Deleted.
- A camera-roll cleanup is a once-or-twice-a-year job. "Not enough usage" is the #1 subscription cancellation reason (26–47%); weekly plans lose ~65% of subscribers in 30 days.
- The category leaders (Cleanup ~$14M/mo, Swipewipe ~$1M/mo) are publishers buying installs. A solo dev with no ad budget cannot compete on "clean your camera roll".

Screenshots are different in one decisive way: **they accumulate daily and they are the phone's clipboard.** A screenshot has a shelf life of minutes to weeks. That makes purging a recurring job, not a one-time panic purchase.

## Product

**Job:** keep the few screenshots worth keeping, purge the rest, weekly, in under a minute.

**Core loop:**
New screenshots arrive → weekly inbox (or widget) says "23 new" → swipe left to purge, right to keep → pin the ones you actually need (voucher codes, addresses, tickets) → review → one system delete → inbox zero → next week it refills.

**Differentiation vs native Photos (defensible):**

1. **Inbox, not album.** Native gives you a Screenshots album with everything ever taken. PurgeSwipe gives you only what arrived since your last cleanup, one card at a time.
2. **Grouped by source app.** Shopping, chats, banking, memes. Delete a whole category in one decision instead of 88 individual taps.
3. **OCR text on the card.** The card shows the text that matters ("Order #4821 · Voucher SAVE20") so the decision takes one second. Native requires opening each screenshot.
4. **Pin vault.** Screenshots you keep are searchable by text and never appear in the inbox again. This is why users return: the app becomes the safe place for the 5% they need.
5. **Age-out queue.** "412 screenshots older than 30 days you never opened" is one bulk action native Photos cannot express.

**Non-goals:** camera-roll photos, videos, duplicates, compression, contacts, email. Screenshots only. That is the moat: a narrow, recurring, daily job.

## Monetization

Lifetime-first. No weekly, no monthly.

| Tier | Free | Pro |
|---|---|---|
| First cleanup | unlimited | unlimited |
| Weekly inbox after first cleanup | 1 cleanup/week | unlimited |
| Pin vault + OCR search | 10 pins | unlimited |
| Age-out queue | see count | run it |
| Banner ads | yes | no |

Price: **Lifetime $14.99** (primary, one-time), **Annual $7.99/yr** (secondary). Both shown on the paywall with Restore Purchases, Privacy Policy, Terms. No trial. One-time purchase matches a one-time-job product and protects the 4.8★ rating that drives ASO.

## Screens to design (7)

1. **Onboarding** — one value line + permission. No carousel.
2. **Inbox (Home)** — new count hero, streak, category rows, age-out row, pinned count.
3. **Swipe deck** — full-bleed screenshot, source chip, OCR snippet, keep/delete/undo/pin.
4. **Review & delete** — grid, total count and size, one primary action.
5. **Inbox zero** — the calm payoff, next-refill expectation.
6. **Paywall** — lifetime primary, annual secondary, restore, legal.
7. **Settings** — Pro status, restore, appearance, help, privacy, terms, about.

## Reference data (use these exact numbers in every mockup)

| Item | Value |
|---|---|
| Inbox this week | 23 new, 84 MB |
| Shopee | 9 items, 34 MB |
| Messages | 6 items, 21 MB |
| Banking | 5 items, 18 MB |
| Memes | 3 items, 11 MB |
| Older than 30 days | 412 items, 1.2 GB |
| Selected at review | 18 of 23, 62 MB |
| Pinned | 12 |
| Streak | 5 weeks clear |
| Deck position | 7 of 23 |

The per-app rows must sum to the inbox total. The age-out queue is separate and not part of the 23.

## Design direction

- iPhone 16 Pro, 393×852 pt, portrait.
- Native iOS vocabulary. SF Pro. System colors. One accent: iOS blue `#0A84FF`. Semantic red `#FF3B30`, green `#34C759`.
- The screenshot is the hero. Chrome stays quiet: no gradients, no card-in-card, no emoji, no decorative illustration.
- Liquid Glass on nav/toolbars (iOS 26), graceful iOS 18 fallback.
- 44×44 pt minimum targets, Dynamic Type, VoiceOver labels, Reduce Motion respected.
- Every async screen needs loading, empty, error, offline states. Screens 2 and 5 must show the empty state.
- Copy in English for the store screenshots; vi/en strings live in `Localizable.xcstrings`.

## ASO

- Name (≤30): `PurgeSwipe: Screenshot Cleaner`
- Subtitle (≤30): `Clean your screenshot inbox`
- Keyword field targets: screenshot cleaner, screenshot delete, clear screenshots, screenshot organizer, free up storage
- Screenshot story: "Your screenshots have a shelf life" → "Only the new ones" → "One swipe each" → "Keep what matters" → "Inbox zero"
