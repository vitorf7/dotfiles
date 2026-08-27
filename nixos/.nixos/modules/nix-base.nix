{ ... }:
{
  flake.modules.nixos.nix-base = { config, ... }: {
    programs.nix-ld.enable = true;

    nixpkgs.config.allowUnfree = true;

    # nixpkgs bug: throttled 0.12 imports dbus_next but the package only ships
    # dbus-python in its pythonPath. Override to inject the missing dependency.
    nixpkgs.overlays = [
      (final: prev: {
        throttled = prev.throttled.overrideAttrs (old: {
          pythonPath = old.pythonPath ++ [ prev.python3Packages.dbus-next ];
        });
      })
    ];

    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.auto-optimise-store = true;

    programs.nh = {
      enable = true;
      flake = "/home/${config.vitorf7.username}/dotfiles/nixos/.nixos";
      clean = {
        enable = true;
        extraArgs = "--keep-since 2w --keep 5";
      };
    };

    programs.gpu-screen-recorder.enable = true;
  };
}
