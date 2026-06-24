{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base-system.nix
  ];

  networking.hostName = "nixos-x86-vm";

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  vitorf7.desktop.hyprland.enable = true;
  vitorf7.hardware.vm.enable = true;
  vitorf7.hardware.fingerprint.enable = false;
  vitorf7.hardware.nvidia.enable = false;

  system.stateVersion = "26.05";
}
