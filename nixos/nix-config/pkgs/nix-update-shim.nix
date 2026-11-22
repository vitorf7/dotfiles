# Entry point for nix-update's non-flake mode (`nix-update -f <this file>`),
# which imports a plain nixpkgs-style `{ system, overlays }:` file instead of
# evaluating a flake attribute.
#
# Why every hand-pinned package goes through here rather than `--flake`:
#   - Nix >= 2.35 copies flake sources to the store lazily, so the `path` that
#     `nix flake metadata --json` reports doesn't exist on disk. nix-update's
#     --flake mode hands that path to a separate `nix-instantiate` and fails
#     with `opening file "/nix/store/...-source/...": No such file or directory`.
#     Non-flake mode never touches flake metadata. Revisit `--flake` once
#     nix-update handles non-materialised flake paths.
#   - tide-island additionally loses its `version`/`src` source position under
#     --flake (stdenv.mkDerivation doesn't preserve it) and crashes.
#
# Use with: nix-update -f pkgs/nix-update-shim.nix <name> --override-filename pkgs/<name>.nix
# (the fish `nix-update-derivations` helper does this for every package below).
{
  system ? builtins.currentSystem,
  overlays ? [],
}: let
  # Mirrors modules/packages.nix: unfree allowed, and buildGoModule packages
  # use go_1_26 (wiresteward's go.mod needs >=1.26.6; the default `go` lags).
  pkgs = import <nixpkgs> {
    inherit system;
    config.allowUnfree = true;
    overlays = overlays ++ [(final: prev: {go = prev.go_1_26;})];
  };
in {
  strongbox = pkgs.callPackage ./strongbox.nix {};
  wiresteward = pkgs.callPackage ./wiresteward.nix {};
  openwhispr = pkgs.callPackage ./openwhispr.nix {};
  speakoflow = pkgs.callPackage ./speakoflow.nix {};
  opencode-v1 = pkgs.callPackage ./opencode-v1.nix {};
  quickshell-share-picker = pkgs.callPackage ./quickshell-share-picker.nix {};
  tide-island = pkgs.callPackage ./tide-island.nix {};
  slate = pkgs.callPackage ./slate/package.nix {};
}
