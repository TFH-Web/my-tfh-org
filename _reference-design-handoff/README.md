# Handoff: my.tfh.org Public Sign-Up Pages (`/signup`, `/signup/{slug}`)

## Overview
Two public (unauthenticated-friendly) views on **my.tfh.org**, the church's **Rock RMS** site,
that surface Rock's **Sign-Up (Group Type: Sign-Up Group / Project) feature** without using the
stock "Sign-Up Finder" block chrome (search box, filters, "Results / Below is a listing of the
projects…" text).

- `/signup` — a **menu of Sign-Up Groups** that have at least one open/upcoming opportunity.
  Each entry shows the group's **title, description, image** and how many upcoming dates it has.
- `/signup/{slug}` — e.g. `/signup/kids-min-orientation` — the **group header** (image, title,
  description, meta) plus a card per **upcoming opportunity** (date, time, campus, capacity
  state, register action).

Every opportunity may or may not have a **capacity** configured, so the opportunity card has
five states (below). Anything at capacity either offers a waitlist or is closed.

## About the Design Files
The files in this bundle are **design references created in HTML** — a prototype of the intended
look and behavior, not production code to paste in. The task is to **recreate these designs in
the target environment**: Rock RMS pages on my.tfh.org, built with **Lava templates** (a Dynamic
Data / Content Channel / custom block or the `SignUpFinder`-style block with a fully custom Lava
template), following the conventions already used on my.tfh.org. Class names, markup structure
and the React-ish component wiring in the prototype are incidental — the visual spec and the
behavior spec are what matter.

## Fidelity
**High fidelity.** Colors, type, spacing, radii and states below are final and come from The
Father's House design system. Recreate them exactly. Only the photography is placeholder (the
prototype uses droppable image slots).

## Environment / integration notes (Rock-specific)
- **Route:** the page needs two Rock page routes — `signup` and `signup/{GroupSlug}` (or
  `signup/{ProjectSlug}`). When the route parameter is absent, render the **menu**; when present,
  resolve it to a Sign-Up Group and render the **opportunity list**. An unmatched slug should fall
  back to the menu (or a "Nothing Open Right Now" panel).
- **Slug source:** a group attribute (e.g. `PublicSlug`) is the safest key; don't rely on Id in
  the URL — the marketing team will hand out these links.
- **Group fields used:** Name (title), Description, and an image attribute (Binary File) for the
  photo. If the image attribute is empty, render the card without the photo band — do **not** show
  a broken/empty grey box.
- **Opportunity fields used:** occurrence date + time, Campus (or Location), `SlotsMin/SlotsMax`
  (capacity), participant count, and the group's waitlist setting.
- **Register action** links to the existing Rock registration flow / group-member add page for
  that occurrence — no new registration UI is part of this design.
- Only groups with **at least one future occurrence** appear in the menu; occurrences in the past
  are filtered out.
- Times are rendered in Pacific and labelled as such ("Times shown in Pacific").
- The **black "Mockup state" bar** at the top of the prototype is a demo control for switching
  states. **Do not build it.**

## Screens / Views

### Chrome (both views)
- **Page background:** pure white `#FFFFFF`.
- **Header:** 96px tall, white, **no bottom rule**, horizontal padding 40px. Left: the TFH bug
  mark only (`logo-bug.svg`, 44×44, black — rendered via CSS mask so it can be tinted). Right:
  text link "Logout" (16px/400, `#000`) and a 30px circle with a 1px `#C3C8CC` ring containing a
  16px "?" in `#707378`, gap 20px. This is the existing my.tfh.org nav — keep it as-is.
- **Content column:** `max-width: 1200px`, centered, padding `40px 32px 64px`.
- **Footer:** full-bleed black `#000`, padding 32px, centered column, gap 8px: "The Father's House
  2026" (18px/400, −0.6px tracking, white) and `www.tfh.org` (16px/400, `rgba(255,255,255,0.5)`,
  links to https://www.tfh.org).

### 1. Group menu — `/signup`
- **Purpose:** choose which sign-up you're interested in.
- **Layout:** header block (max-width 760px, gap 12px) then a card grid.
  - H1 "Sign Up at TFH" — 40px / line-height 1 / weight 500 / letter-spacing −1.6px.
  - Intro paragraph — 18px / 1.4 / 400 / −0.6px, color `#707378`, `text-wrap: pretty`.
    Copy: "Pick a sign-up below to see the upcoming dates, campuses and remaining spots. You can
    register for as many as you need."
  - Grid: `repeat(auto-fill, minmax(400px, 1fr))`, gap 20px. Gap between header block and grid: 32px.
