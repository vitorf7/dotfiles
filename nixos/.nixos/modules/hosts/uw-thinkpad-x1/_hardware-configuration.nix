# PLACEHOLDER — replace wholesale with the output of
#   sudo nixos-generate-config --show-hardware-config
# run on the real machine (scripts/initial_nixos_setup.sh does this for you).
#
# Declares no fileSystems on purpose: `.#uw-thinkpad-x1` evaluates so the host
# can be checked from another machine, but a build fails loudly until this file
# is replaced with the generated one.
{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.availableKernelModules = ["xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
