{ pkgs, ... }:

{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./display.nix
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
}
