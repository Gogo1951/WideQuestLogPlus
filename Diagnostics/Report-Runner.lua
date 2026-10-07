local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Report Runner
--------------------------------------------------------------------------------

--[[
    Every report the panel runs, by id, and the tabs that group them. Each
    tab's Run All runs its reports in this order, and each report's own button
    runs just that one. The Event Log and the Taint Log are live tools rather
    than reports, so neither is here. The add-on ships no static game data, so
    there is no Data tab.

    note, where a report has one, turns its text into the few words its status
    row shows. API Endpoints has none on purpose: a [FAIL] on one half of a
    modern/legacy pair is the report working, so counting them would cry wolf.
]]
local D = ns.DiagnosticsStrings

local function EventsNote(text)
	local _, failures = string.gsub(text, "%[FAIL%]", "")
	if failures == 0 then
		return D.EVENTS_ALL_PASS
	end
	return string.format(D.EVENTS_SOME_FAIL, failures)
end

ns.DIAGNOSTIC_REPORTS = {
	questLog = {
		title = D.QUEST_LOG_CONTEXT_TITLE,
		description = D.QUEST_LOG_CONTEXT_DESCRIPTION,
		build = function()
			return ns:BuildQuestLogContextReport()
		end,
	},
	saved = {
		title = D.SAVED_TITLE,
		description = D.SAVED_DESCRIPTION,
		build = function()
			return ns:BuildSavedVariablesReport()
		end,
	},
	display = {
		title = D.DISPLAY_TITLE,
		description = D.DISPLAY_DESCRIPTION,
		build = function()
			return ns:BuildDisplayContextReport()
		end,
	},
	addons = {
		title = D.ADDONS_TITLE,
		description = D.ADDONS_DESCRIPTION,
		build = function()
			return ns:BuildAddOnReport()
		end,
	},
	events = {
		title = D.EVENTS_TITLE,
		description = D.EVENTS_DESCRIPTION,
		build = function()
			return ns:RunEventChecks()
		end,
		note = EventsNote,
	},
	api = {
		title = D.API_TITLE,
		description = D.API_DESCRIPTION,
		build = function()
			return ns:RunApiChecks()
		end,
	},
	libs = {
		title = D.LIBS_TITLE,
		description = D.LIBS_DESCRIPTION,
		build = function()
			return ns:BuildLibraryReport()
		end,
	},
}

ns.DIAGNOSTIC_SECTIONS = {
	{ key = "settings", label = D.SECTION_SETTINGS, reports = { "questLog", "saved", "display", "addons" } },
	{ key = "code", label = D.SECTION_CODE, reports = { "events", "api", "libs" } },
}

function ns:GetDiagnosticSection(key)
	for _, section in ipairs(ns.DIAGNOSTIC_SECTIONS) do
		if section.key == key then
			return section
		end
	end
	return nil
end

function ns:GetDiagnosticReportTitle(id)
	return ns.DIAGNOSTIC_REPORTS[id].title
end

-- A report's last state (waiting, running, done or stopped) and its note, or nil before it has ever run.
function ns:GetDiagnosticReportStatus(id)
	local status = ns.diagnostics.status[id]
	if not status then
		return nil
	end
	return status.state, status.note
end

local function SetStatus(id, state, note)
	ns.diagnostics.status[id] = { state = state, note = note }
end

local STATUS_LABELS = {
	waiting = D.STATUS_WAITING,
	running = D.STATUS_RUNNING,
	done = D.STATUS_DONE,
	stopped = D.STATUS_STOPPED,
}

function ns:GetDiagnosticStatusLabel(state)
	return STATUS_LABELS[state]
end

