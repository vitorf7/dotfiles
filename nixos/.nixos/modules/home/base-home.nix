{ config, pkgs, lib, osConfig, self, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  isDesktop = osConfig.vitorf7.desktop.hyprland.enable;
in
{
  home.username = "vitorf7";
  home.homeDirectory = "/home/vitorf7";

  home.sessionPath = [
    "$HOME/.local/share/bob/nvim-bin"
    "$HOME/.local/share/nvim/mason/bin"
  ];

  home.packages = with pkgs; [
    ghostty
    tmux
    bob
    git
    lazygit
    ripgrep
    stow
  ] 
  ++ lib.optionals isDesktop [
    hyprlock
    hyprsunset
    wlogout
    rofi-wayland
    networkmanagerapplet
    zen-browser
    spotify
    
    # NEW: Pulling the custom compiled package directly out of your flake outputs
    self.packages.${pkgs.system}.hyprmod
  ];

  # --- 1. Files directly inside your Home Directory ($HOME) ---
  home.file = {
    # Places .tmux.conf at the root of your home directory (~/.tmux.conf)
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.tmux.conf";
  };

  # --- 2. Files inside your Config Directory (~/.config) ---
  xdg.configFile = {
    "fish".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fish/.config/fish";
    "ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ghostty/.config/ghostty";
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos/nvim-kick";
  } 
  // lib.optionalAttrs isDesktop {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hyprland/.config/hypr";
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
    "wlogout".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/wlogout/.config/wlogout";
  };

  programs.home-manager.enable = true;
  home.stateVersion = "26.05";
}
