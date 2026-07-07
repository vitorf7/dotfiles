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
    ./vm.nix
    ./quickshell.nix
    ./flatpak.nix
  ];

  programs.nix-ld.enable = true;

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.gpu-screen-recorder.enable = true;
}
