{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system/base-system.nix
    ../../modules/system/fingerprint.nix
    ../../modules/system/nvidia-hybrid.nix
  ];

  networking.hostName = "thinkpad-t480";

  # NVIDIA DRM params: ensure modesetting and fbdev handoff work correctly on
  # PRIME systems even though MX150 currently needs legacy drivers to function.
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  # PRIME offload shifts DRM card numbering — Intel lands on card1 instead of
  # the usual card0. Pin Hyprland (aquamarine backend) to the correct device so
  # it doesn't probe a non-existent or NVIDIA-only node.
  environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/card1";

  vitorf7.desktop.enable = true;
  vitorf7.desktop.hyprland.enable = true;
  vitorf7.desktop.quickshell.enable = true;
  vitorf7.desktop.qs_brain_shell.enable = false;
  vitorf7.desktop.ambxst.enable = true;
  vitorf7.hardware.fingerprint.enable = true;
  vitorf7.hardware.nvidia.enable = true;

  system.stateVersion = "26.05";
}
