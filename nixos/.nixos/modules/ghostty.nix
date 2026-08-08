{ ... }:
{
  flake.modules.darwin.ghostty = { ... }: {
    homebrew.casks = [ "ghostty" ];
  };

  flake.modules.homeManager.ghostty = { config, pkgs, lib, ... }:
    let link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.ghostty ];
      xdg.configFile."ghostty".source = link "${config.home.homeDirectory}/dotfiles/ghostty/.config/ghostty";
    };
}
