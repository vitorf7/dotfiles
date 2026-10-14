{self, ...}: {
  flake.modules.homeManager.hyprmod = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.hyprmod.enable {
      assertions = [
        {
          assertion = osConfig.vitorf7.desktop.hyprland.enable;
          message = "vitorf7.desktop.hyprmod.enable requires vitorf7.desktop.hyprland.enable = true";
        }
      ];

      home.packages = [self.packages.${pkgs.stdenv.hostPlatform.system}.hyprmod];

      xdg.configFile."hypr/hyprland-gui.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprmod/.config/hypr/hyprland-gui.lua";

      # hyprmod's GUI Save writes hyprland-gui.lua via temp-file+rename, which
      # replaces the out-of-store symlink above with a plain regular file and
      # makes the next activation die at checkLinkTargets ("Existing file
      # would be clobbered"). Absorb the stray before that check: copy its
      # content back into the repo (GUI picks become git-tracked), then remove
      # it so the symlink can be recreated.
      home.activation.hyprmodGuiStraySync = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        live="${config.home.homeDirectory}/.config/hypr/hyprland-gui.lua"
        repo="${config.home.homeDirectory}/dotfiles/hyprmod/.config/hypr/hyprland-gui.lua"
        if [[ -f "$live" && ! -L "$live" ]]; then
          if [[ -s "$live" ]]; then
            run cp "$live" "$repo"
          fi
          run rm -f "$live"
        fi
      '';
    };
}
