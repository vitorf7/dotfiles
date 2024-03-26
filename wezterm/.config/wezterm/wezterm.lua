local wezterm = require("wezterm")
local helpers = require("utils/helpers")
local act = wezterm.action
local font = require("utils/font")
local bg = require("utils/background")

local multiple_actions = function(keys)
	local actions = {}
	for key in keys:gmatch(".") do
		table.insert(actions, act.SendKey({ key = key }))
	end
	table.insert(actions, act.SendKey({ key = "\n" }))
	return act.Multiple(actions)
end

local config = {
	macos_window_background_blur = 10,
	color_scheme = helpers.is_dark() and "Catppuccin Mocha" or "Catppuccin Latte", -- or Macchiato, Frappe, Latte
	font = font.get_font({
		"Monaspace Argon",
		"Monaspace Radon",
		"CommitMono",
		"JetBrains Mono",
	}),
	font_size = 17.5,

	background = {
		bg.get_wallpaper(wezterm.home_dir .. "/Pictures/wezterm_bgs/*"),
		bg.get_background(0.8, 0.9),
	},

	window_padding = {
		left = 20,
		right = 20,
		top = 20,
		bottom = 20,
	},

	set_environment_variables = {
		BAT_THEME = helpers.is_dark() and "Catppuccin-mocha" or "Catppuccin-latte",
		TERM = "xterm-256color",
		LC_ALL = "en_US.UTF-8",
	},

	keys = {
		{
			mods = "CMD",
			key = "j",
			action = act.Multiple({
				act.SendKey({ key = "t" }),
				act.SendKey({ key = "Enter" }),
			}),
		}, -- Activate Sesh (Tmux Session Manager) when not in tmux
		-- TMUX Keybindings --
		-- current prefix for tmux CTRL + Space
		{
			mods = "CMD",
			key = "k",
			action = act.Multiple({
				act.SendKey({ mods = "CTRL", key = "Space" }),
				act.SendKey({ key = "T" }),
			}),
		}, -- Activate Sesh (Tmux Session Manager) when in tmux
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
				multiple_actions(":GoToFile"),
			}),
		}, -- Neovim Telescope smart_open
		{
			mods = "CMD|SHIFT",
			key = "p",
			action = act.Multiple({
				act.SendKey({ key = "\x1b" }), -- escape
				multiple_actions(":GoToCommand"),
			}),
		}, -- Neovim command pallete
		{
			mods = "CMD",
			key = "o",
			action = act.Multiple({
				act.SendKey({ key = "\x1b" }), -- escape
				multiple_actions(":BrowseFiles"),
			}),
		}, -- Neovim command pallete
		{
			mods = "CMD|CTRL",
			key = "n",
			action = act.Multiple({
				multiple_actions("nvims"),
			}),
		}, -- Horizontal Split
	},

	send_composed_key_when_left_alt_is_pressed = true,
	send_composed_key_when_right_alt_is_pressed = false,
	adjust_window_size_when_changing_font_size = false,
	enable_tab_bar = false,
	native_macos_fullscreen_mode = false,
	window_decorations = "RESIZE",

	enable_kitty_graphics = true,
}

return config
