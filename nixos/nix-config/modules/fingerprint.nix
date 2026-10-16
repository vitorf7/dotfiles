{inputs, ...}: {
  flake.modules.nixos.fingerprint = {
    config,
    lib,
    ...
  }: {
    imports = [inputs.nixos-06cb-009a-fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"];

    config = lib.mkIf config.vitorf7.hardware.fingerprint.enable {
      services."06cb-009a-fingerprint-sensor" = {
        enable = true;
        backend = "libfprint-tod";
        calib-data-file = ./hosts/thinkpad-t480/calib-data.bin;
      };
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

      powerManagement.resumeCommands = ''
        systemctl restart 06cb-009a-fingerprint-sensor.service
      '';
    };
  };
}
