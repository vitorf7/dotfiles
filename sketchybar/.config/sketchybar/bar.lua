local colors = require("colors")

-- Equivalent to the --bar domain
sbar.bar({
	topmost = "window",
	height = 40,
	color = colors.bar.bg,
	padding_right = 2,
	padding_left = 2,
	margin = 10,
	corner_radius = 10,
	y_offset = 2,
	border_color = colors.bar.bg,
	border_width = 2,
	blur_radius = 10,
	sticky = "on",
})
