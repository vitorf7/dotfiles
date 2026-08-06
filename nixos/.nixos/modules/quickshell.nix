{ ... }:
{
  flake.modules.nixos.quickshell = { config, lib, ... }: lib.mkIf config.vitorf7.desktop.quickshell.enable {
    services.upower.enable = true;
  };

  flake.modules.homeManager.quickshell = { pkgs, lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.quickshell.enable {
    home.packages = with pkgs; [
      quickshell
      playerctl
      cava
      wf-recorder
      imagemagick
      brightnessctl
      libnotify
      cliphist
    ];
  };
}
