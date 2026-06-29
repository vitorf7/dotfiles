{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
{
  programs.git = {
    enable = true;
    settings = {
      gpg.format = "ssh";
      "gpg \"ssh\"".program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      commit.gpgsign = true;
      # signingKey, user.name, and user.email live in ~/.gitconfig.local
      # (not committed — run scripts/setup-gitconfig-local.sh to create it)
      include.path = "~/.gitconfig.local";
    };
  };

  # npm install -g writes to the Nix store by default, which is read-only.
  # Redirect the global prefix to a writable user directory instead.
  home.sessionVariables.NPM_CONFIG_PREFIX = "${config.home.homeDirectory}/.npm-global";
  home.sessionPath = [ "${config.home.homeDirectory}/.npm-global/bin" ];

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
