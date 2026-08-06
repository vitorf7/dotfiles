{ inputs, ... }:
{
  flake.modules.homeManager.desktop = { config, pkgs, lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.enable {
    home.packages = with pkgs; [
      xdg-utils
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      v4l-utils
      easyeffects
      pavucontrol
      alsa-utils
    ] ++ lib.optionals pkgs.stdenv.isx86_64 [
      spotify
    ];

    xdg.mimeApps.defaultApplications = {
      "text/html"           = "zen.desktop";
      "x-scheme-handler/http"  = "zen.desktop";
      "x-scheme-handler/https" = "zen.desktop";
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND      = "1";
      NIXOS_OZONE_WL          = "1";
      QT_QPA_PLATFORM         = "wayland";
      SDL_VIDEODRIVER         = "wayland";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
