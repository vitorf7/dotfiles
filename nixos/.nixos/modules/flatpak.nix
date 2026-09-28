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
      };

      environment.systemPackages = [pkgs.warehouse];
    };
  };
}
