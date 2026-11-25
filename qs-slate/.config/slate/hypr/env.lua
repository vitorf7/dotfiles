-- Your environment variables for the Slate session: ~/.config/slate/hypr/env.lua
--
-- Loaded first, before Slate's own Hyprland config. Apps started from now on get these
-- (apps already running keep what they started with). Saving this file reloads Hyprland's
-- config; if something in it is wrong, Slate shows the error in a notification.
--
-- Shared with the plain Hyprland session: its modules/environment.lua is the one list of
-- env vars (Wayland hints for Firefox/Electron/Qt/SDL/Java, HYPRSHOT_DIR), so the two
-- sessions can't drift. The cursor theme is not set here: Slate owns it (variables.lua).
dofile(os.getenv("HOME") .. "/.config/hypr/modules/environment.lua")
