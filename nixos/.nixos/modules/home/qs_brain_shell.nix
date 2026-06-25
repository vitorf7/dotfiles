{ pkgs, lib, osConfig, inputs, ... }:

lib.mkIf osConfig.vitorf7.desktop.qs_brain_shell.enable {
  assertions = [{
    assertion = osConfig.vitorf7.desktop.quickshell.enable;
    message = "vitorf7.desktop.qs_brain_shell.enable requires vitorf7.desktop.quickshell.enable = true";
  }];

  home.packages = [
    inputs.brain-shell.packages.${pkgs.system}.default
  ];
}
