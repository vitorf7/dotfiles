{ ... }:
{
  flake.modules.darwin.aerospace = { config, lib, ... }: lib.mkIf config.vitorf7.darwin.aerospace.enable {
    homebrew.taps = [ "nikitabobko/tap" ];
    homebrew.extraConfig = ''
      cask "nikitabobko/tap/aerospace", trusted: true
    '';
  };

  flake.modules.homeManager.aerospace = { config, lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.darwin.aerospace.enable {
    xdg.configFile."aerospace".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/aerospace/.config/aerospace";
  };
}
