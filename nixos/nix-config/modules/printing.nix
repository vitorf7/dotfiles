{...}: {
  flake.modules.nixos.printing = {pkgs, ...}: {
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

    # mDNS discovery + .local hostname resolution for printers.
    services.avahi.enable = true;

    # Printer GUI — add/remove printers, set defaults, manage jobs — so the
    # CUPS web UI (localhost:631) isn't needed. system-config-printer-applet
    # provides a tray icon with job notifications.
    environment.systemPackages = [pkgs.system-config-printer];
  };
}
