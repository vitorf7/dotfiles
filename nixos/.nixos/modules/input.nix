{ ... }:
{
  flake.modules.darwin.input = { ... }: {
    homebrew.casks = [
      "karabiner-elements"
      "homerow"
      "keycastr"
      "mouseless@preview"
      "openlogi"
    ];
  };

  flake.modules.homeManager.input = { config, pkgs, lib, ... }:
    home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.openlogi ];

    let
      isDarwin = pkgs.stdenv.isDarwin;
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    lib.mkIf isDarwin {
      xdg.configFile."karabiner".source = link "${config.home.homeDirectory}/dotfiles/karabiner/.config/karabiner";
    };
}
