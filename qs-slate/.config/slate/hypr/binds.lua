-- Your keyboard shortcuts for the Slate session: ~/.config/slate/hypr/binds.lua
--
-- Loaded after Slate's own shortcuts. Saving this file reloads Hyprland's config; if
-- something in it is wrong, Slate shows the error in a notification.
--
-- A curated port of the plain session's modules/keybindings.lua, not a copy of it:
--   * Hyprland keeps EVERY bind registered on a chord, so a chord bound twice fires both
--     actions. Where yours should replace one of Slate's, it is unbound first (below).
--   * What Slate does itself is left to Slate: volume/mic keys (its OSD, so no volumectl),
--     the power menu (no wlogout), wallpapers (no awww/matugen scripts). Those binds are
--     not ported.
--   * Everything on ALT collides with nothing in any of Slate's three shortcut sets.
local HOME = os.getenv("HOME")
local hyprScripts = HOME .. "/.config/hypr/scripts"
local fileManager = FILE_MANAGER or "nautilus"
local mainMod = "ALT"

-- Unbinding a chord nothing is bound to is harmless; pcall in case that ever raises.
local function unbind(chord) pcall(hl.unbind, chord) end

-- Slate binds the digit keys by keycode (layout-independent), so they're unbound and rebound by
-- keycode too: the same chord then ends up with exactly one bind, whichever shortcut set is on.
local function digitCode(i) return "code:" .. (i == 10 and 19 or 9 + i) end

-- ---------------------------------------------------------------- windows (ALT)
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- Toggle split on ALT+T, same as the plain session. (It used to be ALT+J there, which is the same
-- chord as ALT+j below because Hyprland ignores key-name case, so both fired. Slate's own SUPER+J
-- is a separate layout toggle.)
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SUPER + Q", hl.dsp.exec_cmd(hyprScripts .. "/killActiveProcess.sh"))

-- Focus / move with hjkl
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "down" }))

-- Resize with the arrow keys: Slate's own "resize" submap (30px steps, repeating). Not
-- redefined here: two submaps with one name would both put their arrow binds on the same keys.
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))

-- Move / resize with the mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ---------------------------------------------------------------- apps (ALT)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + Space", hl.dsp.exec_cmd("vicinae toggle"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a | wl-copy"))

-- ---------------------------------------------------------------- session
-- Slate's own confirmation dialog and power menu instead of Hyprland's bare exit / wlogout.
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd(SLATE .. " ipc call power confirm logout"))
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exec_cmd(SLATE .. " ipc call bar panel session"))
hl.bind("CTRL + ALT + Delete", hl.dsp.exit())   -- the emergency way out, kept as it was

-- ---------------------------------------------------------------- workspaces
-- Allow "previous workspace" (ALT+Tab below) to cycle back.
hl.config({ binds = { allow_workspace_cycles = true } })

-- Yours win over Slate's ALT+Tab (next window): previous workspace.
unbind("ALT + Tab")
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

