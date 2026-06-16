-- See https://wiki.hypr.land/Configuring/Window-Rules/ for more

-- See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules

-- Ignore maximize requests from all apps. You'll probably like this.
hl.window_rule({
    name = "suppress-maximize-events",
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- Hyprland-run windowrule
hl.window_rule({
    name = "move-hyprland-run",
    match = {
        class = "hyprland-run",
    },
    move = "20 monitor_h-120",
    float = true,
})
hl.window_rule({
    name = "open-ghostty-in-workspace-1",
    match = {
        class = "ghostty",
    },
    workspace = 1,
})
hl.window_rule({
    name = "open-zen-in-workspace-2",
    match = {
        class = "zen",
    },
    workspace = 2,
})
hl.window_rule({
    name = "open-rambox-in-workspace-3",
    match = {
        class = "rambox",
    },
    workspace = 3,
})
hl.window_rule({
    name = "open-obsidian-in-workspace-4",
    match = {
        class = "obsidian",
    },
    workspace = 4,
})
hl.window_rule({
    name = "open-spotify-in-workspace-5",
    match = {
        class = "spotify",
    },
    workspace = 5,
})
hl.layer_rule({
    name = "vicinae-blur",
    blur = true,
    ignore_alpha = 0,
    match = {
        namespace = "vicinae",
    },
})

-- disable animation for vicinae only
hl.layer_rule({
    name = "vicinae-no-animation",
    no_anim = true,
    match = {
        namespace = "vicinae",
    },
})
