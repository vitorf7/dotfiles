{ ... }:

{
  imports = [
    ./boot.nix
    ./networking.nix
    ./locale.nix
    ./users.nix
    ./power.nix
    ./webcam.nix
    ./security.nix
    ./audio.nix
    ./bluetooth.nix
    ./display.nix
    ./hyprland.nix
    ./qs_brain_shell.nix
    ./ambxst.nix
    ./tide_island.nix
    ./caelestia_shell.nix
    ./vm.nix
    ./quickshell.nix
    ./flatpak.nix
  ];

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

  programs.gpu-screen-recorder.enable = true;
}
