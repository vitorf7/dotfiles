{...}: {
  flake.modules.homeManager.hypridle = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.hypridle.enable {
      assertions = [
        {
          assertion = osConfig.vitorf7.desktop.hyprland.enable;
          message = "vitorf7.desktop.hypridle.enable requires vitorf7.desktop.hyprland.enable = true";
        }
      ];

      home.packages = [pkgs.hypridle];

      xdg.configFile."hypr/hypridle.conf".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hypridle/.config/hypr/hypridle.conf";
    };
}
