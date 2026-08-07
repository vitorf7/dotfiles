{ ... }:
{
  flake.modules.nixos.nordvpn = { config, lib, ... }: lib.mkIf config.vitorf7.networking.nordvpn.enable {
    services.nordvpn.enable = true;
    networking.firewall.checkReversePath = "loose";
    users.users.${config.vitorf7.username}.extraGroups = [ "nordvpn" ];
  };

  flake.modules.darwin.nordvpn = { config, lib, ... }: lib.mkIf config.vitorf7.networking.nordvpn.enable {
    homebrew.casks = [ "nordvpn" ];
  };
}
