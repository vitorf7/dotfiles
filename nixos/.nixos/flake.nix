{
  description = "Vitor's Unified Modular Multi-OS Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    brain-shell = {
      url = "github:Brainitech/Brain_Shell/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ambxst = {
      url = "github:Axenide/Ambxst";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # TODO: add nix-darwin for macOS M1 support
    # nix-darwin = {
    #   url = "github:LnL7/nix-darwin/master";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {

      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { system, ... }:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          packages.hyprmod = pkgs.callPackage ./pkgs/hyprmod.nix { };
          packages.mouseless = pkgs.callPackage ./pkgs/mouseless.nix { };
        };

      flake = {
        nixosConfigurations =
          let
            mkHost = import ./lib/mkHost.nix { inherit inputs self; root = ./.; };
          in
          {
            # --- Machine 1: ThinkPad T480 (x86_64) ---
            thinkpad-t480 = mkHost {
              system = "x86_64-linux";
              host = "thinkpad-t480";
              # Upstream hardware quirks: throttled (BD-PROCHOT fix), fstrim,
              # TrackPoint scroll emulation, Kaby Lake i915 tuning. NVIDIA PRIME
              # stays hand-rolled in modules/system/nvidia-hybrid.nix (MX150/Pascal
              # needs the legacy_535 pin; upstream's pascal module forces legacy_580).
              extraModules = [ inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480 ];
            };

            # --- Machine 2: ARM Virtual Machine (aarch64) ---
            nixos-arm-vm = mkHost {
              system = "aarch64-linux";
              host = "nixos-arm-vm";
            };

            # --- Machine 3: x86_64 Virtual Machine ---
            nixos-x86-vm = mkHost {
              system = "x86_64-linux";
              host = "nixos-x86-vm";
            };

            # --- Machine 4: macOS M1 (darwin) ---
            # Pending nix-darwin integration. aarch64-darwin is already in `systems`
            # so package builds work. Full darwinConfigurations added once nix-darwin
            # input is uncommented above.
          };
      };

    };
}
