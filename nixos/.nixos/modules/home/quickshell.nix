{ pkgs, lib, osConfig, inputs, ... }:

lib.mkIf osConfig.vitorf7.desktop.quickshell.enable {
  home.packages = with pkgs; [
    quickshell

    # Common runtime deps available to any Quickshell config
    playerctl
    cava
    wf-recorder
    imagemagick
    brightnessctl
    libnotify
    cliphist
    nerd-fonts.jetbrains-mono
  ];
}
