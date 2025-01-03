return {
	display = 1,
	paddings = 5,
	group_paddings = 5,
	corner_radius = 8,
	bar = {
		height = 40,
	},
	y_offset = 5,

	-- Apple Menu Config
	app = {
		offset = {
			y = 60,
			x = 5,
		},
		corner_radius = 2,
		font = {
			text = {
				family = "Monaspace Neon",
				size = 14.0,
			},
			numbers = {
				family = "Monaspace Neon",
				size = 14.0,
			},
			icons = "SF Pro Text", -- Used for icons (or NerdFont)
			style_map = {
				["Regular"] = "Regular",
				["Semibold"] = "Medium",
				["Bold"] = "Bold",
				["Heavy"] = "Bold",
				["Black"] = "ExtraBold",
			},
			overrides = {
				TimeView = {
					family = "FiraMono Nerd Font",
					size = 2.0,
				},
			},
		},
	},
	icons = "sf-symbols", -- Options: "sf-symbols", "nerdfont"
	animated_icons = false, -- Set to true if you want to use animated icons

	font = {
		text = "Monaspace Neon", -- Used for text
		numbers = "Monaspace Neon", -- Used for numbers
		icons = "SF Pro Text", -- Used for icons (or NerdFont)
		style_map = {
			["Regular"] = "Regular",
			["Semibold"] = "Medium",
			["Bold"] = "Bold",
			["Heavy"] = "Bold",
			["Black"] = "ExtraBold",
		},
	},
}
