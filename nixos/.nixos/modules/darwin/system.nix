{ config, pkgs, lib, username, ... }:

{
  # Determinate Nix owns /etc/nix/nix.conf — do NOT let nix-darwin touch it.
  # Nix settings go in /etc/nix/nix.custom.conf instead.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;

  # nix-darwin state version — set to current at first activation, never change after.
  system.stateVersion = 5;

  # Required for user-scoped system.defaults and sudo PAM.
  system.primaryUser = username;

  # Register Nix-managed fish in /etc/shells.
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish pkgs.zsh pkgs.bash ];

  # Set fish as the login shell via dscl.
  # users.users.${username}.shell is silently ignored unless the user is in
  # users.knownUsers, which is unsafe for pre-existing macOS accounts.
  # Using an activation script with dscl is the reliable alternative.
  # "loginShell" is claimed internally by the nix-darwin fish module — use a
  # distinct name to avoid the script being silently shadowed.
  system.activationScripts.setDefaultShell.text = ''
    fish="/run/current-system/sw/bin/fish"
    current=$(/usr/bin/dscl . -read /Users/${username} UserShell 2>/dev/null | /usr/bin/awk '{print $2}')
    if [ "$current" != "$fish" ]; then
      echo "setting login shell to fish..."
      /usr/bin/dscl . -create /Users/${username} UserShell "$fish"
    fi
  '';

  # With home-manager.useUserPackages = true, user packages land in
  # /etc/profiles/per-user/<user>/bin. nix-darwin doesn't add this to the fish
  # PATH automatically, so inject it via fish.shellInit (runs before user config.fish).
  programs.fish.shellInit = ''
    fish_add_path --prepend --global /etc/profiles/per-user/${username}/bin
  '';

  time.timeZone = "Europe/London";

  # Touch ID for sudo — works in Terminal.app, Ghostty and any PTY that doesn't
  # inherit the stdin PAM session. iTerm2/tmux require extra config.
  security.pam.services.sudo_local.touchIdAuth = true;
}
