-- Tide Island IPC keybinds
-- Sourced only when tide_island.enable = true (via ~/.config/hypr-tide-island/keybinds.lua symlink)

hl.bind("SUPER + O", hl.dsp.exec_cmd("quickshell ipc --any-display -p /usr/share/tide-island call overview toggle"))
hl.bind("SUPER + L", hl.dsp.exec_cmd("quickshell ipc --any-display -p /usr/share/tide-island call tide showLyrics"))
hl.bind("SUPER + SHIFT + C", hl.dsp.exec_cmd("quickshell ipc --any-display -p /usr/share/tide-island call tide showCustom"))
hl.bind("SUPER + down", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide showClock"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide togglePlayer"))
hl.bind("SUPER + C", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide toggleControlCenter"))
hl.bind("SUPER + W", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call tide toggleWallpaperPicker"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("/usr/bin/quickshell ipc --any-display -p /usr/share/tide-island call island toggle"))
