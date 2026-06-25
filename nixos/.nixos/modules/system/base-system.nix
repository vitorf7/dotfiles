{ config, pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./display.nix
    ./vm.nix
    ./quickshell.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  programs.nix-ld.enable = true;
  programs.fish.enable = true;

  users.users.vitorf7 = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.fish;
  };

  zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 50; };
  boot.kernel.sysctl = { "vm.swappiness" = 100; "vm.page-cluster" = 0; };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # v4l2loopback: virtual camera support (OBS virtual cam, video calls, etc.)
  # uvcvideo (real webcam driver) loads automatically — no config needed.
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
  '';
}
