{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.enable {
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Lid switch behaviour — applies to any desktop, not just Hyprland.
  # The Hyprland clamshell toggle script handles eDP-1 on the compositor side.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "vitorf7" ];
  };

  environment.etc."1password/custom_allowed_browsers" = {
    text = "zen\n";
    mode = "0755";
  };
}
