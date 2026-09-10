# nix-update's --flake mode can't locate the source position of `version`/
# `src` for these two derivations (stdenv.mkDerivation / appimageTools.wrapAppImage
# lose that metadata internally) and crashes. This shim gives nix-update's
# non-flake mode — which imports a plain nixpkgs-style `{ system, overlays }:`
# file instead of evaluating a flake attribute — a path that works around it.
# Use with: nix-update -f pkgs/nix-update-shim.nix <name> --override-filename pkgs/<name>.nix
{ system ? builtins.currentSystem, overlays ? [ ] }:
let
  pkgs = import <nixpkgs> { inherit system overlays; };
in
{
  tide-island = pkgs.callPackage ./tide-island.nix { };
  mouseless   = pkgs.callPackage ./mouseless.nix { };
}
