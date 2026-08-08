{ inputs, self, ... }:
let username = "vitorf7";
in
{
  flake.nixosConfigurations.nixos-x86-vm = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      { nixpkgs.hostPlatform = "x86_64-linux"; }
      self.modules.nixos.options
      self.modules.nixos.nix-base
      # hardware-configuration.nix: not committed to git.
      # Generate with nixos-generate-config on the VM and add to hosts/nixos-x86-vm/.
      { networking.hostName = "nixos-x86-vm"; }
      {
        vitorf7.username = username;
        vitorf7.desktop.enable = true;
        vitorf7.desktop.hyprland.enable = true;
        vitorf7.desktop.quickshell.enable = true;
        vitorf7.desktop.qs_brain_shell.enable = true;
        vitorf7.desktop.caelestia_shell.enable = false;
        vitorf7.hardware.vm.enable = true;
        vitorf7.git.defaultProfile = "personal";
        vitorf7.git.personal.enable = true;
        system.stateVersion = "26.05";
      }
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
      inputs.brain-shell.nixosModules.default
      inputs.ambxst.nixosModules.default
      ({ lib, ... }: { programs.ambxst.enable = lib.mkOverride 999 false; })
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
        home-manager.users.${username} = { ... }: {
          imports = with self.modules.homeManager; [
            core shell editor git secrets dev desktop onepassword
            browsers media communication ai gaming
            ghostty kitty alacritty vicinae
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
