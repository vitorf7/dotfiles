{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.hyprland.enable {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  programs.hyprland.enable = true;
}
