-- Autostart necessary processes
hl.on("hyprland.start", function()
	hl.exec_cmd("hypridle")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("ibus-daemon -rxRd")
	-- hl.exec_cmd("waybar")
	hl.exec_cmd("vicinae server")
	hl.exec_cmd("avizo-service")
	hl.exec_cmd("lxqt-policykit-agent")
	-- hl.exec_cmd("caelestia shell -d")
	-- hl.exec_cmd("tide-island")
	-- Start the DMS systemd user service (graphical-session.target is not active in this Hyprland setup)
	hl.exec_cmd("systemctl --user start dms")
end)

-- exec-once = easyeffects --gapplication-service
