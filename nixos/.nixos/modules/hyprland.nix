{...}: {
  flake.modules.nixos.hyprland = {
    config,
    pkgs,
    lib,
    ...
  }:
    lib.mkIf config.vitorf7.desktop.hyprland.enable {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      xdg.portal = {
        enable = true;
        extraPortals = [pkgs.xdg-desktop-portal-gtk];
        config = {
          common.default = ["hyprland" "gtk"];
          hyprland.default = ["hyprland" "gtk"];
        };
      };
    };

  flake.modules.homeManager.hyprland = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.hyprland.enable {
      home.packages = with pkgs; [
        hyprsunset
        hyprshot
        wlogout
        rofi
        waybar
        networkmanagerapplet
        swayosd
        nwg-look
        avizo
        nwg-dock-hyprland
        lxqt.lxqt-policykit

        wiremix
        bluetui
        wtype
        ydotool
      ]
      ++ lib.optionals (!osConfig.vitorf7.desktop.quickshell.enable) [
        # swaync ships a systemd user service (BusName=org.freedesktop.Notifications,
        # WantedBy=graphical-session.target) that starts automatically. Only install
        # it when quickshell is NOT active — otherwise quickshell owns the DBus
        # notification service and swaync.service would steal it.
        swaynotificationcenter
      ];

      systemd.user.services.ydotool = {
        Unit = {
          Description = "ydotoold — ydotool input event daemon";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.ydotool}/bin/ydotoold";
          Restart = "always";
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      xdg.configFile = {
        "hypr/scheme".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/scheme";
        "hypr/hyprland.lua".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/hyprland.lua";
        "hypr/.claude".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/.claude";
        "hypr/SETUP_README.md".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/SETUP_README.md";
        "hypr/scripts".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/scripts";
        "hypr/modules".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/modules";
        "rofi".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/rofi/.config/rofi";
        "waybar".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/waybar/.config/waybar";
        "swaync".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/swaync/.config/swaync";
        "wlogout".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/wlogout/.config/wlogout";
        "matugen".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/matugen/.config/matugen";
        # Only symlinked when quickshell is NOT active; its presence tells hyprland.lua
        # to autostart swaync as the notification daemon (waybar-based setup).
        # When quickshell is active it owns DBus org.freedesktop.Notifications instead.
        "hypr-swaync" = lib.mkIf (!osConfig.vitorf7.desktop.quickshell.enable) {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/swaync/.config/hypr-swaync";
        };
      };
    };

  flake.modules.homeManager.theming = {
    pkgs,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.enable {
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
