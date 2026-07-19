-- Clamshell mode: handle lid open/close events in pure Lua.
--
-- The two separate switch:on / switch:off binds already encode the lid state,
-- so there is no need to read /proc/acpi/button/lid/LID0/state as the old
-- shell script did.
--
-- Dynamic monitor enable/disable and runtime workspace rule changes do not yet
-- have a pure Lua API equivalent, so those remain as os.execute("hyprctl ...")
-- calls — but all logic, constants, and control flow live here in Lua.

local DELL_MONITOR = "desc:Dell Inc. DELL U2419HC"
local EDP_MONITOR  = "eDP-1"

local function on_lid_close()
    -- Disable internal display
    os.execute('hyprctl keyword monitor "eDP-1, disable"')
    -- Reassign workspace 10 to Dell so it is accessible while the lid is shut
    os.execute('hyprctl keyword workspace "10, monitor:' .. DELL_MONITOR .. '"')
    os.execute('hyprctl dispatch moveworkspacetomonitor 10 "' .. DELL_MONITOR .. '"')
end

local function on_lid_open()
    -- Restore internal display at its position in the three-monitor layout
    os.execute('hyprctl keyword monitor "eDP-1, 1920x1080@60, 3840x0, 1"')
    -- Return workspace 10 to eDP-1
    os.execute('hyprctl keyword workspace "10, monitor:eDP-1, default:true"')
    os.execute('hyprctl dispatch moveworkspacetomonitor 10 eDP-1')
end

hl.bind("switch:on:Lid Switch",  on_lid_close, { locked = true })
hl.bind("switch:off:Lid Switch", on_lid_open,  { locked = true })
