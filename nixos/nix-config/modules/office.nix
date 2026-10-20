{...}: {
  flake.modules.darwin.office = {
    config,
    lib,
    ...
  }: let
    cfg = config.vitorf7.darwin;
  in {
    homebrew.masApps =
      {}
      // lib.optionalAttrs cfg.work.enable {
        Keynote = 361285480;
        Numbers = 361304891;
        Pages = 361309726;
      };
  };

  flake.modules.homeManager.office = {
    config,
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    isLinux = pkgs.stdenv.isLinux;

    # The Craft suite (WordCraft, GridCraft, PhotoCraft, ...) is installed and
    # kept up to date by upstream's ArtCraft Launcher instead of nixpkgs, so
    # the apps don't wait on a flake update. Nix only makes sure the launcher
    # exists; its "Update and restart" renames the new AppImage over this same
    # path, so the stable name survives self-updates. The apps it installs
    # land as user Flatpaks (also visible in Warehouse).
    launcherPath = "${config.home.homeDirectory}/Applications/artcraft-launcher.AppImage";

    artcraft-launcher-bootstrap = pkgs.writeShellApplication {
      name = "artcraft-launcher-bootstrap";
      runtimeInputs = with pkgs; [coreutils curl gawk jq];
      text = ''
        dest=${lib.escapeShellArg launcherPath}
        if [ -e "$dest" ]; then
          exit 0
        fi

        tmp="$(mktemp -d)"
        trap 'rm -rf "$tmp"' EXIT
        fetch() { curl -fsSL --retry 5 --retry-all-errors "$@"; }

        release="$(fetch https://api.github.com/repos/storytold/craft-launcher/releases/latest)"
        asset_url() { jq -r --arg n "$1" '.assets[] | select(.name == $n) | .browser_download_url' <<<"$release"; }

        name="$(jq -r --arg s "-linux-$(uname -m).AppImage" \
          'first(.assets[].name | select(endswith($s))) // empty' <<<"$release")"
        if [ -z "$name" ]; then
          echo "no $(uname -m) AppImage in the latest craft-launcher release" >&2
          exit 1
        fi

        fetch -o "$tmp/$name" "$(asset_url "$name")"
        fetch -o "$tmp/SHA256SUMS.txt" "$(asset_url SHA256SUMS.txt)"
        # Refuse anything the release's checksums don't vouch for.
        awk -v n="$name" '$2 == n' "$tmp/SHA256SUMS.txt" >"$tmp/expected"
        if [ ! -s "$tmp/expected" ]; then
          echo "$name is missing from SHA256SUMS.txt" >&2
          exit 1
        fi
        (cd "$tmp" && sha256sum -c expected)

        mkdir -p "$(dirname "$dest")"
        install -m 755 "$tmp/$name" "$dest.part"
        mv "$dest.part" "$dest"
        echo "installed $name to $dest"
      '';
    };
  in
    lib.mkIf (isLinux && (osConfig.vitorf7.desktop.enable or false)) {
      home.packages = with pkgs; [
        libreoffice
        artcraft-launcher-bootstrap
      ];

      # Runs at login rather than during activation so a network hiccup
      # never fails a rebuild; Restart retries until the download succeeds.
      systemd.user.services.artcraft-launcher-bootstrap = {
        Unit = {
          Description = "Download the ArtCraft Launcher AppImage if it is missing";
          ConditionPathExists = "!${launcherPath}";
        };
        Service = {
          Type = "oneshot";
          ExecStart = lib.getExe artcraft-launcher-bootstrap;
          Restart = "on-failure";
          RestartSec = "5min";
        };
        Install.WantedBy = ["default.target"];
      };

      # Launched straight from the AppImage via the appimage binfmt
      # (modules/appimage.nix).
      xdg.desktopEntries.artcraft-launcher = {
        name = "ArtCraft Launcher";
        genericName = "Craft App Suite Launcher";
        comment = "Install, update and open the Craft apps";
        exec = launcherPath;
        categories = ["Office" "Graphics"];
        terminal = false;
      };
    };
}
