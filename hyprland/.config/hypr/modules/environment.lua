-- See https://wiki.hyprland.org/Configuring/Environment-variables/
-- Cursor defaults. HYPRCURSOR_THEME is read by the hyprcursor library and
-- HYPRCURSOR_SIZE by Hyprland itself (note: HYCURSOR_SIZE without the PR is
-- not a real variable). All four are overridden by ~/.config/hypr/
-- hyprland-gui.lua, which the hyprmod GUI writes on Save whenever you pick
-- a different cursor (see the loader at the bottom of hyprland.lua).
-- hl.env("XCURSOR_SIZE", "24")
-- hl.env("XCURSOR_THEME", "rose-pine-hyprcursor")
-- hl.env("HYPRCURSOR_SIZE", "24")
-- hl.env("HYPRCURSOR_THEME", "rose-pine-hyprcursor")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("NIXOS_OZONE_WL", "1")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("HYPRSHOT_DIR", "~/Pictures/Screenshots")
