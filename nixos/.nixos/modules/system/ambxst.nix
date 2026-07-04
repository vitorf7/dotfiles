{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.ambxst.enable {
  # Delegates to the upstream Ambxst NixOS module (imported in mkHost.nix) which installs:
  # - The ambxst package (binary + Quickshell QML source)
  # - System fonts (Roboto, Noto, Phosphor Icons, Nerd Fonts, League Gothic, ...)
  # - services.upower, services.power-profiles-daemon (both mkDefault)
  # - programs.gpu-screen-recorder, networking.networkmanager (both mkDefault,
  #   already set explicitly in base-system.nix so no conflict)
  programs.ambxst.enable = true;
}
