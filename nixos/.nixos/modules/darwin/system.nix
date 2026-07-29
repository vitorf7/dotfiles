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

  # Register Nix-managed fish in /etc/shells so chsh can point at it.
  # The actual shell change (chsh) is a manual post-step — see README.
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish pkgs.zsh pkgs.bash ];

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
