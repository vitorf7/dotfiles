{self, ...}: {
  # Trialled for meetings only, alongside SpeakoFlow (which keeps dictation).
  #
  # No NixOS half: upstream's nixosModule only sets up ydotool + uinput +
  # group membership for Wayland paste, which users.nix and hyprland.nix
  # already provide. Meetings need no aloop bridge like SpeakoFlow's — the
  # app records PipeWire's default sink monitor directly.
  #
  # No autostart service either: there's no documented start-hidden flag, so
  # launch it before calls. Its dictation hotkey must stay off our Hyprland
  # binds — it re-binds via hyprctl on every launch, unbinding any clash.
  flake.modules.homeManager.openwhispr = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.openwhispr.enable {
      home.packages = [self.packages.${pkgs.stdenv.hostPlatform.system}.openwhispr];

      # OpenWhispr generates its Hyprland binds into ~/.config/hypr/openwhispr-binds.lua
      # (hyprland.lua loads it with a pcall'd require — see the last line there).
      # Linking it into the repo keeps the file present only while this module is
      # enabled, and the app's in-place writes land in git-tracked storage.
      xdg.configFile."hypr/openwhispr-binds.lua".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/modules/openwhispr-binds.lua";

      # A plain file left at the link's path (from before this link existed, or
      # if the app ever replaces it) would make activation die at
      # checkLinkTargets. Absorb it into the repo first, then remove it.
      home.activation.openwhisprBindsStraySync = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        live="${config.home.homeDirectory}/.config/hypr/openwhispr-binds.lua"
        repo="${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/modules/openwhispr-binds.lua"
        if [[ -f "$live" && ! -L "$live" ]]; then
          if [[ -s "$live" ]]; then
            run cp "$live" "$repo"
          fi
          run rm -f "$live"
        fi
      '';
    };
}
