{ ... }:
{
  flake.modules.darwin.sketchybar = { config, lib, ... }: lib.mkIf config.vitorf7.darwin.enable {
    homebrew.taps  = [ "felixkratz/formulae" ];
    homebrew.brews = [
      { name = "felixkratz/formulae/sketchybar"; args = [ "HEAD" ]; }
      "lua"
      "lpeg"
    ];
  };

  flake.modules.homeManager.sketchybar = { config, lib, osConfig, ... }:
    let
      dot = "${config.home.homeDirectory}/dotfiles";
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    lib.mkIf osConfig.vitorf7.darwin.enable {
      xdg.configFile = {
        "sketchybar/sketchybarrc".source          = link "${dot}/sketchybar/.config/sketchybar/sketchybarrc";
        "sketchybar/init.lua".source              = link "${dot}/sketchybar/.config/sketchybar/init.lua";
        "sketchybar/bar.lua".source               = link "${dot}/sketchybar/.config/sketchybar/bar.lua";
        "sketchybar/colors.lua".source            = link "${dot}/sketchybar/.config/sketchybar/colors.lua";
        "sketchybar/colors_catppuccin.lua".source = link "${dot}/sketchybar/.config/sketchybar/colors_catppuccin.lua";
        "sketchybar/default.lua".source           = link "${dot}/sketchybar/.config/sketchybar/default.lua";
        "sketchybar/icons.lua".source             = link "${dot}/sketchybar/.config/sketchybar/icons.lua";
        "sketchybar/settings.lua".source          = link "${dot}/sketchybar/.config/sketchybar/settings.lua";
        "sketchybar/items".source                 = link "${dot}/sketchybar/.config/sketchybar/items";
        "sketchybar/helpers".source               = link "${dot}/sketchybar/.config/sketchybar/helpers";
      };
    };
}
