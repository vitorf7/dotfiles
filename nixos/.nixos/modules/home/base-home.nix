# This file is superseded by the modular home structure.
# The entry point is now modules/home/default.nix which imports:
#   core.nix    — shell, editor, cli tools, dotfile symlinks
#   desktop.nix — Hyprland ecosystem, waybar, rofi, etc.
#   theming.nix — GTK/Qt theming, matugen
#   dev.nix     — k9s, lazygit, language runtimes
{ ... }: { imports = [ ./default.nix ]; }
