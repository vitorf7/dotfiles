-- Autostart necessary processes
hl.on("hyprland.start", function()
	-- hyprmod persists only XCURSOR_* env; hyprcursor picks its own theme at
	-- compositor start (falling back to rose-pine-hyprcursor), so replay the
	-- saved choice. hyprland-gui.lua has loaded by now and hl.env has set these.
	local cursorTheme = os.getenv("XCURSOR_THEME")
	if cursorTheme then
		hl.exec_cmd("hyprctl setcursor " .. cursorTheme .. " " .. (os.getenv("XCURSOR_SIZE") or "24"))
	end
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
	-- (dms is started from ~/.config/hypr-dank-material-shell/autostart.lua,
	-- loaded by hyprland.lua only on hosts with dank_material_shell.enable.)
	hl.exec_cmd("systemctl --user start xdg-desktop-portal.service")
	hl.exec_cmd("systemctl --user start openlogi-agent.service")
	hl.exec_cmd("systemctl --user start ydotool.service")
	-- EasyEffects is a user service (modules/desktop.nix) so it restarts with
	-- WirePlumber; it waits for DMS's StatusNotifierWatcher itself.
	hl.exec_cmd("systemctl --user start easyeffects.service")
end)
