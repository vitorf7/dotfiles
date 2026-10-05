{...}: {
  flake.modules.nixos.winboat = {
    config,
    lib,
    pkgs,
    ...
  }:
    lib.mkIf config.vitorf7.desktop.winboat.enable {
      environment.systemPackages = with pkgs; [
        winboat
        freerdp
      ];
    };
}
