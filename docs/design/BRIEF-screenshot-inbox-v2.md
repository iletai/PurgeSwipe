# PurgeSwipe — Screenshot Inbox design board (v2 prompt, branded)

Execute this fully. Output: ONE self-contained `index.html` at the project root (inline CSS and inline SVG; the only external resource allowed is the Google Fonts stylesheet; no JS required).

## Product (unchanged)

PurgeSwipe: Screenshot Cleaner. Screenshots pile up daily as the phone's clipboard (orders, chat quotes, addresses, tickets, memes). The app shows an INBOX of only the screenshots that arrived since the last cleanup, one card at a time, plus a PIN VAULT for the few worth keeping.
Job: keep the few worth keeping, purge the rest, weekly, in under a minute.
Loop: new screenshots -> "23 new" -> swipe left purge / right keep -> pin what matters -> review -> one system delete -> inbox zero -> refills next week.
Must be visible in the design (not only copy): new-only inbox, grouping by source app, OCR text on the card, pin vault, age-out queue.

## Brand direction: "Shelf Life" (derived from the app icon)

The app icon is a tilted white screenshot card on a blue->violet diagonal gradient with a teal photo window, gold four-point sparkles and a white return arrow. Extend that world; do not fall back to a stock iOS Settings look.

Palette (use these exact hex, name them as CSS variables):

| Name | Hex | Role |
|---|---|---|
| Night Ink | `#0B1030` | dark canvas, deck backdrop, primary text on light |
| Electric Blue | `#2F6BFF` | primary action, selection, brand |
| Violet Glow | `#7B3FE4` | gradient end, hero highlights, Pro |
| Lagoon Teal | `#14B8C6` | positive/keep, photo-window accents, secondary gradient start |
| Spark Gold | `#FFD561` | sparkles, streak, Pro badge, "best value" (fill only) |
| Purge Coral | `#FF4D6A` | delete/destructive only |
| Paper | `#F5F7FF` | light canvas (cool, not grey) |

Signature gradient: `linear-gradient(145deg, #14B8C6 0%, #2F6BFF 45%, #7B3FE4 100%)` for hero surfaces, primary buttons and the app mark. Soft glow (blue/violet, low opacity) is allowed behind hero numbers and the primary button only.

Type:
- Display and big numbers: Google Font "Bricolage Grotesque" (weights 600-800), loaded with `@import url('https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,600..800&display=swap')`, fallback `-apple-system`.
- Body, labels, controls: `-apple-system, "SF Pro Text", system-ui`.
- Hero numerals ("23", "412", "18") at 64-96px, tight tracking, tabular digits.

