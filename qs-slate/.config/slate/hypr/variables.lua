-- Your default apps, monitors and cursor for the Slate session: ~/.config/slate/hypr/variables.lua
--
-- Loaded before Slate's own Hyprland config, which uses any of these you set here instead
-- of its defaults. Saving this file reloads Hyprland's config; if something in it is wrong,
-- Slate shows the error in a notification. Settings → Default Apps can still change them.

TERMINAL     = "ghostty"    -- Super+Return
FILE_MANAGER = "nautilus"   -- Super+E

-- The same pick as the plain session's modules/keybindings.lua: the first of these that
-- is installed (the zen-browser flake's binary has been both names).
local function firstInstalled(...)
    for _, cmd in ipairs({ ... }) do
        local handle = io.popen("command -v " .. cmd .. " 2>/dev/null")
        if handle then
            local found = handle:read("*a")
            handle:close()
            if found ~= "" then return cmd end
        end
    end
    return select(1, ...)
end
BROWSER = firstInstalled("zen-browser", "zen")

-- Monitors by output name (`hyprctl monitors` lists them). Not set: modules/monitors.lua
-- places your monitors by description, and Settings → Displays handles the rest.
-- MONITOR1 = "eDP-1"
--
-- CURSOR_THEME = "Slate-Cursors"   -- Slate's own; yours (WhiteSur) is still set for the plain session
-- CURSOR_SIZE  = 20
