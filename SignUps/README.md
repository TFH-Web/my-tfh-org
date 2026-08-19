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

`Slug` = the slugified group name — `kids-min-orientation`. Derived entirely
from data already in Rock; there is no attribute to create and nothing for an
admin to fill in.
`Occurrence` = the raw integer Schedule Id.

### Why the slug is normalised in Lava, not SQL

The slug is a name with no Id, so resolution is a **string match** — and the two
sides have to normalise identically or links break. They do, by construction:

1. SQL derives a **raw** name-slug (the `REPLACE` chain). Its output may still
   contain odd characters; that is fine and deliberate.
2. **Both** the link generation and the match then pipe that raw value through
   the same `RegExReplace:'[^a-z0-9-]',''`.

Same input, same chain, same strip on both sides — so they are equal whatever the
chain leaves behind. A group named `Pastor's Lunch` with a curly apostrophe, or
`Serve Day (Napa)` with parentheses, resolves correctly without the chain having
to know about those characters.

That final strip is why normalisation lives in Lava. SQL has no regex replace, so
a SQL-side derivation can only enumerate characters one at a time and will always
be incomplete. The earlier version matched the SQL chain's output directly against
the Lava-sanitised inbound slug — two *different* normalisations — and any
character the chain missed produced a dead link.

Resolution therefore runs in two steps: a small query returns every eligible
group with its raw slug (currently 8 rows), Lava finds the match, and the main
query then fetches by integer group Id.

### Two things this costs

- **Name collisions are possible.** Two groups deriving the same slug — an annual
  repeat, or the same sign-up at two campuses — resolve to whichever the loop
  reaches first, and the other becomes unreachable with no error. Accepted as an
  admin-side concern: keep public sign-up group names distinct.
- **Renaming a group breaks existing links.** The slug is the name, so a rename
  changes the URL and anything already printed or emailed 404s. Rename before
  publicising a link, not after.

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

## Navigation and breadcrumbs

The group and detail views rewrite Rock's breadcrumb trail **client-side**.

`<Rock:PageBreadCrumbs>` is a server-side control fed by the page hierarchy plus
any crumbs a block contributes through `GetBreadCrumbs()`. HTML Content blocks
contribute none, so the trail otherwise shows each page's static name regardless
of the slug. Rock's own Sign-Up Detail block does this properly — that is what its
`SetPageTitle` setting is for — but it is C# block behaviour an HTML block cannot
reach.

Resulting trails:

| Page | Trail |
|---|---|
| `/signups/{slug}` | **Kids Min Orientation** |
| `/signups/{slug}/{occurrence}` | *Kids Min Orientation* / **Thursday, August 27** |

**The group is treated as the root of the trail**, even though it is not the root
page — the ancestor crumb for the sign-up menu is removed. The scripts drop every
crumb above the group rather than assuming a fixed depth, so a change to the page
hierarchy will not leave a stray crumb behind.

Consequence to be aware of: **there is no longer any link from a group page back
to `/signups`.** That is deliberate — deep links go straight to a group, and the
menu is not presented as its parent — but it does mean the menu is only reachable
by typing the URL.

Group names reach the script through a `data-` attribute rather than being
interpolated into it, so a name containing an apostrophe cannot break it. Both
scripts bail out silently if `.breadcrumb` is absent.

Two known limits: there is a brief flash of the static name before the rewrite,
and the server-rendered `<title>` is unchanged, so link previews still show the
page name. Fixing either properly needs a custom C# block.

### Page settings worth changing

- **Display Page Title** — the layouts render `<h1 class="pagetitle">` from the
  page name, which sits above the block's own H1 and produces two H1s per page.
  Turn it off on 3716 and 3717, or drop the block's H1.
- The register page (3718) is Rock's own block; its breadcrumb is untouched. The
  same rewrite could go in the HTML Content block already on that page.

## Design deviations from the handoff

These are deliberate, driven by what the data and platform actually support.

| Handoff says | Built as | Why |
|---|---|---|
| Five capacity states incl. "Join Waitlist" | Four states | Sign-Up Groups have **no waitlist**. Every `%Wait%` column is on `Registration*` tables. At-capacity is simply closed. |
| Custom black/inverting buttons | `btn btn-primary` / `btn btn-default` | Requested: native theme buttons so states match the rest of the site. Nothing in the CSS touches `.btn`. |
| One action per opportunity card | Two — Details + Register | Requested, to reach the new opportunity detail page. |
| Duration pill on every card | Only when > 0 minutes | Most schedules have `DTEND = DTSTART + 1 second`, i.e. no duration was set. The pill would read "0 min". |
| `PublicSlug` group attribute as the URL key | Slug derived from the group name | The handoff advised an attribute; rejected because an optional field an admin must remember to fill in is a worse failure mode than deriving the URL from data already present. Its other advice — don't put Ids in the URL — is followed. |
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
