-- Clamshell mode: disable/enable eDP-1 when the lid is closed/opened.
--
-- WHY A DAEMON instead of hl.bind("switch:on:Lid Switch"):
--   hl.bind registers all actions through the __lua dispatcher, which does
--   not fire for switch events in the current Hyprland Lua integration.
--   A background daemon polls /proc/acpi/button/lid/*/state and calls
--   hyprctl eval, bypassing this limitation entirely. It survives reloads.
--
-- WHY monitor.added:
--   On boot the daemon's initial check may run before external monitors have
--   finished connecting (total_monitors() == 1 → skip disable). The
--   monitor.added event fires each time an external monitor comes online,
--   giving a second chance to apply the correct clamshell state.

local script = os.getenv("HOME") .. "/.config/hypr/scripts/clamshell.sh"
local daemon = os.getenv("HOME") .. "/.config/hypr/scripts/clamshell-daemon.sh"

-- Start the polling daemon once for ongoing lid open/close detection.
hl.on("hyprland.start", function()
    hl.exec_cmd(daemon)
end)

-- Re-check lid state whenever a monitor connects (handles boot-time race where
-- external monitors arrive after the daemon's first check saw only eDP-1).
hl.on("monitor.added", function()
    hl.exec_cmd(script .. " check")
end)
