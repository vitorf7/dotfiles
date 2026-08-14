{ ... }:
{
  flake.modules.darwin.communication = { ... }: {
    homebrew.casks = [
      "slack"
      "whatsapp"
      "zoom"
      "rambox"
      "ferdium"
    ];
  };

  flake.modules.homeManager.communication = { pkgs, lib, ... }: {
    home.packages = lib.optionals pkgs.stdenv.isLinux [
      pkgs.rambox
      pkgs.ferdium
    ];
  };
}
