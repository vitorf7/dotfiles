{ config, lib, ... }:

lib.mkIf config.vitorf7.hardware.vm.enable {
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
