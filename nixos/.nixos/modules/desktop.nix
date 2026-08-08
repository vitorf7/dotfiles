{ ... }:
{
  flake.modules.homeManager.desktop = { config, pkgs, lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.enable {
    home.packages = with pkgs; [
      xdg-utils
      v4l-utils
      easyeffects
      pavucontrol
      alsa-utils
    ];

    home.sessionVariables = {
      NIXOS_OZONE_WL          = "1";
      QT_QPA_PLATFORM         = "wayland";
      SDL_VIDEODRIVER         = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
