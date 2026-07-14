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
    killall
    nix-ld
    os-prober
    gcc
    gnumake
    unzip
    ghostty
    kitty
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
    jq
    direnv
    delta
    git
    mise
    rbenv
    eza
    tree-sitter
    sesh
    gh
  ];

  xdg.configFile = {
    "fish".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fish/.config/fish";
    "ghostty".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/ghostty/.config/ghostty";
    "tmux".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.config/tmux";
    "nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nvim-kick";
    "starship.toml".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/starship/.config/starship.toml";
    "bat".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/bat/.config/bat";
    "fastfetch".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/fastfetch/.config/fastfetch";
    "lazygit".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/lazygit/.config/lazygit";
    "gh".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/gh/.config/gh";
  };

  home.file = {
    ".tmux.conf".source = config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/tmux/.tmux.conf";
  };
}
