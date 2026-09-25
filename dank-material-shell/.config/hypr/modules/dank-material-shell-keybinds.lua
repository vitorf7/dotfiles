-- DankMaterialShell (DMS) IPC keybinds and window rules for Hyprland
-- Sourced only when vitorf7.desktop.dank_material_shell.enable = true

-- DMS docs recommend hiding the Hyprland logo/splash
hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
	},
})

-- DMS layers should not animate
hl.layer_rule({
	name = "dms-no-anim",
	no_anim = true,
	match = {
		namespace = "dms",
	},
})

-- DMS/quickshell windows are floating by default
hl.window_rule({
	name = "dms-floating",
	match = {
		class = "^(org\\.quickshell)$",
	},
	float = true,
})

-- DMS recommended app rules
hl.window_rule({
	name = "gnome-apps-no-border",
	match = {
		class = "^(org\\.gnome\\.)",
	},
	border_size = 0,
	rounding = 12,
})

hl.window_rule({
	name = "wezterm-no-border",
	match = {
		class = "^(org\\.wezfurlong\\.wezterm)$",
	},
	border_size = 0,
})

hl.window_rule({
	name = "alacritty-no-border",
	match = {
		class = "^(Alacritty)$",
	},
	border_size = 0,
})

hl.window_rule({
	name = "zen-no-border",
	match = {
		class = "^(zen)$",
	},
	border_size = 0,
})

hl.window_rule({
	name = "ghostty-no-border",
	match = {
		class = "^(com\\.mitchellh\\.ghostty)$",
	},
	border_size = 0,
})

hl.window_rule({
	name = "kitty-no-border",
	match = {
		class = "^(kitty)$",
	},
	border_size = 0,
})

hl.window_rule({
	name = "dms-inactive-opacity",
	match = {
		float = false,
		focus = false,
	},
	opacity = "0.9 0.9",
})

hl.window_rule({
	name = "float-calculator",
	match = {
		class = "^(gnome-calculator)$",
	},
	float = true,
})

hl.window_rule({
	name = "float-blueman",
	match = {
		class = "^(blueman-manager)$",
	},
	float = true,
})

hl.window_rule({
	name = "float-nautilus",
	match = {
		class = "^(org\\.gnome\\.Nautilus)$",
	},
	float = true,
})

-- Keybinds
local mod = "SUPER"

hl.bind(mod .. " + Space", hl.dsp.exec_cmd("dms ipc call spotlight toggle"))
hl.bind(mod .. " + Tab", hl.dsp.exec_cmd("dms ipc call hypr toggleOverview"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd("dms ipc call clipboard toggle"))
hl.bind(mod .. " + N", hl.dsp.exec_cmd("dms ipc call notifications toggle"))
hl.bind(mod .. " + M", hl.dsp.exec_cmd("dms ipc call processlist focusOrToggle"))
hl.bind(mod .. " + comma", hl.dsp.exec_cmd("dms ipc call settings focusOrToggle"))
hl.bind(mod .. " + Y", hl.dsp.exec_cmd("dms ipc call dash toggle wallpaper"))
hl.bind(mod .. " + P", hl.dsp.exec_cmd("dms ipc call powerprofile toggle"))

hl.bind(mod .. " + ALT + L", hl.dsp.exec_cmd("dms ipc call lock lock"))

-- === Audio Controls ===
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("dms ipc call audio increment 3"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("dms ipc call audio decrement 3"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("dms ipc call audio mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("dms ipc call audio micmute"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("dms ipc call mpris playPause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("dms ipc call mpris previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("dms ipc call mpris next"), { locked = true })
hl.bind(
	"CTRL + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("dms ipc call mpris increment 3"),
	{ locked = true, repeating = true }
)
hl.bind(
	"CTRL + XF86AudioLowerVolume",
	hl.dsp.exec_cmd("dms ipc call mpris decrement 3"),
	{ locked = true, repeating = true }
)

-- === Brightness Controls ===
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd([[dms ipc call brightness increment 5 ""]]),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd([[dms ipc call brightness decrement 5 ""]]),
	{ locked = true, repeating = true }
)
