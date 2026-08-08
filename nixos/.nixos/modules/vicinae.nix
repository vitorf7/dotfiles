{ ... }:
{
  # macOS: install via Homebrew cask
  flake.modules.darwin.vicinae = { ... }: {
    homebrew.casks = [ "vicinae" ];
  };

  # All platforms: install package (Linux only) + symlink config
  flake.modules.homeManager.vicinae = { config, pkgs, lib, ... }: {
    home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.vicinae ];

    xdg.configFile."vicinae".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/vicinae/.config/vicinae";
  };
}
