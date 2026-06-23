{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base-system.nix
    ../../modules/system/fingerprint.nix
    ../../modules/system/nvidia-hybrid.nix
  ];

  networking.hostName = "thinkpad-t480";

  vitorf7.desktop.hyprland.enable = true;
  vitorf7.hardware.fingerprint.enable = true;
  vitorf7.hardware.nvidia.enable = true;

  system.stateVersion = "26.05";
}
