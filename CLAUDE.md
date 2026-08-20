# CLAUDE.md — my.tfh.org (MyTFH)

Repo: https://github.com/TFH-Web/my-tfh-org

---

## This repo mirrors production

`Pages/` is a faithful mirror of the live MyTFH site (Rock site 17) on
rock.tfh.org, pulled 2026-08-20 via the Magnus CLI. It replaced a set of
hand-organised topical folders that dated from January 2019 and had drifted
from live for years.

Treat `Pages/` as accurate **as of its pull date**, not as a live feed. Nothing
syncs it automatically. Before relying on a file for anything consequential,
re-pull it:

```bash
magnus cat <block-content-path> -s https://rock.tfh.org
```

The Magnus workflow, server list, `-s` requirement and CLI gotchas are
documented in the parent `../CLAUDE.md`. Read that before running any `magnus`
command.

---

## Project Overview

Frontend development for **my.tfh.org** — the member- and public-facing Rock RMS
site. Sign-up pages, registration flows, forms, and any other page content served
from the `MyTFH` site.

> **This is NOT rock.tfh.org.** The internal staff site lives in `../rock-frontend`
> and is a different site, a different theme, and a **different design system**.
> Do not carry tokens, stylesheets, or components between the two.

| | `rock-frontend` | `my-tfh` (here) |
|---|---|---|
| Domain | rock.tfh.org | my.tfh.org, mytfh.org |
| Rock site | Rock RMS (id 1) | MyTFH (**id 17**) |
| Theme | `Rock` (v1, LESS) | `MyTFH-2021` (v1, LESS) |
| Audience | Internal staff | Members and the public |
| Design system | Internal: `#36454f` brand, 10px radii, system font | Public: white/`#F1F1F1`, 20px radii, Neue Haas Grotesk |

The parent `../CLAUDE.md` applies here too — scratch queries go in
`_temporary-files/`, and every file pasted into Rock carries a GitHub permalink
comment at the top.

> ⚠️ **This repo's default branch is `master`, not `main`.** The parent rule says
> to point permalinks at `main`, which is right for `rock-frontend` and
> `rock-code` but 404s here. Source comments in this repo must use
> `.../blob/master/...` unless and until the default branch is renamed.

---

## Environment

- **Rock v17.6.1** — same database and instance as rock.tfh.org
- **Theme `MyTFH-2021`** — a **v1 theme, so it compiles LESS.** Not the v2/RockV2
  plain-CSS path that applies to devrock.
- **Lava engine is Fluid**, not DotLiquid. Fluid is a stricter parser:
  - String literals reject invalid escape sequences. `'[^a-z0-9\-]'` fails to
    parse (`\-` is not a valid escape); write `'[^a-z0-9-]'` instead.
  - Errors surface as `Lava Error: End of tag '%}' was expected at (line:col)`,
    and the column points at the real offender.

### Where custom CSS goes

**Theme Styler → CSS Overrides**, as LESS.
Admin → CMS → Themes → **MyTFH-2021** → Theme Styler → CSS Overrides

- It is compiled by **dotless**, so prefer LESS variables (`@tfh-*`) over CSS
  custom properties, and avoid `:has()` — emit a modifier class from the Lava
  instead.
- dotless evaluates `grid-column: 1 / -1` as arithmetic. Don't use it.
- Namespace everything under a feature prefix so an override cannot reach the
  rest of the site.

### Site-level head content

Admin → CMS → Sites → **MyTFH** → Page Header Content already loads Adobe Fonts:

```html
<script src="//use.typekit.net/dpm1txa.js"></script>
<script>try{Typekit.load();}catch(e){}</script>
```

The kit is **domain-scoped** — `my.tfh.org` must be listed in Adobe Fonts → Web
Projects or `neue-haas-grotesk-text` / `-display` silently fail to serve and
everything falls back to Helvetica.

If you ever add a `<link>` to a file under `/Themes/`, **bump `?v=` on every
change** — that path is served with a one-year max-age and Page Header Content
cannot fingerprint.

---

## Design System — my.tfh.org public

From the design handoff in `_reference-design-handoff/`. Smaller scale than
tfh.org; headings weight 500, body 400, headline copy in Title Case.

```less
@ink:        #000000;  // primary text, buttons, footer
@ink-2:      #707378;  // secondary text
@ink-off:    #A9AEB2;  // disabled ink
@panel:      #F1F1F1;  // cards, panels, pills
@track:      #E2E3E6;  // progress track, at-capacity pill, disabled ring
@rule:       #C3C8CC;  // hairline rules
@link:       #2D5BFF;  // links, arrow-button hover
@green:      #5D6F54;  // progress fill, low-capacity pill
@green-soft: #B1C1A9;  // available pill
@green-ink:  #21291F;  // ink on the soft green pill
```

