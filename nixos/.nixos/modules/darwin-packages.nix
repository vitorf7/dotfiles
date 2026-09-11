{...}: {
  flake.modules.homeManager.darwin-packages = {pkgs, ...}: {
    home.packages = with pkgs; [
      graphviz
      poppler
      ghostscript
      wimlib
      mas
      scdoc
      yq-go
    ];
  };
}
