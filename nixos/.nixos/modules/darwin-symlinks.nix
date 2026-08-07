{ ... }:
{
  flake.modules.homeManager.darwin-symlinks = { config, pkgs, lib, ... }:
    let
      dot = "${config.home.homeDirectory}/dotfiles";
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."bin".source = link "${dot}/bin/.config/bin";

      home.file.".aliases".source = link "${dot}/zsh/.aliases";

      home.activation.installRubyBuildPlugin = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        RBENV_PLUGIN_DIR="$HOME/.rbenv/plugins/ruby-build"
        if [ ! -d "$RBENV_PLUGIN_DIR" ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone --quiet \
            https://github.com/rbenv/ruby-build.git "$RBENV_PLUGIN_DIR"
        fi
      '';
    };
}
