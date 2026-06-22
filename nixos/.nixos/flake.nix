{
  description = "Vitor's Unified Modular Multi-OS Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { pkgs, system, ... }: {
        # Define your custom package natively within flake-parts
        packages.hyprmod = pkgs.callPackage ./pkgs/hyprmod.nix { };
      };


      flake = {
        nixosConfigurations = {
          
          # --- Machine 1: ThinkPad T480 ---
          thinkpad-t480 = inputs.nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = { inherit self; }; 
            modules = [
              ./hosts/thinkpad-t480/configuration.nix
              ./modules/options.nix
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit self; };
                home-manager.users.vitorf7 = import ./modules/home/base-home.nix;
              }
            ];
          };

          # --- Machine 2: ARM Virtual Machine ---
          nixos-vm = inputs.nixpkgs.lib.nixosSystem {
            system = "aarch64-linux"; # Targets the Apple Silicon/ARM Architecture
            specialArgs = { inherit self; }; 
            modules = [
              ./hosts/nixos-vm/configuration.nix
              ./modules/options.nix
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.extraSpecialArgs = { inherit self; };
                home-manager.users.vitorf7 = import ./modules/home/base-home.nix;
              }
            ];
          };

        };
      }; 

    };
}
