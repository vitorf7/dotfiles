{ ... }:
{
  flake.modules.homeManager.alacritty = { config, pkgs, lib, ... }:
    let link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.alacritty ];
      xdg.configFile."alacritty".source = link "${config.home.homeDirectory}/dotfiles/alacritty/.config/alacritty";
    };
}
