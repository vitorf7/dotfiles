{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
{
  home.packages = with pkgs; [
    k9s
    lazygit
    nodejs
    go
    rustup
    opencode
  ];

  xdg.configFile = {
    "k9s".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/k9s/.config/k9s";
  };
}
