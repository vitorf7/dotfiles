-- Caelestia Shell IPC keybinds
-- Sourced only when caelestia_shell.enable = true (via ~/.config/hypr-caelestia/keybinds.lua symlink)
-- Source: github.com/caelestia-dots/caelestia/blob/main/hypr/hyprland/keybinds.lua

-- ── Helper functions (inlined from caelestia's hyprland/functions.lua) ────────

-- Resize the active window by a percentage of its current size.
local function resize_active_window(x, y)
	local win = hl.get_active_window()
	if win and win.size then
		local w = (win.size.x * (x / 100)) or 800
		local h = (win.size.y * (y / 100)) or 600
		return { x = w, y = h, relative = true }
	end
end

-- Resize to an absolute size that is x%/y% of the active monitor.
local function resize_by_screen(x, y)
	local screen = hl.get_active_monitor()
	if screen and type(screen.width) == "number" and type(screen.height) == "number" then
		if not (x == 0 and y == 0) then
			local w = (x and x > 0) and math.floor(screen.width * x / 100) or screen.width
			local h = (y and y > 0) and math.floor(screen.height * y / 100) or screen.height
			return { x = w, y = h, relative = false }
		end
	end
end

-- Compute resize + move dispatch targets for PiP placement (bottom-right,
-- 1/4 of monitor height, with a small margin).
local function move_actions(win)
	local screen = hl.get_active_monitor()
	if screen and screen.width and screen.height and win and win.size then
		local monitor_height = screen.height / screen.scale
		local monitor_width = screen.width / screen.scale
		local scale_factor = (monitor_height / 4) / win.size.y
		local target_width = win.size.x * scale_factor
		local target_height = win.size.y * scale_factor
		local x_resize = math.floor(math.max(200, target_width))
		local y_resize = math.floor(math.max(150, target_height))
		local offset = math.min(monitor_width, monitor_height) * 0.03
		local move_x = math.floor(screen.x + monitor_width - x_resize - offset)
		local move_y = math.floor(screen.y + monitor_height - y_resize - offset)
		return {
			hl.dsp.window.resize({ x = x_resize, y = y_resize, window = win }),
			hl.dsp.window.move({ x = move_x, y = move_y, relative = false, window = win }),
		}
	end
end

-- ── Conflict resolution ───────────────────────────────────────────────────────
-- These keys are registered in keybindings.lua; unbind them so the caelestia
-- variants below take effect cleanly.

hl.unbind("ALT + Tab") -- was: previous workspace → becomes: cycle window
hl.unbind("XF86AudioRaiseVolume")
hl.unbind("XF86AudioLowerVolume")
hl.unbind("XF86AudioMute")
hl.unbind("XF86AudioMicMute")

-- ── Launcher ──────────────────────────────────────────────────────────────────

-- Launcher (Super tap)
hl.bind("SUPER + SUPER_L", hl.dsp.global("caelestia:launcher"), { release = true })

-- ── Shell UI toggles ──────────────────────────────────────────────────────────

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

-- ── Brightness ────────────────────────────────────────────────────────────────
-- Replaces lightctl in keybindings.lua — caelestia shows its own OSD.

hl.bind("XF86MonBrightnessUp", hl.dsp.global("caelestia:brightnessUp"), { locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.global("caelestia:brightnessDown"), { locked = true })

-- ── Media ─────────────────────────────────────────────────────────────────────
-- Replaces playerctl in keybindings.lua — caelestia shows its media widget.

hl.bind("CTRL + SUPER + Space", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.global("caelestia:mediaToggle"), { locked = true })
hl.bind("CTRL + SUPER + Equal", hl.dsp.global("caelestia:mediaNext"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.global("caelestia:mediaNext"), { locked = true })
hl.bind("CTRL + SUPER + Minus", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.global("caelestia:mediaPrev"), { locked = true })
hl.bind("XF86AudioStop", hl.dsp.global("caelestia:mediaStop"), { locked = true })

-- ── Kill / restart shell ──────────────────────────────────────────────────────

hl.bind("CTRL + SUPER + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill"), { release = true })
hl.bind(
	"CTRL + SUPER + ALT + R",
	hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"),
	{ release = true }
)

-- ── Special workspace toggles ─────────────────────────────────────────────────

hl.bind("SUPER + S", hl.dsp.exec_cmd("caelestia toggle specialws"))
hl.bind("CTRL + SHIFT + Escape", hl.dsp.exec_cmd("caelestia toggle sysmon"))
hl.bind("SUPER + M", hl.dsp.exec_cmd("caelestia toggle music"))
hl.bind("SUPER + D", hl.dsp.exec_cmd("caelestia toggle communication"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("caelestia toggle todo"))

-- ── Screenshots ───────────────────────────────────────────────────────────────

hl.bind("Print", hl.dsp.exec_cmd("caelestia screenshot"), { locked = true })
hl.bind("SUPER + SHIFT + S", hl.dsp.global("caelestia:screenshotFreeze"))
hl.bind("SUPER + SHIFT + ALT + S", hl.dsp.global("caelestia:screenshot"))

-- ── Clipboard & emoji ─────────────────────────────────────────────────────────

hl.bind("SUPER + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard"))
hl.bind("SUPER + ALT + V", hl.dsp.exec_cmd("pkill fuzzel || caelestia clipboard -d"))
hl.bind("SUPER + Period", hl.dsp.exec_cmd("pkill fuzzel || caelestia emoji -p"))

-- ── Window cycling (overrides ALT + Tab from keybindings.lua) ────────────────

hl.bind("ALT + Tab", hl.dsp.window.cycle_next(), { repeating = true })
hl.bind("SHIFT + ALT + Tab", hl.dsp.window.cycle_next({ next = false }), { repeating = true })

-- ── Workspace scroll / page navigation ───────────────────────────────────────
-- SUPER + 1-10 and SUPER + ALT + 1-10 live in keybindings.lua (always active).

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "+1" }))
hl.bind("CTRL + SUPER + Left", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind("CTRL + SUPER + Right", hl.dsp.focus({ workspace = "+1" }), { repeating = true })
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER + Page_down", hl.dsp.focus({ workspace = "+1" }), { repeating = true })

-- Move window to prev/next workspace
hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind("SUPER + ALT + mouse_down", hl.dsp.window.move({ workspace = "-1" }))
hl.bind("SUPER + ALT + mouse_up", hl.dsp.window.move({ workspace = "+1" }))
hl.bind("CTRL + SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind("CTRL + SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })

