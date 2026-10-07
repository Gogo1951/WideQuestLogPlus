# Wide Quest Log Plus // Notes

> The maintainer's settled rulings for Wide Quest Log Plus, kept so no review raises them again: exceptions to the Gogo1951 add-on Style Guide, and decisions it leaves open.

## Exceptions

### Author and community links

- **Departs from:** TOC FILE FORMAT, `## Author: Gogo1951`; TOC FILE FORMAT → Footer, the Discord line; OPTIONS PANEL → Main Page Layout, the Discord row; `References/Canonical Files/LICENSE.txt`, the copyright line.
- **Instead:** The author is StormtrooperTK421, `LICENSE` keeps its original copyright line, and the add-on lists no Discord link anywhere.
- **Why:** The add-on is StormtrooperTK421's and lives in their repo, so it carries their name rather than the Gogo1951 brand.

### CurseForge only

- **Departs from:** TOC FILE FORMAT → Release IDs, `## X-Wago-ID:`; OPTIONS PANEL → Main Page Layout, the Wago row.
- **Instead:** No TOC carries a Wago ID, and the options panel lists no Wago link.
- **Why:** The add-on is published on CurseForge alone and has no Wago project.

### Standalone CI and release workflows

- **Departs from:** COMMON-CORE, the shared files and reusable workflows.
- **Instead:** The repo carries its own complete CI and release workflows, started from Common-Core's, and calls nothing in Common-Core.
- **Why:** The repo belongs to another owner, so its build and release must not depend on a repo they don't control.

### Stock quest log icon

- **Departs from:** TOC FILE FORMAT, `IconTexture` pointing into `Includes/Images/`.
- **Instead:** Every TOC's `IconTexture` is Blizzard's quest log book icon, by file ID.
- **Why:** The add-on has no icon art of its own, and the stock quest log icon says what it is.

### Quest tag IDs in code

- **Departs from:** GAME NAMES, IDs living in the flavor folders.
- **Instead:** The quest tag IDs that pick the D, R, P, G and E letters stay in a table in `Features/Quest-Display.lua`.
- **Why:** They are fixed engine enum values, identical on every client, so a seven-folder data set would hold no information the code doesn't.

### Quest log settings on the General panel

- **Departs from:** OPTIONS PANEL → Main Page Layout, the root panel's sections; FILE STRUCTURE, `Options/Options-{Feature-Name}.lua`.
- **Instead:** The quest log's settings sit in a Quest Log section of the General panel, with no feature panel of their own.
- **Why:** The add-on has a single feature, so one panel is simpler for players than a second panel holding all of its settings.

### No Data tab in Diagnostic Tools

- **Departs from:** DIAGNOSTIC TOOLS → Layout, the Data tab; TOC FILE FORMAT → File Group Order, `Diagnostics/Validate-Data.lua`.
- **Instead:** While the add-on ships no static game data, Diagnostic Tools has no Data tab and no TOC loads the Validate Data report.
- **Why:** With no data files the tab would hold no rows, and an empty tab only confuses players.

## Decisions

- Wide Quest Log Plus has no row in the Gogo Add-ons master list, because it isn't a Gogo1951 add-on; the Prelaunch Review's master-list reconciliation doesn't apply to it.
- The Prelaunch Review checks the local `.pkgmeta`, `.luacheckrc` and `LICENSE` rather than GitHub's, because they reach GitHub only through PRs to the `forever` branch.
- Declined: carrying the pre-AceDB saved window height into AceDB; a one-time return to the default height is acceptable.
- Declined: carrying the pre-AceDB WoW Forever window position and quest log key choice into AceDB, because the build that saved them never reached players.
- The Enable Wide Quest Log for This Profile toggle takes effect at the next `/reload`, which the add-on offers when the Options window closes, so with it off the add-on leaves the quest log key and the world map entirely to Blizzard.
- `/wide` is the add-on's only slash command; resetting the window and switching the quest log key live in the options panel, and the quest log key opens the quest log.
- Declined: a mini-map button, because the quest log key and `/wide` already open the quest log and the options.
- The gap above each zone name is a single on/off toggle, off by default.
- Sorting works on every client; on Classic Era and TBC it redraws Blizzard's own rows in sorted order rather than replacing them, so the add-ons that hook those rows keep working.
- Zone order offers alphabetical by full name (the default, matching Blizzard's quest log) and average quest level, highest or lowest first; quest order offers level, lowest first (the default, matching Blizzard's) or highest first, or alphabetical. The add-on sorts to these itself on every client, so the labels hold on WoW Forever too.
- The options panel carries a WoW Forever-only Enable Wide Quest Log for This Profile toggle, on by default, under Enable Welcome Message; with it off, the whole Quest Log section is hidden. The Reset Size and Position button sits right-aligned, a quarter wider than a standard button for longer translations.
