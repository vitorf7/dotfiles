{inputs, ...}: {
  flake.modules.darwin.browsers = {...}: {
    homebrew.casks = [
      "arc"
      "brave-browser"
      "helium-browser"
      "vivaldi"
      "zen"
    ];
  };

  flake.modules.homeManager.browsers = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    isLinux = pkgs.stdenv.isLinux;
  in
    lib.mkIf osConfig.vitorf7.desktop.enable {
      home.packages = lib.optionals isLinux [
        inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      xdg.mimeApps.defaultApplications = lib.mkIf isLinux {
        "text/html" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
      };

      home.sessionVariables = lib.mkIf isLinux {
        MOZ_ENABLE_WAYLAND = "1";
      };

      # Historically forced to `true`: the IPU6 driver stack exposes ~45
      # internal pipeline-stage /dev/video* nodes (all just generically named
      # "ipu6") that raw V4L2 enumeration lists as if they were real cameras —
      # burying the actual Logitech C922 deep in Google Meet's camera picker.
      # Routing getUserMedia through PipeWire's camera provider exposed just
      # the two real devices.
      #
      # Reverted to `false` (2026-09): Zen's PipeWire/portal camera client
      # delivers a constantly laggy low-fps self-view in Google Meet even
      # though the negotiated link is MJPG 1280x720@60 (verified via pw-dump
      # + v4l2-ctl, no CPU bottleneck) while direct V4L2 and native camera
      # apps are smooth. Cost: the ipu6 node spam returns in Meet's picker —
      # pick "C922 Pro Stream Webcam" by name; Meet remembers the choice.
      #
      # Glob the profile dir rather than hardcoding the random profile
      # suffix Zen generates on first launch.
      home.activation.zenPipewireCamera = lib.mkIf isLinux (lib.hm.dag.entryAfter ["writeBoundary"] ''
        for profileDir in "$HOME"/.config/zen/*/; do
          [ -d "$profileDir" ] || continue
          cat > "$profileDir/user.js" <<'EOF'
// Managed by dotfiles (modules/browsers.nix).
user_pref("media.webrtc.camera.allow-pipewire", false);
user_pref("media.navigator.video.max_fr", 30);
user_pref("media.navigator.video.max_fs", 3600);
EOF
        done
      '');
    };
}
