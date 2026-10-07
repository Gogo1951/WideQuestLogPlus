# Wide Quest Log Plus // Technical Reference

This document combines architecture notes and contribution guidance for developers working on Wide Quest Log Plus. For end-user documentation, see [README.md](https://github.com/DustinChecketts/WideQuestLogPlus/blob/forever/README.md).

## File Map

```
WideQuestLogPlus/
├── .github/
│   ├── dependabot.yml                 Keeps the pinned actions current
│   └── workflows/
│       ├── ci.yml                     Standalone CI: externals, Lua 5.1 syntax, luacheck, StyLua
│       └── package.yml                Standalone release: a tag builds the zip from forever and uploads it
├── .gitattributes
├── .gitignore
├── .luacheckrc
├── .pkgmeta                           Ace3 externals and the zip's ignore list
├── WideQuestLogPlus_Vanilla.toc       Classic Era, Season of Discovery included
├── WideQuestLogPlus_TBC.toc           TBC Anniversary
├── WideQuestLogPlus_Camelot.toc       WoW Forever
├── Data/                              No flavor folders, since the add-on ships no static game data
│   ├── Flavor.lua                     Canonical flavor identity, copied byte for byte
│   ├── Data.lua                       Locale, palette, registry names, URLs, ns.LAYOUT geometry, tracking marks
│   └── Default-Settings.lua           AceDB defaults
├── Diagnostics/                       Diagnostic Tools from Magic Eraser, with no Data tab
│   └── Manifests.lua                  Per-client API checks and the Quest Log Context probe
├── Features/
│   ├── Core.lua                       Version, event dispatcher, AceDB, welcome
│   ├── Utilities.lua                  Colors, Questie module lookup, sorting
│   ├── Announcements.lua              ns:PrintMessage
│   ├── Quest-Display.lua              Quest title text, tracking mark, quest ID, objective lines
│   ├── Window.lua                     Window art, height clamp and resize grip, both quest logs
│   ├── Classic-Quest-List.lua         Classic Era and TBC: list rows, sorting, zone gaps, VoiceOver
│   ├── Classic-Quest-Details.lua      Classic Era and TBC: detail pane layout, objectives, rewards, quest ID
│   ├── Classic-Quest-Log.lua          Classic Era and TBC: widens Blizzard's window, art, resizing
│   ├── Forever-Tracking.lua           WoW Forever: tracking, deferring to Questie's tracker
│   ├── Forever-Quest-Log.lua          WoW Forever: window, buttons, refresh, quest log takeover
│   ├── Forever-Quest-List.lua         WoW Forever: list rows and sorting
│   └── Forever-Quest-Details.lua      WoW Forever: detail pane on QuestInfo_Display
├── Includes/
│   ├── Images/                        Window art (WQLP_*.blp), untracked quest mark (WQLP_Untracked.tga)
│   └── Libraries/                     Vendored Ace3, never edited
├── Locales/
│   ├── enUS.lua                       Source of truth
│   └── {langCode}.lua                 The other ten supported locales
├── Options/
│   ├── Options-Utilities.lua
│   ├── Options-General.lua            Root panel
│   ├── Options-Forever-Quest-Log.lua  WoW Forever: wide quest log toggle and reload prompt, merged into General
│   ├── Options-Profiles.lua           Stock AceDBOptions
│   └── Options.lua                    Registration, opener, /wide
├── LICENSE
├── README.md
├── README-Notes.md
├── README-Technical.md
└── README-Testing.md                  Manual test plan
```

The unsuffixed `WideQuestLogPlus.toc` and the root-level `Legacy.lua`, `Modern.lua`, `Common.lua`, `Layout.lua` and `img/` are retired. Don't bring them back: their code lives in `Features/` and their art in `Includes/Images/`.

## Architecture

### Two Quest Logs, One Layout

Classic Era and TBC still ship Blizzard's classic `QuestLogFrame`, so the three `Features/Classic-*.lua` files widen it in place. They move Blizzard's own regions and rows, swap the art, and hook `QuestLog_Update` and `QuestLog_SetSelection` (the list file) and `QuestLog_UpdateQuestDetails` and `QuestFrameItems_Update` (the details file) to restyle what Blizzard just drew; `Classic-Quest-Log.lua` owns the window itself, its art and resizing. WoW Forever runs the Retail engine, which replaced that frame with a list docked in the world map, so there is nothing to widen. The four `Features/Forever-*.lua` files build a window of their own instead. Each client's TOC lists only its own files, so neither side checks which client it is on.

Both share `ns.LAYOUT` (`Data/Data.lua`) and `Features/Window.lua`, which is why the two look the same. The detail pane's text column is exactly two columns of reward buttons wide (147 + 1 + 147px), because reward buttons can't shrink. The window grows by `EXTRA_WIDTH`, whatever that column plus its margins needs beyond the classic parchment, and the art fills the difference with a strip cut from the last pixels of the middle piece, so both seams continue the art on either side. Numbers in the details (objective counts, gold, experience, the quest ID) end two spaces inside the column (`ns.TwoSpacesWide`), because body text wraps short of the edge and a number flush against it looks like it runs past.

### Event Loop

`Features/Core.lua` owns the only event frame. Its `EVENTS` table pairs every event the add-on can handle with a handler name. An event is registered only once a loaded file defines that handler, so Classic, whose quest log works purely through hooks, registers just `ADDON_LOADED` and `PLAYER_LOGIN`. What was registered is exported as `ns.EVENT_NAMES` for Diagnostics.

On WoW Forever every quest event funnels into `ns.RequestUpdate()`, which repaints at most once a frame and only while the window is open, because `QUEST_LOG_UPDATE` arrives in bursts. `PLAYER_LEVEL_UP` is there because the difficulty colors change with the player's level. `GROUP_ROSTER_UPDATE` refreshes only the bottom buttons, because Share is enabled only in a group. A hook on Questie's tracker `Update`, and the `OnHide` of each window that borrows the quest detail elements, request the same repaint.

### Combat Lockdown

The options opener refuses during combat: it prints the mandated message and returns, never queues. Nothing else defers. The WoW Forever window is the add-on's own unprotected frame, and Classic's quest log, its scroll bar and the panel manager's positioning of it are unprotected, so both quest logs work in combat.

## Taint

Classic only hooks Blizzard's functions, but three things it does are seen by Blizzard's code as coming from an add-on:

- The window's new size goes to the panel manager through `SetUIPanelAttribute`, the interface Blizzard provides for this, rather than by replacing the `UIPanelWindows` entry.
- A taller window needs more list rows, so `QUESTS_DISPLAYED` (read by `QuestLog_Update`) is raised, the extra rows are created here, and `QuestLog_Update` runs when the row count changes.
- The zone gaps move Blizzard's list rows and widen the list's scroll range through `FauxScrollFrame_Update`.

None of it reaches anything protected on those clients.

On WoW Forever, Blizzard's code sees three things:

- `ToggleQuestLog` and `QuestMapFrame_OpenToQuestDetails` are replaced at load, but only when `enableWideQuestLog` is on; with it off, Blizzard's are never touched, so the world map never opens through add-on code. Flipping `enableWideQuestLog` applies at the next `/reload`: when the Options window closes with the profile's value differing from the load-time takeover, a popup offers the reload. Their callers (the key binding, the micro menu button, and a click on a quest in the objective tracker) call them last thing, so the taint goes no further than that one keypress or click. A quest that isn't in the log still goes to Blizzard's original.
- `QuestInfo_Display` is Blizzard's detail renderer, shared with the quest giver window and the map's details, so the add-on calls it only while neither of those is using it (`QuestInfoInUseElsewhere`). Each caller sets up everything it reads, so nothing carries over. A `hooksecurefunc` on it puts the shared objective lines and reward positions back Blizzard's way after anyone else uses them.
- The window's name goes in `UISpecialFrames`, so Escape closes it. Blizzard reads that list through `securecall`.

## Questie Tracking

### WoW Forever

Questie's tracker keeps its own list of tracked quests and only learns about new ones through `C_QuestLog.AddQuestWatch`. The client's automatic watch on accepting a quest bypasses that, so a quest can be watched by Blizzard yet missing from Questie's tracker. Questie's tracker also shows only quests in its database, which much of WoW Forever's new content isn't yet.

So while Questie's tracker is enabled, `Features/Forever-Tracking.lua` counts a quest as tracked only if Questie's tracker shows it. Tracking calls `AddQuestWatch` even when Blizzard already has the watch, since that call is what tells Questie. Untracking goes through Questie when Blizzard has no watch to remove. A quest Questie can't show is refused, with a one-time chat explanation per quest and a tooltip on the greyed-out Track button. Untracking from Questie's own menu doesn't always touch Blizzard's watch list, which is why the window also repaints on Questie's tracker updates.

### Before Questie's Tracker Starts (Every Client)

Questie starts its tracker a few seconds after login, partway through its staged startup. Until then nothing reads as tracked: on WoW Forever Questie's quest list is still empty, and on Classic Era and TBC Anniversary Questie keeps no Blizzard watches and only later replaces `IsQuestWatched` with its own. With Mark Untracked Quests on, that would flash a red eye on every quest. So `ns.ShowTrackingMark` (`Features/Quest-Display.lua`) draws no marks while Questie's tracker is enabled but not yet `started`, and hooks `QuestieTracker:HookBaseTracker`, which Questie calls as the tracker starts, to redraw the quest log.

## Sorting

Both quest logs sort with the same rules in `Features/Utilities.lua`: zones by `zoneSort` (alphabetical by full name, the default, or average quest level either way) and quests within each zone by `questSort` (level, lowest first by default, or highest first, or alphabetical). Ties fall back to the quest log's own order. The defaults match how Blizzard's Classic quest log lists them, and the add-on sorts to them itself so they hold on WoW Forever too. `ns.SortZones` freezes the zone order when the window opens, so turning in or dropping a quest doesn't reshuffle zones under the cursor; closing the window, or changing a setting, clears it.

On WoW Forever, `BuildEntries` in `Features/Forever-Quest-List.lua` feeds the sorted entries to the add-on's own list, with the same visibility rules as the map's quest list. The first time the window opens in a session, `ns.ExpandAllZones` opens every zone, so collapsing one lasts only until the next login or reload.

On Classic Era and TBC the rows are Blizzard's. `QuestLog_Update` fills row *i* with quest log entry *i* + scroll offset, and every row handler (click, shift-click track and link, collapse, the party tooltip) finds its entry from the row's ID plus that offset. So after Blizzard draws, `Features/Classic-Quest-List.lua` redraws each row with the entry at its sorted place, the way `QuestLog_Update` would, and sets the row's ID to match. Selecting a quest highlights its row by place in the list, so the highlight is moved again after `QuestLog_SetSelection`. A collapsed zone lists no quests, so it sorts by its average from when it was last seen open, or after the rest when it hasn't been. When the sorted order is the quest log's own, which it is at the defaults, nothing is redrawn.

## ElvUI and VoiceOver (Classic Era and TBC)

Both work on Blizzard's own quest log frames, so the Classic files make room for them rather than replacing what they draw.

- **ElvUI** skins the window but can't know about this add-on's art. With ElvUI loaded, `Features/Classic-Quest-Log.lua` hides Blizzard's art and the "no active quests" parchment and draws none of its own, leaving the skin's backdrop.
- **VoiceOver** puts a play button over the start of each quest title. With it loaded, each title starts with as many spaces as clear 24px (spaces only, since a tab draws as a missing glyph in some fonts, ElvUI's among them).
- VoiceOver hands out its buttons by Blizzard's order, row *i* to entry *i* + scroll offset. With sorting on, `MatchVoiceOverButtons` deals them out again by what each row now shows, through VoiceOver's own button functions. Those functions rewrite the title and move the check, so the row styling runs last, and `UpdateList` also hooks VoiceOver's overlay `Update`, which can run after the `QuestLog_Update` hook.

## Resizing

The grip in the bottom-right corner (`ns.CreateResizeGrip`, `Features/Window.lua`) drags the window taller. `ns.ClampHeight` snaps the height to whole list rows, never below the default height and never closer than `MINIMUM_BOTTOM_CLAMP` to the bottom of the screen. The height is saved when the drag ends. It is applied every time the window opens, not at load, because the screen size and UI scale aren't settled at load and the clamp would cut it short. The clamped value is never written back, so a smaller screen shrinks the window, not the setting. Only the plain lower half of each upper art piece stretches; the top half carries the border and keeps its proportions.

On Classic the window belongs to Blizzard's panel manager, which keeps a 152px clamp below it to clear the action bars. `ApplyHeight` trades that clamp away a pixel for every pixel of extra height, down to `MINIMUM_BOTTOM_CLAMP`, because at a normal UI scale there's no other room to grow. It tells the panel manager the new height and clamp each time, or the manager scales the whole window down to fit the space it thinks the window needs. Under ElvUI the grip follows the skin's inset backdrop rather than the frame's own corner.

On WoW Forever the window is the add-on's own, so it also moves: dragging its title bar saves its position.

## Saved Variables

`WideQuestLogPlusDB`, managed by AceDB-3.0, is the only SavedVariables table and holds every setting. The add-on uses the **Simple** model: one shared Default profile, so Reset Profile restores every option on the profile.

The profile holds the options panel's settings. `global` holds only the window's saved height, and on WoW Forever its position, with no defaults. They are presentation, kept out of the profile's reach so a profile reset or switch never moves or resizes the window; the General panel's Reset Size and Position button clears them. Classic saves no position, since Blizzard's panel manager places that window.

AceDB applies `ns.DATABASE_DEFAULTS` (`Data/Default-Settings.lua`) whenever a key is missing, and handles an explicit `false` correctly. No default lists are seeded.

### Migration Chain

- **Pre-AceDB keys** (`Features/Core.lua`, `ns:OnAddonLoaded`, remove after 2026-11-06): before `AceDB:New`, nils the old top-level `height`, `point` and `useMap`, which nothing reads. The old height is deliberately not carried over.

## Adding a New Setting

1. Add the key and its default to `ns.DATABASE_DEFAULTS.profile` in `Data/Default-Settings.lua`. Only window state that a profile reset must not touch goes in `global`.
2. Add its control to `Options/Options-General.lua`, or to `Options/Options-Forever-Quest-Log.lua` when it only applies on WoW Forever, with its label and `desc` in `Locales/enUS.lua`. A control in the Quest Log section takes `hidden = questLogHidden`, so the section goes as a whole when the wide quest log is off on WoW Forever.
3. Read it live where it applies. If it changes what's on screen, call `ns.RefreshQuestLog()` from the control's `set`; `ns:ApplyProfile` already calls it on profile changes.
4. Add it to the Quest Log Context report in `Diagnostics/Manifests.lua`.

## Adding a New Event

Add `{ "EVENT_NAME", "OnEventName" }` to `EVENTS` in `Features/Core.lua` and define `ns:OnEventName` in the feature file that needs it. Core registers it on the clients whose files define the handler, and Diagnostics picks it up from `ns.EVENT_NAMES`.

## Adding a New API Call

1. Confirm the client has it: its branch of [wow-ui-source](https://github.com/Gethe/wow-ui-source), or an existing Diagnostics row. Don't gate on a client difference nobody has shown.
2. Add its path to `SHARED_FUNCTIONS`, `CLASSIC_FUNCTIONS` or `FOREVER_FUNCTIONS` in `Diagnostics/Manifests.lua` (tables, strings and numbers have their own `Rows` lines there).
3. Add the global to `read_globals` in `.luacheckrc`.

## Localization

- **`enUS.lua` is the source of truth** and the only locale passing the default-fallback flag. The other locale files belong to the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`); never hand-edit them.
- **Placeholders** (`%s`, `%d`) must match `enUS` in count, type and order in every locale, or the string errors at runtime.
- **Game names never go in `Locales/`.** Zone names come from the quest log headers the client supplies. The tag at the right of a row (Elite, Dungeon) comes from the client's quest tag, or from Blizzard's `FAILED`, `COMPLETE`, `ELITE` and `DAILY`. Window labels such as Abandon Quest, Track, Share, Exit and All are Blizzard's GlobalStrings too. The quest-type letters (D, R, P, G, E) are the add-on's own words, so they are locale keys, picked by `QUEST_TAG_SUFFIX` in `Features/Quest-Display.lua` from the tag ID that `GetQuestTagInfo` (Classic) or `C_QuestLog.GetQuestTagInfo` (WoW Forever) returns.

## Common Pitfalls

- **Reading `ns.db` at file scope**: it doesn't exist until `ADDON_LOADED`, and Blizzard can redraw the Classic quest log before then. Read settings at use (the Classic sorting and gap code checks `ns.db` first), or in `ns:OnDatabaseReady` on WoW Forever.
- **Calling `QuestInfo_Display` while the quest giver window is open**: blanks it mid turn-in. Go through `ns.DisplayQuestDetails`, which checks `QuestInfoInUseElsewhere`.
- **Editing `QUEST_TEMPLATE_LOG` in place**: changes Blizzard's own quest detail panes. `LOG_TEMPLATE` is a `CopyTable` of it; change the copy.
- **Restyling every `QuestFrameItems_Update`**: the quest giver window lays out its rewards through it too. The hook acts only when `questState` is `"QuestLog"`.
- **Forgetting to re-anchor Classic rows**: `PositionRows` moved them for the zone gaps, and `QuestLog_Update` doesn't put them back. Every pass re-anchors every row, gap or not.
- **Re-entering `QuestLog_Update`**: widening the scroll range can scroll the list, which runs `QuestLog_Update` again. `extendingScroll` guards `ExtendScrollRange`.
- **Resizing Classic's window without telling the panel manager**: it scales the whole window down. `ApplyHeight` always sets the `height` and `bottomClampOverride` panel attributes with the frame's height.
- **Applying the saved height at load**: the screen isn't settled, so the clamp cuts it short. Apply it in `OnShow`, and never save the clamped value.
- **Matching Blizzard's art by file path**: current clients return nil from `GetTextureFilePath` for XML textures. `IdentifyBlizzardArt` checks the file ID first.
- **Leaving sort ties to `table.sort`**: it isn't stable, so equal rows swap between repaints. Every comparator ends on `sortIndex`.
- **Registering an event a client lacks**: throws. Add events through `EVENTS` in Core, never `RegisterEvent` in a feature file.

## Contributing

- **Issues**: [GitHub Issues](https://github.com/DustinChecketts/WideQuestLogPlus/issues).
- **Bug reports**: game client and version, locale, the character's class and level, which other quest add-ons are installed (Questie, ElvUI, VoiceOver), steps to reproduce, and the Diagnostic Tools' Quest Log Context and Display Context reports (plus the Event Log when the quest log didn't update).
- **PR guidelines**: keep each PR to one change; run `stylua --syntax lua51`, `luac -p` and `luacheck .` before pushing (CI runs all three). Any change to the shape of saved data ships its own migration, tagged `MIGRATION (remove after YYYY-MM-DD)` 30 days past its release. The add-on sends no chat and writes no macros, so the 255-byte limits don't apply yet; a change that starts sending chat measures in bytes against ruRU. Update this document if the architecture, File Map or Saved Variables change.
- **PR descriptions say what a player will notice**, in plain language, the way release notes do; commit messages carry the developer detail.
