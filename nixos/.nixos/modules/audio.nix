{ ... }:
{
  flake.modules.nixos.audio = { config, lib, ... }: lib.mkIf config.vitorf7.desktop.hyprland.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
      wireplumber.extraConfig."99-volume-limit" = {
        "monitor.alsa.rules" = [{
          matches = [{ "node.name" = "~alsa_output.*"; }];
          actions.update-props = {
            "channelmix.max-volume" = 1.5;
          };
        }];
      };
    };
  };
}
