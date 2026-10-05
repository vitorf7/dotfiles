{inputs, ...}: let
  # dcal's Google OAuth consent is hardcoded in core/internal/oauth/google.go:
  # the broad `calendar.events` scope (all calendars in the account, including
  # ones shared to the user) plus the full Google Tasks read/write scope. The
  # work Google Workspace admin rejected that breadth, so patch it down to
  # Google's granular `calendar.events.owned` scope (read/write on calendars
  # the user owns only) and drop the Tasks scope — upstream degrades Tasks
  # gracefully without it (AvengeMedia/dankcalendar PR #30).
  # Like the DMS patch in dank-material-shell.nix, this rides whatever
  # version `nix flake update` brings in — re-check the sed still applies
  # after a big bump.
  dcalPatched = pkgs:
    (inputs.dankcalendar.lib.mkDcal pkgs).overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          sed -i \
            -e 's|gcalendar.CalendarEventsScope|"https://www.googleapis.com/auth/calendar.events.owned"|' \
            -e '/gtasks.TasksScope/d' \
            -e '/google.golang.org\/api\/tasks/d' \
            core/internal/oauth/google.go
        '';
    });
in {
  flake.modules.nixos.dankcalendar = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.dankcalendar.nixosModules.dank-calendar];

    config = lib.mkIf config.vitorf7.desktop.dankcalendar.enable {
      programs.dank-calendar = {
        enable = true;
        package = dcalPatched pkgs;
        # dcal runs as a user daemon bound to the graphical session; DMS
        # auto-discovers the dcal binary on PATH and uses it as its calendar
        # backend.
        systemd.enable = true;
      };

      # dcal stores OAuth tokens in the Secret Service keyring (falls back to
      # an encrypted on-disk store when unavailable). GDM already wires
      # pam_gnome_keyring so the keyring unlocks at login.
      services.gnome.gnome-keyring.enable = true;
    };
  };

  flake.modules.homeManager.dankcalendar = {
    osConfig,
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.dankcalendar.homeModules.dank-calendar];

    config = lib.mkIf osConfig.vitorf7.desktop.dankcalendar.enable {
      programs.dank-calendar = {
        enable = true;
        # Same patched derivation as the NixOS side (identical store path, so
        # environment.systemPackages and home.packages never shadow each other).
        package = dcalPatched pkgs;
        # The NixOS side owns the systemd user service (systemd.packages from
        # the package) to avoid duplicate unit definitions.
        systemd.enable = false;
      };
    };
  };
}
