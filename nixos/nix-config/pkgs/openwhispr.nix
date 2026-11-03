{
  appimageTools,
  fetchurl,
  lib,
}: let
  pname = "openwhispr";
  version = "1.11.0";

  # Vendored from upstream's nix/package.nix rather than taken as a flake
  # input: upstream doesn't bump that file on release (still 1.7.4 at the
  # v1.10.4 tag), so pinning here keeps nix-update-derivations in charge.
  src = fetchurl {
    url = "https://github.com/OpenWhispr/openwhispr/releases/download/v${version}/OpenWhispr-${version}-linux-x86_64.AppImage";
    hash = "sha256-fI8RCYVybv/sDSrm8Kw0O2TzX5Z+Cf/9z6pL/wwpMH4=";
  };

  appimageContents = appimageTools.extractType2 {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    # Clipboard/keystroke backends the app shells out to (wtype on Hyprland),
    # plus libraries beyond the FHS defaults — same list as upstream.
    extraPkgs = pkgs:
      with pkgs; [
        xdotool
        wtype
        ydotool
        wl-clipboard
        xclip
        xsel
        kdotool
        playerctl
        libsecret
        libnotify
        libpulseaudio
        # Native system-audio helper (meetings) links libpipewire-0.3.
        pipewire
        # Only for pactl (talks to pipewire-pulse; no daemon is started).
        # Meeting detection reads `pactl --format=json list source-outputs`
        # to tell call apps from sink-monitor captures. Without it the
        # fallback is a blind `pw-cli | grep Stream/Input/Audio` count, which
        # SpeakoFlow's always-on speakoflow_tap keeps above zero, so no
        # prompt ever fires.
        pulseaudio
        # libstdc++/libgomp for the bundled whisper/llama/sherpa/qdrant.
        stdenv.cc.cc.lib
      ];

    extraInstallCommands = ''
      desktop=$(find ${appimageContents} -maxdepth 1 -name '*.desktop' | head -n1)
      install -Dm644 "$desktop" $out/share/applications/${pname}.desktop
      sed -i 's|^Exec=[^ ]*|Exec=${pname}|' $out/share/applications/${pname}.desktop
      if [ -d ${appimageContents}/usr/share/icons ]; then
        cp -r ${appimageContents}/usr/share/icons $out/share/
      fi
    '';

    meta = {
      description = "Voice dictation, meeting transcription and notes";
      homepage = "https://github.com/OpenWhispr/openwhispr";
      license = lib.licenses.mit;
      mainProgram = pname;
      platforms = ["x86_64-linux"];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    };
  }
