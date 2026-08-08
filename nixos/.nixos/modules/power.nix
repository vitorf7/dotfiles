{ ... }:
{
  flake.modules.nixos.power = { config, lib, ... }: {
    zramSwap = { enable = true; algorithm = "zstd"; memoryPercent = 50; };
    boot.kernel.sysctl = { "vm.swappiness" = 100; "vm.page-cluster" = 0; };

    services.logind.settings.Login = lib.mkIf config.vitorf7.desktop.enable {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "ignore";
      HandleLidSwitchDocked = "ignore";
    };
  };
}
