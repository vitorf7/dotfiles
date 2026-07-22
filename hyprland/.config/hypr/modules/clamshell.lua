-- Clamshell mode: disable/enable the internal monitor on lid close/open.
--
-- When the monitor state changes, Hyprland fires monitor.added / monitor.removed,
-- which triggers assign_workspaces() in monitors.lua automatically.
-- The hl.timer call below is a safety net in case the monitor event is delayed.

local monitor_manager = require("modules.monitor_manager")

-- Must match the hl.monitor() definition in monitors.lua exactly.
local EDPS_ON = "eDP-1,1920x1080@60,3840x0,1"

-- Lid close: disable internal display.
hl.bind("switch:on:Lid Switch", function()
	hl.exec_cmd("hyprctl keyword monitor eDP-1,disable")
	hl.timer(monitor_manager.assign_workspaces, { timeout = 600, type = "oneshot" })
end, { locked = true })

-- Lid open: re-enable internal display.
hl.bind("switch:off:Lid Switch", function()
	hl.exec_cmd("hyprctl keyword monitor " .. EDPS_ON)
	hl.timer(monitor_manager.assign_workspaces, { timeout = 600, type = "oneshot" })
end, { locked = true })
