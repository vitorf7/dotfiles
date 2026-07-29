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
    networking.nordvpn.enable = lib.mkEnableOption "NordVPN client (CLI + GUI) with systemd daemon";
    networking.globalprotect.enable = lib.mkEnableOption "GlobalProtect VPN client (gpclient CLI + gpgui GUI) via GlobalProtect-openconnect flake";
    networking.wiresteward.enable = lib.mkEnableOption "Wiresteward WireGuard VPN agent with per-cluster interfaces (dev/prod x AWS/GCP/Merit)";

    darwin.enable = lib.mkEnableOption "macOS (nix-darwin) base configuration";
    darwin.homebrew.enable = lib.mkEnableOption "Declarative Homebrew (taps, casks, mas apps)";
    darwin.aerospace.enable = lib.mkEnableOption "Aerospace WM + sketchybar + jankyborders stack";
    darwin.colima.enable = lib.mkEnableOption "Colima container runtime as a launchd user agent";
  };
}
