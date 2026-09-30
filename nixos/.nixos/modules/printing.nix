{...}: {
  flake.modules.nixos.printing = {...}: {
    # Driverless printing (AirPrint/Mopria) for the Canon PIXMA MG3650S over
    # Wi-Fi. The printer advertises IPP on the LAN, so no proprietary driver
    # is needed — CUPS talks to it via ipp:// and "everywhere" generates the
    # PPD from the device's own IPP capabilities. Fallback if driverless
    # quality/features disappoint: services.printing.drivers = [pkgs.cnijfilter2]
    # (unfree, allowed by nix-base) and switch the queue model to the Canon PPD.
    services.printing.enable = true;

    # mDNS discovery + .local hostname resolution for the printer.
    services.avahi.enable = true;

    hardware.printers.ensurePrinters = [
      {
        # NOTE: the mDNS hostname below is a best guess — after the printer
        # joins the Wi-Fi, confirm the exact advertised name with
        #   avahi-browse -rt _ipp._tcp
        # (or `lpinfo -v`) and update deviceUri if it differs, then rebuild.
        name = "Canon-MG3650S";
        deviceUri = "ipp://Canon-MG3600-series.local/ipp/print";
        model = "everywhere";
        description = "Canon PIXMA MG3650S (driverless)";
        location = "Home";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    hardware.printers.ensureDefaultPrinter = "Canon-MG3650S";
  };
}
