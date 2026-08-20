{ ... }:
{
  flake.modules.darwin.system = { config, pkgs, lib, ... }:
    let username = config.vitorf7.username; in
    {
    # nix-darwin manages /etc/nix/nix.conf and the nix-daemon launchd job directly
    # (nix.enable defaults to true) — safe because we install plain Nix via
    # NixOS/nix-installer, not Determinate Nix, so nothing else owns nix.conf.
    #
    # experimental-features must be set here (not just passed via CLI flags) because
    # it needs to be in the system-wide daemon baseline: an unprivileged, non-trusted
    # user's --extra-experimental-features override is silently ignored by the
    # nix-daemon, so without this only root/sudo invocations would have nix-command
    # and flakes available.
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    nixpkgs.config.allowUnfree = true;

    system.stateVersion = 5;

    system.primaryUser = username;

    programs.fish.enable = true;
    environment.shells = [ pkgs.fish pkgs.zsh pkgs.bash ];

    system.activationScripts.postActivation.text = ''
      fish="/run/current-system/sw/bin/fish"
      current=$(/usr/bin/dscl . -read /Users/${username} UserShell 2>/dev/null | /usr/bin/awk '{print $2}')
      if [ "$current" != "$fish" ]; then
        echo "setting login shell to fish for ${username}..."
        /usr/bin/dscl . -create /Users/${username} UserShell "$fish"
      fi
    '';

    programs.fish.shellInit = ''
      fish_add_path --prepend --global /etc/profiles/per-user/${username}/bin
    '';

    time.timeZone = "Europe/London";

    security.pam.services.sudo_local.touchIdAuth = true;
  };
}
