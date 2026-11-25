-- Anything else for the Slate session's Hyprland: ~/.config/slate/hypr/hyprland.lua
--
-- Loaded last, after Slate's own config and your other files here (env, variables,
-- monitors, binds, rules, autostart), so it wins over all of them. Saving this file reloads
-- Hyprland's config; if something in it is wrong, Slate shows the error in a notification.
--
-- Not loaded in this session, on purpose: the plain session's appearance.lua, animations.lua
-- and layouts.lua (Slate has its own look: borders, gaps, blur, shadows, animations), and its
-- keybindings.lua and autostart.lua (ported by hand in binds.lua / autostart.lua here).
local modules = os.getenv("HOME") .. "/.config/hypr/modules/"

-- Keyboard layouts (us,gb), Caps/Alt options, repeat rate, the mouse's sensitivity, and the
-- ydotool device pinned to "gb" that makes the £ key work (see binds.lua). Its touchpad
-- gesture is dropped: Slate sets up gestures from Settings, and two would both fire.
local gesture = hl.gesture
hl.gesture = function() end
local ok, err = pcall(dofile, modules .. "input.lua")
hl.gesture = gesture
if not ok then error(err, 0) end

-- Clamshell mode: switch the internal panel off with the lid closed and a monitor attached.
-- Slate's own lid action (Settings → Power) is "the system's" by default, i.e. it does nothing
-- here; leave it that way, since anything else would stop logind's own lid handling.
dofile(modules .. "clamshell.lua")
