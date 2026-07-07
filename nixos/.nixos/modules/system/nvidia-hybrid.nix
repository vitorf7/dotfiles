{ config, lib, ... }:

lib.mkIf config.vitorf7.hardware.nvidia.enable {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # MX150 is Pascal (GP108) — requires the legacy 535 series driver.
    # The current open-source default (595.x) dropped support for this GPU and
    # logs "No NVIDIA GPU found" at boot, leaving the dGPU completely inactive.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;

    modesetting.enable = true;
    powerManagement.enable = true;
    # Fine-grained power management aggressively powers the NVIDIA GPU off/on.
    # With an external display on USB-C/Thunderbolt, this can destabilise DRM
    # connector enumeration on the Intel side. Disabled until 3-monitor setup
    # is confirmed stable; re-enable for better battery life on single-screen use.
    powerManagement.finegrained = false;
    open = false;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      # Run `lspci | grep -E 'VGA|3D'` on the T480 to confirm these IDs
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Intel VAAPI (intel-media-driver) is now supplied by nixos-hardware's
  # common/gpu/intel/kaby-lake module via hardware.intelgpu — see the
  # lenovo-thinkpad-t480 import in flake.nix. PRIME offload still needs
  # hardware.graphics enabled.
  hardware.graphics.enable = true;
}
