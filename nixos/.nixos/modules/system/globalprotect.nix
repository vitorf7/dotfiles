{ config, lib, pkgs, inputs, ... }:

lib.mkIf config.vitorf7.networking.globalprotect.enable {
  environment.systemPackages = [
    # Provides: gpclient (CLI), gpauth (auth helper), gpservice (background
    # service), gpgui-helper, and gpgui (proprietary GUI — 7-day trial, then paid).
    # Launch via: gpclient launch-gui   or from the application menu.
    inputs.globalprotect-openconnect.packages.${pkgs.system}.default
  ];

  # Provides the StatusNotifierItem / AppIndicator D-Bus service so the system
  # tray icon shows up on non-GNOME desktops (Hyprland, Sway, etc.).
  # Your bar (Quickshell / Caelestia / Waybar) must also expose a tray widget
  # that reads StatusNotifierItem to display the icon.
  services.ayatana-indicators.enable = true;

  # gpclient uses pkexec (polkit) to create VPN tunnels without running as root.
  # This is almost certainly already enabled by the desktop module, but being
  # explicit here makes the dependency self-documenting and is idempotent.
  security.polkit.enable = true;
}
