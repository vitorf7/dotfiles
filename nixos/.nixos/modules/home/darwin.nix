{ config, pkgs, lib, username, ... }:

let
  dot = "${config.home.homeDirectory}/dotfiles";
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  imports = [ ./core.nix ./dev.nix ];

  home = {
    username = username;
    # lib.mkForce overrides the null default that home-manager's nixos/common.nix sets
    # on non-NixOS platforms (home-manager master, types.path no longer accepts null).
    homeDirectory = lib.mkForce "/Users/${username}";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;

  # Darwin-only CLI tools — shared tools (bat, fd, git, etc.) come from core.nix / dev.nix.
  home.packages = with pkgs; [
    # Kubernetes / infra
    argocd
    awscli2
    buf
    certbot
    cfssl
    docker
    docker-buildx
    docker-compose
    kubecolor
    kubeconform
    kubectl
    kustomize
    lazydocker
    kind
    popeye
    tflint

    # Build / dev toolchain
    cmake
    ninja
    pkg-config
    pre-commit
    stylua
    shellcheck
    semgrep
    richgo

    # Shell / TUI
    btop
    chafa
    diff-so-fancy
    difftastic
    entr
    evans
    figlet
    findutils
    gitmux
    glow
    gnugrep
    gnused
    graphviz
    gum
    jless
    jujutsu
    libsixel
    # lua: NOT here — sketchybar's SbarLua bindings are built against Homebrew's
    # lua specifically, and sketchybarrc hardcodes #!/opt/homebrew/bin/lua.
    # Kept on Homebrew (see homebrew.nix) to avoid breaking the bar.
    luarocks
    mas             # Mac App Store CLI
    moreutils
    nowplaying-cli  # macOS media control
    pipenv
    pipx
    pngpaste        # paste images from clipboard — macOS specific
    poppler
    reattach-to-user-namespace
    scdoc
    superfile
    switchaudio-osx # audio source switching — macOS specific
    tectonic
    television
    terminal-notifier
    tig
    tlrc
    tree
    uv
    wakatime-cli
    watchman
    wget
    wimlib
    xh
    yazi
    ydiff
    yq-go
    ghostscript
    imagemagick
    ffmpegthumbnailer
  ];

  xdg.configFile = {
    # macOS-specific app configs — whole-directory links (no secrets alongside).
    "aerospace".source  = link "${dot}/aerospace/.config/aerospace";
    "superfile".source  = link "${dot}/superfile/.config/superfile";
    "karabiner".source  = link "${dot}/karabiner/.config/karabiner";
    "gh-dash".source    = link "${dot}/gh-dash/.config/gh-dash";
    "lf".source         = link "${dot}/lf/.config/lf";
    "alacritty".source  = link "${dot}/alacritty/.config/alacritty";
    "bin".source        = link "${dot}/bin/.config/bin";

    # sketchybar — per-file because weather_vars.lua is a strongbox secret.
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
    # Secret — weather API key; strongbox-encrypted in dotfiles/secrets/.
    "sketchybar/weather_vars.lua".source     = link "${dot}/secrets/.config/sketchybar/weather_vars.lua";
  };

  home.file = {
    ".gitignore_global".source = link "${dot}/git/.gitignore_global";
    ".aliases".source          = link "${dot}/zsh/.aliases";
  };
}
