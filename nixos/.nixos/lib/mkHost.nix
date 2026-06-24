{ inputs, self, root }:
{ system, host, extraModules ? [] }:

inputs.nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit self; };
  modules = [
    (root + "/hosts/${host}/configuration.nix")
    (root + "/modules/options.nix")
    inputs.home-manager.nixosModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = { inherit inputs self; };
      home-manager.users.vitorf7 = import (root + "/modules/home/default.nix");
    }
  ] ++ extraModules;
}
