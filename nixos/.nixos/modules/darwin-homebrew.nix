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
          "fencesandbox/tap"
          "garrettkrohn/treekanga"
          "jnsahaj/lumen"
          "buo/cask-upgrade"
          "caarlos0/tap"
          "hashicorp/tap"
          "snyk/tap"
          "teamookla/speedtest"
        ];

        brews = [
          "fencesandbox/tap/fence"
          "dnsmasq"
          "httpd"
          "julia"
          "cocoapods"
          "composer"
          "openjdk"
          "media-control"
          "lpeg"
          "nvm"
          "powerlevel10k"
          "unar"
          "pipx"
          "hashicorp/tap/terraform"
          "hashicorp/tap/terraform-ls"
          "snyk/tap/snyk"
          "teamookla/speedtest/speedtest"
          "awscli@1"
          "stow"
        ];

        casks = [
          "1password"
          "1password-cli"
          "appcleaner"
          "bartender"
          "daisydisk"
          "desktoppr"
          "keepingyouawake"
          "meetingbar"
          "tomatobar"
          "arc"
          "brave-browser"
          "helium-browser"
          "vivaldi"
          "zen"
          "cursor"
          "visual-studio-code@insiders"
          "jetbrains-toolbox"
          "beekeeper-studio"
          "dbeaver-community"
          "insomnia"
          "postman"
          "karabiner-elements"
          "homerow"
          "keycastr"
          "mouseless@preview"
          "utm"
          "ollama-app"
          "slack"
          "whatsapp"
          "zoom"
          "rambox"
        ] ++ lib.optionals (!cfg.work.enable) [
          "nordvpn"
          "steam"
          "openemu"
        ] ++ [
          "spotify"
          "vlc"
          "elgato-wave-link"
          "logos"
          "obsidian"
          "sf-symbols"
          "font-sf-pro"
          "font-sf-mono"
          "font-codicon"
          "font-meslo-for-powerline"
          "font-meslo-lg-dz"
          "zulu@17"
          "gpg-suite"
        ];

        masApps = {
          HP = 1474276998;
          iMovie = 408981434;
        } // lib.optionalAttrs cfg.work.enable {
          "Okta Verify" = 490179405;
          Keynote = 361285480;
          Numbers = 361304891;
          Pages = 361309726;
        };

        extraConfig = ''
          cask "caarlos0/tap/tt", trusted: true
        '';
      };
    };
}