- **Group card** (whole card is the click target → `/signup/{slug}`):
  - Background `#F1F1F1`, radius **20px**, no border, **no shadow**, `overflow: hidden`.
  - Hover: `outline: 2px solid #000; outline-offset: -2px` (nothing else moves; no scale).
  - Photo band: full width × **200px**, full-bleed to the card edges (no inset margin).
  - Body: padding 24px, column, gap 12px.
    - Title (group name) — 24px / 1.1 / 500 / −1px.
    - Description — 18px / 1.4 / 400 / −0.6px, `#707378`, 1–3 sentences.
    - Footer row (pushed to the bottom, `padding-top: 8px`, space-between): "N upcoming dates"
      (16px/400, `#707378`) and a **48px circular black arrow button pointing right** (hover fill
      `#2D5BFF`).

### 2. Opportunity list — `/signup/{slug}`
- **Purpose:** pick a date/campus and register.
- **Back link:** "← All Sign-Ups", 16px/400, `#2D5BFF`, underline on hover.
- **Group header:** two columns — `minmax(280px, 440px) 1fr`, gap 40px, `align-items: start`.
  - Left: group photo, full width × **280px**, radius 20px.
  - Right: column, gap 16px.
    - Eyebrow "SIGN-UP GROUP" — 14px/1, uppercase, letter-spacing 1.2px, display face, `#707378`.
    - H1 group name — 40px / 1 / 500 / −1.6px.
    - Description — 18px / 1.4 / 400 / −0.6px, `#707378`, max-width 620px.
    - Meta pills (row, gap 10px, wrap): "N upcoming dates", "N campuses", duration (e.g. "1 hour").
      Each: 16px/400 black on `#F1F1F1`, radius 99999px, padding 10px 16px.
- **Section head:** row, baseline, space-between, `border-bottom: 1px solid #C3C8CC`,
  `padding-bottom: 16px`. Left "Upcoming Opportunities" (24px/1.1/500/−1px), right "Times shown in
  Pacific" (16px/400, `#707378`).
- **Opportunity grid:** `repeat(auto-fill, minmax(300px, 1fr))`, gap 20px.
- **Opportunity card:** background `#F1F1F1`, radius 20px, padding 24px, column, gap 20px,
  `min-height: 250px`, no border/shadow. Content, top to bottom:
  1. Date — 22px / 1.1 / 500 / −0.8px (e.g. "Thursday, Aug 27").
  2. Time — 18px / 1.3 / 400 / −0.6px, `#707378` (e.g. "7:15 PM").
  3. Campus — same style as time (e.g. "Napa").
  4. Capacity block (see states).
  5. Action, pinned to the bottom (`margin-top: auto`).

