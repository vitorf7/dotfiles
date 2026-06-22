{ config, pkgs, lib, ... }:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev";
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  programs.nix-ld.enable = true;
  programs.fish.enable = true;
  
  users.users.vitor = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.fish;
  };

  zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 50; };
  boot.kernel.sysctl = { "vm.swappiness" = 100; "vm.page-cluster" = 0; };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.hyprland.enable = lib.mkIf config.vitor.desktop.hyprland.enable true;
  services.xserver.enable = lib.mkIf config.vitor.desktop.hyprland.enable true;
  services.displayManager.gdm.enable = lib.mkIf config.vitor.desktop.hyprland.enable true;
  
  services.pipewire = lib.mkIf config.vitor.desktop.hyprland.enable {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  
  hardware.bluetooth = lib.mkIf config.vitor.desktop.hyprland.enable {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = lib.mkIf config.vitor.desktop.hyprland.enable true;
}
