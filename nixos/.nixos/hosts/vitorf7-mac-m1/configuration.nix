{ ... }:

{
  imports = [ ../../modules/darwin/base-darwin.nix ];

  # hostname -s is unreliable on macOS (no MDM here, but keep the pattern
  # consistent with uw-mac-m1) — nrs reads ~/.config/nix-darwin-host instead.
  networking.hostName = "vitorf7-mac-m1";
  networking.computerName = "vitorf7-mac-m1";

  vitorf7.darwin.enable = true;
  vitorf7.darwin.homebrew.enable = true;
  vitorf7.darwin.aerospace.enable = true;
  vitorf7.darwin.colima.enable = false; # enable once launchd service is verified
  vitorf7.darwin.work.enable = false; # personal machine — no Okta Verify, gets nordvpn
}
