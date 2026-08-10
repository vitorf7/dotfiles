{ ... }:
{
  flake.modules.darwin.homebrew = { config, lib, ... }:
    let cfg = config.vitorf7.darwin; in
    lib.mkIf cfg.homebrew.enable {
      homebrew = {
        enable = true;
        onActivation = {
          cleanup = "zap";
          autoUpdate = true;
          upgrade = true;
        };
        global.brewfile = true;

        taps = [
          "buo/cask-upgrade"
          "caarlos0/tap"
        ];

        brews = [
          "dnsmasq"
          "httpd"
          "unar"
          "coreutils"
        ];

        extraConfig = ''
          cask "caarlos0/tap/tt", trusted: true
        '';
      };
    };
}
