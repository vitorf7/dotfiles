{ config, lib, ... }:

{
  zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 50; };
  boot.kernel.sysctl = { "vm.swappiness" = 100; "vm.page-cluster" = 0; };

  # Lid switch behaviour — applies to any desktop, not just Hyprland.
  # The Hyprland clamshell toggle script handles eDP-1 on the compositor side.
  services.logind.settings.Login = lib.mkIf config.vitorf7.desktop.enable {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };
}
