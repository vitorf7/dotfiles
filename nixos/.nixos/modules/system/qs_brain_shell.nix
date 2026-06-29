{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.qs_brain_shell.enable {
  # Delegates to the upstream brain-shell NixOS module which installs:
  # - The Brain_Shell QML source package
  # - All runtime deps (slurp, wl-clipboard, wtype, awww, lm_sensors,
  #   hyprshutdown, xdg-desktop-portal-hyprland, qt6ct, ...)
  # - System fonts (nerd-fonts.jetbrains-mono, nerd-fonts.symbols-only)
  # - QT_QPA_PLATFORMTHEME=qt6ct environment variable
  # - services.pipewire.enable and services.blueman.enable
  programs.brain-shell.enable = true;
}
