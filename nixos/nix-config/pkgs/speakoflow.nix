{
  appimageTools,
  fetchurl,
  lib,
  makeWrapper,
  symlinkJoin,
  pipewire,
  alsa-plugins,
}: let
  pname = "speakoflow";
  version = "2.2.0";

  # Release AppImage rather than the upstream flake: since the transcribe.cpp
  # switch (Oct 2026) only CI stages libtranscribe.so + the ggml backends into
  # the bundle — the flake's buildRustPackage never installs them, so its
  # binary can't start. The AppImage ships them.
  src = fetchurl {
    url = "https://github.com/AbhishekBarali/SpeakoFlow/releases/download/v${version}/SpeakoFlow_${version}_amd64.AppImage";
    hash = "sha256-twBNi+/NqIs2KsP74qu+4206p1jXF0DyYffYs36f68M=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
    # The bundled GTK hook hard-codes GDK_BACKEND=x11, which keeps the
    # recording overlay off gtk-layer-shell on Hyprland (it ends up an empty,
    # bordered, blurred X11 window). Prefer Wayland, fall back to X11; an
    # explicit GDK_BACKEND from the caller still wins.
    postExtract = ''
      substituteInPlace $out/apprun-hooks/linuxdeploy-plugin-gtk.sh \
        --replace-fail 'export GDK_BACKEND=x11' 'export GDK_BACKEND="''${GDK_BACKEND:-wayland,x11}"'
    '';
  };

  # Same as upstream's flake wrapper: cpal is forced onto the ALSA backend, so
  # the pipewire/pulse ALSA plugins must be findable for any device to work.
  alsaPluginDir = symlinkJoin {
    name = "speakoflow-alsa-plugins";
    paths = [
      "${pipewire}/lib/alsa-lib"
      "${alsa-plugins}/lib/alsa-lib"
    ];
  };
in
  # wrapAppImage rather than wrapType2: wrapType2 always re-extracts `src`
  # itself, discarding the patched contents above.
  appimageTools.wrapAppImage {
    inherit pname version src;
    contents = appimageContents;
    # Same nix-update hack wrapType2 uses: keep `src` reachable on the result.
    passthru.src = src;

    # Text insertion shells out to whichever of these is on PATH
    # (wtype → dotool → ydotool on Wayland, wl-copy for the clipboard); the
    # FHS env only sees its own /usr/bin, so they're bundled in here.
    extraPkgs = pkgs:
      with pkgs; [
        wtype
        wl-clipboard
        ydotool
        alsa-plugins
        pipewire
        vulkan-loader
        libayatana-appindicator
      ];

    extraInstallCommands = ''
      source "${makeWrapper}/nix-support/setup-hook"
      wrapProgram $out/bin/${pname} \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
        --set ALSA_PLUGIN_DIR ${alsaPluginDir}

      desktop=$(find ${appimageContents} -maxdepth 1 -name '*.desktop' | head -n1)
      install -Dm644 "$desktop" $out/share/applications/${pname}.desktop
      sed -i 's|^Exec=[^ ]*|Exec=${pname}|' $out/share/applications/${pname}.desktop
      if [ -d ${appimageContents}/usr/share/icons ]; then
        cp -r ${appimageContents}/usr/share/icons $out/share/
      fi
    '';

    meta = {
      description = "Local-first voice dictation, assistant and meeting transcription";
      homepage = "https://github.com/AbhishekBarali/SpeakoFlow";
      license = lib.licenses.mit;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