| Element | Spec |
|---|---|
| H1 | 40px / 1 / 500 / −1.6px |
| H2 | 24px / 1.1 / 500 / −1px |
| Card date | 22px / 1.1 / 500 / −0.8px |
| Body | 18px / 1.4 / 400 / −0.6px |
| Small | 16px / 1 |

- **Radii** — 20px cards and panels, 8px medium buttons, 99999px pills
- **Spacing** — 8 / 10 / 12 / 16 / 20 / 24 / 32 / 40 / 64px; grid gaps 20px
- **Shadows** — none, anywhere
- **Page background** — pure white
- **Fonts** — `neue-haas-grotesk-text` 400/500; `neue-haas-grotesk-display` for eyebrows

---

## Rock Coding Rules

- **Block output** — HTML Content blocks strip `<html>/<head>/<body>`. Output fragments only.
- **No outer padding or margin** on a block's outermost wrapper, at any breakpoint.
  Rock already pads every block; a second gutter insets the content from
  everything else on the page. Spacing *between* inner elements is fine.
- **No vendor prefix on custom classes.** The `MyTFH-2021` theme is entirely
  our own code — there is no Spark-shipped stylesheet of ours to collide with —
  so classes are named for the feature (`.signup-card`, `.signup-opp`), not
  prefixed. This differs from `../rock-frontend`, which layers on Spark's
  internal theme and therefore does prefix `tfh-`.
  **Still check a new name before using it.** Bootstrap 3 and Rock core are in
  the cascade; grep the compiled `theme/Styles/theme.css` and `bootstrap.css`,
  which is where those class names actually appear.
- **Buttons: use native `btn btn-primary` / `btn btn-default`.** Do not write
  custom button styles, even when a mockup shows them — hover, focus and active
  states should come from the theme and match the rest of the site. A disabled
  action is `btn btn-default disabled`.
- **No inline styles**, except a value that genuinely comes from Lava
  (`style="width: {{ pct }}%"`, `background-image: url(...)`).
- **No `!important`** unless overriding a Rock style that cannot be targeted
  otherwise — comment why.
- **No ID selectors** — reserved for Rock/Lava block targeting.
- **No external JS frameworks or CDNs.** Rock already bundles jQuery, Bootstrap 3
  and Font Awesome.
- **Public pages take untrusted URL input.** Sanitise every page parameter in
  Lava *and* pass it to `{% sql %}` as a bound parameter. Never interpolate a
  parameter into a SQL body.

---

## Rock reference — IDs verified 2026-08-18

| Thing | Id |
|---|---|
| MyTFH site | 17 |
| Sign-up menu / group page | 3716 |
| Sign-up opportunity detail page | 3717 |
| Sign-Up Register page | 3718 |
| Interest List page (Connection Opportunity) | 3377 |
| Login page | 3436 |
| `Sign-Up Group` group type | 176 (`499B1367-06B3-4538-9D56-56D53F55DCB1`) |
| Root "Sign-Up Groups" group | 226249 |

**Routing gotcha:** `signup/{OpportunityId}` on page 3377 already occupies the
singular two-segment slot. Sign-up pages therefore use plural **`signups`**.
Two parameterised routes of the same shape on the same site cannot coexist —
one silently swallows the other.

**Route parameter naming:** `PageParameter` resolves route values *ahead of*
query-string values. Never name a route segment the same as a query parameter
a Rock block needs, or the route value shadows it and the block fails silently.

**Public URL slugs:** derived from the entity name, with no Id and no
admin-editable override — the URL is a pure function of data already in Rock.
Because that makes resolution a string match, **normalise in Lava, not SQL.**
SQL has no regex replace, so a SQL-side slug can only enumerate characters and
will always miss some; have SQL emit a raw slug and pipe it through the same
`RegExReplace:'[^a-z0-9-]',''` on *both* the generation and matching sides, so
they agree by construction. Matching a SQL-derived slug against a
Lava-sanitised inbound one is two different normalisations and silently breaks
links for any name containing punctuation. Two reasons: names collide (annual repeats, per-campus duplicates) and
would otherwise silently resolve to whichever row sorts first; and an inbound
URL segment must be sanitised to `[a-z0-9-]`, so any name-derived string
containing other characters — `(`, `?`, `#`, a curly apostrophe `’` — cannot
survive the round trip. Keep the name half cosmetic.

---

## Rock Sign-Up feature — verified constraints

Established against prod on 2026-08-18. These cost real work to discover.

