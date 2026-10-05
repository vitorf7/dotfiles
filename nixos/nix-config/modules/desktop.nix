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

      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        SDL_VIDEODRIVER = "wayland";
        _JAVA_AWT_WM_NONREPARENTING = "1";
      };
    };
}
