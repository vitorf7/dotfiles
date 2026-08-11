{ inputs, self, ... }:
let username = "vitorfaiante";
in
{
  flake.darwinConfigurations.uw-mac-m1 = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      { nixpkgs.hostPlatform = "aarch64-darwin"; }
      self.modules.darwin.options
      {
        vitorf7.username = username;
        # hostname -s returns this value — nrs fish function uses it as the default flake attr.
        networking.hostName = "uw-mac-m1";
        networking.computerName = "uw-mac-m1";
        vitorf7.darwin.enable = true;
        vitorf7.darwin.homebrew.enable = true;
        vitorf7.darwin.aerospace.enable = true;
        vitorf7.darwin.colima.enable = true;
        vitorf7.darwin.work.enable = true;
        vitorf7.git.defaultProfile = "work";
        vitorf7.git.personal.enable = true;
        vitorf7.git.personal.directories = [ "~/dotfiles/" "~/code/personal/" "~/code/nvim-kick" "~/.config/nvim" ];
        vitorf7.git.work.enable = true;
        vitorf7.git.work.directories = [ "~/code/uw/" ];
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
            browsers media communication input onepassword ai
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
