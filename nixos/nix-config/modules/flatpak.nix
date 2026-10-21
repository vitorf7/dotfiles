{inputs, ...}: {
  flake.modules.nixos.flatpak = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];

    config = lib.mkIf config.vitorf7.desktop.flatpak.enable {
      services.flatpak = {
        enable = true;
        remotes = [
          {
            name = "flathub";
            location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
          }
        ];
        # Warehouse can't update apps; keep flatpaks current on every rebuild
        # and weekly via a systemd timer.
        update = {
          onActivation = true;
          auto = {
            enable = true;
            onCalendar = "weekly";
          };
        };
      };

      environment.systemPackages = [pkgs.warehouse];
    };
  };
}
