{ config, lib, ... }:

lib.mkIf config.vitorf7.hardware.fingerprint.enable {
  services.fprintd.enable = true;
  security.pam.services = {
    login.fprintAuth = lib.mkForce true;
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
  };
}
