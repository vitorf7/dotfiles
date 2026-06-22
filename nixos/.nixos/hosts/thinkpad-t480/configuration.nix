{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base-system.nix
    ../../modules/system/fingerprint.nix
    ../../modules/system/nvidia-hybrid.nix
  ];

  networking.hostName = "thinkpad-t480";

  vitor.desktop.hyprland.enable = true;
  vitor.hardware.fingerprint.enable = true;
  vitor.hardware.nvidia.enable = true;

  system.stateVersion = "24.05";
}
