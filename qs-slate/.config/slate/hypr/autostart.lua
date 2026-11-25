-- Apps to start with the Slate session: ~/.config/slate/hypr/autostart.lua
--
-- Settings → Startup Apps is the easy way; this file is for commands. They run once when
-- you log in (not again when the config reloads), so saving this file doesn't start them
-- twice; changes apply from your next login. If something in it is wrong, Slate shows the
-- error in a notification.
--
-- Deliberately short. The plain session's modules/autostart.lua also starts these, and
-- Slate already does each of them itself, so starting them here would run two of each:
--   hypridle            -> Slate's idle and lock
--   awww-daemon         -> Slate's wallpaper
--   avizo-service       -> Slate's on-screen indicators (volume, brightness)
--   lxqt-policykit-agent-> Slate's password prompts (only one agent can register)
--   hyprctl setcursor   -> Slate sets its cursor
--   graphical-session-holder -> not needed: UWSM activates graphical-session.target
-- And these are systemd user services wanted by graphical-session.target, so they start
-- on their own under UWSM (check with `systemctl --user status <name>` if one doesn't):
--   xdg-desktop-portal, openlogi-agent, ydotool, easyeffects, speakoflow
hl.on("hyprland.start", function()
    hl.exec_cmd("vicinae server")
end)
