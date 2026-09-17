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

      xdg.configFile."hypr-hyprmod/hyprland-gui.lua".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprmod/.config/hypr/hyprland-gui.lua";
    };
}
