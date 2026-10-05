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
      (pkgs.symlinkJoin {
        name = "ferdium-v8-capped";
        paths = [pkgs.ferdium];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/ferdium \
            --add-flags "--js-flags=--max-old-space-size=512"
        '';
      })
      pkgs.rambox
    ];
  };
}
