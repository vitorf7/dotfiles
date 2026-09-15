{self, ...}: {
  flake.modules.darwin.dev = {...}: {
    homebrew.taps = [
      "hashicorp/tap"
      "snyk/tap"
      "teamookla/speedtest"
    ];
    homebrew.brews = [
      "hashicorp/tap/terraform"
      "hashicorp/tap/terraform-ls"
      "snyk/tap/snyk"
      "teamookla/speedtest/speedtest"
      "awscli@1"
      "julia"
      "cocoapods"
      "composer"
      "openjdk"
      "evans"
      "grpcui"
    ];
  };

  flake.modules.homeManager.dev = {
    config,
    pkgs,
    lib,
    ...
  }: let
    isDarwin = pkgs.stdenv.isDarwin;
    dot = "${config.home.homeDirectory}/dotfiles";
    link = config.lib.file.mkOutOfStoreSymlink;
  in {
    home.packages = with pkgs;
      [
        nodejs
        yarn
        python3
        go_1_26
        rustup
        evans
        grpcui
        yq-go

        self.packages.${pkgs.stdenv.hostPlatform.system}.apix
        self.packages.${pkgs.stdenv.hostPlatform.system}.strongbox
      ]
      ++ lib.optionals isDarwin [
        cmake
        ninja
        pkg-config
        pre-commit
        stylua
        shellcheck
        semgrep
        richgo
        luarocks
        watchman
        wakatime-cli
        tectonic
        uv
        pipenv
      ];

    # `cargo install --git` (e.g. Mason installing nil, which isn't on
    # crates.io) uses cargo's bundled libgit2 by default, which can't
    # complete SSH-agent auth against the 1Password SSH agent even though
    # the git.nix `url."git@github.com:".insteadOf` rewrite + real `git`
    # CLI work fine for normal repo use. Forcing cargo to shell out to the
    # real `git` binary sidesteps that libgit2 limitation entirely.
    home.file.".cargo/config.toml".source = link "${dot}/cargo/.cargo/config.toml";
    home.file.".apix.yaml".source = link "${dot}/secrets/.apix.yaml";
  };
}
