{inputs, ...}: {
  systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];

  perSystem = {system, ...}: let
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
      # wiresteward's go.mod needs >=1.26.6; nixpkgs' default `go` lags
      # behind, so buildGoModule packages here use go_1_26 instead.
      overlays = [(final: prev: {go = prev.go_1_26;})];
    };

    # tide-island, mouseless, and hyprmod are Hyprland/Linux-only; guard them
    # so darwin evals don't throw on a missing platform key or build a
    # package that doesn't apply there.
    linuxOnlyPackages = pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      tide-island = pkgs.callPackage ../pkgs/tide-island.nix {};
      mouseless = pkgs.callPackage ../pkgs/mouseless.nix {};
      hyprmod = inputs.hyprmod.packages.${system}.default;
    };
  in {
    packages =
      linuxOnlyPackages
      // {
        apix = inputs.apix.packages.${system}.default;
        go-latest = pkgs.callPackage ../pkgs/go-latest.nix {};
        strongbox = pkgs.callPackage ../pkgs/strongbox.nix {};
        wiresteward = pkgs.callPackage ../pkgs/wiresteward.nix {};
      };

    devShells.default = pkgs.mkShell {
      packages = [pkgs.nix-update pkgs.nurl pkgs.jq pkgs.yq pkgs.git pkgs.curl];
    };
  };
}
