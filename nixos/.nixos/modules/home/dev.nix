{ config, pkgs, self, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
{
  home.packages = with pkgs; [
    k9s
    lazygit
    nodejs
    yarn
    python3
    go
    rustup
    opencode
    rtk
    
    self.packages.${pkgs.stdenv.hostPlatform.system}.strongbox
  ];

  xdg.configFile = {
    "k9s".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/k9s/.config/k9s";
  };
}
