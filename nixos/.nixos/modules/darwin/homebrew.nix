{ config, lib, ... }:

let cfg = config.vitorf7.darwin; in

lib.mkIf cfg.homebrew.enable {

  homebrew = {
    enable = true;

    onActivation = {
      # Verified via `brew bundle cleanup --file $HOME/.Brewfile`: nothing extra
      # installed beyond what's declared here, so zap is safe.
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    global.brewfile = true;

    taps = [
      # WM + status bar stack
      "nikitabobko/tap"           # aerospace cask
      "felixkratz/formulae"       # sketchybar (trusted binary)

      # Third-party tools staying on brew
      "fencesandbox/tap"          # fence
      "garrettkrohn/treekanga"    # treekanga
      "jnsahaj/lumen"             # lumen
      "buo/cask-upgrade"          # brew cu - manual upgrade helper
      "caarlos0/tap"              # tt (cask)
      "hashicorp/tap"             # terraform, terraform-ls
      "snyk/tap"                  # snyk
      "teamookla/speedtest"       # speedtest

      # For casks below
      {
        name = "chmouel/lazyworktree";
        clone_target = "https://github.com/chmouel/lazyworktree";
        force_auto_update = null;
      }
    ];

    # CLI tools that cannot easily move to nixpkgs:
    # - tap-only or non-standard builds
    # - service-managed by brew (dnsmasq, httpd)
    # - heavy language-managed runtimes (julia, cocoapods, openjdk)
    # - pending Phase 0 nixpkgs name-collision check (rtk, ktop)
    brews = [
      # UW / tap-only
      { name = "felixkratz/formulae/sketchybar"; args = ["HEAD"]; }
      "fencesandbox/tap/fence"    # sandbox CLI — https://github.com/fencesandbox/fence

      # sketchybar dependency — its SbarLua bindings are built against this specific
      # Homebrew lua, and sketchybarrc's shebang hardcodes /opt/homebrew/bin/lua
      "lua"

      # Staying on brew — service-managed
      "dnsmasq"
      "httpd"

      # Staying on brew — heavy ecosystems
      "julia"
      "cocoapods"
      "composer"
      "openjdk"

      # Staying on brew — tap-only utilities
      "media-control"
      # tt: actually a cask from caarlos0/tap — moved to extraConfig below (trusted: true)
      "lpeg"
      "nvm"                       # note: prefer mise for version management; remove if not used
      "powerlevel10k"             # zsh-only; irrelevant with fish as login shell — remove when ready

      # ktop: may not be in nixpkgs aarch64-darwin — verify before moving
      "ktop"
      "unar"   # nixpkgs unar has a linker crash on aarch64-darwin (cctools BPT trap)
      "minikube"  # bundles its own kubectl binary, conflicts with standalone kubectl in buildEnv

      # Work tools — re-added after zap removed them (not in the original Brewfile dump,
      # installed manually after the fact, so missed in the initial migration mapping)
      "hashicorp/tap/terraform"
      "hashicorp/tap/terraform-ls"
      "snyk/tap/snyk"
      "teamookla/speedtest/speedtest"

      # awscli v1 — keep only if something requires it; otherwise remove
      "awscli@1"

      # stow: keep during migration; remove once home-manager owns all links
      "stow"
    ];

    casks = [
      # Password management
      "1password"
      "1password-cli"

      # Window management + status bar (configs managed via home-manager symlinks)
      # aerospace: installed via extraConfig below with trusted: true (tap trust workaround)
      "ghostty"

      # Productivity
      "appcleaner"
      "bartender"
      "daisydisk"
      "desktoppr"
      "keepingyouawake"
      "meetingbar"
      "raycast"
      "tomatobar"

      # Browsers
      "arc"
      "brave-browser"
      "helium-browser"
      "vivaldi"
      "zen"

      # Development
      "cursor"
      "visual-studio-code@insiders"
      "jetbrains-toolbox"
      "beekeeper-studio"
      "dbeaver-community"
      "insomnia"
      "postman"

      # Keyboard / input (hardware-integration builds)
      "karabiner-elements"
      "homerow"
      "keycastr"
      "mouseless@preview"

      # Virtualisation / containers
      "utm"
      "ollama-app"

      # Communication
      "slack"
      "whatsapp"
      "zoom"
      "rambox"
    ] ++ lib.optionals (!cfg.work.enable) [
      # Personal VPN — not used on the work Mac
      "nordvpn"
    ] ++ [

      # Media
      "spotify"
      "vlc"
      "elgato-wave-link"

      # Misc
      "kitty"
      # lazyworktree: installed via extraConfig below with trusted: true
      "logos"
      "obsidian"
      "sf-symbols"
      "vicinae"

      # Fonts — Apple proprietary / not in nixpkgs
      "font-sf-pro"
      "font-sf-mono"
      "font-codicon"
      # Meslo variants without a nixpkgs nerd-fonts equivalent
      "font-meslo-for-powerline"
      "font-meslo-lg-dz"
      # font-hack-nerd-font, font-jetbrains-mono-nerd-font, font-meslo-lg-nerd-font,
      # font-symbols-only-nerd-font, font-commit-mono, font-monaspace,
      # font-noto-color-emoji: removed — confirmed duplicated by fonts.packages
      # in fonts.nix (both installed side by side in ~/Library/Fonts and
      # /Library/Fonts/Nix Fonts).

      # Java
      "zulu@17"

      # GPU suite
      "gpg-suite"
    ];

    masApps = {
      HP = 1474276998;
      iMovie = 408981434;
      Keynote = 409183694;
      Numbers = 409203825;
      Pages = 409201541;
    } // lib.optionalAttrs cfg.work.enable {
      # Manually reinstalled via `mas install 490179405` after zap removed it twice
      # (it wasn't declared, so cleanup treated the installed app as orphaned).
      # Declaring it now that it's present — brew bundle only downloads if missing,
      # so this should just match the existing install rather than re-attempt it.
      "Okta Verify" = 490179405;
    };

    # Casks from third-party taps require trusted: true — nix-darwin's cask type
    # doesn't expose this flag, so they go here as raw Brewfile content.
    extraConfig = ''
      cask "nikitabobko/tap/aerospace", trusted: true
      cask "chmouel/lazyworktree/lazyworktree", trusted: true
      cask "caarlos0/tap/tt", trusted: true
    '';
  };
}
