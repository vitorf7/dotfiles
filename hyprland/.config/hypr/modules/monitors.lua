-- See https://wiki.hyprland.org/Configuring/Monitors/

-- Explicit monitor layout for T480 desk setup.
-- Matching by description (not connector name) so the config survives
-- hub reconnects where DP-1/DP-2 numbering may shift.
--
-- Physical layout (left → right):
--   [LG 27GL650F 120Hz] [Dell U2419HC 60Hz] [Internal eDP-1]
--        0x0                 1920x0               3840x0
--
-- The internal panel differs per machine (T480: 1920x1080@60, X1 Carbon:
-- 2880x1800@120 2.8K OLED), so its mode uses "highres" — Hyprland picks the
-- highest supported resolution at the highest available refresh at runtime,
-- which keeps this shared file correct on both hosts.

-- LG 27GL650F: main, leftmost, 120Hz
hl.monitor({
	output = "desc:LG Electronics 27GL650F",
	mode = "1920x1080@120",
	position = "0x0",
	scale = 1,
})

-- Dell U2419HC: secondary, center, 60Hz
hl.monitor({
	output = "desc:Dell Inc. DELL U2419HC",
	mode = "1920x1080@60",
	position = "1920x0",
	scale = 1,
})

-- Internal eDP-1: tertiary, rightmost. "highres" = highest supported
-- resolution + refresh the panel offers (per-machine, see header).
hl.monitor({
	output = "eDP-1",
	mode = "highres",
	position = "3840x0",
	scale = 1.5,
})

-- Fallback: any other monitor (other machines, future devices)
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})
