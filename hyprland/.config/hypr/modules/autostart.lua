-- Autostart necessary processes
hl.on("hyprland.start", function()
    -- hl.exec_cmd("ambxst")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("awww-daemon")
    -- hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("vicinae server")
    hl.exec_cmd("avizo-service")
    hl.exec_cmd("lxqt-policykit-agent")
end)

-- exec-once = easyeffects --gapplication-service
