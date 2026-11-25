-- Your window and workspace rules for the Slate session: ~/.config/slate/hypr/rules.lua
--
-- Loaded after Slate's own rules, so these win where they overlap. Saving this file reloads
-- Hyprland's config; if something in it is wrong, Slate shows the error in a notification.
--
-- Shared with the plain Hyprland session: its modules/windowrules.lua (apps to their
-- workspaces, floating dialogs, SpeakoFlow's overlays, vicinae's blur and animation rules).
--
-- Two rules in that file are Hyprland's own defaults, which Slate already defines under the
-- same names; skipped here so a rule isn't registered twice.
local alreadyBySlate = {
    ["suppress-maximize-events"] = true,
    ["fix-xwayland-drags"] = true,
}
local windowRule = hl.window_rule
hl.window_rule = function(rule, ...)
    if type(rule) == "table" and alreadyBySlate[rule.name] then return end
    return windowRule(rule, ...)
end
local ok, err = pcall(dofile, os.getenv("HOME") .. "/.config/hypr/modules/windowrules.lua")
hl.window_rule = windowRule
if not ok then error(err, 0) end
