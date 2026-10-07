# Wide Quest Log Plus // Manual Test Plan

This is the manual test plan for Wide Quest Log Plus, the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/DustinChecketts/WideQuestLogPlus/blob/forever/README.md); for how it works, see [README-Technical.md](https://github.com/DustinChecketts/WideQuestLogPlus/blob/forever/README-Technical.md).

## Before you start

**Run the whole list on each flavor in turn: Classic Era, WoW Forever, and TBC Anniversary.** Steps are numbered continuously so you can report "failed on step N."

Gather these once on each client so you aren't caught short mid-run:

- **A character with a well-stocked quest log**: at least eight quests spread over at least three zones, at a spread of levels. Among them you need one quest with a count objective (such as "kill 8"), one quest that is already complete, and one quest that rewards gold, experience and an item. A dungeon, group or elite quest is a bonus, since it shows the type letter.
- **A quest giver nearby** you can talk to, one with a quest to offer or to turn in.
- **Something to fight**, any open-world mob.
- **Questie, if you play with it, with its tracker on.** Step 6 uses it on every client. On WoW Forever the tracking steps must then follow Questie's tracker instead of Blizzard's; without Questie, they follow Blizzard's tracker.
- **A non-English client**, only for the optional last step.

No second player is needed, because the add-on never sends anything to other players. Unless a step says otherwise, be **out of combat**, standing in the open world. Settings changes take effect the next time the quest log opens, so after changing one, close the Options window and press the quest log key (`L` by default) to look.

This plan deliberately skips Share Quest (it needs a group), the greyed-out Track button for quests missing from Questie's database (there is no dependable quest to test it with), the Feedback & Support link boxes, the stock profile copy and delete controls, and every Diagnostic Tools report except Quest Log Context.

## Verify this release's changes

**One TOC per client**

**1.** At character select, open the **AddOns** list. Wide Quest Log Plus must appear **once**, spelled with spaces, with the quest log book icon beside it, and must not be flagged as out of date or incompatible. This closes the change that gave every client its own TOC and retired the shared one. Failure is the add-on missing, listed twice, still spelled `WideQuestLogPlus`, flagged out of date, or showing a blank square or question mark for its icon.

**Settings moved into the Options Interface**

**2.** Type `/wqlp`, then `/widequestlogplus`. Each must get the game's usual reply to a command it doesn't know, because both were retired in favor of `/wide` and the options panel. This closes the slash command change. Failure is the old help text printing, or the quest log changing size.

**3.** Log in. A line must print in the shape *"Wide Quest Log Plus // Version ... Settings (including the option to disable this message) can be found under Options > AddOns > Wide Quest Log Plus. Enjoying the add-on? Tell a friend about it! (="*. Type `/wide`, untick **Enable Welcome Message**, and type `/reload`: no line may print. Tick it again and `/reload`: the line must be back. This closes the new welcome message. Failure is no line, a line that ignores the toggle, or `nil`, `%s` or a raw key such as `CHAT_LOADED` in it.

**Sorting and zone spacing**

**4.** With **Zone Order** on **Alphabetical (Default)** and **Quest Order** on **Level, Lowest First (Default)**, open the quest log. Zones must run A to Z by full name (so a zone named "The ..." files under T), each zone's quests must run lowest level first, and there must be **no blank line** between zones, since the gap is now off by default. **On WoW Forever this is a change in the default, so watch it there: that client used to list highest level first.** Failure is any other order, or gaps between zones out of the box.

**5.** Tick **Space Above Zone Names** and open the quest log. A blank line must sit above every zone name except the first. Scroll to the very bottom: the last quest must still be reachable and fully visible. Untick it and reopen the log: the gaps must be gone, with no `/reload`. **On Classic Era and TBC Anniversary the gaps move Blizzard's own rows, so check there that no row is drawn on top of another or past the bottom edge.** Failure is gaps that ignore the toggle, a last quest you can't scroll to, or overlapping rows.

**6.** Track some quests and leave at least one untracked, then type `/wide`: **Mark Untracked Quests** must sit under **Quest Order**, with no line of text under it. Hover it: the tooltip must read "Tracked quests lose their checkmark, and untracked quests get an eye instead. Handy if you track almost everything.", with the teal check right after "checkmark" and the red eye right after "eye". Tick it and open the quest log. Tracked quests must show nothing in front of their name, and each untracked quest a red crossed-out eye in the same slot, with every title still lined up. Shift + Click an untracked quest: its eye must go and it must appear in your tracker. Untick the option: the teal checks must be back on the tracked quests and the eyes gone, with no `/reload`. **On Classic Era and TBC Anniversary the mark is drawn in Blizzard's own check, so scroll the list too and check that no row keeps the wrong mark.** With the option still ticked and Questie's tracker on, log out, log back in and open the quest log the moment you can: no row may flash a red eye. The marks may be missing for a few seconds, then must appear on only the untracked quests without you touching anything. Failure is a missing or blank-square icon (the game was not restarted after install), both marks or neither on a row, or a mark that ignores the toggle.

**7.** Set **Zone Order** to **Average Level, Highest First** and open the quest log. The zone whose quests average the highest level must sit at the top, and the rest must follow in falling order. Set it to **Average Level, Lowest First**: the order must flip. Then set **Quest Order** to **Level, Highest First**: within every zone, the highest-level quest must now come first. Set it to **Alphabetical**: within every zone, quests must run A to Z by name. Failure is zones still in A to Z order, a zone order that doesn't match the levels shown, a quest order setting that changes nothing, or quests moving into the wrong zone.

**8.** Leave **Quest Order** on **Alphabetical** and open the quest log. Click a quest that isn't first in its zone: the details pane must show **that** quest, and the highlight must sit on **that** row. With your chat box closed, Shift + Click a different, untracked quest: the tracking check must appear on **that** row, and that quest must appear in your tracker. Click a zone name: **that** zone must collapse. **This step matters most on Classic Era and TBC Anniversary, where sorting redraws Blizzard's own rows, so a row can show one quest while acting on another.** Failure is the details, highlight, check or collapse landing on a different quest or zone from the one you clicked.

**Reset Size and Position**

**9.** Open the quest log and drag the grip in its bottom-right corner to make it taller. On WoW Forever, also drag the window by its title bar to somewhere else on screen. Close the log and type `/wide`: **Reset Size and Position** must sit at the right, its right edge lined up with the dropdowns above, with its whole label inside the button. Click it, and accept the prompt *"Reset the quest log to its default size and position?"*. Reopen the log: it must be back to its default height, and on WoW Forever back at its starting place near the top-left of the screen. Failure is no prompt, or the window keeping its dragged size or place.

**Blizzard's quest log on WoW Forever**

**10.** On WoW Forever only, type `/wide`. **Enable Wide Quest Log for This Profile** must sit directly under **Enable Welcome Message**, ticked. Untick it: the whole **Quest Log** section, header through **Reset Size and Position**, must vanish at once. Close the Options window: a popup must offer to reload. Click **Reload UI**, then press `L`: Blizzard's quest list, docked in the world map, must open instead of the add-on's window, and the quest log button on the micro menu must do the same. Type `/wide`, tick it again, untick and re-tick it, and close the window: a popup must offer to reload only if the final state differs from the one you loaded with, so here it must appear. Reload and press `L`: the add-on's window must open again. Toggle it twice and close: no popup may appear. On Classic Era and TBC Anniversary the toggle **must not appear at all**, the Quest Log section must always show, and closing Options must never prompt. Failure is the toggle missing on WoW Forever or present on the other two, the section staying while it is off, a missing or unwanted popup, or `L` ignoring the setting after the reload.

**Profiles**

**11.** Set both orders away from their defaults, tick **Space Above Zone Names** and **Mark Untracked Quests**, untick **Enable Welcome Message**, and drag the quest log taller. Then open Options > AddOns > Wide Quest Log Plus > **Profiles** and click **Reset Profile**. Click back to the main panel: both orders must read **(Default)**, the gap and the untracked marks must be unticked, and the welcome message ticked, straight away with no `/reload`. Open the quest log: it must **keep** the taller size you dragged it to, because a profile reset never moves or resizes the window. Failure is any setting surviving the reset, stale values until a reload, or the window snapping back to its default size.

**Diagnostic Tools**

**12.** Open **Diagnostic Tools**, tick **Enable Diagnostic Tools**, open the **Settings** tab, and click **Run** beside **Quest Log Context**. The report's first line must end with `Flavor` and `Data`, each naming the client you are on: `Vanilla` on Classic Era, `Camelot` on WoW Forever, `TBC` on TBC Anniversary. The one exception is a Season of Discovery realm, which reads `Flavor Vanilla (Season of Discovery) // Data Discovery`. Below it, the zone order, quest order, zone spacing and welcome message must match what the main panel shows, and Questie, ElvUI and VoiceOver must each read `loaded` or `not loaded` correctly. This closes the new Diagnostic Tools panel. Failure is a Lua error, `nil` or another client's name in the header, or settings that don't match the panel.

When steps 1-12 pass on every flavor, this release's changes are verified. Proceed to `4 - Pre-Launch Review Prompt.md`.

## Core checks

**13.** Log in, then type `/reload`. Both times there must be no Lua error window and no red error text, and the welcome line from step 3 must print. Failure is any error naming Wide Quest Log Plus.

**14.** Type `/wide`. The settings must appear **docked inside the Blizzard Options window**, with Wide Quest Log Plus selected in the category list on the left. Failure looks like either nothing happening at all, or a standalone window floating free of the Options frame. **TBC Anniversary is the flavor that historically breaks this, so a tester who runs only Classic Era has not finished.**

**15.** Close the window, then press `Esc`, choose **Options**, then **AddOns**, and select **Wide Quest Log Plus**. The same docked panel must appear, with three entries under it in this order: **Wide Quest Log Plus**, **Profiles**, **Diagnostic Tools**. Each must open without error. The add-on has no mini-map button, so `/wide` and this list are every way in. Failure is a missing or blank entry, the wrong order, or a floating window, and again **TBC Anniversary is the flavor to watch**.

**16.** Pull a mob and, while still in combat, type `/wide`. Chat must print *"As a safety precaution, the Options Interface cannot be opened during combat."* and the panel must **not** open. Finish the fight and wait: the panel must not open by itself afterwards. Failure is the panel opening, silence, or a red `ADDON_ACTION_BLOCKED` error.

**17.** Press `L`. The quest log must open as one wide window: the quest list on the left and the selected quest's details on the right, with no seams or gaps in the parchment art. Every quest row must start with its level in brackets, such as `[14]`, with a letter after the level for a dungeon, raid, PvP, group or elite quest (`[14D]`, `[60R]`, `[30P]`, `[22G]`, `[56E]`). Your complete quest must say `(Complete)` at the right of its row, and tracked quests must show a check in front of their name. Close it and click the quest log button on the micro menu: the same window must open. **On WoW Forever, also press `M`: the world map must still show Blizzard's own quest list beside it.** Failure is a narrow, single-pane log, missing levels, titles running into their tags, or the micro menu button opening something else.

**18.** Select the quest with a count objective. Each objective must show a green check when done (and a blank of the same width when not, so names line up), with its count, such as `3 / 8`, lined up in a column on the right. Select the quest with gold, experience and an item: the gold and the experience must line up on the right in the same way, and the item must sit in the rewards. Under everything, at the bottom right, a smaller line must read `ID` and the quest's number. Failure is a count overlapping its objective's name, numbers running past the edge of the parchment, no quest ID, or a raw key such as `QUEST_ID`.

**19.** Open your chat box and Shift + Click a quest: a link to that quest must be placed in the chat box. Close the chat box and Shift + Click the same quest: it must toggle tracking, with the check in front of its name and your tracker both updating. Shift + Click it again to put it back. Failure is Shift + Click doing nothing, toggling tracking while the chat box is open, or the check and the tracker disagreeing.

**20.** Hover the grip in the quest log's bottom-right corner: a tooltip must read *"Drag to resize the quest log"*. Drag it down: the window must grow in whole rows, the list must show more quests, and the art must stretch with no seams. Close the log, type `/reload`, and reopen it: it must open at the height you dragged it to. Failure is the art tearing, the list not growing, or the height forgotten after the reload.

**21.** On WoW Forever only, drag the quest log by its title bar to a new place, type `/reload`, and reopen it: it must open where you left it. Press `Esc`: it must close. Collapse the zone of a tracked quest, close the log, and click that quest in your objective tracker (or in Questie's tracker): the log must open with the zone reopened and that quest selected and scrolled into view. **WoW Forever is the only client where the add-on builds its own window, so these paths exist nowhere else.** Failure is a forgotten position, `Esc` not closing it, or a tracker click opening the world map or the wrong quest.

**22.** Open the quest log, then talk to the quest giver so its window opens beside it. The quest giver window must show its text and rewards exactly as normal, and must not go blank. Close it: the quest log's details must come back on their own. **This step matters most on WoW Forever, where the quest giver window and the quest log draw their details with the same pieces.** Failure is a blank or garbled quest giver window, rewards shifted out of place there, or a quest log that stays blank afterwards.

**23.** Pull a mob and, while in combat, press `L`, click a quest, Shift + Click it to toggle tracking, and close the log. Everything must work exactly as out of combat. **On WoW Forever, where the add-on takes over the quest log key, also click a quest in your tracker during the fight.** Failure is the log refusing to open, a red `ADDON_ACTION_BLOCKED` error, or a Lua error.

**24.** Type `/reload`, then open **Diagnostic Tools**. **Enable Diagnostic Tools** must be **off**, even though you ticked it in step 12, with only the warning paragraph and the toggle visible. Failure is the toggle still on, or the tabs showing while it is off.

**25.** Optional, on a non-English client. Log in: the welcome line must print in that language. Type `/wide`: every label and tooltip must render in that language. Open the quest log: type letters may be translated, and the quest ID line must show a real number. Failure is a raw key such as `ZONE_ORDER` on screen, `nil` or a stray `%s` or `%d` anywhere, or text that runs off the panel.

When every step passes on each of Classic Era, WoW Forever, and TBC Anniversary, manual testing is complete. Proceed to `4 - Pre-Launch Review Prompt.md`.
