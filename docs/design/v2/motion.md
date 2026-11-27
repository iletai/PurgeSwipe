# PurgeSwipe v2 — motion

Stitch output is static, so this file is the only motion source. Every row is implementable. Reduce Motion uses the stated fallback in all cases.

## Navigation and presentation

| Trigger | Property | From → to | SwiftUI | Timing | Interruptible | Haptic | Reduce Motion |
|---|---|---|---|---|---|---|---|
| Tap a deck row | push | Home → Deck | `NavigationStack` push (system slide) | system 0.35 s | yes (edge swipe back) | `.impact(.light)` on tap | system cross-fade |
| Deck finished → Review | push | Deck → Review | system push | 0.35 s | yes | `.success` | cross-fade |
| Tap gear | push | Home → Settings | system push | 0.35 s | yes | `.selection` | cross-fade |
| Settings → Help / About | push | — | system push | 0.35 s | yes | none | cross-fade |
| Paywall entry | sheet | — | `.sheet` `.presentationDetents([.large])` `.presentationDragIndicator(.visible)` | system spring | yes (drag down) | `.selection` | system |
| Onboarding | full-screen cover | — | `.fullScreenCover` | system | no | none | system |
| Onboarding page 2 | content swap | page 1 → page 2 | `.tabViewStyle(.page)` or `withAnimation(.smooth)` | 0.3 s | yes | `.selection` | cross-fade |
| Success screen | content swap | Review → success | `.smooth` on the state enum | 0.3 s | no | `.success` | cross-fade |

## Deck interaction (the signature motion)

| Trigger | Property | From → to | SwiftUI | Timing | Interruptible | Haptic | Reduce Motion |
|---|---|---|---|---|---|---|---|
| Drag card | `offset`, `rotationEffect` | 0 → finger position, 0° → ±8° | `DragGesture` bound directly, `rotation = offset.width / 40` | 1:1 with finger | yes | `.impact(.light)` when `abs(x)` crosses 80 pt | card moves, rotation fixed at 0° |
| Release over threshold | `offset`, `opacity` | current → ±screen width, 1 → 0 | `withAnimation(.snappy(duration: 0.25))` | 0.25 s | no | `.impact(.medium)` | cross-fade out 0.2 s |
| Release under threshold | `offset`, `rotation` | current → 0 | `withAnimation(.bouncy)` | 0.35 s | yes | none | `.smooth` 0.25 s, no bounce |
| Undo | card returns | off-screen → centre | `.bouncy` insert | 0.4 s | no | `.impact(.light)` | `.smooth` |
| Counter pill value change | number | 17 → 18 | `.contentTransition(.numericText())` | 0.25 s | yes | none | no numeric roll, plain fade |
| Deck empties | CUV appears | card → `ContentUnavailableView` | `.smooth` 0.3 s | 0.3 s | no | `.success` | cross-fade |

## Controls, states and feedback

| Trigger | Property | From → to | SwiftUI | Timing | Interruptible | Haptic | Reduce Motion |
|---|---|---|---|---|---|---|---|
| Press any capsule | scale, opacity | 1 → 0.97, 1 → 0.85 | `.buttonStyle` pressed state (system + `ScaleButtonStyle`) | 120 ms in, 180 ms out | yes | none | opacity only |
| List row press | background | clear → `#D1D1D6` / `#3A3A3C` | system `List` row highlight | instant in, 250 ms fade out | yes | none | same (no motion) |
| Segmented control | selection thumb | segment → segment | system `Picker(.segmented)` | 0.2 s | yes | `.selection` | system |
| Plan selection | checkmark, fill | circle outline → filled accent | `withAnimation(.snappy)` + `symbolEffect(.bounce, value:)` | 0.25 s | yes | `.selection` | no bounce |
| Delete | CTA → success | spinner → `checkmark.circle` | `.smooth` + `symbolEffect(.bounce)` | 0.3 s | no | `.success` | cross-fade |
| Delete failure | alert | — | `.alert` (system) | system | n/a | `.error` | system |
| Scan progress | width | 0 → 100 % | `ProgressView(value:)` implicit | continuous | n/a | none | same |
| Skeleton → content | opacity | 0.5 redacted → 1 | `.smooth` | 0.3 s | no | none | cross-fade |
| Paywall purchase fails | inline error | — | `.smooth` height change | 0.3 s | no | `.error` | cross-fade |

## Scroll behaviours

- Home: large title collapses to inline on scroll (system), gear stays in the bar, ad slot scrolls with content and never overlays a row.
- Deck: no scroll; the photo is fixed, the bar is `safeAreaBar(edge: .top)` so it stays translucent over the photo.
- Review: the grid scrolls under the pinned bottom bar; the bar is `safeAreaBar(edge: .bottom)` with the scroll edge effect, no hard border.
- Settings / Help / About: standard grouped `List` bounce, no custom refresh.
- `refreshable` is not used anywhere (no remote data).

## Haptics summary (`sensoryFeedback`)

| Event | Feedback |
|---|---|
| Deck threshold crossed | `.impact(.light)` |
| Card committed | `.impact(.medium)` |
| Deck finished | `.success` |
| Photos deleted | `.success` |
| Analysis or deletion failed | `.error` |
| Segment / plan change, row tap, gear | `.selection` |
