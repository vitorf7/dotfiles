{ ... }:
{
  flake.modules.nixos.gaming = { config, lib, pkgs, ... }: lib.mkIf config.vitorf7.desktop.gaming.enable {
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    programs.gamemode.enable = true;
    environment.systemPackages = with pkgs; [
      heroic
      (retroarch.withCores (cores: with cores; [
        mgba
        snes9x
        beetle-psx-hw
        genesis-plus-gx
        mupen64plus
        nestopia
        gambatte
        desmume
      ]))
    ];
  };

  flake.modules.homeManager.gaming = { lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.gaming.enable {
    programs.lutris.enable = true;
    programs.mangohud = {
      enable = true;
      settings = {
        gamemode = true;
        gpu_fan = true;
        show_fps_limit = true;
        fps = true;
      };
    };
  };

  flake.modules.darwin.gaming = { config, lib, ... }:
    lib.mkIf (!config.vitorf7.darwin.work.enable) {
      homebrew.casks = [
        "steam"
        "openemu"
      ];
    };
}
