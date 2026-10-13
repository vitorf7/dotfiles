{...}: {
  flake.modules.homeManager.theming = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    # Declarative theme catalog — "downloading" another theme is appending a
    # line here and rebuilding. Themes not in nixpkgs follow the hand-pinned
    # derivation pattern in pkgs/ (see hyprmod.nix); anything dropped manually
    # into ~/.local/share/icons also works with zero Nix involvement.
    #
    # The *selection* is deliberately NOT managed here: home-manager's dconf
    # activation rewrites every managed key on each rebuild, which is what made
    # nwg-look/gsettings picks never stick. Defaults are seeded once below, and
    # switching happens at runtime: icon themes via nwg-look/hyprmod or
    # hypr/scripts/iconSelect.sh, cursor themes via the hyprmod GUI's Cursor
    # page (which persists its picks in ~/.config/hypr/hyprland-gui.lua, an
    # out-of-store symlink into the repo, loaded by hyprland.lua).
    #
    # Icon themes are plain packages — GTK finds them via XDG_DATA_DIRS, and a
    # single package may ship several sub-themes (papirus: Papirus,
    # Papirus-Dark, Papirus-Light).
    #
    # Cursor themes carry their theme name: they are also symlinked into
    # ~/.local/share/icons (one of the two user dirs hyprcursor actually
    # searches, per the Hyprland wiki), so packaged themes stay discoverable
    # once home.pointerCursor (which used to provide that wiring) is gone.
    # Any XCursor-format theme works too — hyprctl setcursor falls back to
    # XCursor when no hyprcursor manifest is found.
    iconThemes = with pkgs; [
      papirus-icon-theme
    ];

    cursorThemes = [
      {
        name = "rose-pine-hyprcursor";
        package = pkgs.rose-pine-hyprcursor;
      }
    ];
  in
    lib.mkIf osConfig.vitorf7.desktop.enable {
      home.packages = iconThemes ++ map (t: t.package) cursorThemes;

      # Make packaged cursor themes discoverable by hyprcursor without
      # relying on env-var search paths.
      xdg.dataFile = builtins.listToAttrs (
        map
        (t: {
          name = "icons/${t.name}";
          value.source = "${t.package}/share/icons/${t.name}";
        })
        cursorThemes
      );

      # Keep the home profile on the XCursor search path for apps that honor
      # it — same wiring home.pointerCursor used to provide before this module
      # stopped pinning a single cursor.
      home.sessionSearchVariables.XCURSOR_PATH = [
        "${config.home.profileDirectory}/share/icons"
      ];

      # Only color-scheme stays declaratively pinned. icon-theme, cursor-theme
      # and cursor-size are seeded with defaults once (home.activation
      # .themeDefaults below) and then owned by runtime tools.
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };

      qt = {
        enable = true;
        platformTheme.name = "gtk3";
      };

      home.activation.themeDefaults = lib.hm.dag.entryAfter ["dconfSettings"] ''
        if [[ -v DBUS_SESSION_BUS_ADDRESS ]]; then
          export DCONF_DBUS_RUN_SESSION=""
        else
          export DCONF_DBUS_RUN_SESSION="${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon"
        fi

        # Seed defaults only where unset — never clobber a runtime choice. The
        # dconfSettings step above resets the three keys this repo used to
        # manage exactly once (the first switch after they stopped being
        # managed); this immediately re-seeds them, so that switch is invisible
        # and later selections survive every rebuild.
        seedDconfKey() {
          if [[ -z "$($DCONF_DBUS_RUN_SESSION ${pkgs.dconf}/bin/dconf read "$1" 2>/dev/null)" ]]; then
            run $DCONF_DBUS_RUN_SESSION ${pkgs.dconf}/bin/dconf write "$1" "$2"
          fi
        }

        seedDconfKey /org/gnome/desktop/interface/icon-theme "'Papirus-Dark'"
        seedDconfKey /org/gnome/desktop/interface/cursor-theme "'rose-pine-hyprcursor'"
        seedDconfKey /org/gnome/desktop/interface/cursor-size "24"

        unset DCONF_DBUS_RUN_SESSION
      '';
    };
}
