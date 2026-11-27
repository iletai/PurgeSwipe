# PurgeSwipe — Motion spec (Stitch output is static; this file is the motion source)

Global: `.snappy` for decisions, `.smooth` for state swaps, system transitions for navigation.
Every gesture has a visible alternative. Reduce Motion → cross-fade (`.smooth` with `duration: 0.001` on transforms off).

| Screen | Trigger | Property | From → To | SwiftUI | Timing | Interruptible | Haptic | Reduce Motion |
|---|---|---|---|---|---|---|---|---|
| Onboarding | appear | opacity + offset | 0 → 1, +12 pt → 0 | `.smooth` on the title block | 0.4 s, 0.05 stagger | no | — | cross-fade only |
| Onboarding | page change | dots | first → second active | `withAnimation(.snappy)` | 0.25 s | yes | `.selection` | cross-fade |
| Home | appear | skeleton → content | redacted → real | `.smooth` | 0.3 s | no | — | same |
| Home | row press | background | clear → #D1D1D6 | `List` default | fade out 0.25 s | yes | `.impact(light)` | same |
| Home | gear → Settings | navigation | push | `NavigationStack` push | system | yes | — | system |
| Home → Paywall | present | sheet | bottom → large detent | `.sheet` | system | yes (swipe down) | — | system |
| Deck | swipe left/right | card offset + rotation | 0 → ±screen, ±8° | `.snappy` + `DragGesture` | 0.28 s | yes (snap back) | `.success` on keep, `.impact(medium)` on trash | cross-fade, no rotation |
| Deck | counter changes | number | 17 → 18 | `.contentTransition(.numericText())` | 0.3 s | no | — | same |
| Deck | undo | card re-insert | from top edge → center | `.snappy` | 0.32 s | yes | `.impact(light)` | cross-fade |
| Review | grid appear | opacity | 0 → 1 | `.smooth` | 0.25 s | no | — | same |
| Review | delete | confirm then dismiss | sheet/alert → grid | system `confirmationDialog` → pop | system | no | `.success` | same |
| Paywall | plan select | checkmark + fill | outline → filled | `withAnimation(.snappy)` | 0.2 s | yes | `.selection` | same |
| Paywall | purchase | button → progress | label → spinner | `.smooth` | — | no | `.success` / `.error` | same |
| Paywall | dismiss | sheet | large detent → down | `.sheet` | system | yes | — | system |
| Settings | row press | highlight | clear → #D1D1D6 | `List` default | 0.25 s | yes | `.selection` | same |
| Settings | toggle change (if added) | knob | off → on | system | 0.2 s | yes | `.selection` | same |

Pressed states (all controls): scale `.97` + opacity `.85` within 120 ms; glass bar items use `.interactive()`.
Scroll: Home large title collapses with the system scroll edge effect; Review grid scrolls under the `.glass` bottom bar.
No custom animation on the status bar, the Dynamic Island or the home indicator.
