{ pkgs, lib, osConfig, self, ... }:

lib.mkIf osConfig.vitorf7.desktop.tide_island.enable {
  assertions = [
    {
      assertion = osConfig.vitorf7.desktop.quickshell.enable;
      message = "vitorf7.desktop.tide_island.enable requires vitorf7.desktop.quickshell.enable = true";
    }
    {
      assertion = osConfig.vitorf7.desktop.hyprland.enable;
      message = "vitorf7.desktop.tide_island.enable requires vitorf7.desktop.hyprland.enable = true (Tide Island targets Hyprland)";
    }
  ];

  home.packages = [
    self.packages.${pkgs.stdenv.hostPlatform.system}.tide-island
  ];

  systemd.user.services.tide-island = {
    Unit = {
      Description = "Tide Island Dynamic Island for Hyprland";
      After = [ "wayland-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${self.packages.${pkgs.stdenv.hostPlatform.system}.tide-island}/bin/tide-island";
      Restart = "always";
      RestartSec = 3;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
