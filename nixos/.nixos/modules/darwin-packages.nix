{ ... }:
{
  flake.modules.homeManager.darwin-packages = { pkgs, ... }: {
    home.packages = with pkgs; [
      graphviz poppler ghostscript imagemagick ffmpegthumbnailer wimlib
      mas scdoc yq-go evans
    ];
  };
}
