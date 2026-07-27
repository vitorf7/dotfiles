{ config, lib, pkgs, inputs, ... }:

let
  # OpenSSL 3.x rejects older TLS parameters (TLS 1.0/1.1, SHA1 certs, weak
  # ciphers) used by the Palo Alto GlobalProtect gateway at vpn.uw.systems.
  # This config re-enables the legacy provider and lowers the security level
  # to 1, scoped only to the GP binaries via OPENSSL_CONF wrapper below.
  opensslLegacyCnf = pkgs.writeText "openssl-gp-legacy.cnf" ''
    openssl_conf = openssl_init

    [openssl_init]
    providers = provider_sect
    ssl_conf = ssl_sect

    [provider_sect]
    default = default_sect
    legacy = legacy_sect

    [default_sect]
    activate = 1

    [legacy_sect]
    activate = 1

    [ssl_sect]
    system_default = system_default_sect

    [system_default_sect]
    CipherString = DEFAULT:@SECLEVEL=1
    MinProtocol = TLSv1
  '';

  gpPkg = inputs.globalprotect-openconnect.packages.${pkgs.system}.default;

  gpWrapped = pkgs.symlinkJoin {
    name = "globalprotect-openconnect-wrapped";
    paths = [ gpPkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in gpclient gpauth gpservice gpgui gpgui-helper; do
        if [ -f "$out/bin/$bin" ]; then
          wrapProgram "$out/bin/$bin" \
            --set OPENSSL_CONF ${opensslLegacyCnf}
        fi
      done
    '';
  };
in

lib.mkIf config.vitorf7.networking.globalprotect.enable {
  environment.systemPackages = [ gpWrapped ];

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
