{...}: {
  flake.modules.nixos.networking = {...}: {
    networking.networkmanager.enable = true;

    # Prefer DNS-over-TLS.
    #
    # UW resolves private services through *public* DNS: e.g.
    # grafana.dev.merit.uw.systems is a CNAME to
    # private-ingress-v2.dev.merit.uw.systems, which answers with a private
    # 10.x address reachable only over wiresteward. Virgin Media (home ISP)
    # tampers with responses that carry private IPs, so the lookup comes back
    # NODATA and the host looks like it doesn't exist — while every other
    # network check passes, which makes it a confusing failure. UW documents
    # this in infra/wiresteward/README.md ("DNS rebind protection" → "Virgin
    # ISP (UK)") and the prescribed workaround is forcing DoT.
    #
    # domains = ["~."] makes every query prefer the resolvers below over the
    # DHCP-supplied ones NetworkManager pushes per-link (Virgin's, which don't
    # speak DoT anyway). More specific routing domains still win, so
    # wiresteward's ~telecomplus.internal / ~tp.private continue to go to
    # 10.253.253.253 over wg-prod-merit.
    #
    # dnsovertls = "opportunistic" (not "true"/strict): DoT to the resolvers
    # below is attempted first, but falls back to plaintext to those same
    # resolvers if DoT negotiation fails. Strict mode broke outright on
    # networks that block port 853 — corporate/managed wifi and captive
    # portals being the usual offenders, since they can't intercept encrypted
    # DNS to redirect you to a login page — causing total DNS failure instead
    # of just losing the rebind-protection benefit. A manual per-link
    # override is still available if ever needed:
    #   sudo resolvectl dnsovertls <link> no
    networking.nameservers = [
      "1.1.1.1#one.one.one.one"
      "1.0.0.1#one.one.one.one"
      "9.9.9.9#dns.quad9.net"
    ];

    services.resolved = {
      enable = true;
      dnsovertls = "opportunistic";
      domains = ["~."];
      # avahi (printing.nix) owns mDNS on :5353; resolved's responder would
      # compete with it and break .local lookups for printers/scanners.
      settings.Resolve.MulticastDNS = "no";
    };

    # NetworkManager defaults to mdns=default → registers with resolved per link.
    networking.networkmanager.connectionConfig."connection.mdns" = 0;
  };
}
