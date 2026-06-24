{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.hyprland.enable {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.hyprland.enable = true;
}