--[[
    Every report opens with the client header; a tab's box prints it once at
    the top and drops each report's own copy.
]]
local function StripHeader(text)
	local header = GetClientHeader()
	if string.sub(text, 1, #header) == header then
		return (string.gsub(string.sub(text, #header + 1), "^\n+", ""))
	end
	return text
end

local function AppendReportBlock(lines, run, id)
	local part = run.parts[id]
	if not part then
		return
	end
	lines[#lines + 1] = "---- " .. ns:GetDiagnosticReportTitle(id) .. " ----"
	lines[#lines + 1] = part.text
	lines[#lines + 1] = ""
end

-- A tab's box: the client header once, then one block per report that has finished.
local function Compose(run)
	local lines = { GetClientHeader(), "" }
	for _, id in ipairs(run.ids) do
		AppendReportBlock(lines, run, id)
	end
	return lines
end

local function NotifyPanel()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Diagnostics)
end

local function Publish(run)
	local lines = Compose(run)
	if run.stopped then
		lines[#lines + 1] = D.REPORT_STOPPED
	end
	ns.diagnostics.outputs[run.target] = table.concat(lines, "\n")
	NotifyPanel()
end

local function SetProgress(run, text)
	ns.diagnostics.progress = { target = run.target, text = text }
end

--[[
    One report at a time, a frame apart, so the panel repaints between them and
    a long run never stalls one frame. Every step checks the
    run's generation, so Stop, or the panel being switched off, ends the chain.
    A report that throws is written into the box as an error and the run goes
    on, so one broken report never costs the rest.
]]
local currentRun
local runGeneration = 0
local RunNext

local function Complete(run, id, text, note)
	run.parts[id] = { text = StripHeader(text) }
	SetStatus(id, "done", note)
	run.index = run.index + 1
	Publish(run)
	C_Timer.After(0, function()
		if run.generation == runGeneration then
			RunNext(run)
		end
	end)
end

function RunNext(run)
	local id = run.ids[run.index]
	if not id then
		currentRun = nil
		ns.diagnostics.running = nil
		SetProgress(run, #run.ids == 1 and D.PROGRESS_DONE_ONE or string.format(D.PROGRESS_DONE, #run.ids))
		Publish(run)
		return
	end

	SetStatus(id, "running")
	SetProgress(run, string.format(D.PROGRESS_RUNNING, run.index, #run.ids, ns:GetDiagnosticReportTitle(id)))
	NotifyPanel()

	local report = ns.DIAGNOSTIC_REPORTS[id]
	C_Timer.After(0, function()
		if run.generation ~= runGeneration then
			return
		end
		local ok, text = pcall(report.build)
		if not ok then
			Complete(run, id, string.format(D.REPORT_ERROR, tostring(text)), D.REPORT_ERROR_NOTE)
			return
		end
		Complete(run, id, text, report.note and report.note(text) or nil)
	end)
end

--[[
    target names the tab whose box the run writes to. One run at a time; the
    panel disables every run button while one is going.
]]
local function StartRun(target, ids)
	if currentRun or #ids == 0 then
		return
	end
	runGeneration = runGeneration + 1
	local run = { target = target, ids = ids, index = 1, parts = {}, generation = runGeneration }
	for _, id in ipairs(ids) do
		SetStatus(id, "waiting")
	end
	currentRun = run
	ns.diagnostics.running = target
	Publish(run)
	RunNext(run)
end

function ns:RunDiagnosticSection(key)
	local section = ns:GetDiagnosticSection(key)
	if section then
		StartRun(key, section.reports)
	end
end

function ns:RunDiagnosticReport(key, id)
	StartRun(key, { id })
end

-- Keeps every report that finished, marks the rest stopped, and says so at the foot of the box.
function ns:StopDiagnosticRun()
	local run = currentRun
	if not run then
		return
	end
	runGeneration = runGeneration + 1
	currentRun = nil
	ns.diagnostics.running = nil
	for _, id in ipairs(run.ids) do
		local status = ns.diagnostics.status[id]
		if status and (status.state == "waiting" or status.state == "running") then
			SetStatus(id, "stopped")
		end
	end
	run.stopped = true
	SetProgress(run, D.PROGRESS_STOPPED)
	Publish(run)
end
