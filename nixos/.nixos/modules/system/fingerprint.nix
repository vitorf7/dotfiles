{ config, lib, ... }:

# The T480's fingerprint reader (06cb:009a, Synaptics Metallica MIS) is NOT
# supported by mainline libfprint. We use the community flake
# github:ahbnr/nixos-06cb-009a-fingerprint-sensor which packages the necessary
# drivers.
#
# Phase 1 (current): python-validity backend — needed to enroll fingerprints
#   and generate /var/lib/python-validity/calib-data.bin.
#   After enrolling, copy calib-data.bin to hosts/thinkpad-t480/calib-data.bin
#   and switch to the libfprint-tod backend below (Phase 2).
#
# Phase 2 (after enrolling): uncomment libfprint-tod block, comment out
#   python-validity block, rebuild, then run fprintd-enroll again.

lib.mkIf config.vitorf7.hardware.fingerprint.enable {

  # --- Phase 2: libfprint-tod (bingch's driver) ---
  # Uses calibration data produced by the python-validity Phase 1 enroll.
  # calib-data.bin lives at hosts/thinkpad-t480/calib-data.bin (relative to
  # this file at modules/system/fingerprint.nix, hence ../../hosts/...).
  services."06cb-009a-fingerprint-sensor" = {
    enable = true;
    backend = "libfprint-tod";
    calib-data-file = ../../hosts/thinkpad-t480/calib-data.bin;
  };
  security.pam.services = {
    login.fprintAuth = lib.mkForce true;
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
  };

  # The 06cb:009a sensor loses its USB state on suspend/hibernate.
  # Restart the driver service after any resume so the lock screen
  # can authenticate via fingerprint again.
  powerManagement.resumeCommands = ''
    systemctl restart 06cb-009a-fingerprint-sensor.service
  '';
}
