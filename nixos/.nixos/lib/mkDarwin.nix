{ inputs, self, root }:
{ system, host, username, extraModules ? [], extraSpecialArgs ? {} }:

inputs.nix-darwin.lib.darwinSystem {
  specialArgs = { inherit inputs self username; } // extraSpecialArgs;
  modules = [
    { nixpkgs.hostPlatform = system; }
    (root + "/hosts/${host}/configuration.nix")
    (root + "/modules/options.nix")
    inputs.home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-bak";
      home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      home-manager.extraSpecialArgs = { inherit inputs self username; } // extraSpecialArgs;
      home-manager.users.${username} = import (root + "/modules/home/darwin.nix");
    }
  ] ++ extraModules;
}
