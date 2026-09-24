{...}: {
  flake.modules.darwin.communication = {...}: {
    homebrew.casks = [
      "slack"
      "whatsapp"
      "zoom"
      "ferdium"
      "rambox"
    ];
  };

  flake.modules.homeManager.communication = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.optionals pkgs.stdenv.isLinux [
      pkgs.ferdium
      pkgs.rambox
    ];
  };
}
