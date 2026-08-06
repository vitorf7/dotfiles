{ inputs, ... }:
{
  systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

  perSystem = { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      packages = {
        hyprmod    = inputs.hyprmod.packages.${system}.default;
        tide-island = pkgs.callPackage ../pkgs/tide-island.nix { };
        go-latest  = pkgs.callPackage ../pkgs/go-latest.nix { };
        strongbox  = pkgs.callPackage ../pkgs/strongbox.nix { };
      };
    };
}
