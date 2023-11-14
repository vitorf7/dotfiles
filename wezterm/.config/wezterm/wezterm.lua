local wezterm = require("wezterm")
local act = wezterm.action

local multiple_actions = function(keys)
	local actions = {}
	for key in keys:gmatch(".") do
		table.insert(actions, act.SendKey({ key = key }))
	end
	table.insert(actions, act.SendKey({ key = "\n" }))
	return act.Multiple(actions)
end

local config = {
	term = "xterm-256color",
	macos_window_background_blur = 10,
	color_scheme = "Catppuccin Mocha", -- or Macchiato, Frappe, Latte
	font = wezterm.font_with_fallback({
		{
			family = "JetBrainsMono Nerd Font",
			weight = "Bold",
			harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
		},
	}),
	font_size = 17.5,

	window_padding = {
		left = 20,
		right = 20,
		top = 20,
		bottom = 20,
	},

	keys = {
		{
			mods = "CMD",
			key = "j",
			action = act.Multiple({
				act.SendKey({ key = "t" }),
				act.SendKey({ key = "Enter" }),
			}),
		}, -- Activate t-smart-session-manager
		-- TMUX Keybindings --
		-- current prefix for tmux CTRL + Space
		{
			mods = "CMD",
			key = "k",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "T" }),
			}),
		}, -- Activate t-smart-session-manager
		{
			mods = "CMD",
			key = "t",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "c" }),
			}),
		}, -- New tab
		{
			mods = "CMD",
			key = "d",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "%" }),
			}),
		}, -- Vertical Split
		{
			mods = "CMD|SHIFT",
			key = "d",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = '"' }),
			}),
		}, -- Horizontal Split
		{
			mods = "CMD",
			key = "1",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "1" }),
			}),
		}, -- Select tab 1
		{
			mods = "CMD",
			key = "2",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "2" }),
			}),
		}, -- Select tab 2
		{
			mods = "CMD",
			key = "3",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "3" }),
			}),
		}, -- Select tab 3
		{
			mods = "CMD",
			key = "4",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "4" }),
			}),
		}, -- Select tab 4
		{
			mods = "CMD",
			key = "5",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "5" }),
			}),
		}, -- Select tab 5
		{
			mods = "CMD",
			key = "6",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "6" }),
			}),
		}, -- Select tab 6
		{
			mods = "CMD",
			key = "7",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "7" }),
			}),
		}, -- Select tab 7
		{
			mods = "CMD",
			key = "8",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "8" }),
			}),
		}, -- Select tab 8
		{
			mods = "CMD",
			key = "9",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "9" }),
			}),
		}, -- Select tab 9
		{
			mods = "CMD",
			key = "g",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "g" }),
			}),
		}, -- Lazygit tmux custom binding
		{
			mods = "CMD",
			key = "G",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "G" }),
			}),
		}, -- GH Dash tmux custom binding
		{
			mods = "CMD",
			key = "p",
			action = act.Multiple({
				act.SendKey({ key = "\x1b" }), -- escape
				multiple_actions(":Telescope smart_open"),
			}),
		}, -- Neovim Telescope smart_open
		{
			mods = "CMD|SHIFT",
			key = "p",
			action = act.Multiple({
				act.SendKey({ key = "\x1b" }), -- escape
				multiple_actions(":Legendary"),
			}),
		}, -- Neovim Legendary
	},

	window_background_opacity = 0.9,

	send_composed_key_when_left_alt_is_pressed = true,
	send_composed_key_when_right_alt_is_pressed = false,
	adjust_window_size_when_changing_font_size = false,
	enable_tab_bar = false,
	native_macos_fullscreen_mode = false,
	window_decorations = "RESIZE",
}

return config
