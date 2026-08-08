{ ... }:
{
  flake.modules.darwin.media = { ... }: {
    homebrew.casks = [
      "spotify"
      "vlc"
      "elgato-wave-link"
    ];
    homebrew.brews = [
      "media-control"
    ];
  };

  flake.modules.homeManager.media = { pkgs, lib, osConfig, ... }:
    let
      isLinux  = pkgs.stdenv.isLinux;
      isDarwin = pkgs.stdenv.isDarwin;
    in
    lib.mkIf (osConfig.vitorf7.desktop.enable or (osConfig.vitorf7.darwin.enable or false)) {
      home.packages = with pkgs;
        lib.optionals (isLinux && pkgs.stdenv.isx86_64) [
          spotify
        ] ++ lib.optionals isDarwin [
          nowplaying-cli
          switchaudio-osx
        ];
    };
}
