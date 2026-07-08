{ config, lib, inputs, ... }:

{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  config = lib.mkIf config.vitorf7.desktop.flatpak.enable {
    services.flatpak = {
      enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
      {
        name = "sonuscape";
        location = "https://dl.sonuscape.net/flatpak/sonuscape.flatpakrepo";
      }
    ];
      packages = [{
        appId = "net.sonuscape.mouseless";
        origin = "sonuscape";
      }];
    };
  };
}
