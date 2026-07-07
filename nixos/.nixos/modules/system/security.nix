{ config, lib, ... }:

lib.mkIf config.vitorf7.desktop.enable {
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
