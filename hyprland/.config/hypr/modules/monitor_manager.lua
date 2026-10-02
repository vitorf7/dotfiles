-- Workspace assignment logic for all monitor configurations.
--
-- Scenarios handled (derived from monitors present at runtime):
--
--   internal only              → WS 1-10 on internal
--   internal + LG              → WS 1-5 on LG,   6-10 on internal
--   internal + Dell            → WS 1-5 on Dell, 6-10 on internal
--   internal + LG + Dell       → WS 1-5 on LG,  6-9 on Dell,  10 on internal
--   LG only (clamshell)        → WS 1-10 on LG
--   Dell only (clamshell)      → WS 1-10 on Dell
--   LG + Dell (clamshell)      → WS 1-5 on LG,  6-10 on Dell
--   internal + office          → WS 1-5 on office, 6-10 on internal
--   office only (clamshell)    → WS 1-10 on office
--
-- Additionally, each monitor's FOCUSED workspace is kept within its assigned
-- range: Hyprland auto-creates a fresh workspace (e.g. 11) on a monitor that
-- comes online without one, so out-of-range focus gets snapped to the first
-- workspace of the monitor's range (LG → 1, Dell → 6, internal → 6/10).

-- ── Helpers ───────────────────────────────────────────────────────────────────

-- TODO: replace OFFICE_MODEL with the actual description substring from
-- `hyprctl monitors all` once connected at the office (see find_monitors).
local OFFICE_DESC = "OFFICE_MODEL"

local function find_monitors()
	local internal, lg, dell, office
	for _, m in ipairs(hl.get_monitors()) do
		if m.disabled then goto continue end  -- skip disabled monitors (e.g. eDP-1 in clamshell)
		if     m.name == "eDP-1"               then internal = m
		elseif m.description:find("27GL650F")  then lg       = m
		elseif m.description:find("U2419HC")   then dell     = m
		elseif m.description:find(OFFICE_DESC) then office   = m
		end
		::continue::
	end
	return internal, lg, dell, office
end

local function move_workspace(ws, mon_name)
	-- Set the default monitor for this workspace (applies to unvisited workspaces too).
	hl.workspace_rule({ workspace = tostring(ws), monitor = mon_name })
	-- Move the workspace to the correct monitor if it already exists (has windows).
	hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(ws), monitor = mon_name }))
end

local function assign(first, last, mon_name)
	for ws = first, last do
		move_workspace(ws, mon_name)
	end
end

-- Keep each monitor's FOCUSED workspace within its assigned range.
--
-- Hyprland auto-creates a workspace with the next free ID (e.g. 11) on any
-- monitor that comes online without one, and moving workspaces 6-9 to the
-- Dell afterwards does not change what the Dell is *showing*. If the active
-- workspace is out of range, snap the monitor to the first workspace of its
-- range; if it is in range, leave it (mid-session focus is preserved).
local function ensure_focus(mon, first, last)
	local ws = hl.get_active_workspace(mon)
	if ws and ws.id >= first and ws.id <= last then return end
	hl.dispatch(hl.dsp.focus({ monitor = mon.name }))
	hl.dispatch(hl.dsp.focus({ workspace = tostring(first) }))
end

-- ── Public ────────────────────────────────────────────────────────────────────

local M = {}

function M.assign_workspaces()
	local internal, lg, dell, office = find_monitors()

	-- Remember which monitor is active so the correction below does not
	-- steal the cursor on a mid-session plug/unplug.
	local prev = hl.get_active_monitor()

	if     internal and not lg  and not dell and not office then
		assign(1, 10, internal.name)
		ensure_focus(internal, 1, 10)

	elseif internal and lg      and not dell and not office then
		assign(1, 5,  lg.name)
		assign(6, 10, internal.name)
		ensure_focus(lg,       1, 5)
		ensure_focus(internal, 6, 10)

	elseif internal and dell    and not lg   and not office then
		assign(1, 5,  dell.name)
		assign(6, 10, internal.name)
		ensure_focus(dell,     1, 5)
		ensure_focus(internal, 6, 10)

	elseif internal and lg      and dell     and not office then
		assign(1, 5,  lg.name)
		assign(6, 9,  dell.name)
		move_workspace(10, internal.name)
		ensure_focus(lg,       1, 5)
		ensure_focus(dell,     6, 9)
		ensure_focus(internal, 10, 10)

	elseif internal and office  and not lg   and not dell   then
		assign(1, 5,  office.name)
		assign(6, 10, internal.name)
		ensure_focus(office,    1, 5)
		ensure_focus(internal,  6, 10)

	elseif office and not internal and not lg  and not dell then
		assign(1, 10, office.name)
		ensure_focus(office, 1, 10)

	elseif lg   and not internal and not dell and not office then
		assign(1, 10, lg.name)
		ensure_focus(lg, 1, 10)

	elseif dell and not internal and not lg   and not office then
		assign(1, 10, dell.name)
		ensure_focus(dell, 1, 10)

	elseif lg   and dell and not internal     and not office then
		assign(1, 5,  lg.name)
		assign(6, 10, dell.name)
		ensure_focus(lg,   1, 5)
		ensure_focus(dell, 6, 10)
	end

	-- Restore the previously active monitor (it may have been re-focused
	-- by an ensure_focus correction above).
	if prev and hl.get_monitor(prev.name) then
		hl.dispatch(hl.dsp.focus({ monitor = prev.name }))
	end
end

-- ── Event registration ────────────────────────────────────────────────────────

hl.on("hyprland.start",  M.assign_workspaces)
hl.on("monitor.added",   M.assign_workspaces)
hl.on("monitor.removed", M.assign_workspaces)

return M
