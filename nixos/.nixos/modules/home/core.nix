{ config, pkgs, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
in
{
  home.sessionPath = [
    "$HOME/.local/share/bob/nvim-bin"
    "$HOME/.local/share/nvim/mason/bin"
  ];

  home.packages = with pkgs; [
    ghostty
    tmux
    bob-nvim
    stow
    ripgrep
    fd
    fzf
    zoxide
    bat
    fastfetch
    starship
    neovim
    fx
    direnv
    delta
    mise
    rbenv
    eza
    tree-sitter
  ];

  xdg.configFile = {
    "fish".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fish/.config/fish";
    "ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ghostty/.config/ghostty";
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nvim-kick";
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/starship/.config/starship.toml";
    "bat".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/bat/.config/bat";
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fastfetch/.config/fastfetch";
  };

  home.file = {
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.tmux.conf";
  };
}
