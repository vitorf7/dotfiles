{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.enable {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
}
