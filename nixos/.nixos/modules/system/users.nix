{ pkgs, ... }:

{
  programs.fish.enable = true;

  users.users.vitorf7 = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.fish;
  };
}
