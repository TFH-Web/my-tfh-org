# my.tfh.org Public Sign-Up Pages

Public, marketing-linkable views of Rock's Sign-Up feature on **my.tfh.org**
(site 17, theme `MyTFH-2021`).

| File | Goes where |
|---|---|
| `signups-menu-and-group-block.html` | HTML Content block on **page 3716** |
| `signups-opportunity-detail-block.html` | HTML Content block on **page 3717** |
| *(styles)* | Merged into `theme/Styles/_css-overrides.less` as **section 22** |

## URL structure

```
/signups                                     page 3716   menu of sign-up groups
/signups/{Slug}                              page 3716   one group + its opportunities
/signups/{Slug}/{Occurrence}                 page 3717   one opportunity
/signups/{Slug}/{Occurrence}/register        page 3718   Rock's Sign-Up Register block
```

`Slug` = the group name, slugified, **with the group Id appended** —
`kids-min-orientation-345104`. Generated entirely from data already in Rock;
there is no attribute to create and nothing for an admin to fill in.
`Occurrence` = the raw integer Schedule Id.

### Why the Id is in the slug

Resolution matches on that **trailing integer**, not on the name. Two
consequences, both deliberate:

- **Collisions are impossible.** Two groups sharing a name — an annual repeat, or
  the same sign-up run at two campuses — would previously derive the same slug,
  and the resolver's `TOP 1 ... ORDER BY g.Id` would silently serve the older one
  while the newer became unreachable. No error, no hint.
- **Group names can contain anything.** Because nothing is matched by string, the
  name half of the slug never has to survive a round trip. That matters: the
  inbound slug is sanitised to `[a-z0-9-]`, so before this change any character
  the SQL derivation left in place — `(`, `)`, `?`, `!`, `+`, `#`, a curly
  apostrophe `’` — appeared in the generated link, was stripped on the way back
  in, and failed to match. A group named `Pastor’s Lunch` would 404. Now the name
  half is cosmetic and cannot break anything.

A useful consequence: **renaming a group does not break existing links.** The
name half of the slug changes, but the trailing Id still resolves, so anything
already printed or emailed keeps working and simply shows the new name.

There is deliberately **no admin-editable slug override**. Custom slugs would be
another field to maintain, another thing to get wrong, and another way for a
printed URL to stop matching. The trade is that every URL carries a number.

**Plural `signups`, not `signup`.** The singular two-segment slot is already
taken by `signup/{OpportunityId}` on page 3377 (Interest List, a Connection
Opportunity feature). Both are two-segment parameterised routes on the same
site and cannot coexist — one would silently swallow the other.

## Setup steps in Rock

### 1. Routes

| Page | Add route | Remove |
|---|---|---|
| 3716 | `signups` and `signups/{Slug}` | keep `signup` (harmless, lands on the menu) |
| 3717 | `signups/{Slug}/{Occurrence}` | `signup/detail` once nothing links to it |
| 3718 | `signups/{Slug}/{Occurrence}/register` | keep `signup/register` |

> **Do not name the third segment `ScheduleId`.** Rock's `PageParameter`
> resolves route values ahead of query-string values. The register page
> carries `?ScheduleId=<IdKey>` for Rock's own block; a route segment of the
> same name holding a raw integer shadows it and breaks registration with no
> visible error.

### 2. Swap the blocks
- **Page 3716** — remove the Sign-Up Finder block (7907), add an HTML Content block
- **Page 3717** — remove the Sign-Up Detail block (7908), add an HTML Content block
- **Page 3718** — leave exactly as it is. Rock's Sign-Up Register block stays.

On both new HTML Content blocks:

| Setting | Value |
|---|---|
| Enabled Lava Commands | **Sql, RockEntity** (both required) |
| Cache Duration | **0** — capacity must never be cached |

### 3. Styles
Styles live in **`theme/Styles/_css-overrides.less`, section 22** — the file
`theme.less` imports at line 861, which is what backs
Admin → CMS → Themes → **MyTFH-2021** → Theme Styler → **CSS Overrides**.

There is no separate sign-up stylesheet. Rock has one override field, so the
section lives inside that file with the rest of the site's overrides.

To deploy, paste the current `_css-overrides.less` into the Theme Styler CSS
Overrides field and save; Rock recompiles the theme. If it fails to compile
Rock reports it on save and rejects the whole field, so nothing renders
half-styled.

`MyTFH-2021` is a **v1 theme, so this is compiled by dotless.** Section 22 is
written accordingly:

