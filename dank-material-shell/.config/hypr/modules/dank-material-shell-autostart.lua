-- DankMaterialShell (DMS) autostart.
-- This file is only symlinked by Nix when vitorf7.desktop.dank_material_shell.enable = true
-- (modules/dank-material-shell.nix), and hyprland.lua loads it only when present.
-- It's loaded after modules/autostart.lua, so graphical-session-holder (which
-- activates graphical-session.target, needed by the dms unit) is started first.
hl.on("hyprland.start", function()
	hl.exec_cmd("systemctl --user start dms")
end)
