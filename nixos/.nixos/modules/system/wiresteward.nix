{ config, lib, pkgs, ... }:

let
  wiresteward = pkgs.callPackage ../../pkgs/wiresteward.nix { };
  # Encrypted at rest via strongbox (see repo-root .gitattributes). Only
  # forced when actually read below, inside the mkIf block — Nix's laziness
  # means hosts with wiresteward disabled never touch this file at all.
  secretsFile = import ../../secrets/wiresteward-secrets.nix;
in

lib.mkIf config.vitorf7.networking.wiresteward.enable {
  environment.systemPackages = [ pkgs.wireguard-tools ];

  boot.kernelModules = [ "wireguard" ];

  # Real config, encrypted at rest via strongbox — see repo-root .gitattributes.
  environment.etc."wiresteward/config.json".source = ../../secrets/wiresteward-config.json;

  systemd.tmpfiles.rules = [
    "d /var/lib/wiresteward 0700 root root -"
  ];

  systemd.services.wiresteward-agent = {
    description = "Wiresteward Agent";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStartPre = pkgs.writeShellScript "wiresteward-cleanup" ''
        for iface in $(${pkgs.iproute2}/bin/ip -o link show | ${pkgs.gnugrep}/bin/grep -oP '(?<=\d: )wg-[^:@]+'); do
          ${pkgs.iproute2}/bin/ip link delete "$iface" || true
        done
      '';
      ExecStart = "${wiresteward}/bin/wiresteward -agent";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  systemd.network = {
    enable = true;
    networks."uw-merit" = {
      matchConfig.Name = "wg-prod-merit";
      networkConfig.DNS = secretsFile.uwDnsServer;
      networkConfig.Domains = secretsFile.uwDnsDomains;
    };
  };

  # systemd-networkd only watches for the wg-prod-merit interface name match
  # reactively — it manages no physical links. Disabling wait-online prevents
  # boot from hanging waiting for interfaces that don't exist yet.
  systemd.services.systemd-networkd-wait-online.enable = lib.mkForce false;
}
