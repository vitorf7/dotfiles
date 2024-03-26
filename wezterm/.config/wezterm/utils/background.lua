local M = {}
local h = require("utils/helpers")
local wezterm = require("wezterm")

--- M.get_background
-- @param dark (int) Represents the darkness level of the background.
-- @param light (int) Represents the lightness level of the background.
-- @return The computed background color.
M.get_background = function(dark, light)
	dark = dark or 0.8
	light = light or 0.8
	return {
		source = {
			Gradient = {
				colors = { h.is_dark() and "#000000" or "#ffffff" },
			},
		},
		width = "100%",
		height = "100%",
		opacity = h.is_dark() and dark or light,
	}
end

M.get_wallpaper = function(dir)
	local wallpapers = {}
	for _, v in ipairs(wezterm.glob(dir)) do
		if not string.match(v, "%.DS_Store$") then
			table.insert(wallpapers, v)
		end
	end
	local wallpaper = h.get_random_entry(wallpapers)
	return {
		source = { File = { path = wallpaper } },
		height = "Cover",
		width = "Cover",
		horizontal_align = "Center",
		repeat_x = "Repeat",
		repeat_y = "Repeat",
		opacity = 1,
		-- speed = 200,
	}
end

return M
