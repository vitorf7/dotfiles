{inputs, ...}: {
  flake.modules.darwin.databases = {...}: {
    homebrew.casks = [
      "beekeeper-studio"
      "dbeaver-community"
      "insomnia"
      "postman"
    ];
  };

  # beekeeper-studio is pulled from nixpkgs-stable, not the unstable pin
  # everything else uses: unstable currently flags it insecure (EOL bundled
  # Electron) but nixos-26.05 hasn't (yet) backported that flag onto its
  # older 5.7.3 release, so this sidesteps needing
  # nixpkgs.config.permittedInsecurePackages.
  flake.modules.homeManager.databases = {pkgs, ...}: let
    # Not `config = pkgs.config;` — that re-exposes the live pkgs.config
    # attrset (internal fields included) into a different nixpkgs revision's
    # import and can fail to type-check there.
    pkgs-stable = import inputs.nixpkgs-stable {inherit (pkgs) system; config.allowUnfree = true;};
  in {
    home.packages = [
      pkgs.postman
      pkgs-stable.beekeeper-studio
    ];
  };
}
