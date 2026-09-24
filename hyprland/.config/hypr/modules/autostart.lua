-- Autostart necessary processes
hl.on("hyprland.start", function()
	hl.exec_cmd("hypridle")
	hl.exec_cmd("awww-daemon")
	-- hl.exec_cmd("waybar")
	hl.exec_cmd("vicinae server")
	hl.exec_cmd("avizo-service")
	hl.exec_cmd("lxqt-policykit-agent")
	-- hl.exec_cmd("caelestia shell -d")
	-- hl.exec_cmd("tide-island")
	-- graphical-session.target is never activated in this Hyprland setup (no
	-- UWSM/session-manager to legitimately pull it in — Hyprland's own
	-- `systemctl --user start graphical-session.target` would be refused
	-- too, since that target has RefuseManualStart=yes upstream and can
	-- only be reached via a dependency pull). graphical-session-holder
	-- (modules/hyprland.nix) Wants= it, so starting the holder first
	-- transitively activates it. Everything else that is
	-- WantedBy/Requisite=graphical-session.target (xdg-desktop-portal,
	-- openlogi-agent, ydotool, dms) needs it active before it can start.
	hl.exec_cmd("systemctl --user start graphical-session-holder.service")
	hl.exec_cmd("systemctl --user start dms")
	hl.exec_cmd("systemctl --user start xdg-desktop-portal.service")
	hl.exec_cmd("systemctl --user start openlogi-agent.service")
	hl.exec_cmd("systemctl --user start ydotool.service")
end)

-- exec-once = easyeffects --gapplication-service
