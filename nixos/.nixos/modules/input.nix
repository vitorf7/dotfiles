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

  flake.modules.homeManager.input = { config, pkgs, lib, ... }: {
    home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.openlogi ];
    xdg.configFile = lib.mkIf pkgs.stdenv.isDarwin {
      "karabiner".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/karabiner/.config/karabiner";
    };
  };
}
