{ config, pkgs, lib, osConfig, inputs, ... }:

lib.mkIf osConfig.vitorf7.desktop.enable {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        IdentityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
      };
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/personalgit.pub";
      };
      "personalgit" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "~/.ssh/personalgit.pub";
        IdentitiesOnly = true;
      };
    };
  };

  home.packages = with pkgs; [
    xdg-utils
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    nerd-fonts.monaspace

    # Webcam control and virtual camera tooling
    v4l-utils

    # Audio: works with Elgato Wave mic and any USB audio device via PipeWire.
    # easyeffects provides noise suppression, EQ, and compressor for the mic.
    # pavucontrol provides GUI volume control, including boosting above 100%.
    easyeffects
    pavucontrol
    alsa-utils
  ] ++ lib.optionals pkgs.stdenv.isx86_64 [
    spotify
  ];

  xdg.mimeApps.defaultApplications = {
    "text/html" = "zen.desktop";
    "x-scheme-handler/http" = "zen.desktop";
    "x-scheme-handler/https" = "zen.desktop";
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
  };
}
