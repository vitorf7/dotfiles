{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
{
  programs.git = {
    enable = true;
    settings = {
      gpg.format = "ssh";
      # Use the stable system symlink rather than a nix store path, which
      # would change on every 1Password update and break signing after rebuild.
      "gpg \"ssh\"".program = "/run/current-system/sw/bin/op-ssh-sign";
      commit.gpgsign = true;
      # signingKey, user.name, and user.email live in ~/.gitconfig.local
      # (not committed — run scripts/setup-gitconfig-local.sh to create it)
      include.path = "~/.gitconfig.local";
    };
  };

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
