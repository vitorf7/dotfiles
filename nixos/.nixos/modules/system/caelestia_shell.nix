{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.caelestia_shell.enable {
  # Caelestia Shell is a user-space Quickshell component. All packages and the
  # systemd user service are managed in the home module (caelestia_shell.nix).
  # System-level deps (upower, pipewire, hyprland) are already covered by the
  # co-enabled quickshell.nix and hyprland.nix system modules.
}
