{ inputs, self, ... }:
let username = "vitorf7";
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
        home-manager.users.${username} = { lib, ... }: {
          imports = with self.modules.homeManager; [
            core shell editor git secrets dev
            ghostty kitty alacritty vicinae
            darwin-packages darwin-symlinks
            kubernetes docker aerospace sketchybar
          ];
          home.username = username;
          home.homeDirectory = lib.mkForce "/Users/${username}";
          home.stateVersion = "26.05";
          programs.home-manager.enable = true;
        };
      }
    ];
  };
}
