-- This is an example Hyprland config file.

-- Refer to the wiki for more information.

-- https://wiki.hyprland.org/Configuring/

-- Please note not all available settings / options are set here.

-- For a full list, see the wiki

-- You can split this configuration into multiple files

-- Create your files separately and then link them to this file like this:

-- source = ~/.config/hypr/myColors.conf

-- Source all modules

-- source = $HOME/.config/hypr/modules/variables.conf
require("modules.environment")
require("modules.monitors")
require("modules.autostart")
require("modules.input")
require("modules.layouts")
require("modules.appearance")
require("modules.animations")
require("modules.keybindings")
require("modules.windowrules")

-- HyprMod managed settings
require("hyprland-gui")

-- Tide-island
-- hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("quickshell ipc --any-display -p /usr/share/tide-island call overview toggle"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("quickshell ipc --any-display -p /usr/share/tide-island call tide showLyrics"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("quickshell ipc --any-display -p /usr/share/tide-island call tide showCustom"))
hl.bind("SUPER + down", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide showClock"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide togglePlayer"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide toggleControlCenter"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide toggleWallpaperPicker"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call island toggle"))

-- Ambxst
-- loadfile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")()

-- OVERRIDES
-- Down here you can write or source anything that you want to override from Ambxst's settings.
