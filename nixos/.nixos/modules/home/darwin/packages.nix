{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Kubernetes / infra
    argocd
    awscli2
    buf
    certbot
    cfssl
    colima
    coreutils
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
    luarocks
    mas
    moreutils
    nowplaying-cli
    pipenv
    pngpaste
    poppler
    reattach-to-user-namespace
    scdoc
    superfile
    switchaudio-osx
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
}
