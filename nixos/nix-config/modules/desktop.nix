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
          # Qt aborts (qFatal in createPlatformIntegration, SIGABRT) when there is
          # no display to connect to, and under UWSM this unit can start before
          # the compositor's WAYLAND_DISPLAY has been imported into the user
          # manager, or before its socket exists. Wait (best effort, ~60 s) for a
          # usable Wayland socket, adopting the first one in $XDG_RUNTIME_DIR if the
          # variable is missing, and start anyway after that so a headless login
          # never hangs the unit.
          i=0
          while [ "$i" -lt 120 ]; do
            if [ -z "$WAYLAND_DISPLAY" ]; then
              for s in "$XDG_RUNTIME_DIR"/wayland-[0-9]; do
                if [ -S "$s" ]; then
                  WAYLAND_DISPLAY=$(${pkgs.coreutils}/bin/basename "$s")
                  export WAYLAND_DISPLAY
                  break
                fi
              done
            fi
            if [ -n "$WAYLAND_DISPLAY" ] && [ -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY" ]; then
              break
            fi
            ${pkgs.coreutils}/bin/sleep 0.5
            i=$((i + 1))
          done

          # EasyEffects (Qt) checks QSystemTrayIcon::isSystemTrayAvailable()
          # exactly once at startup and never retries; it returns false unless
          # DMS's org.kde.StatusNotifierWatcher is already on the session bus.
          # Wait for the bus name first, otherwise EE starts before DMS and
          # shows no tray icon.
          ${pkgs.glib}/bin/gdbus wait --session --timeout 60 org.kde.StatusNotifierWatcher || true
          exec ${lib.getExe pkgs.easyeffects} --service-mode
        '';

        # EasyEffects' virtual sink is created with monitor.channel-volumes=false,
        # so the sink's own volume (what Slate's slider and the volume keys set on
        # the default output) never reaches the monitor ports EasyEffects reads:
        # at 0% the audio still plays at full level. The property can be flipped on
        # the live node (verified: volume then follows the slider, 0 is silent),
        # but not at creation, so do it once the node exists after each (re)start.
        #
        # Deliberately does NOT touch the default input. Pinning it to
        # easyeffects_source meant apps recorded EasyEffects' virtual mic, whose
        # own capture followed some other device, so the Wave:3's hardware mute
        # button silenced nothing anyone was hearing. The default input is left
        # to WirePlumber's priorities in audio.nix (Wave:3 > BT headset >
        # laptop mic); the wave3.json input preset only applies to an app that
        # picks "Easy Effects Source" by hand. Default output is likewise left
        # to Slate's Output device list.
        # Best effort: if the sink never shows up the unit still runs.
        applyAudio = pkgs.writeShellScript "easyeffects-apply-audio" ''
          node_id() {
            ${pkgs.pipewire}/bin/pw-dump 2>/dev/null \
              | ${pkgs.jq}/bin/jq -r --arg n "$1" '.[] | select(.info.props."node.name" == $n) | .id' \
              | ${pkgs.coreutils}/bin/head -n1
          }
          i=0
          while [ "$i" -lt 120 ]; do
            sink=$(node_id easyeffects_sink)
            if [ -n "$sink" ]; then
              exec ${pkgs.pipewire}/bin/pw-cli set-param "$sink" Props '{ params = [ "monitor.channel-volumes" true ] }'
            fi
            ${pkgs.coreutils}/bin/sleep 0.5
            i=$((i + 1))
          done
        '';
      in {
        Unit = {
          Description = "EasyEffects audio effects (service mode)";
          After = ["pipewire.service" "wireplumber.service" "dms.service"];
          PartOf = ["wireplumber.service" "graphical-session.target"];
        };
        Service = {
          ExecStart = "${start}";
          ExecStartPost = "-${applyAudio}";
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
