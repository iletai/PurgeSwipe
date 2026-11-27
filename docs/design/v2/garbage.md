# PurgeSwipe v2 — garbage ledger

Project `244497281594604385`. Stitch has **no delete-screen resource** (`stitch delete` covers project/workspace/context/file/skill/priority/webhook/connection only; there is no `delete_screen` MCP tool). Every id below is either `superseded` (a later render replaced it) or `rejected` (wrong shape / wrong device / wrong type). None is referenced by `screens.md`, `acceptance.json` or the handoff.

## Delete these in the Canvas web UI (safe to remove, no reference)

| id | key | reason |
|---|---|---|
| `526f425a82eb46e0924493ae899682aa` | onboarding-1 | Skip hit area 33x22 pt |
| `06eab6bcafd04ca2ac0a3b23e6ba0082` | onboarding-2 | old chrome, Arial mix |
| `ca722f789d9a4f7ba6fd7536e9f1f047` | onboarding-2 | DESKTOP output |
| `f0652d473f4b43ee85d6e7834b305422` | home-denied | 15 pt status bar at x=28, iOS 18 back title visible |
| `95720bd0fe914c8cb8e696ec63849a2d` | home-denied | Arial fallback, CTA 88x19 pt |
| `47415163749f4bfd978a2d4b821977e3` | home-empty | Arial fallback |
| `d472f25700c94c59a90f3fc5af3e26d4` | deck-mid | DESKTOP output |
| `37d3772a83c24b3fa003bc59a5b72f1b` | deck-mid | home indicator 19 pt up |
| `6c0bf99ebc434ed381d09cda96d4221f` | deck-similar | DESKTOP output |
| `2197118ef32c4176bcfb88e6deb36ec8` | deck-similar | badge pill under nav bar |
| `c6e9b2a0eb7242dc88bf44ef5b2cdce4` | deck-similar | badge pill still under the bar |
| `982afa60e3204fe99d7b5879a2aedab9` | deck-finished | Arial fallback, CTA 19 pt |
| `586ab313d8b34aa18b6b9cd7b492101e` | deck-finished | DESKTOP output |
| `2e7f5b1a10c140dc892b62b46cf36ffd` | review-marked | DESKTOP output |
| `e93791f05e40412b8585277fade2cc43` | review-marked | status bar and island lost |
| `853d588da1ef47d6b38bc07252c5ac06` | review-success | 15 pt status bar, back title, island collision |
| `f9f6e3f08b8644a991f2eb0d059957ac` | review-success | DESKTOP output |
| `9b787cca5cb845b89c36f2ffea432799` | review-cap | home indicator 19 pt up |
| `f5edb941a1354f39861147ea4137390d` | paywall-products | DESKTOP output |
| `fde9922bc5a34e53a866761080bf1d8e` | paywall-error | 9 pt legal text, 18 pt links |
| `d8cd3ae3154a44d7b5b9ec064f35a947` | paywall-error | checkmarks overlapping labels |
| `6dd0a53a6f3d4dabb0a27419a2c6530f` | settings-free | non-MOBILE canvas, Arial |
| `9138197460554578bb97ff462f6bc021` | settings-free | Arial fallback |
| `172edcceddd746e2aa452047b9869e8f` | settings-pro | DESKTOP output |
| `e05a42a657014c2894cdd32eea1ecccd` | settings-pro | Arial fallback |
| `f6cb79d8f1404ecf8f45a0760e58c0c8` | help | DESKTOP output |
| `0e4066ec76f4441da17ed67cbe8666cb` | help | home indicator 19 pt up |

## Keep, but never reference (screens that shipped as GAP/REJECT)

| id | key | verdict | why it stays in the project |
|---|---|---|---|
| `207285d9bb064cfc92b3a018c30aa75d` | deck-mid | GAP | only MOBILE render of the deck; photo-card + invented caption documented |
| `c6e9b2a0eb7242dc88bf44ef5b2cdce4` | deck-similar | superseded to the fix3 retry | — |
| `8e96bcbb10e847328538392ac5b6c441` | deck-finished | GAP | Arial + 19 pt CTA |
| `701a33e434d14f2b816c6c18f4f0e0ab` | review-marked | GAP | newest render, chrome unverified |
| `7bce18ff374a46f3b2d8b4cce7e08e9a` | review-success | GAP | indicator 19 pt |
| `5e42463a25f74d9e9dd9f8be3b7966aa` | paywall-products | REJECT | serif type |
| `d4b7d58f39994c95a91d93f043cb3173` | paywall-error | GAP | re-render unverified |
| `f4cc162def3a4bf2b8279f5bb41bbfb9` | about | GAP | indicator 19 pt |
| `4bbc12379ff1498aadb267ca302b75ce` | deck-mid-dark | GAP | inherits the light defect |
| `7b81174b05f043ae9c8bf14c9b783a0f` | review-marked-dark | GAP | inherits the light defect |
| `b44a1d8a70354c18bd6edf09cbc4b314` | paywall-products-dark | REJECT | serif type |

## Root causes worth preventing next time

1. `stitch generate variant` inherits the source screen, so a defect in the base multiplies across every variant (the serif paywall came from a variant of `home-ready` after Stitch reset the font family on that branch).
2. Asking for a "photo full-bleed" makes Stitch emit a stock-photo card **with the photo's own UI baked in** (caption "Moraine Lake, Banff", heart icon). Next time: ask for a plain 16:9 image region with no overlay, or supply the photo as an uploaded asset.
3. The geometry gate does not compare font *stacks* on every element — it missed the serif paywall. The PNG read caught it. Keep the PNG read as a hard gate.
