{ ... }:
{
  flake.modules.nixos.winboat = { config, lib, pkgs, ... }:
    lib.mkIf config.vitorf7.desktop.winboat.enable {
      nixpkgs.config.permittedInsecurePackages = [
        "electron-40.10.5"
      ];
      environment.systemPackages = with pkgs; [
        winboat
        freerdp
      ];
    };
}
