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
        # gdm-password substacks login, and pam_fprintd.so before pam_unix.so
        # swallows the password prompt until the ~30s verify timeout — so
        # nixpkgs' GDM module deliberately sets this false and runs
        # gdm-fingerprint in parallel instead (either-or at the greeter).
        login.fprintAuth = false;
        # Intentionally off — see 3dd7eca.
        sudo.fprintAuth = false;
        # DMS lock screen handles fingerprint itself in parallel via D-Bus
        # (enableFprint), and hyprlock's native support does the same — a
        # pam_fprintd.so in a lock stack is strictly serial.
        hyprlock.fprintAuth = false;
        # Polkit prompts ("other apps"): password first, fingerprint fallback
        # after a blank/failed submit. Experimental rules API — relative
        # offset per pam.nix docs; re-check after big nixpkgs bumps.
        polkit-1.fprintAuth = true;
        polkit-1.rules.auth.fprintd.order =
          config.security.pam.services.polkit-1.rules.auth.unix.order + 50;
      };
    };
}
