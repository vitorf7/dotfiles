# Slate (https://github.com/daylerees/slate): a Hyprland + Quickshell desktop
# shell that runs as its own "Slate" login session, with its own Hyprland
# config (~/.config/hypr isn't read there). The package and the generic
# `programs.slate` module live in pkgs/slate/ so they can go upstream as-is;
# this file only maps vitorf7.desktop.slate.enable onto them and symlinks
# ~/.config/slate (settings.json, hypr/ and user/ tweaks) to dotfiles.
{...}: let
  # Slate replaces DMS rather than sitting beside it: DMS's NixOS service is
  # WantedBy graphical-session.target, which the Slate session (under UWSM)
  # activates too, so both shells would start — two bars, two notification
  # servers.
  assertionsFor = cfg: [
    {
      assertion = cfg.desktop.hyprland.enable;
      message = "vitorf7.desktop.slate.enable requires vitorf7.desktop.hyprland.enable = true";
    }
    {
      assertion = cfg.desktop.quickshell.enable;
      message = "vitorf7.desktop.slate.enable requires vitorf7.desktop.quickshell.enable = true";
    }
    {
      assertion = !cfg.desktop.dank_material_shell.enable;
      message = "vitorf7.desktop.slate.enable replaces DMS: set vitorf7.desktop.dank_material_shell.enable = false (its graphical-session.target service would start inside the Slate session too)";
    }
  ];
in {
  flake.modules.nixos.slate = {
    config,
    lib,
    ...
  }: {
    imports = [../pkgs/slate/nixos-module.nix];

    config = lib.mkIf config.vitorf7.desktop.slate.enable {
      assertions = assertionsFor config.vitorf7;
      programs.slate.enable = true;
      # GDM still lists every session; this only preselects Slate.
      services.displayManager.defaultSession = lib.mkDefault "slate";
    };
  };

  flake.modules.homeManager.slate = {
    config,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.slate.enable {
      assertions = assertionsFor osConfig.vitorf7;

      # The whole folder, out of the store, so Slate's Settings can write
      # settings.json back into dotfiles.
      xdg.configFile."slate".source =
        config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/qs-slate/.config/slate";
    };
}
