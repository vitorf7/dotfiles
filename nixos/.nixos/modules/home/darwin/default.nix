{ config, lib, username, ... }:

{
  imports = [ ../core.nix ../git.nix ../secrets.nix ../dev.nix ./packages.nix ./symlinks.nix ];

  home = {
    username = username;
    homeDirectory = lib.mkForce "/Users/${username}";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
