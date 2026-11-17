-- OpenWhispr keybinds (managed automatically)
-- If you delete this file, also remove the matching load line from your Hyprland config.
hl.bind("SUPER + SEMICOLON", hl.dsp.exec_cmd("dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App.Toggle"))
hl.bind("SUPER + APOSTROPHE", hl.dsp.exec_cmd("dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App.ToggleVoiceAgent"))
hl.bind("CTRL + SUPER + SEMICOLON", hl.dsp.exec_cmd("dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App.ToggleTranslation"))
hl.bind("SUPER + ALT + SEMICOLON", hl.dsp.exec_cmd("dbus-send --session --type=method_call --dest=com.openwhispr.App /com/openwhispr/App com.openwhispr.App.ToggleMeeting"))
