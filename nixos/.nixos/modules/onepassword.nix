{ ... }:
{
  flake.modules.nixos.onepassword = { config, lib, ... }: lib.mkIf config.vitorf7.desktop.enable {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ config.vitorf7.username ];
    };
    environment.etc."1password/custom_allowed_browsers" = {
      text = "zen\n";
      mode = "0755";
    };
  };

  flake.modules.darwin.onepassword = { ... }: {
    homebrew.casks = [
      "1password"
      "1password-cli"
    ];
  };

  flake.modules.homeManager.onepassword = { config, lib, pkgs, osConfig, ... }:
    lib.mkIf (osConfig.vitorf7.desktop.enable || osConfig.vitorf7.darwin.enable) {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;

      includes = lib.optional (pkgs.stdenv.isDarwin && osConfig.vitorf7.darwin.colima.enable)
        "${config.home.homeDirectory}/.config/colima/ssh_config";

      settings = lib.mkMerge [
        {
          # macOS path contains a space ("Group Containers") so must be quoted;
          # embed the quotes in the value so home-manager renders them verbatim.
          "*".IdentityAgent =
            if pkgs.stdenv.isDarwin
            then ''"${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
            else "${config.home.homeDirectory}/.1password/agent.sock";
        }

        # Default github.com entry follows defaultProfile
        (lib.mkIf (osConfig.vitorf7.git.defaultProfile == "personal" && osConfig.vitorf7.git.personal.enable) {
          "github.com" = {
            HostName = "github.com";
            User = "git";
            IdentityFile = "~/.ssh/personalgit.pub";
          };
        })
        (lib.mkIf (osConfig.vitorf7.git.defaultProfile == "work" && osConfig.vitorf7.git.work.enable) {
          "github.com" = {
            HostName = "github.com";
            User = "git";
            IdentityFile = "~/.ssh/workgit.pub";
          };
        })

        (lib.mkIf osConfig.vitorf7.git.personal.enable {
          "personalgit" = {
            HostName = "github.com";
            User = "git";
            IdentityFile = "~/.ssh/personalgit.pub";
            IdentitiesOnly = true;
          };
        })

        (lib.mkIf osConfig.vitorf7.git.work.enable {
          "workgit" = {
            HostName = "github.com";
            User = "git";
            IdentityFile = "~/.ssh/workgit.pub";
            IdentitiesOnly = true;
          };
        })
      ];
    };
  };
}
