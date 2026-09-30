{...}: {
  flake.modules.darwin.office = {
    config,
    lib,
    ...
  }: let
    cfg = config.vitorf7.darwin;
  in {
    homebrew.masApps =
      {}
      // lib.optionalAttrs cfg.work.enable {
        Keynote = 361285480;
        Numbers = 361304891;
        Pages = 361309726;
      };
  };

  flake.modules.homeManager.office = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    isLinux = pkgs.stdenv.isLinux;
  in
    lib.mkIf (isLinux && (osConfig.vitorf7.desktop.enable or false)) {
      home.packages = with pkgs; [
        libreoffice
      ];
    };
}
