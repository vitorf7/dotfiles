{ lib, ... }:

{
  options.vitorf7 = {
    desktop.hyprland.enable = lib.mkEnableOption "Hyprland Wayland Desktop Ecosystem";
    hardware.nvidia.enable = lib.mkEnableOption "Nvidia PRIME Hybrid Graphics";
    hardware.fingerprint.enable = lib.mkEnableOption "Fingerprint Reader Support";
    hardware.vm.enable = lib.mkEnableOption "VM guest optimizations (QEMU/SPICE)";
    desktop.quickshell.enable = lib.mkEnableOption "Quickshell framework + common shell runtime deps";
    desktop.qs_brain_shell.enable = lib.mkEnableOption "Brain_Shell Quickshell config (requires quickshell.enable)";
  };
}
