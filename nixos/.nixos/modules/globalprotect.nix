{ inputs, ... }:
{
  flake.modules.nixos.globalprotect = { config, lib, pkgs, ... }: lib.mkIf config.vitorf7.networking.globalprotect.enable {
    environment.systemPackages =
      let
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
      [ gpWrapped ];

    services.ayatana-indicators.enable = true;
    security.polkit.enable = true;
  };
}