-- Scratchpad (Slate's own "secret" workspace is on SUPER+S, a different one)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- SUPER+1..0 go to workspace N; SUPER+ALT+1..0 move the window there. Slate's own shortcut set
-- gives SUPER+1..3 to "focus monitor N" and SUPER+ALT+1..3 to "go to workspace N" (the opposite of
-- yours), and the other two sets bind SUPER+1..0 to the same thing yours does: unbound first, so
-- each chord has exactly one action, yours.
for i = 1, 10 do
    local code = digitCode(i)
    unbind("SUPER + " .. code)
    hl.bind("SUPER + " .. code, hl.dsp.focus({ workspace = i }))
    unbind("SUPER + ALT + " .. code)
    hl.bind("SUPER + ALT + " .. code, hl.dsp.window.move({ workspace = i }))
end

-- Ghostty owns these Super+letter chords: its config (ghostty/.config/ghostty/config) sends them to
-- tmux and nvim (cmd+j runs the `t` session switcher, cmd+k is the tmux prefix + T, cmd+t a new tmux
-- window, cmd+d a split, cmd+e/p/r nvim and reload). Slate binds them globally, and Hyprland takes a
-- bound chord before any app sees it, so Slate's versions are unbound here. When you add a `super+x`
-- keybind to Ghostty, add it to this list. (Not listed: SUPER+1..9, Ghostty's tmux windows. Those
-- are the workspace binds above, as they are in the plain session.)
--   SUPER+J  toggle split            -> ALT+T          SUPER+K  Nova hold-to-talk -> Nova's bar button
--   SUPER+E  Files                   -> ALT+E          SUPER+T  text editor       -> the launcher
--   SUPER+P  colour picker/pseudo    -> ALT+C / ALT+P  SUPER+D  maximize
--   SUPER+R  resize submap/launcher  -> ALT+R / SUPER+Space
for _, chord in ipairs({
    "SUPER + J", "SUPER + K", "SUPER + T", "SUPER + D", "SUPER + E",
    "SUPER + P", "SUPER + R", "SUPER + SHIFT + P",
}) do
    unbind(chord)
end

-- ---------------------------------------------------------------- screenshots and recording
-- Slate has its own (Print, Super+Print); these stay on their own keys. SUPER+SHIFT+4/5 are
-- "move window to workspace 4/5" in Slate's two Hyprland sets: yours replace those two (the
-- SUPER+ALT+N binds above move windows).
unbind("SUPER + SHIFT + " .. digitCode(4))
unbind("SUPER + SHIFT + " .. digitCode(5))
-- hyprshot copies the PNG to the clipboard itself; piping into wl-copy would clobber it.
hl.bind("SUPER + SHIFT + 5", hl.dsp.exec_cmd("hyprshot -m output -m active -o ~/Screenshots"))
hl.bind("SUPER + SHIFT + 4", hl.dsp.exec_cmd("hyprshot -m region -o ~/Screenshots"))
-- hyprshot --raw piped into satty for annotation; Enter/Ctrl+C copies, Ctrl+S saves.
local satty = "satty -f - --early-exit --copy-command wl-copy"
    .. " --output-filename ~/Screenshots/satty-%Y%m%d-%H%M%S.png"
hl.bind("SUPER + CTRL + 5", hl.dsp.exec_cmd("sh -c 'hyprshot -m window -m active --raw | " .. satty .. "'"))
hl.bind("SUPER + CTRL + 4", hl.dsp.exec_cmd("sh -c 'hyprshot -m region --freeze --raw | " .. satty .. "'"))
hl.bind("SHIFT + SUPER + ALT + CTRL + R", hl.dsp.exec_cmd(hyprScripts .. "/record.sh --sound"))

-- ---------------------------------------------------------------- keyboard
-- £ on ALT+3 (macOS Option+3 muscle memory): raw keycodes through ydotool so it works in
-- fields like 1Password that block virtual keyboards. Resolved via the "gb" layout that
-- input.lua (hyprland.lua here) pins to ydotoold's device.
hl.bind("ALT + 3", hl.dsp.exec_cmd("ydotool key 42:1 4:1 4:0 42:0"))

-- Keyboard layout toggle (US <-> GB), with a notification naming the active layout.
hl.bind(
    "SUPER + SHIFT + K",
    hl.dsp.exec_cmd(
        "hyprctl switchxkblayout all next && notify-send -t 3000 'Keyboard Layout' "
            .. "\"$(hyprctl -j devices | jq -r '[.keyboards[] | select(.main)] | first | .active_keymap')\""
    )
)

-- ---------------------------------------------------------------- per-host modules
-- Same idea as the plain session's marker files: home-manager only creates these on hosts
-- where the feature is enabled, so a missing file simply means "not on this host".
local function ifPresent(path, before)
    local file = io.open(path, "r")
    if not file then return end
    file:close()
    if before then before() end
    dofile(path)
end

-- SpeakoFlow dictation. SUPER+Escape is its "cancel", and Slate's sets use it for "force-quit
-- an app": unbound only when SpeakoFlow is actually on this host.
ifPresent(HOME .. "/.config/hypr-speakoflow/keybinds.lua", function() unbind("SUPER + Escape") end)
-- OpenWhispr (generated by the app; symlinked in only while enabled).
ifPresent(HOME .. "/.config/hypr/openwhispr-binds.lua")
