{ ... }:

{
  imports = [
    ./core.nix
    ./desktop.nix
    ./theming.nix
    ./dev.nix
  ];

  home = {
    username = "vitorf7";
    homeDirectory = "/home/vitorf7";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
