{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.hyprland.enable {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  programs.hyprland.enable = true;

  # Clamshell mode: don't suspend when lid closes with external monitors connected.
  # The Hyprland side (toggling eDP-1 via hyprctl) lives in your dotfiles —
  # see ~/dotfiles/hyprland/.config/hypr/scripts/ for the clamshell toggle script.
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchExternalPower = "ignore";
    lidSwitchDocked = "ignore";
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "vitorf7" ];
  };
}
