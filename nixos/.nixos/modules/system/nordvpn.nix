{ config, lib, ... }:

lib.mkIf config.vitorf7.networking.nordvpn.enable {
  services.nordvpn.enable = true;

  # Required so VPN return packets are not dropped by the reverse-path filter.
  # Also recommended by the NixOS nordvpn module docs when firewall is enabled.
  networking.firewall.checkReversePath = "loose";

  # Add the main user to the nordvpn group so they can talk to nordvpnd
  # without requiring root. Log out and back in after first rebuild.
  users.users.vitorf7.extraGroups = [ "nordvpn" ];
}
