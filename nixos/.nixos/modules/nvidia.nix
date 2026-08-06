{ ... }:
{
  flake.modules.nixos.nvidia = { config, lib, ... }: lib.mkIf config.vitorf7.hardware.nvidia.enable {
    hardware.nvidia = {
      package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
      modesetting.enable = true;
      powerManagement.enable = true;
      powerManagement.finegrained = false;
      prime.intelBusId = "PCI:0:2:0";
      prime.nvidiaBusId = "PCI:1:0:0";
    };

    hardware.graphics.enable = true;
  };
}
