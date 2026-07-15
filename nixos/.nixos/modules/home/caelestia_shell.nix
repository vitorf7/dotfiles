{ pkgs, lib, osConfig, inputs, ... }:

lib.mkIf osConfig.vitorf7.desktop.caelestia_shell.enable {
  assertions = [
    {
      assertion = osConfig.vitorf7.desktop.quickshell.enable;
      message = "vitorf7.desktop.caelestia_shell.enable requires vitorf7.desktop.quickshell.enable = true";
    }
    {
      assertion = osConfig.vitorf7.desktop.hyprland.enable;
      message = "vitorf7.desktop.caelestia_shell.enable requires vitorf7.desktop.hyprland.enable = true (Caelestia Shell targets Hyprland)";
    }
  ];

  home.packages = [
    inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  systemd.user.services.caelestia-shell = {
    Unit = {
      Description = "Caelestia Shell Quickshell config for Hyprland";
      After = [ "wayland-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${inputs.caelestia-shell.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/caelestia-shell";
      Restart = "always";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
