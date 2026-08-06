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

  flake.modules.homeManager.onepassword = { config, lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*".IdentityAgent = "${config.home.homeDirectory}/.1password/agent.sock";
        "github.com" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/personalgit.pub";
        };
        "personalgit" = {
          HostName = "github.com";
          User = "git";
          IdentityFile = "~/.ssh/personalgit.pub";
          IdentitiesOnly = true;
        };
      };
    };
  };
}
