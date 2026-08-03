{ config, pkgs, lib, self, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
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
    rtk    # token-optimised Claude Code proxy — same package on Linux and macOS
    stern
    krew

    self.packages.${pkgs.stdenv.hostPlatform.system}.strongbox
  ];

  xdg.configFile."k9s".source = link "${dotfilesPath}/k9s/.config/k9s";
}
