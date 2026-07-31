{ config, pkgs, lib, ... }:

lib.mkIf config.vitorf7.desktop.hyprland.enable {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "hyprland" "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
      gnome.default = [ "gnome" "gtk" ];
    };
  };
}
