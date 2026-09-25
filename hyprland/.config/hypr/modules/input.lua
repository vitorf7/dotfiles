-- https://wiki.hyprland.org/Configuring/Variables/#input
hl.config({
	input = {
		kb_layout = "us,gb",
		kb_variant = "",
		kb_model = "",
		kb_options = "lv3:ralt_alt",
		kb_rules = "",
		follow_mouse = 1,
		sensitivity = 0,
		repeat_delay = 200,
		repeat_rate = 40,
		touchpad = {
			natural_scroll = false,
		},
	},
})

-- See https://wiki.hypr.land/Configuring/Gestures
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- Example per-device config

-- See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

-- ydotool's virtual keyboard doesn't inherit the global "us,gb" layout — it
-- always resolves raw keycodes via whatever layout is assigned to it here.
-- Pin it to GB so "Shift+3" (KEY_3=4) resolves to £ (see keybindings.lua).
hl.device({
	name = "ydotoold-virtual-device",
	kb_layout = "gb",
})
