{ pkgs, lib, osConfig, ... }:

lib.mkIf osConfig.vitorf7.desktop.hyprland.enable {
  home.packages = with pkgs; [
    nwg-look
    papirus-icon-theme
    # Add your preferred GTK theme package here, e.g.:
    # rose-pine-gtk-theme
    # catppuccin-gtk
  ];

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Sans";
      size = 11;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
  };
}
