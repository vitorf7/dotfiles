{ ... }:
{
  flake.modules.nixos.ambxst = { config, lib, ... }: lib.mkIf config.vitorf7.desktop.ambxst.enable {
    programs.ambxst.enable = true;
  };

  flake.modules.homeManager.ambxst = { config, lib, osConfig, ... }:
    let dotfilesPath = "${config.home.homeDirectory}/dotfiles";
    in lib.mkIf osConfig.vitorf7.desktop.ambxst.enable {
      assertions = [{
        assertion = osConfig.vitorf7.desktop.hyprland.enable;
        message = "vitorf7.desktop.ambxst.enable requires vitorf7.desktop.hyprland.enable = true";
      }];

      xdg.configFile."ambxst".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ambxst/.config/ambxst";

      home.file.".local/share/ambxst/axctl.toml".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ambxst/.local/share/ambxst/axctl.toml";

      home.file.".local/share/ambxst/pinnedapps.json".source =
        config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ambxst/.local/share/ambxst/pinnedapps.json";
    };
}
