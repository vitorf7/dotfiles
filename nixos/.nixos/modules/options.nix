{ lib, ... }:

{
  options.vitorf7 = {
    desktop.enable = lib.mkEnableOption "General desktop environment (browser, fonts, themes, audio)";
    desktop.hyprland.enable = lib.mkEnableOption "Hyprland Wayland Desktop Ecosystem";
    hardware.nvidia.enable = lib.mkEnableOption "Nvidia PRIME Hybrid Graphics";
    hardware.fingerprint.enable = lib.mkEnableOption "Fingerprint Reader Support";
    hardware.vm.enable = lib.mkEnableOption "VM guest optimizations (QEMU/SPICE)";
    desktop.quickshell.enable = lib.mkEnableOption "Quickshell framework + common shell runtime deps";
    desktop.qs_brain_shell.enable = lib.mkEnableOption "Brain_Shell Quickshell config (requires quickshell.enable)";
    desktop.ambxst.enable = lib.mkEnableOption "Ambxst Quickshell shell";
    desktop.tide_island.enable = lib.mkEnableOption "Tide Island Dynamic Island for Hyprland (Quickshell-based)";
    desktop.caelestia_shell.enable = lib.mkEnableOption "Caelestia Shell Quickshell Config";
    desktop.flatpak.enable = lib.mkEnableOption "Flatpak support with declarative package management";
  };
}
