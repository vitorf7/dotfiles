{ username, ... }:

{
  imports = [
    ./core.nix
    ./git.nix
    ./secrets.nix
    ./desktop.nix
    ./hyprland.nix
    ./theming.nix
    ./dev.nix
    ./quickshell.nix
    ./qs_brain_shell.nix
    ./ambxst.nix
    ./tide_island.nix
    ./caelestia_shell.nix
  ];

  home = {
    username = username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
