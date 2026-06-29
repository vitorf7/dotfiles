{ ... }:

{
  imports = [
    ./core.nix
    ./desktop.nix
    ./hyprland.nix
    ./theming.nix
    ./dev.nix
    ./quickshell.nix
    ./qs_brain_shell.nix
  ];

  home = {
    username = "vitorf7";
    homeDirectory = "/home/vitorf7";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
