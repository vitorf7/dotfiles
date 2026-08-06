{ lib, ... }:
{
  options.flake = {
    modules = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.unspecified);
      default = {};
      description = "Module registry keyed by class (nixos, darwin, homeManager) then by name.";
    };
    darwinConfigurations = lib.mkOption {
      type = lib.types.attrsOf lib.types.unspecified;
      default = {};
    };
  };
}
