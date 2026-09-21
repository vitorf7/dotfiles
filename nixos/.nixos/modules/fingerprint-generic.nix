{...}: {
  # Generic fprintd path for hosts whose reader is supported upstream by
  # libfprint. thinkpad-t480 uses modules/fingerprint.nix instead — its
  # 06cb:009a reader needs the out-of-tree driver plus a calibration blob.
  flake.modules.nixos.fingerprint-generic = {
    config,
    lib,
    ...
  }:
    lib.mkIf config.vitorf7.hardware.fingerprint.enable {
      services.fprintd.enable = true;

      security.pam.services = {
        login.fprintAuth = lib.mkForce true;
        # Intentionally off — see 3dd7eca.
        sudo.fprintAuth = false;
        hyprlock.fprintAuth = true;
      };
    };
}
