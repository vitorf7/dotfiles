{...}: {
  flake.modules.darwin.macos-utils = {
    config,
    lib,
    ...
  }: let
    cfg = config.vitorf7.darwin;
  in {
    homebrew.casks = [
      "appcleaner"
      "bartender"
      "daisydisk"
      "desktoppr"
      "keepingyouawake"
      "meetingbar"
      "utm"
      "logos"
      "sf-symbols"
      "gpg-suite"
      "zulu@17"
    ];

    homebrew.masApps =
      {
        HP = 1474276998;
        iMovie = 408981434;
      }
      // lib.optionalAttrs cfg.work.enable {
        "Okta Verify" = 490179405;
      };
  };
}
