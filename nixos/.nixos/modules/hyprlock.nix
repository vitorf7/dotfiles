{...}: {
  flake.modules.homeManager.hyprlock = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.hyprlock.enable {
      assertions = [
        {
          assertion = osConfig.vitorf7.desktop.hyprland.enable;
          message = "vitorf7.desktop.hyprlock.enable requires vitorf7.desktop.hyprland.enable = true";
        }
      ];

      home.packages = [pkgs.hyprlock];

      xdg.configFile."hypr/hyprlock.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprlock/.config/hypr/hyprlock.conf";

      xdg.configFile."hypr/hyprlock".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprlock/.config/hypr/hyprlock";
    };
}
