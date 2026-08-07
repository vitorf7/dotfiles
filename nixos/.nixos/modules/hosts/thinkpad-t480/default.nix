{ inputs, self, ... }:
let username = "vitorf7";
in
{
  flake.nixosConfigurations.thinkpad-t480 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      self.modules.nixos.options
      self.modules.nixos.nix-base
      ./_hardware-configuration.nix
      # Host identity + hardware quirks
      {
        vitorf7.username = username;
        networking.hostName = "thinkpad-t480";
        # NVIDIA DRM params: modesetting and fbdev handoff on PRIME systems.
        boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
        # PRIME offload shifts DRM card numbering — pin Hyprland to Intel node.
        environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/card1";
      }
      # Feature flags
      {
        vitorf7.desktop.enable = true;
        vitorf7.desktop.hyprland.enable = true;
        vitorf7.desktop.quickshell.enable = true;
        vitorf7.desktop.qs_brain_shell.enable = false;
        vitorf7.desktop.ambxst.enable = false;
        vitorf7.desktop.tide_island.enable = false;
        vitorf7.desktop.caelestia_shell.enable = true;
        vitorf7.desktop.flatpak.enable = true;
        vitorf7.desktop.gaming.enable = true;
        vitorf7.desktop.winboat.enable = true;
        vitorf7.networking.nordvpn.enable = true;
        vitorf7.networking.globalprotect.enable = true;
        vitorf7.networking.wiresteward.enable = true;
        vitorf7.hardware.fingerprint.enable = true;
        vitorf7.hardware.nvidia.enable = true;
        vitorf7.git.defaultProfile = "personal";
        vitorf7.git.personal.enable = true;
        vitorf7.git.personal.directories = [ "~/dotfiles/" "~/code/personal/" "~/code/nvim-kick" "~/.config/nvim" ];
        vitorf7.git.work.enable = true;
        vitorf7.git.work.directories = [ "~/code/uw/" ];
        system.stateVersion = "26.05";
      }
      # NixOS modules (Phase 2)
      self.modules.nixos.boot
      self.modules.nixos.locale
      self.modules.nixos.networking
      self.modules.nixos.users
      self.modules.nixos.power
      self.modules.nixos.webcam
      self.modules.nixos.audio
      self.modules.nixos.bluetooth
      self.modules.nixos.display
      self.modules.nixos.vm
      self.modules.nixos.fingerprint
      self.modules.nixos.nvidia
      self.modules.nixos.nordvpn
      self.modules.nixos.globalprotect
      self.modules.nixos.wiresteward
      # NixOS modules (Phase 3 cross-class)
      self.modules.nixos.hyprland
      self.modules.nixos.quickshell
      self.modules.nixos.qs-brain-shell
      self.modules.nixos.ambxst
      self.modules.nixos.secrets
      self.modules.nixos.flatpak
      self.modules.nixos.docker
      self.modules.nixos.gaming
      self.modules.nixos.winboat
      self.modules.nixos.fonts
      self.modules.nixos.onepassword
      # Upstream NixOS modules
      inputs.brain-shell.nixosModules.default
      inputs.ambxst.nixosModules.default
      ({ lib, ... }: { programs.ambxst.enable = lib.mkOverride 999 false; })
      inputs.sops-nix.nixosModules.sops
      # nixos-hardware: throttled, fstrim, TrackPoint, Kaby Lake i915, NVIDIA PRIME/Pascal
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
      inputs.nixos-hardware.nixosModules.common-gpu-nvidia
      "${inputs.nixos-hardware}/common/gpu/nvidia/pascal"
      # Home-manager
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
        home-manager.users.${username} = { ... }: {
          imports = with self.modules.homeManager; [
            core shell editor git secrets dev desktop onepassword
            browsers media communication ai gaming
            ghostty kitty alacritty
            hyprland theming quickshell qs-brain-shell ambxst
            tide-island caelestia-shell
            kubernetes docker
          ];
          home.username = username;
          home.homeDirectory = "/home/${username}";
          home.stateVersion = "26.05";
          programs.home-manager.enable = true;
        };
      }
    ];
  };
}