-- Move window to / out of special workspace
hl.bind("CTRL + SUPER + SHIFT + up", hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL + SUPER + SHIFT + down", hl.dsp.window.move({ workspace = "e+0" }))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special" }))

-- ── Window actions ────────────────────────────────────────────────────────────
-- Focus (ALT + hjkl) and move-in-direction (ALT + SHIFT + hjkl) stay in
-- keybindings.lua. Only resize, drag, pin, fullscreen, float, close are here.

-- Resize
hl.bind("SUPER + Minus", hl.dsp.window.resize(resize_active_window(-10, 0)), { repeating = true })
hl.bind("SUPER + Equal", hl.dsp.window.resize(resize_active_window(10, 0)), { repeating = true })
hl.bind("SUPER + SHIFT + Minus", hl.dsp.window.resize(resize_active_window(0, -10)), { repeating = true })
hl.bind("SUPER + SHIFT + Equal", hl.dsp.window.resize(resize_active_window(0, 10)), { repeating = true })
hl.bind("SUPER + ALT + left", hl.dsp.window.resize(resize_active_window(-10, 0)), { repeating = true })
hl.bind("SUPER + ALT + right", hl.dsp.window.resize(resize_active_window(10, 0)), { repeating = true })
hl.bind("SUPER + ALT + up", hl.dsp.window.resize(resize_active_window(0, -10)), { repeating = true })
hl.bind("SUPER + ALT + down", hl.dsp.window.resize(resize_active_window(0, 10)), { repeating = true })

-- Drag & resize via mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("SUPER + X", hl.dsp.window.resize(), { mouse = true })

-- Center & fit to screen
hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.center())
hl.bind("CTRL + SUPER + ALT + Backslash", function()
	hl.dispatch(hl.dsp.window.resize(resize_by_screen(55, 70)))
	hl.dispatch(hl.dsp.window.center())
end)

-- PiP: float, resize + move to bottom-right, then pin
hl.bind("SUPER + ALT + backslash", function()
	local a = hl.get_active_window()
	if a then
		local pip = move_actions(a) or {}
		if not a.floating then
			table.insert(pip, 1, hl.dsp.window.float())
		end
		table.insert(pip, hl.dsp.window.pin({ action = "on", window = "address:" .. a.address }))
		for _, x in ipairs(pip) do
			hl.dispatch(x)
		end
	end
end)

-- Pin, fullscreen, float, close
hl.bind("SUPER + P", hl.dsp.window.pin())
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind("SUPER + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + ALT + space", hl.dsp.window.float())
hl.bind("SUPER + Q", hl.dsp.window.close())

-- ── Volume (wpctl — replaces volumectl/Avizo when caelestia is active) ────────

local volumeStep = 10
local volumeMax = 100

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(
		"wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l "
			.. (volumeMax / 100)
			.. " @DEFAULT_AUDIO_SINK@ "
			.. volumeStep
			.. "%+"
	),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(
		"wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume @DEFAULT_AUDIO_SINK@ " .. volumeStep .. "%-"
	),
	{ locked = true, repeating = true }
)

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })

hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- ── Recording ─────────────────────────────────────────────────────────────────

hl.bind("SUPER + ALT + R", hl.dsp.exec_cmd("caelestia record -s"))
hl.bind("CTRL + ALT + R", hl.dsp.exec_cmd("caelestia record"))
hl.bind("SUPER + SHIFT + ALT + R", hl.dsp.exec_cmd("caelestia record -r"))

-- ── Sleep ─────────────────────────────────────────────────────────────────────

hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("systemctl suspend-then-hibernate"), { locked = true })
