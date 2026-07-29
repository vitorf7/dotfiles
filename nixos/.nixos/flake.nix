{
  description = "Vitor's Unified Modular Multi-OS Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Do NOT set inputs.nixpkgs.follows here: Hyprland's nixpkgs must be newer
    # than ours (it requires wayland-protocols >= 1.49 which our nixos-unstable
    # pin may not yet have). We pin mesa from hyprland's nixpkgs instead (below)
    # to keep graphics drivers in sync and avoid FPS drops on hybrid GPU setups.
    hyprland.url = "github:hyprwm/Hyprland";

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

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprmod = {
      url = "github:vitorf7/hyprmod/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
    };

    # Do NOT set inputs.nixpkgs.follows here: the flake's python-validity package
    # requires nixpkgs 24.11 build conventions that differ from nixos-unstable.
    nixos-06cb-009a-fingerprint-sensor = {
      url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor?ref=24.11";
    };

    # Do NOT set inputs.nixpkgs.follows here: the flake has specific Rust
    # toolchain requirements and bundles the proprietary gpgui binary.
    globalprotect-openconnect = {
      url = "github:yuezk/GlobalProtect-openconnect";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          packages = {
            hyprmod = inputs.hyprmod.packages.${system}.default;
            tide-island = pkgs.callPackage ./pkgs/tide-island.nix { };
            go-latest = pkgs.callPackage ./pkgs/go-latest.nix {};
	    strongbox = pkgs.callPackage ./pkgs/strongbox.nix {};
          };
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
              # TrackPoint scroll emulation, Kaby Lake i915 tuning, NVIDIA PRIME
              # offload + the Pascal driver pin. modules/system/nvidia-hybrid.nix
              # only keeps the bits these can't know (bus IDs, our own tuning
              # decisions) and overrides the driver-version default — see there.
              extraModules = [
                inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
                inputs.nixos-hardware.nixosModules.common-gpu-nvidia
                "${inputs.nixos-hardware}/common/gpu/nvidia/pascal"
                inputs.nixos-06cb-009a-fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"
              ];
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
          };

        darwinConfigurations =
          let
            mkDarwin = import ./lib/mkDarwin.nix { inherit inputs self; root = ./.; };
          in
          {
            # --- Machine 4: macOS M1 Pro, UW work laptop (aarch64-darwin) ---
            uw-mac-m1 = mkDarwin {
              system = "aarch64-darwin";
              host = "uw-mac-m1";
              username = "vitorfaiante";
            };

            # --- Machine 5: macOS M1, personal laptop (aarch64-darwin) ---
            vitorf7-mac-m1 = mkDarwin {
              system = "aarch64-darwin";
              host = "vitorf7-mac-m1";
              username = "vitorf7";
            };
          };
      };

    };
}
