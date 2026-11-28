# PurgeSwipe — Viability Check

Date: 2026-11-28
Notebook: `6a0603d9-cbf5-48f0-9671-6a55fb4b95bc` (46 sources, deep research)
Raw answers: `d1-native-vs-swipe.json`, `d2-retention.json`, `d3-monetization.json`

## Verdict

The three doubts are correct:

1. **The swipe gesture is not differentiation.** It is an interaction layer over PhotoKit. All deletion still goes through the same system confirmation and Recently Deleted folder as native Photos.
2. **There is no retention mechanic in the current build.** The category's only proven hook is daily nostalgia ("On This Day" + widget + streak), which PurgeSwipe does not ship.
3. **The revenue model is mismatched to the usage pattern.** Freemium + banner ads + monthly subscription on a one-and-done utility is the exact combination the benchmarks show failing for solo developers.

This is not a build-quality problem. The app is built correctly for a product that has no reason to be opened twice.

## 1. Swipe vs native Photos

Native iOS Photos already does: exact-duplicate detection and merge, Recently Deleted, albums, search, multi-select delete, storage recommendations.

What native does **not** do (the only defensible gaps):

| Gap | Real? | PurgeSwipe has it? | Competitors have it? |
|---|---|---|---|
| Similar-photo grouping + best-shot pick | Yes — native only merges exact duplicates | Yes (Vision feature prints) | Yes, all of them |
| Video compression without deleting | Yes | **No** | Swipewipe, Cleanup, Cleaner Kit |
| Month-by-month chunking | Yes — cognitive, not technical | Partially (decks, not months) | Yes |
| Daily nostalgia + streak + widget | Yes | **No** | Swipewipe |
| On-device / no account | Claimed by everyone | Yes | Yes |

Reviewer verdict on the gesture itself (Ping.Fm, 2025): Swipewipe is *"a prettier interface thrown on a function your phone already does"* and *"the actual deleting part is something you could handle right in your Photos app"*.

Real user value is speed and reduced decision fatigue, not capability. Slider reviewers report 4 GB in 5 minutes and 2,000 photos in 90 minutes. That is a real job-to-be-done — but it is a **one-time job**.

## 2. Retention

Structural evidence against subscription retention:

- "Not enough usage" is the single largest cancellation reason across categories (26–47% of churned users).
- Weekly plans: ~65% churn within the first 30 days; year-one retention 1.2–3.4% (RevenueCat 2026 / Adapty 2026).
- Verbatim, Cleanup (App Store): *"This is the type of utility that I might run twice a year... I plan to uninstall it before the free one week trial."*
- Verbatim, Swipewipe: *"once you clean your phone out you don't really need it on a weekly basis."*
- Verbatim, Swipewipe: *"I plan to resubscribe for a week every few months."*

The only mechanism with qualitative evidence of bringing users back:

1. **"On This Day" nostalgia feed + widget + streak** — users say it is the only reason they still open the app (*"Now a days I just use the 'on this day' feature"*), and some cancel the subscription but keep the app.
2. **Month-by-month chunking with saved progress** — makes a 20k library finishable.
3. **Best-shot curation** — removes the decision paralysis that blocks the chore.

PurgeSwipe ships none of these. Its trigger is "Storage Almost Full", which fires a few times per year. Expected D30 retention: single digits.

Counter-example: *Selects* (solo dev, free, no paywall) reported ~54% D30 retention on ~370 installs — because the free app became a daily nostalgia routine, not a cleaner. It earned ~$20/month in donations.

## 3. Monetization

| App | Est. revenue/mo | Est. downloads/mo | Model | Why it wins |
|---|---|---|---|---|
| Cleanup (Codeway) | ~$14M (Jul 2026 est.) | ~6M | weekly sub $5.95–11.99, $29.99/yr | Paid UA on Facebook/YouTube via Adjust |
| Swipewipe (MWM) | ~$1M (2026 est.) | ~300K | weekly $3.99–9.99, $29.99/yr, lifetime, ads | Acquired by MWM for ad spend + monetization; 5M+ lifetime downloads |
| Slider (June Ninth) | NO DATA | NO DATA | free, optional tip | Organic, no paywall |
| Selects (solo) | ~$20 | ~370 lifetime | free, donations | Organic Reddit |

The leaders are **publishers with paid acquisition**, not better products. Hard paywalls convert 5× freemium (10.7% vs 2.1% D35, RevenueCat 2026), which funds the ad spend. That flywheel requires capital, not craft.

Solo math at benchmark rates (2.1% download→paid, ~$0.32 net revenue per install):

- $1,000 MRR ≈ **1,900–3,100 installs/month**
- $3,000 MRR ≈ **5,600–9,300 installs/month**

Without paid UA or a viral channel, that volume does not happen. And free, well-rated competitors (Clever Cleaner, Slider, Quack) actively destroy willingness to pay weekly.

Price-model fit for a one-and-done utility:

| Model | Fit | Why |
|---|---|---|
| Weekly sub | **Poor** | 65% 30-day churn, "predatory" reviews, needs constant UA |
| Monthly sub | Poor | Same recurring-need problem |
| Annual $19.99–29.99 | Moderate | Accepted, but renewal is weak |
| **Lifetime $9.99–14.99** | **Best** | Matches usage, low refunds, drives 4.8★ reviews → ASO |
| Banner ads | Poor | $0.05–0.15 RPI; needs 100k+ downloads to matter |

## 4. What this means for the current spec

The spec's own numbers are the problem:

- `$4.99/mo, $19.99/yr, $29.99 lifetime` — a monthly sub on a twice-a-year job.
- Free tier capped at 25 deletions/day — the cap is only felt by users who already cleaned, i.e. exactly the users who will churn.
- Banner ads — revenue too small to matter at solo volumes, but enough to hurt reviews.
- No widget, no streak, no nostalgia feed, no stats history beyond the last cleanup.
- Trigger is a storage warning, not a daily habit.

## 5. Options

**A. Ship as an ASO/portfolio experiment.** Keep the build, price lifetime-first ($9.99), drop or de-emphasize the monthly sub, keep ads only if they do not hurt reviews. Expect low hundreds of dollars per month at best. Value is learning ASO and shipping, not MRR.

**B. Reframe as a daily memory app.** Add "On This Day" deck, widget, streak, and a cumulative stats/Wrapped screen. Cleaning becomes the byproduct. This is Swipewipe's actual engine and the only retention path with evidence. Cost: one widget target + one feed + one stats screen. Risk: you now compete with Apple's Memories and with a 5M-download incumbent.

**C. Niche down to a recurring deletion job.** Screenshots, screen recordings, Live Photos, or burst shots accumulate *daily*. Same codebase, different default deck, different ASO. This is the only option where the recurring need is structurally true rather than manufactured. Risk: smaller search volume, but far less publisher competition.

Recommended: **C as positioning, B as one retention feature, A as the monetization model** (lifetime-first, no weekly, no monthly). Do not run the current freemium+sub+ads plan.

## 6. Kill criteria

Stop investing if, 60 days after launch:

- D7 retention < 10% (means the app is a one-time tool, which the pricing must admit)
- Organic installs < 300/month with no paid UA
- Lifetime conversion < 0.5% of installs
- Average rating < 4.5 (below this, ASO compounding stops)
