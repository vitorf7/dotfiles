{ self, ... }:
{
  flake.modules.nixos.hyprland = { config, pkgs, lib, ... }: lib.mkIf config.vitorf7.desktop.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common.default   = [ "hyprland" "gtk" ];
        hyprland.default = [ "hyprland" "gtk" ];
      };
    };
  };

  flake.modules.homeManager.hyprland = { config, pkgs, lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.hyprland.enable {
    home.packages = with pkgs; [
      hyprlock
      hypridle
      hyprsunset
      hyprshot
      wlogout
      rofi
      waybar
      swaynotificationcenter
      networkmanagerapplet
      swayosd
      nwg-look
      avizo
      nwg-dock-hyprland
      lxqt.lxqt-policykit

      wiremix
      bluetui

      self.packages.${pkgs.stdenv.hostPlatform.system}.hyprmod
    ];

    xdg.configFile = {
      "hypr".source    = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr";
      "rofi".source    = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rofi/.config/rofi";
      "waybar".source  = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/waybar/.config/waybar";
      "swaync".source  = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/swaync/.config/swaync";
      "wlogout".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wlogout/.config/wlogout";
      "matugen".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/matugen/.config/matugen";
    };
  };

  flake.modules.homeManager.theming = { pkgs, lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.enable {
    home.packages = with pkgs; [
      papirus-icon-theme
      rose-pine-hyprcursor
    ];

    home.pointerCursor = {
      enable = true;
      name = "rose-pine-hyprcursor";
      package = pkgs.rose-pine-hyprcursor;
      gtk.enable = false;
      size = 24;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        icon-theme = "Papirus-Dark";
        cursor-theme = "rose-pine-hyprcursor";
        cursor-size = 24;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
    };
  };
}
