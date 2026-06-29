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
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default

    nerd-fonts.monaspace

    # Webcam control and virtual camera tooling
    v4l-utils

    # Audio: works with Elgato Wave mic and any USB audio device via PipeWire.
    # easyeffects provides noise suppression, EQ, and compressor for the mic.
    easyeffects
    alsa-utils
  ] ++ lib.optionals pkgs.stdenv.isx86_64 [
    spotify
  ];
}
