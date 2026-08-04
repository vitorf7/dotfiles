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

  vitorf7.git.defaultProfile = "personal";
  vitorf7.git.personal.enable = true;
  vitorf7.git.personal.directories = [ "~/configfiles/" "~/personal/" ]; 

  # ── Login items ───────────────────────────────────────────────────────────
  # Registers GUI apps as macOS Login Items via sfltool.
  # Sketchybar is excluded — it runs as a brew LaunchAgent (brew services).
  # Aerospace is excluded — its cask registers its own login item.
  # Guards skip any app not yet installed (e.g. before first Homebrew run).
  #
  # Uses postActivation (not a custom script name) — system.activationScripts
  # is internal in nix-darwin master; only hardcoded names execute.
  # types.lines merges with other postActivation blocks (e.g. login shell in
  # system.nix) without conflict.
  system.activationScripts.postActivation.text = ''
    for app in \
      "/Applications/Bartender 5.app" \
      "/Applications/MeetingBar.app" \
      "/Applications/1Password.app" \
      "/Applications/NordVPN.app" \
      "/Applications/Vicinae.app"; do
      if [[ -d "$app" ]]; then
        /usr/bin/sfltool add-item loginitems "$app"
      fi
    done
  '';
}
