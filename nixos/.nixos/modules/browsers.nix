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

      # The IPU6 driver stack exposes ~45 internal pipeline-stage /dev/video*
      # nodes (all just generically named "ipu6") that raw V4L2 enumeration
      # lists as if they were real cameras — burying the actual Logitech
      # C922 deep in Google Meet's camera picker. PipeWire's own camera
      # provider already exposes just the two real devices cleanly (Built-in
      # Front Camera via libcamera, C922 via V4L2); this pref makes
      # getUserMedia route through that instead of raw V4L2 enumeration.
      # Glob the profile dir rather than hardcoding the random profile
      # suffix Zen generates on first launch.
      home.activation.zenPipewireCamera = lib.mkIf isLinux (lib.hm.dag.entryAfter ["writeBoundary"] ''
        for profileDir in "$HOME"/.config/zen/*/; do
          [ -d "$profileDir" ] || continue
          cat > "$profileDir/user.js" <<'EOF'
// Managed by dotfiles (modules/browsers.nix).
user_pref("media.webrtc.camera.allow-pipewire", true);
EOF
        done
      '');
    };
}
