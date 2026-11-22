{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  python3,
  glib,
  gobject-introspection,
  quickshell,
  librsvg,
  imagemagick,
  wl-clipboard,
  libnotify,
  curl,
  xdg-utils,
  xdg-user-dirs,
  diffutils,
  fontconfig,
  grim,
  slurp,
  hyprpicker,
  brightnessctl,
  wtype,
  wf-recorder,
  pulseaudio,
  v4l-utils,
  poppler-utils,
  ffmpeg,
  pciutils,
}:
# Slate — a desktop shell for Hyprland built with Quickshell.
# https://github.com/daylerees/slate
#
# Packaged from the Nix store the way Slate expects a distro package to be:
# scripts/update.py sees its code under /nix/store/ and treats it as "packaged",
# so Settings -> Updates only tells you about new releases and never tries to
# install one itself. Bump `version`/`hash` (nix-update-derivations) and
# rebuild instead; a NixOS generation is the "go back".
#
# Written to be upstreamable as-is: nothing here refers to this repo. An
# upstream flake.nix would build it from its own checkout with
#   (callPackage ./package.nix {}).overrideAttrs { src = self; version = "..."; }
let
  # QML runs `python3` by name and the scripts are `#!/usr/bin/env python3`,
  # so this python has to be the first on the session's PATH.
  python = python3.withPackages (ps: [
    ps.pillow
    ps.numpy
    ps.pygobject3 # the tray's register; Gio/GLib from scripts
  ]);

  # What Slate shells out to (packaging/nixos.nix's list, minus the GUI apps
  # and system services that belong in the NixOS module).
  runtimePath = lib.makeBinPath [
    python
    quickshell
    librsvg
    imagemagick
    wl-clipboard
    libnotify
    curl
    xdg-utils
    xdg-user-dirs
    diffutils # cmp
    glib # gio / gsettings / gdbus
    fontconfig # fc-list
    grim
    slurp
    hyprpicker
    brightnessctl
    wtype # on-screen keyboard
    wf-recorder # screen recording
    pulseaudio # pactl
    v4l-utils # v4l2-ctl (Settings -> Webcam)
    poppler-utils # pdftoppm (Quick Look)
    ffmpeg
    pciutils
  ];

  typelibPath = lib.makeSearchPath "lib/girepository-1.0" [
    glib.out
    gobject-introspection
  ];
in
  stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "slate";
    version = "0.36.0";

    src = fetchFromGitHub {
      owner = "daylerees";
      repo = "slate";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Fv6IBarwnZHIzPHOmwpkNMHuR6VBijK07BYqHrRJc3M=";
    };

    dontConfigure = true;
    dontBuild = true;
    # `/bin/sh` and `/usr/bin/env` both exist on NixOS; leaving the shebangs
    # alone keeps `python3` resolving to the one on the session PATH (above),
    # the same one QML calls by name.
    dontPatchShebangs = true;

    installPhase = ''
      runHook preInstall

      share=$out/share/slate

      # Slate's code (install.sh's stage_code)
      mkdir -p $out/share
      cp -r shell $share
      mkdir -p $share/packaging
      cp packaging/*.txt $share/packaging/
      echo "v${finalAttrs.version}" > $share/VERSION
      chmod +x $share/bin/* $share/scripts/*.sh $share/scripts/*.py \
        $share/greeter/run-greeter.sh $share/session/slate-session

      # The slate command
      mkdir -p $out/bin
      ln -s $share/bin/slate $out/bin/slate

      # The login session: SHARED points at this package, and the session's
      # environment carries Slate's runtime tools (Slate itself is started
      # through Hyprland, so it inherits the session's environment, not a
      # wrapper's).
      {
        echo '#!/bin/sh'
        echo 'export PATH="${runtimePath}''${PATH:+:$PATH}"'
        echo 'export GI_TYPELIB_PATH="${typelibPath}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"'
        tail -n +2 shell/session/slate-session
      } > $out/bin/slate-session
      substituteInPlace $out/bin/slate-session \
        --replace-fail 'SHARED="/usr/local/share/slate /usr/share/slate"' "SHARED=\"$share\""
      chmod +x $out/bin/slate-session

      install -Dm644 shell/session/slate.desktop $out/share/wayland-sessions/slate.desktop
      substituteInPlace $out/share/wayland-sessions/slate.desktop \
        --replace-fail /usr/local/bin/slate-session $out/bin/slate-session

      # Slate Settings' desktop entry and icon, Slate Cursors, Geist
      # (install.sh's for_everyone)
      install -Dm644 shell/data/slate-settings.desktop $out/share/applications/slate-settings.desktop
      substituteInPlace $out/share/applications/slate-settings.desktop \
        --replace-fail @SLATE@ $out/bin/slate
      for s in 512 256 128 64 48 32 16; do
        install -Dm644 shell/assets/icon/settings-$s.png \
          $out/share/icons/hicolor/''${s}x''${s}/apps/slate-settings.png
      done
      ln -s $share/cursors/Slate-Cursors $out/share/icons/Slate-Cursors
      mkdir -p $out/share/fonts/slate
      for f in $share/fonts/Geist*-Variable.ttf; do
        ln -s "$f" $out/share/fonts/slate/
      done

      runHook postInstall
    '';

    passthru.providedSessions = ["slate"];

    meta = {
      description = "Desktop shell for Hyprland built with Quickshell";
      homepage = "https://github.com/daylerees/slate";
      changelog = "https://github.com/daylerees/slate/releases/tag/v${finalAttrs.version}";
      # Slate is MIT; the bundled Geist fonts are OFL, Tabler icons MIT,
      # Slate Cursors (from Bibata) GPL-3.0.
      license = with lib.licenses; [mit ofl gpl3Only];
      platforms = lib.platforms.linux;
      mainProgram = "slate";
    };
  })
