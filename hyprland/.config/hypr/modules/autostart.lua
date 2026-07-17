-- Autostart necessary processes
hl.on("hyprland.start", function()
    hl.exec_cmd("hypridle")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("vicinae server")
    hl.exec_cmd("avizo-service")
    hl.exec_cmd("lxqt-policykit-agent")
    hl.exec_cmd("sleep 1 && ~/.config/hypr/scripts/workspace-init.sh")
    -- hl.exec_cmd("tide-island")
end)

-- exec-once = easyeffects --gapplication-service
