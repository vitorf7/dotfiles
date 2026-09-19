-- Swaync notification daemon autostart.
-- This file is only symlinked by Nix when vitorf7.desktop.quickshell.enable = false
-- (waybar-based setup). When a quickshell shell (DMS, caelestia, tide-island, etc.)
-- is active, this file is absent and quickshell owns the DBus notification service.
hl.on("hyprland.start", function()
	hl.exec_cmd("swaync")
end)
