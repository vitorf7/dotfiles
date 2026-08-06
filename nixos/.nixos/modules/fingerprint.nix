{ ... }:
{
  flake.modules.nixos.fingerprint = { config, lib, ... }: lib.mkIf config.vitorf7.hardware.fingerprint.enable {
    # calib-data.bin lives at hosts/thinkpad-t480/calib-data.bin
    services."06cb-009a-fingerprint-sensor" = {
      enable = true;
      backend = "libfprint-tod";
      calib-data-file = ../hosts/thinkpad-t480/calib-data.bin;
    };
    security.pam.services = {
      login.fprintAuth = lib.mkForce true;
      sudo.fprintAuth = true;
      hyprlock.fprintAuth = true;
    };

    powerManagement.resumeCommands = ''
      systemctl restart 06cb-009a-fingerprint-sensor.service
    '';
  };
}
