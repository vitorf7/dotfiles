-- Your monitor setup for the Slate session: ~/.config/slate/hypr/monitors.lua
--
-- Loaded after Slate's own config (including what you set in Settings → Displays), so
-- anything here wins. Saving this file reloads Hyprland's config; if something in it is
-- wrong, Slate shows the error in a notification.
--
-- Shared with the plain Hyprland session:
--   monitors.lua         the desk layout (LG, Dell, internal eDP-1, matched by description)
--   monitor_manager.lua  which workspaces live on which monitor, per monitor combination
--
-- monitor_manager.lua and Slate's per-monitor workspaces (NUM_WPM) both react to
-- monitor.added: if workspaces misbehave on the desk, comment out the second line and
-- use Slate's model instead.
local modules = os.getenv("HOME") .. "/.config/hypr/modules/"
dofile(modules .. "monitors.lua")
dofile(modules .. "monitor_manager.lua")
