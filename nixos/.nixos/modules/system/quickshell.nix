{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.quickshell.enable {
  hardware.sensor.hddtemp.enable = true;
  services.upower.enable = true;
}
