{ inputs, self, root }:
{ system, host, extraModules ? [] }:

inputs.nixpkgs.lib.nixosSystem {
  specialArgs = { inherit inputs self; };
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
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs self; };
      home-manager.users.vitorf7 = import (root + "/modules/home/default.nix");
    }
  ] ++ extraModules;
}
