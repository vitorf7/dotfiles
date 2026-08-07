{ inputs, ... }:
{
  flake.modules.homeManager.caelestia-shell = { config, lib, osConfig, ... }:
    {
      imports = [ inputs.caelestia-shell.homeManagerModules.default ];

      config = lib.mkIf osConfig.vitorf7.desktop.caelestia_shell.enable {
        assertions = [
          {
            assertion = osConfig.vitorf7.desktop.quickshell.enable;
            message = "vitorf7.desktop.caelestia_shell.enable requires vitorf7.desktop.quickshell.enable = true";
          }
          {
            assertion = osConfig.vitorf7.desktop.hyprland.enable;
            message = "vitorf7.desktop.caelestia_shell.enable requires vitorf7.desktop.hyprland.enable = true (Caelestia Shell targets Hyprland)";
          }
        ];

        programs.caelestia = {
          enable = true;
          cli.enable = true;
        };

        xdg.configFile."hypr-caelestia/keybinds.lua".source =
          config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/dotfiles/hyprland/.config/hypr/modules/caelestia-keybinds.lua";

        xdg.configFile."caelestia".source =
          config.lib.file.mkOutOfStoreSymlink
            "${config.home.homeDirectory}/dotfiles/caelestia/.config/caelestia";
      };
    };
}
