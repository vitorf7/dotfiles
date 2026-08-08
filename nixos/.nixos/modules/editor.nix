{ ... }:
{
  flake.modules.homeManager.editor = { config, pkgs, ... }:
    let link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      home.sessionPath = [
        "$HOME/.local/share/bob/nvim-bin"
        "$HOME/.local/share/nvim/mason/bin"
      ];

      home.packages = with pkgs; [
        bob-nvim
        tree-sitter
      ];

      xdg.configFile."nvim".source = link "${config.home.homeDirectory}/nvim-kick";
    };
}