### 3. Empty state
Reached when no group has an upcoming opportunity (or a slug doesn't resolve).
H1 "Sign Up at TFH", then a `#F1F1F1` radius-20 panel, padding `64px 40px`, centered, gap 16px:
- "Nothing Open Right Now" — 24px/1.1/500/−1px.
- Body (max-width 520px, 18px/1.4, `#707378`): "There are no sign-ups with upcoming dates today.
  New opportunities post regularly — check back soon, or reach your campus team at hello@tfh.org."

## Capacity states (the five opportunity-card variants)
Let `left = capacity − taken`.

| # | Condition | Capacity block | Action |
|---|---|---|---|
| 1 | No capacity configured | Text "Open sign-up — no limit", 16px/400 `#707378`. No progress bar. | **Register** (primary) |
| 2 | `left > 5` | Pill "N spots left" — 16px/500, ink `#21291F` on `#B1C1A9`, radius 99999px, padding 8px 14px. Plus progress bar. | **Register** (primary) |
| 3 | `1 ≤ left ≤ 5` (low) | Same pill geometry, ink `#FFFFFF` on `#5D6F54`. Copy "N spots left" / "1 spot left". Plus progress bar. | **Register** (primary) |
| 4 | `left = 0`, waitlist **enabled** | Pill "At Capacity" — 16px/500, ink `#707378` on `#E2E3E6`. Bar at 100%. | **Join Waitlist** (secondary) + note "We'll email you if a spot opens." (16px/1.3, `#707378`) |
| 5 | `left = 0`, waitlist **disabled** | Same "At Capacity" pill + full bar. | Non-interactive "Sign-Ups Closed" — 18px/1/400/−0.6px, ink `#A9AEB2`, radius 8px, padding 14px 22px, `box-shadow: inset 0 0 0 2px #E2E3E6`; note below: "This date reached capacity." |

- **Progress bar** (whenever capacity is configured): 100% × 6px track, radius 99999px, track
  `#E2E3E6`, fill `#5D6F54`, width = `round(taken / capacity × 100)%`.
- **Alternate capacity wording** (a toggle in the prototype, pick one for production): "N spots
  left" (default) or "X of Y spots taken".
- Capacity numbers are the only place numerals appear; never show a capacity when Rock has none.

## Buttons (design-system `Button`)
- **Register** = Primary, medium: solid black fill, white 18px label, radius **8px**, no arrow icon.
  Hover **inverts**: transparent fill, black label (2px black ring). No scale, no bounce.
- **Join Waitlist** = Secondary, medium: transparent with `inset 0 0 0 2px #000`, black label,
  radius 8px. Hover: solid black fill, white label.
- Labels are verb-first, 2–3 words. Never "Submit" or "Click here".

## Interactions & Behavior
- Group card click → navigate to `/signup/{slug}` (full page load is fine; a client-side swap is
  also acceptable since the prototype does it in place).
- "← All Sign-Ups" → `/signup`.
- Register → Rock registration for that occurrence. Join Waitlist → same flow, waitlist mode.
- Hover states as specified above; transitions ≤200ms (`cubic-bezier(.4,0,.2,1)`), color/background
  only. **No animation beyond that** — no parallax, springs, or entrance animations.
- Responsive: both grids are `auto-fill minmax()`, so they collapse to one column naturally. Below
  ~720px the group header stacks (photo above text) and the content gutter tightens to 24px.
  Keep tap targets ≥44px.
- Loading: if occurrences are fetched async, show the card skeletons (same geometry, `#F1F1F1`
  panels) rather than a spinner.

## State Management
Minimal — the page is read-mostly.
- `route` / slug param: `null` → menu, `{slug}` → detail, unmatched → empty state.
- Per group: name, description, image URL, slug, upcoming-occurrence list, distinct campus count,
  duration label.
- Per occurrence: date label, time label, campus, capacity (nullable), taken count, waitlist flag;
  derived: `left`, `isLow`, `isFull`, `canRegister`, `canWaitlist`, `isClosed`, `pct`.

## Design Tokens
Colors — white `#FFFFFF` (page), `#F1F1F1` (cards/panels/pills), `#E2E3E6` (bar track, at-capacity
pill, disabled ring), `#C3C8CC` (hairline rules, help-icon ring), `#A9AEB2` (disabled ink),
`#707378` (secondary text), `#000000` (primary text, buttons, footer), green `#5D6F54` (bar fill,
low-capacity pill), `#B1C1A9` (available pill), `#21291F` (ink on the light green pill),
blue `#2D5BFF` (links, arrow-button hover).

Type — Neue Haas Grotesk Text Pro via Adobe Fonts (`neue-haas-grotesk-text` 400/500;
`neue-haas-grotesk-display` for the eyebrow), fallback Helvetica Neue. **my.tfh.org runs a smaller
scale than tfh.org:** H1 40/1/−1.6, H2 24/1.1/−1, card date 22/1.1/−0.8, body 18/1.4/−0.6,
small 16/1. Headings weight 500, body 400. Headline copy is Title Case.
⚠️ The Adobe web project is **domain-scoped** — my.tfh.org must be listed in Adobe Fonts → Web
Projects or the faces silently won't serve.

Spacing — 8 / 10 / 12 / 16 / 20 / 24 / 32 / 40 / 64px. Grid gaps 20px. Content gutter 32px
(24px mobile). Radii — 20px cards/panels, 8px medium buttons and the disabled chip,
99999px pills and the arrow button. Shadows — **none** anywhere. Borders — 1px `#C3C8CC` hairline
rules, 2px black ring on secondary buttons.

## Assets
- `assets/logo-bug.svg` — the real TFH bug mark, supplied by TFH, rendered through a CSS mask so
  it takes any ink. Included in this bundle. Don't recreate or re-letter it.
- Group photography: **not included** — the prototype uses droppable placeholders. Use warm,
  natural-light documentary photos of real TFH people, full-bleed inside the radius-20 crop.
- Icons: only the design system's single solid arrow glyph (in the round arrow button). No icon
  library, no emoji.

## Files
- `Signup Page.dc.html` — the prototype (all four states; the black bar at the top switches them).
- `image-slot.js` — placeholder-image helper used by the prototype only; not part of the design.
- `assets/logo-bug.svg` — brand mark.
- `_ds/…/` (in the source project) — the TFH design system tokens and components the prototype
  composes. Values are transcribed above, so the handoff is self-sufficient.
