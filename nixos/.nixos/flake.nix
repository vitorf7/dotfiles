{
  description = "Vitor's Unified Modular Multi-OS Setup";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; }
      (import-tree ./modules);
}
