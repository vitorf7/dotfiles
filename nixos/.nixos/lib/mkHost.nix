{ inputs, self, root }:
{ system, host, extraModules ? [], extraSpecialArgs ? {} }:

inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs self; } // extraSpecialArgs;
  modules = [
    { nixpkgs.hostPlatform = system; }
    (root + "/hosts/${host}/configuration.nix")
    (root + "/modules/options.nix")
    inputs.brain-shell.nixosModules.default
    inputs.ambxst.nixosModules.default
    # Override Ambxst's unusual `lib.mkDefault true` → make it opt-in like everything else.
    # Our system module sets programs.ambxst.enable = true (priority 100) when the
    # vitorf7.desktop.ambxst.enable option is turned on, which beats this (priority 999).
    ({ lib, ... }: { programs.ambxst.enable = lib.mkOverride 999 false; })
    inputs.sops-nix.nixosModules.sops
    (root + "/modules/system/secrets.nix")
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      home-manager.extraSpecialArgs = { inherit inputs self; } // extraSpecialArgs;
      home-manager.users.vitorf7 = import (root + "/modules/home/default.nix");
    }
  ] ++ extraModules;
}
