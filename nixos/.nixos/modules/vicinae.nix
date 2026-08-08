{ ... }:
{
  flake.modules.darwin.vicinae = { ... }: {
    homebrew.casks = [ "vicinae" ];
  };

  flake.modules.homeManager.vicinae = { config, lib, osConfig, ... }:
    lib.mkIf osConfig.vitorf7.darwin.enable {
      xdg.configFile."vicinae".source =
        config.lib.file.mkOutOfStoreSymlink
          "${config.home.homeDirectory}/dotfiles/vicinae/.config/vicinae";
    };
}
