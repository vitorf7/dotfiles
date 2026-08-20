{ inputs, self, ... }:
let
  username = "vitorf7";
  # Single source of truth for the user's home-manager config, referenced by
  # both the darwin-integrated activation (nrs) and the standalone
  # homeConfigurations output (hm / home-manager CLI) below — so the two
  # entry points can never drift apart while sharing the same generation
  # profile.
  homeManagerUserConfig = { lib, ... }: {
    imports = with self.modules.homeManager; [
      core shell editor git secrets dev
      ghostty kitty alacritty vicinae
      darwin-packages darwin-symlinks
      kubernetes docker aerospace sketchybar
      browsers media communication input onepassword ai
    ];
    home.username = username;
    home.homeDirectory = lib.mkForce "/Users/${username}";
    home.stateVersion = "26.05";
    programs.home-manager.enable = true;
  };
in
{
  flake.darwinConfigurations.vitorf7-mac-m1 = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      { nixpkgs.hostPlatform = "aarch64-darwin"; }
      self.modules.darwin.options
      {
        vitorf7.username = username;
        networking.hostName = "vitorf7-mac-m1";
        networking.computerName = "vitorf7-mac-m1";
        vitorf7.darwin.enable = true;
        vitorf7.darwin.homebrew.enable = true;
        vitorf7.darwin.aerospace.enable = true;
        vitorf7.darwin.colima.enable = false;
        vitorf7.darwin.work.enable = false;
        vitorf7.networking.nordvpn.enable = true;
        vitorf7.git.defaultProfile = "personal";
        vitorf7.git.personal.enable = true;
        vitorf7.git.personal.directories = [ "~/dotfiles/" "~/code/personal/" "~/code/nvim-kick" "~/.config/nvim" ];
      }
      # Phase 4 darwin system modules
      self.modules.darwin.system
      self.modules.darwin.defaults
      self.modules.darwin.homebrew
      self.modules.darwin.fonts
      self.modules.darwin.docker
      self.modules.darwin.git
      self.modules.darwin.kubernetes
      self.modules.darwin.sketchybar
      self.modules.darwin.aerospace
      self.modules.darwin.ghostty
      self.modules.darwin.kitty
      self.modules.darwin.vicinae
      self.modules.darwin.browsers
      self.modules.darwin.media
      self.modules.darwin.communication
      self.modules.darwin.gaming
      self.modules.darwin.ai
      self.modules.darwin.ides
      self.modules.darwin.databases
      self.modules.darwin.input
      self.modules.darwin.macos-utils
      self.modules.darwin.onepassword
      self.modules.darwin.nordvpn
      self.modules.darwin.dev
      # Personal machine login items
      {
        system.activationScripts.postActivation.text = ''
          for app in \
            "/Applications/Bartender 5.app" \
            "/Applications/MeetingBar.app" \
            "/Applications/1Password.app" \
            "/Applications/NordVPN.app" \
            "/Applications/Vicinae.app"; do
            if [[ -d "$app" ]]; then
              /usr/bin/sfltool add-item loginitems "$app"
            fi
          done
        '';
      }
      # Home-manager
      inputs.home-manager.darwinModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "hm-bak";
        home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
        home-manager.users.${username} = homeManagerUserConfig;
      }
    ];
  };

  flake.homeConfigurations.vitorf7-mac-m1 =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        osConfig = self.darwinConfigurations.vitorf7-mac-m1.config;
      };
      modules = [
        inputs.sops-nix.homeManagerModules.sops
        homeManagerUserConfig
      ];
    };
}