- LESS variables (`@signup-*`) rather than CSS custom properties
- no `:has()` — the Lava emits `--nophoto` modifier classes instead
- no `grid-column: 1 / -1`, which dotless evaluates as arithmetic
- mobile-first `min-width: @screen-sm-min`, matching the file's own idiom, with
  no arithmetic inside the media query

Adobe Fonts is already loaded site-wide on MyTFH (kit `dpm1txa`). Confirm that
kit publishes `neue-haas-grotesk-text` (400/500) and `neue-haas-grotesk-display`,
and that `my.tfh.org` is listed in the kit's domains — the faces fail silently
otherwise and the pages fall back to Helvetica.

## Adjustable config

Both blocks open with an identical config section. **Keep them in step.**

| Variable | Default | Meaning |
|---|---|---|
| `campusTypeGuid` | Physical | Campus Type allowed publicly |
| `campusStatusGuid` | Open | Campus Status allowed publicly |
| `signUpGroupTypeId` | `176` | Sign-Up Group type |
| `lowSpotThreshold` | `5` | At or below this, the pill switches to the low style |
| `menuUrl` | `/signups` | Menu location, used by back links |

Physical + Open currently resolves to **Vacaville, Napa, East Bay, Roseville,
Los Gatos**. That is two campuses wider than the old Finder allowlist, which
covered only the first three — Roseville and Los Gatos were previously hidden.

It also excludes the `Other` catch-all campus (Online/No-Show), which matters:
`Other` shares Location 14 with Vacaville, so without the filter that location
would resolve ambiguously.

## Design deviations from the handoff

These are deliberate, driven by what the data and platform actually support.

| Handoff says | Built as | Why |
|---|---|---|
| Five capacity states incl. "Join Waitlist" | Four states | Sign-Up Groups have **no waitlist**. Every `%Wait%` column is on `Registration*` tables. At-capacity is simply closed. |
| Custom black/inverting buttons | `btn btn-primary` / `btn btn-default` | Requested: native theme buttons so states match the rest of the site. Nothing in the CSS touches `.btn`. |
| One action per opportunity card | Two — Details + Register | Requested, to reach the new opportunity detail page. |
| Duration pill on every card | Only when > 0 minutes | Most schedules have `DTEND = DTSTART + 1 second`, i.e. no duration was set. The pill would read "0 min". |
| `PublicSlug` group attribute as the URL key | Slug derived from the name + group Id | The handoff advised an attribute and warned against Ids in the URL. Rejected: an optional field an admin must remember is a worse failure mode than a number in the URL, and resolving on the Id is what makes the name half safe to derive. |
| Group photo band | Omitted when absent | As specified — never an empty grey box. Note **6 of 8 groups have no `ProjectImage`**, including both groups with upcoming dates. |

## Content gaps worth fixing

- **`ProjectImage` is empty on both groups that currently have upcoming dates**
  (Kids Min Orientation, Guest Services Training), so the menu renders two
  photo-less cards. The two images that do exist are a logo and a slide frame,
  not the documentary photography the design calls for.
- **Kids Min Orientation has no description** — its card and header render
  without body copy.
- Only capacity states 1 and 2 are reachable with today's data. States 3 (low)
  and 4 (at capacity) can't be seen live until a date fills up.

## Verify first, on the very first paste

0. **Lava is Fluid on this install, not DotLiquid.** It is a stricter parser —
   string literals reject invalid escape sequences (`'[^a-z0-9\-]'` fails;
   `'[^a-z0-9-]'` is correct). Errors read
   `Lava Error: End of tag '%}' was expected at (line:col)` and the column
   points at the real offender.

1. **`{% sql %}` named parameters.** These blocks use the bound form
   (`{% sql slug:'{{ slug }}' %}` → `@slug`) rather than interpolating the URL
   segment into the query. If your Rock build doesn't support it the query will
   error immediately and visibly. The slug is *also* stripped to `[a-z0-9-]` in
   Lava, so that sanitising is a second layer, not the only one.
2. **Outer spacing.** Per the project rule these blocks add no outer padding or
   margin, on the assumption Rock already pads blocks on MyTFH as it does
   elsewhere. If the content sits flush to the viewport edge, that assumption is
   wrong for this theme and the gutter belongs on `.signup`.
3. **Register handoff.** Click through one Register button and confirm Rock's
   block receives the three IdKeys. This is the one path we cannot verify from
   SQL alone.
