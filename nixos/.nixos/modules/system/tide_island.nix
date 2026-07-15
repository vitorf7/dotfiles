{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.tide_island.enable {
  # Tide Island is a user-space Quickshell component. All packages and the
  # systemd user service are managed in the home module (tide_island.nix).
  # System-level deps (upower, bluez, pipewire) are already covered by the
  # co-enabled quickshell.nix and hyprland.nix system modules.
}
