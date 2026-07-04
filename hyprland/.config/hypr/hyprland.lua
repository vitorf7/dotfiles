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

-- Ambxst
loadfile(os.getenv("HOME") .. "/.local/share/ambxst/hyprland.lua")()

-- OVERRIDES
-- Down here you can write or source anything that you want to override from Ambxst's settings.
