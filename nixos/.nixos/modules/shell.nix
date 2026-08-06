{ ... }:
{
  flake.modules.homeManager.shell = { config, pkgs, lib, ... }:
    let
      dot = "${config.home.homeDirectory}/dotfiles";
      link = config.lib.file.mkOutOfStoreSymlink;
      isLinux  = pkgs.stdenv.isLinux;
      isDarwin = pkgs.stdenv.isDarwin;
    in
    {
      home.packages = with pkgs; [
        tmux
        starship
        zoxide
        fzf
        bat
        eza
        direnv
        sesh
        fastfetch
        ripgrep
        fd
      ] ++ lib.optionals isLinux [
        # Wayland colour-generation + wallpaper (not needed without Hyprland on darwin)
        matugen
        awww
      ] ++ lib.optionals isDarwin [
        # Required by tmux copy-mode on macOS
        reattach-to-user-namespace
      ];

      xdg.configFile = {
        "fish/config.fish".source          = link "${dot}/fish/.config/fish/config.fish";
        "fish/aliases.fish".source         = link "${dot}/fish/.config/fish/aliases.fish";
        "fish/fish_plugins".source         = link "${dot}/fish/.config/fish/fish_plugins";
        "fish/functions/nvims.fish".source = link "${dot}/fish/.config/fish/functions/nvims.fish";
        "fish/functions/__sops_key_file.fish".source  = link "${dot}/fish/.config/fish/functions/__sops_key_file.fish";
        "fish/functions/sops-edit.fish".source        = link "${dot}/fish/.config/fish/functions/sops-edit.fish";
        "fish/functions/sops-view.fish".source        = link "${dot}/fish/.config/fish/functions/sops-view.fish";
        "fish/functions/sops-updatekeys.fish".source  = link "${dot}/fish/.config/fish/functions/sops-updatekeys.fish";
        "tmux".source          = link "${dot}/tmux/.config/tmux";
        "starship.toml".source = link "${dot}/starship/.config/starship.toml";
        "bat".source           = link "${dot}/bat/.config/bat";
        "fastfetch".source     = link "${dot}/fastfetch/.config/fastfetch";
      };

      home.file.".tmux.conf".source = link "${dot}/tmux/.tmux.conf";
    };
}
