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
      # lists as if they were real cameras. There are two ways to handle this:
      #
      # --- Option A: PipeWire camera portal (DEFAULT) ---
      # Routes getUserMedia through PipeWire's camera provider, which filters
      # the ipu6 noise and exposes only the real webcam(s). Clean picker in
      # Google Meet. If self-view is laggy, switch to Option B.
      #
      # --- Option B: V4L2 direct ---
      # Uses raw V4L2 enumeration. All 50+ ipu6 nodes appear in Meet's picker;
      # you must select the real webcam by name (e.g. "C922 Pro Stream Webcam").
      # Meet remembers the choice. Native camera apps are smooth.
      #
      # To switch, swap the `allow-pipewire` value below (true <-> false) and rebuild.
      #
      # Glob the profile dir rather than hardcoding the random profile
      # suffix Zen generates on first launch.
      home.activation.zenPipewireCamera = lib.mkIf isLinux (lib.hm.dag.entryAfter ["writeBoundary"] ''
        for profileDir in "$HOME"/.config/zen/*/; do
          [ -d "$profileDir" ] || continue
          cat > "$profileDir/user.js" <<'EOF'
// Managed by dotfiles (modules/browsers.nix).
// --- PipeWire camera portal (Option A) ---
user_pref("media.webrtc.camera.allow-pipewire", true);

// --- V4L2 direct (Option B) ---
// Uncomment the line below and comment out the one above to use raw V4L2.
// user_pref("media.webrtc.camera.allow-pipewire", false);

user_pref("media.navigator.video.max_fr", 30);
user_pref("media.navigator.video.max_fs", 3600);
EOF
        done
      '');
    };
}
