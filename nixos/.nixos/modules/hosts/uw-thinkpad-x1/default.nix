{
  inputs,
  self,
  ...
}: let
  username = "vitorf7";
  # Single source of truth for the user's home-manager config, referenced by
  # both the nixos-integrated activation (nrs) and the standalone
  # homeConfigurations output (hm / home-manager CLI) below — so the two
  # entry points can never drift apart while sharing the same generation
  # profile.
  homeManagerUserConfig = {
    imports = with self.modules.homeManager; [
      core
      shell
      editor
      git
      secrets
      dev
      desktop
      onepassword
      browsers
      media
      communication
      ai
      ghostty
      kitty
      alacritty
      vicinae
      hyprland
      hypridle
      hyprlock
      hyprmod
      theming
      quickshell
      qs-brain-shell
      ambxst
      tide-island
      caelestia-shell
      dank-material-shell
      kubernetes
      docker
    ];
    home.username = username;
    home.homeDirectory = "/home/${username}";
    home.stateVersion = "26.05";
    programs.home-manager.enable = true;
  };
in {
  flake.nixosConfigurations.uw-thinkpad-x1 = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      {nixpkgs.hostPlatform = "x86_64-linux";}
      self.modules.nixos.options
      self.modules.nixos.nix-base
      ./_hardware-configuration.nix
      # Host identity + hardware quirks
      ({pkgs, ...}: {
        vitorf7.username = username;
        networking.hostName = "uw-thinkpad-x1";
        # Modern Intel ThinkPads need the SOF audio stack and the
        # redistributable firmware blobs (Intel Wi-Fi/BT, Xe iGPU). Nothing
        # shared sets these — the T480 predates the requirement.
        hardware.enableRedistributableFirmware = true;
        hardware.firmware = [pkgs.sof-firmware];
      })
      # Feature flags
      {
        vitorf7.desktop.enable = true;
        vitorf7.desktop.hyprland.enable = true;
        vitorf7.desktop.hypridle.enable = false;
        vitorf7.desktop.hyprlock.enable = false;
        vitorf7.desktop.hyprmod.enable = true;
        vitorf7.desktop.quickshell.enable = true;
        vitorf7.desktop.qs_brain_shell.enable = false;
        vitorf7.desktop.ambxst.enable = false;
        vitorf7.desktop.tide_island.enable = false;
        vitorf7.desktop.caelestia_shell.enable = false;
        vitorf7.desktop.dank_material_shell.enable = true;
        vitorf7.networking.globalprotect.enable = true;
        vitorf7.networking.wiresteward.enable = true;
        vitorf7.hardware.fingerprint.enable = true;
        vitorf7.git.defaultProfile = "work";
        vitorf7.git.personal.enable = true;
        vitorf7.git.personal.directories = ["~/dotfiles/" "~/code/personal/" "~/code/nvim-kick" "~/.config/nvim"];
        vitorf7.git.work.enable = true;
        vitorf7.git.work.directories = ["~/code/uw/"];
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
      self.modules.nixos.fingerprint-generic
      self.modules.nixos.globalprotect
      self.modules.nixos.wiresteward
      # NixOS modules (Phase 3 cross-class)
      self.modules.nixos.hyprland
      self.modules.nixos.quickshell
      self.modules.nixos.qs-brain-shell
      self.modules.nixos.ambxst
      self.modules.nixos.dank-material-shell
      self.modules.nixos.secrets
      self.modules.nixos.fonts
      self.modules.nixos.onepassword
      # Upstream NixOS modules
      inputs.brain-shell.nixosModules.default
      inputs.ambxst.nixosModules.default
      ({lib, ...}: {programs.ambxst.enable = lib.mkOverride 999 false;})
      inputs.sops-nix.nixosModules.sops
      # nixos-hardware: generation-agnostic X1 base (TrackPoint, common/pc/laptop
      # → TLP, common/cpu/intel → microcode + i915). Once the exact generation is
      # known, add the matching module BELOW this line — it is strictly additive
      # (each gen module imports ../. ):
      #   Gen  9 → lenovo-thinkpad-x1-9th-gen    (Tiger Lake)
      #   Gen 10 → lenovo-thinkpad-x1-10th-gen   (Alder Lake)
      #   Gen 11 → lenovo-thinkpad-x1-11th-gen   (Raptor Lake)
      #   Gen 12 → lenovo-thinkpad-x1-12th-gen   (Meteor Lake)
      #   Gen 13 → lenovo-thinkpad-x1-13th-gen   (Lunar Lake; enables thermald)
      # Gen 14+ is not in nixos-hardware yet — stay on the generic module.
      inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1
      inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
      # Home-manager
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [inputs.sops-nix.homeManagerModules.sops];
        home-manager.users.${username} = homeManagerUserConfig;
      }
    ];
  };

  flake.homeConfigurations.uw-thinkpad-x1 = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
    extraSpecialArgs = {
      osConfig = self.nixosConfigurations.uw-thinkpad-x1.config;
    };
    modules = [
      inputs.sops-nix.homeManagerModules.sops
      homeManagerUserConfig
    ];
  };
}
