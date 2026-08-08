{ ... }:
{
  flake.modules.darwin.macos-utils = { config, lib, ... }:
    let cfg = config.vitorf7.darwin; in
    {
      homebrew.casks = [
        "appcleaner"
        "bartender"
        "daisydisk"
        "desktoppr"
        "keepingyouawake"
        "meetingbar"
        "tomatobar"
        "utm"
        "logos"
        "obsidian"
        "sf-symbols"
        "gpg-suite"
        "zulu@17"
      ];

      homebrew.masApps = {
        HP = 1474276998;
        iMovie = 408981434;
      } // lib.optionalAttrs cfg.work.enable {
        "Okta Verify" = 490179405;
        Keynote = 361285480;
        Numbers = 361304891;
        Pages = 361309726;
      };
    };
}
