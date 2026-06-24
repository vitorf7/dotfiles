{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.hyprland.enable {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