Signature visual idea: **the fading shelf-life edge.** Every screenshot card carries a thin age ring or corner stamp ("2d", "9d", "31d") and older cards fade toward cool grey; swiping leaves a ghost afterimage trail in coral (purge) or teal (keep); Inbox zero bursts gold four-point sparkles (reuse the icon's sparkle shape as inline SVG). Use the sparkle shape and the tilted-card silhouette as the recurring motif (onboarding mark, empty states, paywall badge, widget).

Style references (in words):
1. Duolingo / Headspace: confident saturated colour, big friendly numerals, rewarding payoff screens, but cleaner.
2. Linear / Arc: dark indigo surfaces, crisp 1px hairlines, restrained glow, dense but calm information.
3. Apple Wallet / Cash App: tactile stacked cards with depth, one dominant action per screen.

Avoid: the stock grouped-inset Settings look (white rows on grey with chevrons everywhere), flat all-white screens, one-colour blue-on-white, generic "Continue" buttons without hierarchy, emoji, stock photos, lorem ipsum, grey skeleton boxes.

## Deliverable

A design board: responsive grid of iPhone 16 Pro frames at exactly 393 x 852 pt (rounded 55px bezel, Dynamic Island, status bar 9:41 + battery, home indicator), each with a caption above (number + name + one-line intent). Board background Night Ink. After the frames, a compact spec section: palette tokens, type scale, spacing/radius, component inventory, per-screen states (loading / empty / error / offline), accessibility notes.

## Screens (9 frames, same content as the approved brief)

1a. Onboarding - value. Mark: tilted screenshot card + sparkle (SVG) on gradient hero. Headline "Your screenshots have a shelf life." Body "Keep the ones you need. Purge the rest. Everything stays on your iPhone." Primary "Continue", text button "Not now". Show a fanned stack of 3 populated screenshot cards with age stamps.
1b. Onboarding - permission. One button "Allow access", line "Only screenshots are read. Nothing leaves your phone." No cancel. Photo-library glyph, "You can change this in Settings later."
2. Inbox (Home), light (Paper). Large title "Inbox", trailing search + gear icons. Gradient hero card: "23 new" (96px Bricolage) + "84 MB" + "Start cleaning" button + streak pill "5 weeks clear" (gold). Section "By app" with 4 rows, each with a drawn app tile: Shopee 9 items 34 MB, Messages 6 items 21 MB, Banking 5 items 18 MB, Memes 3 items 11 MB (rows sum to 23 / 84 MB; add a thin proportional bar per row). Section "Older than 30 days": 412 items, 1.2 GB, "Review" with Pro lock (separate queue, not part of the 23). Row "12 pinned" + caption "Protected". Row "Next refill in 3 days". Bottom: believable 320x50 banner ad (label "Sponsored", tiny app tile, one line copy, "Get" pill) above the tab bar.
2b. Inbox, dark variant (Night Ink) of frame 2.
3. Swipe deck, dark Night Ink with violet radial glow. Top: back chevron, source chip "Shopee", "7 of 23", pin icon. Hero card 9:19.5 aspect, max 361pt wide, slightly rotated next card peeking behind, containing a fully populated Shopee order screenshot (red header, order #4821 "Arrived", product thumbnail drawn as an SVG running shoe, "Running Shoes - White, Size 42", 248,000, timeline "Ordered 10 Mar - Shipped 11 Mar - Delivered 12 Mar", address "12 Nguyen Hue, District 1", paid with Visa, Buy again). Age stamp "9d". OCR strip glued to card bottom: "Order #4821 - Arrived - 248,000". Show a mid-swipe ghost trail. Progress bar. Controls 56pt: Undo, Keep (teal), Delete (coral filled).
4. Review and delete. Title "Review", Cancel. "18 of 23 - 62 MB" as a big numeral line. 4-column grid of 18 populated miniature screenshots (order, chat with bubbles, bank transfer with amount, meme with big text, dark chat, ticket/QR, map address) with coral check badges at bottom-right outside the text area. Sticky bottom: coral "Delete 18", secondary "Review each", caption "Moves to Recently Deleted. Undo for 30 days."
5. Inbox zero. Gold sparkle burst SVG, tilted empty card with teal check, "Inbox zero." "84 MB moved out of your library." "New screenshots appear here automatically." "0 new this week", rendered small widget preview ("23 new", mini card stack), primary "Pin something worth keeping", text button "Done". Use the gradient, not a flat grey screen.
6. Paywall sheet on Night Ink with gradient glow. X dismiss, "PurgeSwipe Pro", "One payment. Yours forever.", 4 features with distinct drawn icons ("Unlimited weekly cleanups", "Unlimited pins and text search", "Age-out queue", "No ads"). Plan cards: "Lifetime $14.99" selected with gold "BEST VALUE - ONE-TIME" tag and gradient border; "Yearly $7.99/yr" unselected, "renews yearly". Bottom-anchored block: Continue (gradient), Restore Purchases, "Terms - Privacy", "Prices in USD. Lifetime is a one-time purchase."
7. Settings, NOT stock: Pro status as a gradient hero card ("PurgeSwipe Pro - Lifetime", gold badge, storage reclaimed total "1.8 GB freed"), then compact grouped rows with coloured icon tiles: Restore Purchases, Pinned screenshots (12), Appearance (System), Help and FAQ, Privacy Policy, Terms of Use, About. Footer "Version 1.0.0 (1)".

Data rules: use exactly these numbers everywhere (23 new, 84 MB, Shopee 9/34 MB, Messages 6/21 MB, Banking 5/18 MB, Memes 3/11 MB, 412 / 1.2 GB older, 18 of 23 / 62 MB selected, 12 pinned, 5 weeks, 7 of 23).

## Density and hierarchy rules

- One hero per screen (a numeral, a card, or a payoff) at least 2.5x the size of the next element; at most 2 type weights per block.
- Fill the 852pt height deliberately: no empty band taller than 32pt except around a centred payoff; anchor primary actions to the bottom above the home indicator.
- 16pt margins, 8pt grid, 44x44 min touch targets, tab bar on frames 2/2b (Inbox, Pinned, Settings) with safe-area padding.
- Every thumbnail and screenshot is drawn in inline SVG/CSS with real text, colours and shapes at its actual size. No empty boxes, no grey placeholder rectangles, no dashed boxes.

## Quality checklist (verify every frame before finishing, fix and re-check)

1. Exactly 393x852, nothing clipped or overflowing, no overlapping text.
2. Uses only the 7 palette colours plus tints; gradient and glow only where specified.
3. Bricolage Grotesque on display numerals and headlines, SF stack on body.
4. Contains at least one drawn illustration/SVG element (sparkle, card stack, shoe, widget).
5. Realistic populated content, exact data above, no lorem ipsum.
6. Does not resemble the stock iOS Settings app.
7. Status bar, Dynamic Island, home indicator present.
