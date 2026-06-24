{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base-system.nix
    
    # Notice we do NOT import fingerprint.nix or nvidia-hybrid.nix here!
  ];

  networking.hostName = "nixos-vm";

  vitorf7.desktop.hyprland.enable = true;
  vitorf7.hardware.vm.enable = true;
  vitorf7.hardware.fingerprint.enable = false;
  vitorf7.hardware.nvidia.enable = false;

  system.stateVersion = "26.05";
}
