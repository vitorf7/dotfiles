{ pkgs, lib, osConfig, ... }:

lib.mkIf osConfig.vitorf7.desktop.enable {
  home.packages = with pkgs; [
    papirus-icon-theme
    rose-pine-gtk-theme
    rose-pine-hyprcursor
  ];

  home.pointerCursor = {
    name = "rose-pine-hyprcursor";
    package = pkgs.rose-pine-hyprcursor;
    size = 24;
    gtk.enable = false;
  };

  # FreeDesktop color-scheme preference — read by Ghostty, GTK4 apps,
  # xdg-desktop-portal, and any portal-aware application.
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "Rose-Pine";
      icon-theme = "Papirus-Dark";
      cursor-theme = "rose-pine-hyprcursor";
      cursor-size = 24;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };
}
