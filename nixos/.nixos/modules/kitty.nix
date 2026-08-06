{ ... }:
{
  flake.modules.darwin.kitty = { ... }: {
    homebrew.casks = [ "kitty" ];
  };

  flake.modules.homeManager.kitty = { pkgs, lib, ... }: {
    home.packages = lib.optionals pkgs.stdenv.isLinux [ pkgs.kitty ];
  };
}