- **Rock's Sign-Up blocks are opportunity-shaped, not group-shaped.** The Finder's
  `Projects` collection is one entry per group + location + schedule; Sign-Up
  Detail's `Project` is a single opportunity. Neither can render "one group with
  a list of its opportunities" at any level of Lava templating. The Finder's
  *markup* is fully replaceable — it's the data shape that rules it out.
- **Sign-Up Groups have no waitlist.** Every `%Wait%` column is on
  `Registration*` tables. At capacity means closed, full stop.
- **Rock's Sign-Up Register block requires `IdKey`, not integer ids** —
  `?ProjectId=<IdKey>&LocationId=<IdKey>&ScheduleId=<IdKey>` (note `ProjectId`,
  not `GroupId`). Raw integers are rejected. `IdKey` cannot be produced by SQL
  but is reachable from Lava:
  `{% schedule id:'3912' %}{{ schedule.IdKey }}{% endschedule %}`.
- **Capacity** is `GroupLocationScheduleConfig.MaximumCapacity` (nullable);
  **taken** is a count of `GroupMemberAssignment` rows. Members can be inactive,
  so decide explicitly whether to count all or active only.
- **Schedules are one-off** (no RRULE), but `Schedule.EffectiveStartDate` is a
  `date` with no time and there is no `NextStartDateTime` column. Parse the time
  out of `DTSTART` in `iCalendarContent`. `DTEND` is frequently `DTSTART + 1
  second`, meaning no real duration was set — suppress duration labels at 0.
- **Campus must be resolved by walking `Location.ParentLocationId` upward.** The
  rooms are child locations, so a direct `Campus.LocationId` join returns nothing
  and makes campus look unpopulated when it is not. `Group.CampusId` is null on
  most sign-up groups.
- **Location 14 (Vacaville Campus) maps to two Campus rows** — `Vacaville` (2)
  and the catch-all `Other` (23). Filtering campuses to **Type = Physical** and
  **Status = Open** excludes `Other` and resolves the ambiguity cleanly.
- **Rooms share names across campuses** — two locations are both "Discover Room"
  (36681 = East Bay, 36682 = Napa). Campus is a required disambiguator in any UI
  listing opportunities.

---

## File Structure

```
Pages/                          mirror of the live MyTFH page tree
  2439-mytfh-homepage/          site root; everything nests below it
    _page.md                    every block on the page: zone, name, type, id
    blocks/{id}-{name}.html     markup, byte-exact from Rock
    {childId}-{child-name}/     child pages, nested to match live
  _ACCESS-DENIALS.md            crawl permission log (currently zero denials)
theme/                          MyTFH-2021 theme, refreshed from serverfs
  Layouts/  Styles/  Assets/
_reference-design-handoff/      design prototype + spec. Reference only
_temporary-files/               scratch probes. Never pasted into Rock
```

289 pages to depth 7; 268 content files.

### What is and isn't in `Pages/`

Only **content-bearing** blocks have a file: HTML Content blocks in content
zones (Main, Feature, SectionA–C, Sidebar1/2). Chrome blocks — Footer, Header,
Login, Navigation — are **recorded in `_page.md` but not written to disk**,
because they are the same shared block instance repeated across dozens of
pages; writing them per-page would create duplicates that silently diverge.

Non-HTML-Content blocks (Workflow Entry, Registration, Page Menu, Login Status,
Redirect, Content Channel View) hold no markup and are recorded only. Many form
pages under `2550-other/2614-forms/` are pure Workflow Entry and therefore have
a `_page.md` but no `blocks/` at all — that is correct, not a gap.

Empty files are meaningful: the block exists in Rock and contains nothing. 25 of
the 268 are like this.

### Pulled files carry no source comment

The parent repo rule requiring a GitHub permalink comment applies to files
**authored here to be pasted into Rock**. Files in `Pages/` are pulls *from*
Rock and are byte-exact — adding a header would make the mirror lie. Add the
comment when you author something new, not when you sync.

### Block content versioning

Rock keeps version history on HTML Content blocks and Magnus exposes each
version as a separate node. Pulls take the **highest version number** and note
the count in `_page.md`. Rock renders the *approved* version, which is almost
always the latest but is not guaranteed to be — check `HtmlContent.IsApproved`
if a pulled file ever disagrees with what the page actually shows.

### Known quirks in live Rock, surfaced by the mirror

- Page **3750** "Group Resources - Copy" duplicates page 2824 with different
  block ids — a staging leftover, probably deletable in Rock.
- Page **2853** "Groups Communication Preferences" uses an older chrome block
  set (ids in the 300s) than every other page — never migrated.

---

## Reporting file changes (REQUIRED)

After updating any file, ALWAYS report which files were updated and include the
**full local path** to each — most of these get copied and pasted into Rock.
List every file touched, on every change.
