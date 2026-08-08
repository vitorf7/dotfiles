{ ... }:
{
  flake.modules.darwin.input = { ... }: {
    homebrew.casks = [
      "karabiner-elements"
      "homerow"
      "keycastr"
      "mouseless@preview"
    ];
  };

  flake.modules.homeManager.input = { config, pkgs, lib, ... }:
    let
      isDarwin = pkgs.stdenv.isDarwin;
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    lib.mkIf isDarwin {
      xdg.configFile."karabiner".source = link "${config.home.homeDirectory}/dotfiles/karabiner/.config/karabiner";
    };
}
