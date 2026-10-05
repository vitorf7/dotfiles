{inputs, ...}: let
  # DMS 1.6-beta currently ships symlinks inside share/quickshell/dms/ that
  # point to files not copied into the output, breaking the noBrokenSymlinks
  # fixup hook. Override the package to remove them before the hook runs.
  dmsShell = pkgs:
    inputs.dank-material-shell.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
    (old: {
      preFixup =
        (old.preFixup or "")
        + ''
          rm -f $out/share/quickshell/dms/AGENTS.md \
                $out/share/quickshell/dms/CLAUDE.md
        '';
    });
in {
  flake.modules.nixos.dank-material-shell = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.dank-material-shell.nixosModules.dank-material-shell];

    config = lib.mkIf config.vitorf7.desktop.dank_material_shell.enable {
      programs.dank-material-shell = {
        enable = true;
        package = dmsShell pkgs;
        systemd.enable = true;
      };
    };
  };

  flake.modules.homeManager.dank-material-shell = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }: {
    imports = [inputs.dank-material-shell.homeModules.dank-material-shell];

    config = lib.mkIf osConfig.vitorf7.desktop.dank_material_shell.enable {
      assertions = [
        {
          assertion = osConfig.vitorf7.desktop.quickshell.enable;
          message = "vitorf7.desktop.dank_material_shell.enable requires vitorf7.desktop.quickshell.enable = true";
        }
        {
          assertion = osConfig.vitorf7.desktop.hyprland.enable;
          message = "vitorf7.desktop.dank_material_shell.enable requires vitorf7.desktop.hyprland.enable = true";
        }
      ];

      programs.dank-material-shell = {
        enable = true;
        package = dmsShell pkgs;
        systemd.enable = false;
      };

      home.sessionVariables = {
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
      };

      xdg.configFile."hypr-dank-material-shell/keybinds.lua".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/dank-material-shell/.config/hypr/modules/dank-material-shell-keybinds.lua";

      # DMS shell settings — bar layout, widgets, fonts, corner radius, etc.
      # Using mkOutOfStoreSymlink so DMS can write back to this file when the
      # user changes settings through the GUI.
      xdg.configFile."DankMaterialShell/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/dank-material-shell/.config/DankMaterialShell/settings.json";
    };
  };
}
