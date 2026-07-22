{ config, pkgs, lib, inputs, ... }:

let
  # Hyprland's own nixpkgs may be newer than ours (it requires wayland-protocols
  # >= 1.49). Pull mesa from there so graphics drivers stay in sync and we avoid
  # FPS drops / graphical glitches on the PRIME hybrid GPU setup.
  pkgs-hypr = inputs.hyprland.inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
lib.mkIf config.vitorf7.desktop.hyprland.enable {
  programs.hyprland = {
    enable = true;
    # Use the flake packages so hyprland and its portal are always in sync.
    # This gives us the latest upstream version instead of the nixpkgs-bundled
    # one, which may lag behind and lack features (e.g. hyprctl repl).
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # Pin mesa to Hyprland's nixpkgs to prevent driver version mismatches between
  # the compositor and the rest of the graphics stack (PRIME offload setup).
  hardware.graphics = {
    package = pkgs-hypr.mesa;
    enable32Bit = true;
    package32 = pkgs-hypr.pkgsi686Linux.mesa;
  };

  # programs.hyprland.enable already enables xdg-desktop-portal-hyprland and
  # sets up the portal. We only need to add gtk here as a fallback for
  # non-Hyprland portal requests, and keep the GNOME portal for GDM/GNOME.
  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "hyprland" "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
      gnome.default = [ "gnome" "gtk" ];
    };
  };
}
