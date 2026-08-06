{ config, pkgs, lib, ... }:

let
  dot = "${config.home.homeDirectory}/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  xdg.configFile = {
    "aerospace".source  = link "${dot}/aerospace/.config/aerospace";
    "superfile".source  = link "${dot}/superfile/.config/superfile";
    "karabiner".source  = link "${dot}/karabiner/.config/karabiner";
    "gh-dash".source    = link "${dot}/gh-dash/.config/gh-dash";
    "lf".source         = link "${dot}/lf/.config/lf";
    "alacritty".source  = link "${dot}/alacritty/.config/alacritty";
    "bin".source        = link "${dot}/bin/.config/bin";
    "vicinae".source    = link "${dot}/vicinae/.config/vicinae";

    # sketchybar — per-file because weather_vars.lua is a sops secret.
    "sketchybar/sketchybarrc".source         = link "${dot}/sketchybar/.config/sketchybar/sketchybarrc";
    "sketchybar/init.lua".source             = link "${dot}/sketchybar/.config/sketchybar/init.lua";
    "sketchybar/bar.lua".source              = link "${dot}/sketchybar/.config/sketchybar/bar.lua";
    "sketchybar/colors.lua".source           = link "${dot}/sketchybar/.config/sketchybar/colors.lua";
    "sketchybar/colors_catppuccin.lua".source = link "${dot}/sketchybar/.config/sketchybar/colors_catppuccin.lua";
    "sketchybar/default.lua".source          = link "${dot}/sketchybar/.config/sketchybar/default.lua";
    "sketchybar/icons.lua".source            = link "${dot}/sketchybar/.config/sketchybar/icons.lua";
    "sketchybar/settings.lua".source         = link "${dot}/sketchybar/.config/sketchybar/settings.lua";
    "sketchybar/items".source                = link "${dot}/sketchybar/.config/sketchybar/items";
    "sketchybar/helpers".source              = link "${dot}/sketchybar/.config/sketchybar/helpers";
    # sketchybar/weather_vars.lua is managed by sops-nix (secrets.nix)
  };

  home.file = {
    ".aliases".source = link "${dot}/zsh/.aliases";
  };

  home.activation.installRubyBuildPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    RBENV_PLUGIN_DIR="$HOME/.rbenv/plugins/ruby-build"
    if [ ! -d "$RBENV_PLUGIN_DIR" ]; then
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone --quiet \
        https://github.com/rbenv/ruby-build.git "$RBENV_PLUGIN_DIR"
    fi
  '';
}
