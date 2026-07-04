{ config, lib, osConfig, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
lib.mkIf osConfig.vitorf7.desktop.ambxst.enable {
  assertions = [{
    assertion = osConfig.vitorf7.desktop.hyprland.enable;
    message = "vitorf7.desktop.ambxst.enable requires vitorf7.desktop.hyprland.enable = true";
  }];

  # Package, fonts, and system services are handled by the Ambxst NixOS module
  # (imported in mkHost.nix), activated via modules/system/ambxst.nix.
  #
  # The Hyprland integration (loadfile block) lives in the dotfiles symlink at
  # ~/dotfiles/hyprland/.config/hypr/hyprland.lua — no Nix management needed.

  # Symlink entire ~/.config/ambxst → dotfiles/ambxst/.config/ambxst
  xdg.configFile."ambxst".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ambxst/.config/ambxst";

  # Individual files under ~/.local/share/ambxst — the whole dir is not symlinked
  # because hyprland.lua / hyprland.conf there are Ambxst-managed, not user config.
  home.file.".local/share/ambxst/axctl.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ambxst/.local/share/ambxst/axctl.toml";

  home.file.".local/share/ambxst/pinnedapps.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ambxst/.local/share/ambxst/pinnedapps.json";
}
