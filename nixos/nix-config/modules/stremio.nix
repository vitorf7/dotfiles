{...}: {
  flake.modules.nixos.stremio = {
    config,
    lib,
    options,
    ...
  }: {
    config = lib.mkIf (config.vitorf7.desktop.stremio.enable && options.services ? flatpak) {
      services.flatpak.packages = [
        {
          appId = "com.stremio.Stremio";
          origin = "flathub";
        }
      ];
    };
  };

  flake.modules.darwin.stremio = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf config.vitorf7.desktop.stremio.enable {
      homebrew.casks = ["stremio"];
    };
  };
}
