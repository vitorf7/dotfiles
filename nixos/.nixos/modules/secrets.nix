{ ... }:
{
  flake.modules.nixos.secrets = { config, ... }: {
    sops.age.keyFile = "/home/${config.vitorf7.username}/.config/sops/age/keys.txt";
  };

  flake.modules.homeManager.secrets = { config, pkgs, lib, osConfig, ... }:
    let
      isDarwin = pkgs.stdenv.isDarwin;
      sopsDirFromFlakeRoot = ../sops;
      gitCfg = osConfig.vitorf7.git;
    in
    {
      sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

      sops.secrets."private_config.fish" = {
        sopsFile = sopsDirFromFlakeRoot + "/shared/private_config.fish";
        format = "binary";
        path = "${config.xdg.configHome}/fish/private_config.fish";
      };

      sops.secrets."weather_vars.lua" = lib.mkIf isDarwin {
        sopsFile = sopsDirFromFlakeRoot + "/darwin/weather_vars.lua";
        format = "binary";
        path = "${config.xdg.configHome}/sketchybar/weather_vars.lua";
      };

      sops.secrets."gitconfig/personal/name".sopsFile    = sopsDirFromFlakeRoot + "/git/personal.yaml";
      sops.secrets."gitconfig/personal/email".sopsFile   = sopsDirFromFlakeRoot + "/git/personal.yaml";
      sops.secrets."gitconfig/personal/signingKey".sopsFile = sopsDirFromFlakeRoot + "/git/personal.yaml";
      sops.secrets."gitconfig/personal/name".key         = "name";
      sops.secrets."gitconfig/personal/email".key        = "email";
      sops.secrets."gitconfig/personal/signingKey".key   = "signingKey";

      sops.secrets."gitconfig/work/name" = lib.mkIf gitCfg.work.enable {
        sopsFile = sopsDirFromFlakeRoot + "/git/work.yaml";
        key = "name";
      };
      sops.secrets."gitconfig/work/email" = lib.mkIf gitCfg.work.enable {
        sopsFile = sopsDirFromFlakeRoot + "/git/work.yaml";
        key = "email";
      };
      sops.secrets."gitconfig/work/signingKey" = lib.mkIf gitCfg.work.enable {
        sopsFile = sopsDirFromFlakeRoot + "/git/work.yaml";
        key = "signingKey";
      };

      sops.templates."git-identity-personal" = {
        path = "${config.xdg.configHome}/git/identity-personal";
        content = ''
          [user]
          	name = ${config.sops.placeholder."gitconfig/personal/name"}
          	email = ${config.sops.placeholder."gitconfig/personal/email"}
          	signingKey = ${config.sops.placeholder."gitconfig/personal/signingKey"}
        '';
      };

      sops.templates."git-identity-work" = lib.mkIf gitCfg.work.enable {
        path = "${config.xdg.configHome}/git/identity-work";
        content = ''
          [user]
          	name = ${config.sops.placeholder."gitconfig/work/name"}
          	email = ${config.sops.placeholder."gitconfig/work/email"}
          	signingKey = ${config.sops.placeholder."gitconfig/work/signingKey"}
        '';
      };
    };
}
