{ config, lib, ... }:

lib.mkIf config.vitorf7.hardware.nvidia.enable {
  hardware.nvidia = {
    # OVERRIDE of nixos-hardware's pascal module (common/gpu/nvidia/pascal,
    # imported in flake.nix), which sets `package = lib.mkDefault
    # nvidiaPackages.legacy_580`. MX150 (Pascal/GP108) is only confirmed
    # working on legacy_535 here — the stable/production branch (595.x)
    # dropped support and logs "No NVIDIA GPU found" at boot. legacy_580 is
    # nixpkgs' current LTSB for this GPU generation and may well work too —
    # test it on real hardware, then delete this override if it does.
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;

    # Not set upstream (defaults to false) — needed for tear-free PRIME output.
    modesetting.enable = true;
    powerManagement.enable = true;
    # Fine-grained power management aggressively powers the NVIDIA GPU off/on.
    # With an external display on USB-C/Thunderbolt, this can destabilise DRM
    # connector enumeration on the Intel side. Disabled until 3-monitor setup
    # is confirmed stable; re-enable for better battery life on single-screen use.
    powerManagement.finegrained = false;

    # Bus IDs are machine-specific — nixos-hardware's prime module (common-gpu-nvidia,
    # imported in flake.nix) deliberately leaves these unset. Run
    # `lspci | grep -E 'VGA|3D'` on the T480 to confirm.
    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:1:0:0";
  };

  # Not set upstream (defaults to false) — required for PRIME offload.
  # `open = false`, PRIME offload (enable/enableOffloadCmd), and
  # services.xserver.videoDrivers = [ "nvidia" ] now come from nixos-hardware's
  # common-gpu-nvidia + pascal modules (flake.nix). Intel VAAPI
  # (intel-media-driver) comes from its common/gpu/intel/kaby-lake module via
  # hardware.intelgpu.
  hardware.graphics.enable = true;
}
