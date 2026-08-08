{ ... }:
{
  flake.modules.nixos.qs-brain-shell = { config, lib, ... }: lib.mkIf config.vitorf7.desktop.qs_brain_shell.enable {
    programs.brain-shell.enable = true;
  };

  flake.modules.homeManager.qs-brain-shell = { lib, osConfig, ... }: lib.mkIf osConfig.vitorf7.desktop.qs_brain_shell.enable {
    assertions = [{
      assertion = osConfig.vitorf7.desktop.quickshell.enable;
      message = "vitorf7.desktop.qs_brain_shell.enable requires vitorf7.desktop.quickshell.enable = true";
    }];
  };
}
