{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base-system.nix
    
    # Notice we do NOT import fingerprint.nix or nvidia-hybrid.nix here!
  ];

  networking.hostName = "nixos-vm";

  # VM-Specific Additions for clipboard and resolution scaling
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  # Wrapper Module Switches
  vitor.desktop.hyprland.enable = true;
  vitor.hardware.fingerprint.enable = false;
  vitor.hardware.nvidia.enable = false;

  system.stateVersion = "24.05";
}
