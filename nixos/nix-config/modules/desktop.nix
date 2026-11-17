{...}: {
  flake.modules.homeManager.desktop = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.enable {
      home.packages = with pkgs; [
        xdg-utils
        v4l-utils
        easyeffects
        pavucontrol
        alsa-utils
        qpwgraph
      ];

      # Out-of-store so EasyEffects preset edits made in its GUI write
      # straight back into the dotfiles repo instead of a read-only nix
      # store path. EE 8.x keeps presets in ~/.local/share/easyeffects
      # (AppDataLocation), not ~/.config — only the preset file is symlinked,
      # not the input/ dir itself: the dir must stay real or EE 8.2.9's
      # QFileSystemWatcher/directory_iterator races crash it (SIGABRT,
      # verified live). EE's own state db stays in ~/.config/easyeffects/db.
      xdg.dataFile."easyeffects/input/wave3.json".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/easyeffects/.local/share/easyeffects/input/wave3.json";

      # EasyEffects as a supervised user service instead of a one-shot Hyprland
      # exec. Any `nrs` that changes WirePlumber's config (e.g. toggling
      # speakoflow, whose aloop rule lives there) restarts wireplumber.service;
      # an unsupervised EE is left disconnected or dead, the default sink falls
      # back to the raw hardware output and everything is suddenly louder and
      # unprocessed. PartOf= makes systemd restart EE along with WirePlumber,
      # and Restart= covers its occasional crashes.
      systemd.user.services.easyeffects = let
        start = pkgs.writeShellScript "easyeffects-service" ''
          # EasyEffects (Qt) checks QSystemTrayIcon::isSystemTrayAvailable()
          # exactly once at startup and never retries; it returns false unless
          # DMS's org.kde.StatusNotifierWatcher is already on the session bus.
          # Wait for the bus name first, otherwise EE starts before DMS and
          # shows no tray icon.
          ${pkgs.glib}/bin/gdbus wait --session --timeout 60 org.kde.StatusNotifierWatcher || true
          exec ${lib.getExe pkgs.easyeffects} --service-mode
        '';
      in {
        Unit = {
          Description = "EasyEffects audio effects (service mode)";
          After = ["pipewire.service" "wireplumber.service" "dms.service"];
          PartOf = ["wireplumber.service" "graphical-session.target"];
        };
        Service = {
          ExecStart = "${start}";
          Restart = "on-failure";
          RestartSec = 2;
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
    };
}
