{ config, pkgs, lib, osConfig, self, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
lib.mkIf osConfig.vitorf7.desktop.hyprland.enable {
  home.packages = with pkgs; [
    hyprlock
    hypridle
    hyprsunset
    wlogout
    rofi
    waybar
    swaynotificationcenter
    networkmanagerapplet
    vicinae
    swayosd
    nwg-look
    avizo

    self.packages.${pkgs.stdenv.hostPlatform.system}.hyprmod
    self.packages.${pkgs.stdenv.hostPlatform.system}.mouseless
  ];

  xdg.configFile = {
    "hypr".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/hyprland/.config/hypr";
    "rofi".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/rofi/.config/rofi";
    "waybar".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/waybar/.config/waybar";
    "swaync".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/swaync/.config/swaync";
    "wlogout".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/wlogout/.config/wlogout";
    "matugen".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/matugen/.config/matugen";
  };
}
