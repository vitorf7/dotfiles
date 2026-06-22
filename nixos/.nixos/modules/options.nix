{ lib, ... }:

{
  options.vitor = {
    desktop.hyprland.enable = lib.mkEnableOption "Hyprland Wayland Desktop Ecosystem";
    hardware.nvidia.enable = lib.mkEnableOption "Nvidia PRIME Hybrid Graphics";
    hardware.fingerprint.enable = lib.mkEnableOption "Fingerprint Reader Support";
  };
}
