local terminal = "ghostty"
local mainMod = "ALT"
local browser = "zen-browser"
local music = "spotify-launcher"
local social = "rambox"
local notes = "obsidian"
local fileManager = "nautilus"
local hyprScripts = "~/.config/hypr/scripts"

-- ##################

-- ## KEYBINDINGS ###

-- ##################

-- Set programs that you use

-- Script directories

-- See https://wiki.hyprland.org/Configuring/Keywords/

-- Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more
hl.bind("SHIFT + " .. mainMod .. " + SUPER + T", hl.dsp.exec_cmd(terminal))
hl.bind("SHIFT + " .. mainMod .. " + SUPER + B", hl.dsp.exec_cmd(browser))
hl.bind("SHIFT + " .. mainMod .. " + SUPER + M", hl.dsp.exec_cmd(music))
hl.bind("SHIFT + " .. mainMod .. " + SUPER + S", hl.dsp.exec_cmd(social))
hl.bind("SHIFT + " .. mainMod .. " + SUPER + N", hl.dsp.exec_cmd(notes))
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + Space", hl.dsp.exec_cmd("$HOME/.config/rofi/launchers/launcher.sh || pkill rofi"))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(hyprScripts .. "/wlogout.sh"))

-- --------------------exit hyprland-----------------------------------------------#

-- --------------------------------------------------------------------------------#
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())

-- --------------------window management-------------------------------------------#

-- --------------------------------------------------------------------------------#
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + SUPER + Q", hl.dsp.exec_cmd(hyprScripts .. "/killActiveProcess.sh"))

-- ---------------wallpaper select & refresh & matugen color generation-----------------------#

-- -------------------------------------------------------------------------------------------#
hl.bind(mainMod .. " + SUPER + W", hl.dsp.exec_cmd(hyprScripts .. "/wallSelect.sh"))
hl.bind(
	"SUPER + SHIFT + W",
	hl.dsp.exec_cmd("vicinae deeplink vicinae://extensions/Matis_Olives/wallpaper/wallpaper-setter")
)
hl.bind(mainMod .. " + SUPER + R", hl.dsp.exec_cmd(hyprScripts .. "/refresh.sh"))

-- ---------------taking screenshot-------------------------------------------------#

-- ---------------------------------------------------------------------------------#
hl.bind(mainMod .. " + Print", hl.dsp.exec_cmd("hyprshot -m output -m active -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m region -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + CTRL + Print", hl.dsp.exec_cmd("hyprshot -m window -m active -o ~/Pictures/Screenshots"))
hl.bind(mainMod .. " + SUPER + S", hl.dsp.exec_cmd("hyprshot -m region --freeze -o ~/Pictures/Screenshots"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

-- Enable workspace cycling
hl.config({
	binds = {
		allow_workspace_cycles = true,
	},
})

-- Bind to previous workspace
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }))
	hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }))
	hl.bind("up", hl.dsp.window.resize({ x = 0, y = -10, relative = true }))
	hl.bind("down", hl.dsp.window.resize({ x = 0, y = 10, relative = true }))
	hl.bind("Return", hl.dsp.submap("reset"))
	hl.bind("Escape", hl.dsp.submap("reset"))
end)
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), {
	mouse = true,
})
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), {
	mouse = true,
})

-- Laptop multimedia keys for volume and LCD brightness with Avizo OSD
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("volumectl -u up"), {
	repeating = true,
	locked = true,
})
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("volumectl -u down"), {
	repeating = true,
	locked = true,
})
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("volumectl toggle-mute"), {
	repeating = true,
	locked = true,
})
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("volumectl -m toggle-mute"), {
	repeating = true,
	locked = true,
})
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("lightctl up"), {
	repeating = true,
	locked = true,
})
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("lightctl down"), {
	repeating = true,
	locked = true,
})

-- Hyprpicker - Color picker (already installed)
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a | wl-copy"))

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), {
	locked = true,
})
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), {
	locked = true,
})
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), {
	locked = true,
})
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), {
	locked = true,
})
