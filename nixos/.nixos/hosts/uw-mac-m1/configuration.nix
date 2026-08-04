{ ... }:

{
  imports = [ ../../modules/darwin/base-darwin.nix ];

  # hostname -s returns this value — the nrs fish function uses it as the default flake attr.
  networking.hostName = "uw-mac-m1";
  networking.computerName = "uw-mac-m1";

  vitorf7.darwin.enable = true;
  vitorf7.darwin.homebrew.enable = true;
  vitorf7.darwin.aerospace.enable = true;
  vitorf7.darwin.colima.enable = false; # enable once launchd service is verified
  vitorf7.darwin.work.enable = true;

  vitorf7.git.defaultProfile = "work";
  vitorf7.git.personal.enable = true;
  vitorf7.git.personal.directories = [ "~/configfiles/" "~/personal/" ];
  vitorf7.git.work.enable = true;
  vitorf7.git.work.directories = [ "~/code/uw/" ];
}
