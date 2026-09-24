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

      # uinput is only present as a lazy-autoload static device node (0600 root:root)
      # until the module is actually loaded — and permission checks on that node
      # happen before autoload kicks in, so an unprivileged open (ydotoold) fails
      # before the "input" group udev rule (see users.nix) ever gets a chance to
      # apply. Force-load it at boot so the real "add" uevent fires and the rule
      # sticks.
      boot.kernelModules = ["uinput"];

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

      # This bare Hyprland setup has no session manager (UWSM, gnome-session,
      # etc.) to ever activate graphical-session.target, and Hyprland itself
      # can't do it directly either — the target ships upstream with
      # RefuseManualStart=yes, so even `systemctl --user start
      # graphical-session.target` from Hyprland's own autostart is refused.
      # It can only be pulled in as a dependency of some other unit that
      # legitimately starts. This service exists purely to hold that
      # dependency open for the lifetime of the session — autostart.lua
      # starts it first, which transitively activates graphical-session.target,
      # which in turn lets everything actually WantedBy/Requisite= it
      # (xdg-desktop-portal, openlogi-agent, ydotool, dms) start correctly.
      # Without this, camera/screen-share portals and the above silently
      # never start on every single login, not just after a rebuild.
      systemd.user.services.graphical-session-holder = {
        Unit = {
          Description = "Keep graphical-session.target active (no session manager to do this for bare Hyprland)";
          Wants = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${pkgs.coreutils}/bin/sleep infinity";
          Restart = "always";
        };
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
