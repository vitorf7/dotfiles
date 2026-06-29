{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.quickshell.enable {
  # hddtemp does not support NVMe drives; use smartmontools for temperature monitoring instead.
  services.upower.enable = true;
}
