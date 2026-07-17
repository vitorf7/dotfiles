-- Caelestia Shell IPC keybinds
-- Sourced only when caelestia_shell.enable = true (via ~/.config/hypr-caelestia/keybinds.lua symlink)
-- Source: github.com/caelestia-dots/caelestia/blob/main/hypr/hyprland/keybinds.lua

-- Launcher (Super tap)
hl.bind("SUPER + SUPER_L", hl.dsp.global("caelestia:launcher"), { release = true })

-- Shell UI toggles
hl.bind("SUPER + N", hl.dsp.global("caelestia:sidebar"))
hl.bind("CTRL + ALT + C", hl.dsp.global("caelestia:clearNotifs"), { locked = true })
hl.bind("SUPER + K", hl.dsp.global("caelestia:showall"))
hl.bind("SUPER + L", hl.dsp.global("caelestia:lock"))
hl.bind("SUPER + ALT + L", function()
    hl.dispatch(hl.dsp.exec_cmd("caelestia shell -d"))
    hl.dispatch(hl.dsp.global("caelestia:lock"))
end, { locked = true })
-- NOTE: CTRL+ALT+Delete is kept as hl.dsp.exit() in keybindings.lua
-- hl.bind("CTRL + ALT + Delete", hl.dsp.global("caelestia:session"))

-- Brightness (replaces lightctl in keybindings.lua — caelestia shows OSD)
hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true })

-- Media (replaces playerctl in keybindings.lua — caelestia shows media widget)
hl.bind("CTRL + SUPER + Space", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("CTRL + SUPER + Equal", hl.dsp.global("caelestia:mediaNext"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true })
hl.bind("CTRL + SUPER + Minus", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true })

-- Kill/restart shell
hl.bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill"), { release = true })
hl.bind("CTRL + SUPER + ALT + R", hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"), { release = true })

-- Special workspace toggles (caelestia-managed)
hl.bind("SUPER + S", hl.dsp.exec_cmd("caelestia toggle specialws"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("caelestia toggle sysmon"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("caelestia toggle music"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("caelestia toggle communication"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("caelestia toggle todo"))

-- Screenshots (via caelestia)
hl.bind("Print", hl.dsp.exec_cmd("caelestia screenshot"), { locked = true })
hl.bind("SUPER + SHIFT + S", hl.dsp.global("caelestia:screenshotFreeze"))
hl.bind("SUPER + SHIFT + ALT + S", hl.dsp.global("caelestia:screenshot"))

-- Clipboard & emoji picker
hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))
