{ pkgs, lib, osConfig, ... }:

lib.mkIf osConfig.vitorf7.desktop.enable {
  home.packages = with pkgs; [
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
    platformTheme.name = "gtk3";
  };
}
