{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.hyprland.enable {
  programs.hyprland.enable = true;
}
