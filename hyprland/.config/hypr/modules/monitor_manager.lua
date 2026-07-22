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

-- ── Helpers ───────────────────────────────────────────────────────────────────

local function find_monitors()
	local internal, lg, dell
	for _, m in ipairs(hl.get_monitors()) do
		if     m.name == "eDP-1"              then internal = m
		elseif m.description:find("27GL650F") then lg       = m
		elseif m.description:find("U2419HC")  then dell     = m
		end
	end
	return internal, lg, dell
end

local function move_workspace(ws, mon_name)
	-- Set workspace rule so unvisited workspaces land on the right monitor
	hl.exec_cmd(("hyprctl keyword workspace '%d, monitor:%s'"):format(ws, mon_name))
	-- Move the workspace if it already exists (has windows)
	hl.exec_cmd(("hyprctl dispatch moveworkspacetomonitor %d %s"):format(ws, mon_name))
end

local function assign(first, last, mon_name)
	for ws = first, last do
		move_workspace(ws, mon_name)
	end
end

-- ── Public ────────────────────────────────────────────────────────────────────

local M = {}

function M.assign_workspaces()
	local internal, lg, dell = find_monitors()

	if     internal and not lg  and not dell then
		assign(1, 10, internal.name)

	elseif internal and lg      and not dell then
		assign(1, 5,  lg.name)
		assign(6, 10, internal.name)

	elseif internal and dell    and not lg   then
		assign(1, 5,  dell.name)
		assign(6, 10, internal.name)

	elseif internal and lg      and dell     then
		assign(1, 5,  lg.name)
		assign(6, 9,  dell.name)
		move_workspace(10, internal.name)

	elseif lg   and not internal and not dell then
		assign(1, 10, lg.name)

	elseif dell and not internal and not lg   then
		assign(1, 10, dell.name)

	elseif lg   and dell and not internal     then
		assign(1, 5,  lg.name)
		assign(6, 10, dell.name)
	end
end

-- ── Event registration ────────────────────────────────────────────────────────

hl.on("hyprland.start",  M.assign_workspaces)
hl.on("monitor.added",   M.assign_workspaces)
hl.on("monitor.removed", M.assign_workspaces)

return M
