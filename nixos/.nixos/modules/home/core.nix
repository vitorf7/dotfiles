{ config, pkgs, lib, ... }:

let
  dotfilesPath = "${config.home.homeDirectory}/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
  isLinux = pkgs.stdenv.isLinux;
in
{
  home.sessionPath = [
    "$HOME/.local/share/bob/nvim-bin"
    "$HOME/.local/share/nvim/mason/bin"
  ];

  # EDITOR/VISUAL are not set here: home.sessionVariables doesn't reach fish
  # (needs programs.fish.enable, unset in this repo — fish is unmanaged, see
  # xdg.configFile below). fish/.config/fish/config.fish already sets these
  # itself via `set -Ux EDITOR nvim`.

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
      prompt = "enabled";
      pager = "nvimpager";
      aliases = {
        co = "pr checkout";
        pv = "pr view";
      };
    };
    extensions = [
      pkgs.gh-dash
      pkgs.gh-pr-review
      pkgs.gh-stack
    ];
  };

  home.packages = with pkgs; [
    gcc
    gnumake
    unzip
    curl      # fisher shells out to curl on every install/update (macOS has one builtin; NixOS needs this)
    tmux
    bob-nvim   # manages neovim installs — bob provides the nvim binary
    stow
    ripgrep
    fd
    fzf
    zoxide
    bat
    fastfetch
    starship
    fx
    jq
    direnv
    sops
    mise
    rbenv
    eza
    tree-sitter
    sesh
  ] ++ lib.optionals isLinux [
    # Linux-only or installed via brew cask / native on macOS
    killall
    nix-ld
    os-prober
    ghostty   # macOS: brew cask (needs Xcode for nixpkgs build)
    kitty     # macOS: brew cask
    matugen   # Wayland colour generation; not used without Hyprland on darwin
    awww      # Wayland wallpaper tool
  ];

  xdg.configFile = {
    # Fish — per-file so ~/.config/fish stays a real writable directory
    # (fish writes fish_variables/fish_plugins itself; per-file avoids polluting the repo).
    "fish/config.fish".source         = link "${dotfilesPath}/fish/.config/fish/config.fish";
    "fish/aliases.fish".source        = link "${dotfilesPath}/fish/.config/fish/aliases.fish";
    "fish/fish_plugins".source        = link "${dotfilesPath}/fish/.config/fish/fish_plugins";
    "fish/functions/nvims.fish".source = link "${dotfilesPath}/fish/.config/fish/functions/nvims.fish";
    # sops.fish helper functions — one function per file (fish autoload requires
    # filename to match the function name exactly).
    "fish/functions/__sops_key_file.fish".source = link "${dotfilesPath}/fish/.config/fish/functions/__sops_key_file.fish";
    "fish/functions/sops-edit.fish".source       = link "${dotfilesPath}/fish/.config/fish/functions/sops-edit.fish";
    "fish/functions/sops-view.fish".source       = link "${dotfilesPath}/fish/.config/fish/functions/sops-view.fish";
    "fish/functions/sops-updatekeys.fish".source = link "${dotfilesPath}/fish/.config/fish/functions/sops-updatekeys.fish";
    # fish/private_config.fish is managed by sops-nix (secrets.nix)

    # These are whole-directory links — safe because no secrets live alongside them.
    "ghostty".source     = link "${dotfilesPath}/ghostty/.config/ghostty";
    "tmux".source        = link "${dotfilesPath}/tmux/.config/tmux";
    "starship.toml".source = link "${dotfilesPath}/starship/.config/starship.toml";
    "bat".source         = link "${dotfilesPath}/bat/.config/bat";
    "fastfetch".source   = link "${dotfilesPath}/fastfetch/.config/fastfetch";
    "lazygit".source     = link "${dotfilesPath}/lazygit/.config/lazygit";
    # nvim-kick is cloned next to dotfiles (~/nvim-kick) on every host —
    # same out-of-store symlink on Linux and macOS.
    "nvim".source        = link "${config.home.homeDirectory}/nvim-kick";
  };

  home.file = {
    ".tmux.conf".source = link "${dotfilesPath}/tmux/.tmux.conf";
  };
}
