{ config, pkgs, lib, osConfig, self, inputs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  isDesktop = osConfig.vitorf7.desktop.hyprland.enable;
in
lib.mkIf isDesktop {
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

    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    self.packages.${pkgs.system}.hyprmod
    self.packages.${pkgs.system}.mouseless
  ] ++ lib.optionals pkgs.stdenv.isx86_64 [
    spotify
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
