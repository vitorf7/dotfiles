{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.vitorf7 = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
    shell = pkgs.fish;
  };

  # Allow the input group to write to /dev/uinput (required by Mouseless)
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="input", MODE="0660"
  '';
}
