{ config, lib, inputs, ... }:

lib.mkIf config.vitorf7.desktop.flatpak.enable {
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  services.flatpak = {
    enable = true;
    remotes = [{
      name = "sonuscape";
      location = "https://dl.sonuscape.net/flatpak/sonuscape.flatpakrepo";
    }];
    packages = [{
      appId = "net.sonuscape.mouseless";
      origin = "sonuscape";
    }];
  };
}
