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

-- HyprMod managed settings (only loaded if hyprmod.enable = true on this host)
local hyprmodGui = os.getenv("HOME") .. "/.config/hypr-hyprmod/hyprland-gui.lua"
local e = io.open(hyprmodGui, "r")
if e then
	e:close()
	loadfile(hyprmodGui)()
end

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

-- DankMaterialShell config (only loaded if dank_material_shell.enable = true on this host)
local dmsConfig = os.getenv("HOME") .. "/.config/hypr-dank-material-shell/keybinds.lua"
local h = io.open(dmsConfig, "r")
if h then
	h:close()
	loadfile(dmsConfig)()
end

-- Swaync (only loaded if quickshell is NOT active — quickshell owns notifications instead)
local swayNcAutostart = os.getenv("HOME") .. "/.config/hypr-swaync/autostart.lua"
local s = io.open(swayNcAutostart, "r")
if s then
	s:close()
	loadfile(swayNcAutostart)()
end

-- Ambxst
-- loadfile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")()

-- OVERRIDES
-- Down here you can write or source anything that you want to override from Ambxst's settings.
