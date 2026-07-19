-- See https://wiki.hyprland.org/Configuring/Monitors/

-- Explicit monitor layout for T480 desk setup.
-- Matching by description (not connector name) so the config survives
-- hub reconnects where DP-1/DP-2 numbering may shift.
--
-- Physical layout (left → right):
--   [LG 27GL650F 120Hz] [Dell U2419HC 60Hz] [Internal eDP-1 60Hz]
--        0x0                 1920x0               3840x0

-- LG 27GL650F: main, leftmost, 120Hz
hl.monitor({
    output   = "desc:LG Electronics 27GL650F",
    mode     = "1920x1080@120",
    position = "0x0",
    scale    = 1,
})

-- Dell U2419HC: secondary, center, 60Hz
hl.monitor({
    output   = "desc:Dell Inc. DELL U2419HC",
    mode     = "1920x1080@60",
    position = "1920x0",
    scale    = 1,
})

-- Internal eDP-1: tertiary, rightmost, 60Hz
hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "3840x0",
    scale    = 1,
})

-- Fallback: any other monitor (other machines, future devices)
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- ── Workspace bindings ────────────────────────────────────────────────────────
--
--   LG    → 1 2 3 4 9     (primary work area)
--   Dell  → 5 6 7 8       (+ 10 when lid is closed, via clamshell.sh)
--   eDP-1 → 10            (moved to Dell on lid close, returned on lid open)
--
-- Bindings set the default "home" monitor for each workspace. Hyprland routes
-- the workspace there on creation; clamshell.sh handles the dynamic ws 10 move.

-- LG: workspaces 1–4, 9  (ws 1 shown on LG at startup)
for _, ws in ipairs({ 1, 2, 3, 4, 9 }) do
    hl.workspace_rule({
        workspace = tostring(ws),
        monitor   = "desc:LG Electronics 27GL650F",
        default   = (ws == 1),
    })
end

-- Dell: workspaces 5–8  (ws 5 shown on Dell at startup)
for _, ws in ipairs({ 5, 6, 7, 8 }) do
    hl.workspace_rule({
        workspace = tostring(ws),
        monitor   = "desc:Dell Inc. DELL U2419HC",
        default   = (ws == 5),
    })
end

-- Internal: workspace 10  (dynamic — see clamshell.sh)
-- No default=true here: in docked mode ws 10 is still the only workspace bound
-- to eDP-1 so hyprland displays it there. In laptop-only mode, workspace-init.sh
-- takes over and dispatches to workspace 1, avoiding a forced ws 10 flash.
hl.workspace_rule({
    workspace = "10",
    monitor   = "eDP-1",
})
