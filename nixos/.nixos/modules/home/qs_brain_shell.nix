{ lib, osConfig, ... }:

lib.mkIf osConfig.vitorf7.desktop.qs_brain_shell.enable {
  assertions = [{
    assertion = osConfig.vitorf7.desktop.quickshell.enable;
    message = "vitorf7.desktop.qs_brain_shell.enable requires vitorf7.desktop.quickshell.enable = true";
  }];

  # All packages and system config are handled by the brain-shell NixOS module
  # (imported in mkHost.nix), activated via modules/system/qs_brain_shell.nix.
}
