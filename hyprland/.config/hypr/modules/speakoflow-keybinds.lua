-- SpeakoFlow dictation keybinds
-- Sourced only when desktop.speakoflow.enable = true (via ~/.config/hypr-speakoflow/keybinds.lua symlink)
--
-- The flags are forwarded to the tray instance started by the speakoflow user
-- service (nixos/nix-config/modules/speakoflow.nix). Its own Tauri shortcuts
-- can't see keys on native Wayland, hence binds here.
-- Punctuation keys because SUPER/SUPER+SHIFT letters are taken by Ghostty's
-- tmux/nvim keybinds, and CTRL+Space (upstream's default) is the tmux prefix.

hl.bind("SUPER + semicolon", hl.dsp.exec_cmd("speakoflow --toggle-transcription"))
hl.bind("SUPER + CTRL + semicolon", hl.dsp.exec_cmd("speakoflow --toggle-post-process"))
hl.bind("SUPER + apostrophe", hl.dsp.exec_cmd("speakoflow --toggle-assistant"))
hl.bind("CTRL + ALT + SUPER + semicolon", hl.dsp.exec_cmd("speakoflow --toggle-call"))
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("speakoflow --cancel"))
