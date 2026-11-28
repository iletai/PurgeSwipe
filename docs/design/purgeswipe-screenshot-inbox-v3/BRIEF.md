# PurgeSwipe — Screenshot Inbox design board v3 (full app, artwork-rich, refined)

Execute this fully. Output: ONE self-contained `index.html` at the project root (inline CSS and inline SVG; only external resource: the Google Fonts stylesheet; no JS required).

## Start from the prior work, evolve it

The previous board (v2, "B") is at `/Users/lequangtrongtai/Library/Application Support/Open Design/namespaces/release-stable/data/projects/purgeswipe-inbox-v2-prompt-test/index.html`. READ IT FIRST. Reuse its CSS variables, frame chrome (bezel, Dynamic Island, status bar), the sparkle/tilted-card motifs and the Shopee/chat/bank/meme/ticket thumbnails, then fix and deepen them. Do NOT restart from scratch. Also read `/Users/lequangtrongtai/orca/PurgeSwipe/docs/design/BRIEF-screenshot-inbox-v2.md` (brand "Shelf Life", palette, type, data rules): everything in it still applies unless this v3 brief overrides it.

User feedback on v2: "UI too simple, lacks artwork, lacks refinement and sophistication, missing screen clusters." v3 must answer all four.

Build strategy (important, the file is large): write the file in sections. First `<head>` + CSS + shared `<svg><defs>` (filters, gradients, symbols), then append one flow section at a time (one write/edit per section), then re-read the file and verify. Define reusable `<symbol>`s (sparkle, card silhouette, app tiles, icons, mascot, thumbnails) once and `<use>` them.

## Real product facts (from the Swift sources, design must reflect them)

- Smart decks (DeckKind): Screenshots (the Inbox deck), Similar photos, Blurry photos, Videos. Show them as categories / smart albums.
- Swipe: left = mark delete, right = keep; pill "N to delete"; Similar deck has a "pick the best" header; videos show duration badge (e.g. 0:42) and size.
- Review: summary "N items - X MB", "Delete N", "Review each", daily free deletion cap with "N left today" and a cap note (free tier), moved-to-Recently-Deleted success, failed and cancelled phases.
- Home states: notDetermined / denied / limited / granted permission, analyzing progress "Analyzing 42%", loading skeleton, empty library, last cleanup summary, Pro-locked rows.
- Settings rows: Pro/purchases, Help & FAQ, Contact, Rate, Share, System Settings, Privacy, Terms, About, Appearance. Help: email, website, refund. No widget and no push notifications exist in v1: still design the Home-screen widget and Lock-screen widget as a "proposed v1.1" cluster, clearly labelled.
- Ads (free tier only): banner above the tab bar on Home, interstitial after a completed cleanup, rewarded "watch an ad to unlock 5 more deletions today" on the cap sheet. Pro = no ads.

## Frame inventory: 12 flow sections, 44 frames (each frame 393 x 852)

Each section has a full-width header band on the board (section number, title, one-line goal, a small SVG glyph, and a thin connector line or arrows between frames showing the flow). Frame ids are unique and sequential (01..44); caption above each frame: id + name + intent. No duplicate names.

