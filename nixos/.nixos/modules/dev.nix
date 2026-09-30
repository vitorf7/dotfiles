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
        evans
        grpcui
        yq-go

        self.packages.${pkgs.stdenv.hostPlatform.system}.apix
        self.packages.${pkgs.stdenv.hostPlatform.system}.strongbox
      ]
      # Linux uses a nixpkgs-provided rust toolchain instead of rustup:
      # rustup shims exec upstream toolchain binaries, whose /lib64
      # interpreter only works via nix-ld, while binaries the shim builds
      # (e.g. Mason `cargo install` tools) carry GC-able /nix/store
      # interpreter paths — see fish/.config/bin/nvfix. On macOS (FHS)
      # rustup's shims and toolchains work natively, so they stay.
      # patchelf is nvfix's workhorse on Linux.
      ++ lib.optionals (!isDarwin) [
        cargo
        rustc
        rustfmt
        patchelf
      ]
      ++ lib.optionals isDarwin [
        rustup
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

    # Self-healing for foreign-managed binaries: anything built on this
    # machine with the nixpkgs go/cc wrappers (Mason `go install`/cargo
    # builds, bob's nvim) bakes GC-able /nix/store/<glibc> interpreter
    # paths into the binaries, so they die after the next `nrs` +
    # `nh clean`. `nvfix` (fish package, ~/.config/bin/nvfix) repoints
    # them onto the rebuild-stable nix-ld paths. The nvim wrapper in the
    # same directory sets CGO_ENABLED=0 so future Mason Go builds come
    # out fully static instead.
    systemd.user.services.nvfix = lib.mkIf (!isDarwin) {
      Unit.Description = "Repoint foreign-built binaries at the stable nix-ld loader";
      Service = {
        Type = "oneshot";
        ExecStart = "${config.home.homeDirectory}/.config/bin/nvfix";
      };
    };
    systemd.user.timers.nvfix = lib.mkIf (!isDarwin) {
      Unit.Description = "Run nvfix daily to heal binaries broken by rebuilds";
      Timer = {
        OnBootSec = "10min";
        OnUnitActiveSec = "1d";
        Persistent = true;
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
