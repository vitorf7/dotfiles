{ ... }:
{
  flake.modules.nixos.users = { config, pkgs, ... }: {
    programs.fish.enable = true;

    users.users.${config.vitorf7.username} = {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
      shell = pkgs.fish;
    };

    services.udev.extraRules = ''
      KERNEL=="uinput", GROUP="input", MODE="0660"
    '';
  };
}
