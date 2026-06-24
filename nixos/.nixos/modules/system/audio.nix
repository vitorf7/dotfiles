{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.hyprland.enable {
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
}
