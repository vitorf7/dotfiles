{ inputs, ... }:
{
  flake.modules.nixos.fingerprint = { config, lib, ... }: {
    imports = [ inputs.nixos-06cb-009a-fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor" ];

    config = lib.mkIf config.vitorf7.hardware.fingerprint.enable {
      services."06cb-009a-fingerprint-sensor" = {
        enable = true;
        backend = "libfprint-tod";
        calib-data-file = ./hosts/thinkpad-t480/calib-data.bin;
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
  };
}
