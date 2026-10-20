{...}: {
  flake.modules.nixos.printing = {
    config,
    pkgs,
    ...
  }: {
    # Driverless printing (AirPrint/Mopria) for the Canon PIXMA MG3650S over
    # Wi-Fi, plus any office printer. Queues are deliberately NOT managed
    # with hardware.printers.ensurePrinters: its "everywhere" model makes
    # lpadmin contact the printer on every cups (re)start, so a start away
    # from the home network — or with the printer off — fails cups.service
    # outright (start-limit-hit; nixpkgs#78535). Instead, cups-browsed +
    # avahi auto-create the queue (IPP Everywhere) whenever a printer is
    # discoverable on the LAN; office printers can be added with the
    # Printers GUI (system-config-printer, below) or lpadmin. Fallback if
    # driverless quality disappoints: ship a PPD via services.printing.drivers
    # (e.g. the unfree cnijfilter2, allowed by nix-base).
    services.printing.enable = true;

    # mDNS discovery + .local hostname resolution for printers/scanners.
    # nssmdns4 is REQUIRED: queues added via the GUI use ipp://<name>.local/...
    # URIs, and without nss-mdns in nsswitch cupsd can't resolve them, so jobs
    # sit "pending" forever. avahi is the single mDNS responder on the box —
    # systemd-resolved's own mDNS is switched off in networking.nix.
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Scanning: sane-airscan speaks eSCL (AirScan) which the MG3650S
    # advertises over mDNS, so no Canon backend is needed. Fallback if it isn't
    # detected: hardware.sane.netConf = "<printer-ip>" for the pixma/bjnp backend.
    hardware.sane = {
      enable = true;
      extraBackends = [pkgs.sane-airscan];
    };
    users.users.${config.vitorf7.username}.extraGroups = ["scanner" "lp"];

    # Printer/scanner GUIs — add/remove printers, set defaults, manage jobs —
    # so the CUPS web UI (localhost:631) isn't needed.
    # system-config-printer-applet provides a tray icon with job notifications.
    environment.systemPackages = [
      pkgs.system-config-printer
      pkgs.simple-scan
    ];
  };
}
