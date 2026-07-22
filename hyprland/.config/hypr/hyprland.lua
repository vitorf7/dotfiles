-- Source all modules
require("modules.environment")
require("modules.monitors")
require("modules.monitor_manager")
require("modules.clamshell")
require("modules.autostart")
require("modules.input")
require("modules.layouts")
require("modules.appearance")
require("modules.animations")
require("modules.keybindings")
require("modules.windowrules")

-- HyprMod managed settings
require("hyprland-gui")

-- Tide Island keybinds (only loaded if tide_island.enable = true on this host)
local tideKeybinds = os.getenv("HOME") .. "/.config/hypr-tide-island/keybinds.lua"
local f = io.open(tideKeybinds, "r")
if f then
	f:close()
	loadfile(tideKeybinds)()
end

-- Caelestia Shell keybinds (only loaded if caelestia_shell.enable = true on this host)
local caelestiaKeybinds = os.getenv("HOME") .. "/.config/hypr-caelestia/keybinds.lua"
local g = io.open(caelestiaKeybinds, "r")
if g then
	g:close()
	loadfile(caelestiaKeybinds)()
end

-- Ambxst
-- loadfile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")()

-- OVERRIDES
-- Down here you can write or source anything that you want to override from Ambxst's settings.
