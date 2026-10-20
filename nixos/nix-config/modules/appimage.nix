{...}: {
  flake.modules.nixos.appimage = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf config.vitorf7.desktop.enable {
      # AppImages expect an FHS layout, so on NixOS they only run through
      # appimage-run. binfmt registers it so `./Foo.AppImage` (and desktop
      # entries pointing at one, e.g. the ArtCraft Launcher in office.nix)
      # just work.
      programs.appimage = {
        enable = true;
        binfmt = true;
      };
    };
  };
}