A. Onboarding (6): 01 Welcome / value (fanned card stack with age stamps, mascot). 02 How it works 1: "New screenshots only" (spot illustration: inbox tray catching cards). 03 How it works 2: swipe left purge / right keep (animated-looking two-way arrow art, ghost trails). 04 How it works 3: pin vault + age-out (vault drawer illustration). 05 Permission priming (pre-prompt, explains why, privacy line). 06 System permission mock sheet (iOS alert: Allow Full Access / Select Photos / Don't Allow) over blurred app, plus step dots on all onboarding frames.
B. Permission and loading states (5): 07 Home: access denied (illustration + Open Settings). 08 Home: limited access (banner "Select more photos" + partial data). 09 Home: analyzing 42% (progress ring around the mark). 10 Home: loading skeleton (shimmer-styled tinted shapes, NOT grey boxes). 11 Home: error "Could not read your library" + Retry (offline-safe).
C. Home / Inbox (5): 12 Inbox light, populated (23 new, by-app rows, older queue, pinned, refill, banner ad, tab bar). 13 Inbox dark. 14 Inbox with last-cleanup summary card and 5-week streak calendar row (last 7 weeks as dots). 15 Smart albums / categories hub: four deck cards (Screenshots 23, Similar 14 groups, Blurry 9, Videos 6 with sizes), each with its own artwork. 16 Search results (query "invoice", OCR highlight chips, matches across inbox, Pro-gated filter).
D. Swipe deck and states (7): 17 Deck at rest (Shopee card, OCR strip). 18 Mid-swipe left, coral ghost trail and "Delete" stamp. 19 Mid-swipe right, teal ghost trail and "Keep" stamp. 20 Deck: chat screenshot variant, pin tooltip. 21 Similar-photos deck ("Pick the best": 3 near-duplicates side by side, best marked with a gold star). 22 Video deck (duration and size badge, scrub bar). 23 Undo toast after a swipe + "7 to delete" pill; deck end card "Deck finished".
E. Review and delete (4): 24 Review grid, 18 of 23 selected, 4 columns, multi-select with checks. 25 Review grid in select mode, sticky bar with count, Select all / Deselect, one tile deselected. 26 Confirm sheet (system-style delete confirmation, "Moves to Recently Deleted. Undo for 30 days."). 27 Deleting in progress (progress ring, mascot sweeping, cancel disabled).
F. Success and inbox zero (3): 28 Success "84 MB moved out of your library" payoff. 29 Delete failed / cancelled with Retry. 30 Inbox zero (burst, empty card, "0 new this week") + a following interstitial-ad frame is listed in section K.
G. Detail / viewer (2): 31 Screenshot detail viewer (full image, OCR text panel in a glass sheet, metadata: date, size, source app, age stamp, Pin / Share / Delete actions). 32 Pinned vault (grid of 12 pinned, pin badges, "Protected", empty-state variant noted in spec).
H. Stats, streaks, achievements (2): 33 Stats: total freed 1.8 GB (hero numeral), weekly bar chart, by-app donut, 5 weeks streak. 34 Achievements: badge shelf (First purge, 1 GB freed, 5 weeks clear, Inbox zero x3, Pin master), locked ones dimmed with silhouette.
I. Paywall (3): 35 Paywall main (as v2, richer). 36 Daily cap reached sheet (free tier, "0 of 20 left today", rewarded ad option + Go Pro). 37 Purchase success "Welcome to Pro" with confetti sparkles.
J. Settings (4): 38 Settings root (hero card, tiles, version). 39 Appearance picker (System / Light / Dark, live preview thumbnails). 40 Help & FAQ (accordion, email, website, refund). 41 About (mark, version, links) - or Privacy summary card; pick About.
K. Ads (1 frame in this section, banner is already in 12): 42 Interstitial after completed cleanup (full-screen mock ad with "Ad" label, countdown ring and a visible close button, plus a "Remove ads with Pro" strip).
L. Widgets and Lock screen, proposed v1.1 (2): 43 iPhone Home screen with small + medium widget ("23 new", mini stack, streak) on a wallpaper. 44 Lock screen with circular, rectangular, inline widgets, labelled "Proposed v1.1".

Dark-mode variants required (in addition to 13): 17 deck is dark by nature; also render dark versions of 24 (review grid, dark), 33 (stats, dark) and 38 (settings, dark) as extra frames numbered 45, 46, 47 and placed at the end of their sections' rows or in a final section M "Dark variants". Total 47 frames. If output budget is a problem, keep all 47 but simplify repeated chrome via symbols, never drop a section.

Data rules: v2 numbers stay exact (23 new, 84 MB, Shopee 9/34 MB, Messages 6/21 MB, Banking 5/18 MB, Memes 3/11 MB, 412 / 1.2 GB older, 18 of 23 / 62 MB, 12 pinned, 5 weeks, 7 of 23). Add consistently: freed total 1.8 GB, daily cap 20 (free), Similar 14 groups / 212 MB, Blurry 9 / 38 MB, Videos 6 / 1.4 GB.

## Artwork system (this is the main gap, invest here)

Hand-build in inline SVG, defined once as `<symbol>`s:
1. Mascot: "Shelfie", a friendly tilted screenshot card with a rounded face (two dot eyes, small smile), a teal photo window as a hat/visor, and a tiny gold sparkle. 6 poses: wave (welcome), swipe (arrows), vault (holding key), sweep (broom of light), sleepy (empty/error), celebrate (arms up, confetti). Consistent 3-tone shading, soft inner highlight, 2px Night Ink outline at 20 percent.
2. Spot illustrations (min 200x160 each, layered shapes, not icons): onboarding x4, permission lock-and-photo, denied (closed door), limited, error (unplugged cable), empty states (inbox tray, vault drawer), success (gold burst), paywall (crown-like sparkle crest over a shelf), cap reached (hourglass), achievement badges x6.
3. Texture and depth: SVG `feTurbulence` grain filter (baseFrequency 0.8, opacity 6-10 percent) overlaid on gradient hero surfaces and the dark canvas; mesh-like gradients made from 2-3 blurred radial blobs; layered parallax shapes (back blob, mid card, front sparkle); glass cards (backdrop-ish: translucent white 8-14 percent fill, 1px inner highlight stroke, soft blur shadow); subtle noise on Night Ink.
4. Micro-detail: age stamps (rounded rect, rotated -6deg, dashed inner border), rubber-stamp "KEEP"/"DELETE" marks, perforated ticket edges, corner folds, shelf-life ring around the age number, small sparkle trails, hairline dividers with gradient fade, tabular numerals.
5. Custom icon set (24px grid, 1.75px stroke, round caps, drawn as `<symbol>`s, NOT emoji, NOT text glyphs): inbox, pin, search, gear, trash, undo, keep-check, photo-library, similar-stack, blur, video, clock, lock, crown-sparkle, chart, trophy, shield, help, mail, star, share, moon/sun, chevron, close.
6. App-tile icons drawn per source app (Shopee, Messages, Banking, Memes, Photos, Maps, Tickets) with distinct shapes and colours (stay within palette tints).

Every frame must contain at least one piece of artwork beyond text and plain rows (mascot, spot illustration, textured hero or drawn thumbnail).

## Refinement rules

- 8pt grid, 4pt for optical nudges. Margins 16 (20 on onboarding). Section gaps 24, in-card padding 16.
- Type scale (px): 96 hero numeral, 56, 34 large title, 28, 22 headline, 17 body, 15 secondary, 13 caption, 11 micro. Max 2 weights per block. Bricolage for 22+ and numerals, SF below. Line-height 1.15 display, 1.35 body. Tabular numerals on all counts.
- Radii tiers only: 8 (chips, small tiles), 12 (thumbnails, inputs), 16 (cards), 24 (hero cards, sheets), 999 (pills, buttons). Frame bezel 55.
- Shadow tiers: s1 `0 1px 2px rgba(11,16,48,.08)`, s2 `0 6px 16px rgba(11,16,48,.12)`, s3 `0 18px 40px rgba(11,16,48,.28)`, glow `0 0 48px rgba(47,107,255,.35)` (primary button and hero numeral only). Dark surfaces use 1px hairline `rgba(255,255,255,.08)` instead of shadow.
- Touch targets 44 minimum. One dominant action per screen. Optical alignment: icons centred in tiles, numerals baseline-aligned with units.
- Contrast: text on gradients white at weight 600+; Spark Gold is fill only, never text on Paper.
- NO TEXT CLIPPING. Give every text container `min-width:0`, explicit `max-width`, `overflow-wrap:anywhere` or `text-overflow:ellipsis` with `-webkit-line-clamp` where truncation is intended, and size hero numerals with `white-space:nowrap` inside containers wide enough (measure: 3 digits at 96px Bricolage is about 190px). Frames use `overflow:hidden` only for the bezel clip, never to hide content mistakes.
- Grids: use CSS grid with `grid-template-columns: repeat(4, minmax(0, 1fr))` and fixed `aspect-ratio` tiles, `gap:8px`, so tiles can never overlap. Thumbnails scale via SVG `viewBox` with `width:100%`.

## Explicit fix list for v2 bugs (verify each)

1. Hero "23 new" was clipped: widen/shrink the container, `white-space:nowrap`, numeral 88-96px, unit label beside it baseline-aligned.
2. Review grid tiles overlapped: replace with the grid rule above; 18 tiles, 4 columns, 5 rows plus a partial row; the sticky bar must not cover tiles (add bottom padding equal to bar height).
3. Deck card text overflowed: the Shopee screenshot content must fit inside the card at its real aspect ratio via `viewBox`; drop or shorten lines rather than overflow; check at every line.
4. Shopee card clipped on the right edge: card width max 361 with 16 margins inside 393; verify the rotated neighbour card also stays inside the frame or is clipped intentionally by the bezel only on its far edge.
5. Frame 1b (permission) was bland: now frames 05 and 06 with mascot, spot illustration, privacy badge row and a realistic system alert mock.
6. Duplicate frame name: all names unique, ids sequential 01..47.

## Verification (do this before finishing, loop until clean)

After writing, re-open the file and for each frame check by reading the markup: nothing wider than 393 or taller than 852, no absolutely-positioned element past the frame edge unintentionally, no two siblings overlapping, every numeral container wide enough, every `<use>` references an existing symbol id, no empty boxes, no lorem ipsum, no emoji. Fix what you find. Then state in your final message the count of frames and sections actually delivered.

## Spec section (after the board)

Palette tokens, type scale, spacing, radius tiers, shadow tiers, artwork inventory (mascot poses, spot illustrations, icons), component inventory, state matrix per screen (loading / empty / error / offline / denied), accessibility notes (contrast, Dynamic Type, VoiceOver labels for swipe actions: "Keep" and "Delete" as accessibility actions, Reduce Motion alternative for ghost trails).
