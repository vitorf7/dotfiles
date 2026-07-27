{ config, lib, pkgs, secretsFile, ... }:

let
  wiresteward = pkgs.callPackage ../../pkgs/wiresteward.nix { };
in

lib.mkIf config.vitorf7.networking.wiresteward.enable {
  environment.systemPackages = [ pkgs.wireguard-tools ];

  boot.kernelModules = [ "wireguard" ];

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
