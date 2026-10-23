{self, ...}: {
  flake.modules.nixos.speakoflow = {
    config,
    lib,
    pkgs,
    ...
  }:
    lib.mkIf config.vitorf7.desktop.speakoflow.enable {
      # SpeakoFlow's meeting mode records "Others" from whichever cpal input
      # device has "monitor" or "loopback" in its name. cpal 0.16's ALSA
      # backend never reads ALSA hints/asoundrc PCMs — it only tries the
      # builtins (default/pipewire/pulse/jack/oss) plus one entry per sound
      # *card*, named after the card — so the only way to give it a system-
      # audio source is a real card called "Loopback": snd-aloop.
      #
      # pcm_substreams=1 pins the pairing: whatever the speakoflow-system-audio
      # user service (homeManager half below) plays into hw:Loopback,1,0 is
      # what cpal captures from plughw:Loopback (= ,0,0). A fixed index keeps
      # it from reshuffling the real cards' numbers.
      boot.kernelModules = ["snd-aloop"];
      boot.extraModprobeConfig = ''
        options snd-aloop index=10 id=Loopback pcm_substreams=1
      '';

      # Lets the host's own alsa-lib resolve `type pulse` for the
      # `default` override in the homeManager half below.
      environment.etc."alsa/conf.d/60-speakoflow-pulse.conf".text = ''
        pcm_type.pulse {
          lib "${pkgs.alsa-plugins}/lib/alsa-lib/libasound_module_pcm_pulse.so"
        }
      '';

      # WirePlumber would otherwise grab both sides of the Loopback card as
      # ordinary sink/source nodes, holding the single capture substream
      # cpal needs and offering it as a default device.
      services.pipewire.wireplumber.extraConfig."60-speakoflow-aloop" = {
        "monitor.alsa.rules" = [
          {
            matches = [{"device.name" = "~alsa_card.platform-snd_aloop.*";}];
            actions.update-props."device.disabled" = true;
          }
        ];
      };
    };

  flake.modules.homeManager.speakoflow = {
    pkgs,
    lib,
    osConfig,
    ...
  }: let
    speakoflow = self.packages.${pkgs.stdenv.hostPlatform.system}.speakoflow;

    # Records the monitor of the *default* output — no --target, so
    # WirePlumber re-links it as the default moves between Bose/speaker/
    # Wave:3 jack — and plays it into the Loopback card for cpal to capture.
    #  * aplay writes interleaved, matching cpal's capture; aloop's
    #    loopback_check_format() fails mismatched interleaving with -EIO.
    #  * plughw, so if SpeakoFlow opened the capture side first (it picks
    #    44.1 kHz when nothing is playing in) the plug layer converts.
    #  * Not node.passive: a passive capture never joins the sink's driver
    #    cycle and only reads silence. Cost: the default output stays awake.
    systemAudioBridge = pkgs.writeShellScript "speakoflow-system-audio" ''
      set -o pipefail
      ${pkgs.pipewire}/bin/pw-record --raw --format f32 --rate 48000 --channels 2 \
        -P '{ stream.capture.sink = true node.name = speakoflow_tap node.description = "SpeakoFlow system-audio tap" }' - \
        | ${pkgs.alsa-utils}/bin/aplay -q -t raw -f FLOAT_LE -r 48000 -c 2 -D plughw:Loopback,1,0
    '';
  in
    lib.mkIf osConfig.vitorf7.desktop.speakoflow.enable {
      home.packages = [speakoflow];

      # Meetings ignore the microphone setting and always open ALSA `default`
      # (meetings/session.rs: start_mic_capture(None, ..)). Inside the
      # AppImage `default` (like `pipewire`) won't open — both are missing
      # from its device list — while `pulse` works, so point `default` at
      # pulse. That still tracks the PipeWire default source (the Wave:3).
      # Host ALSA clients resolve `type pulse` via the NixOS half above.
      xdg.configFile."alsa/asoundrc".text = ''
        pcm.!default {
          type pulse
        }
      '';

      # Kept running in the tray so the Hyprland binds (keybindings.lua) can
      # hand `--toggle-*` flags to it through the single-instance plugin.
      systemd.user.services.speakoflow = {
        Unit = {
          Description = "SpeakoFlow voice dictation";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };
        Service = {
          ExecStart = "${lib.getExe speakoflow} --start-hidden";
          Restart = "on-failure";
        };
        Install.WantedBy = ["graphical-session.target"];
      };

      # A service rather than a PipeWire context.objects bridge: that one is
      # created once at daemon start, and a single transient EBUSY on
      # hw:Loopback,1,0 at login dropped it for the whole session, leaving
      # meetings with a silent "Others". This just retries.
      systemd.user.services.speakoflow-system-audio = {
        Unit = {
          Description = "Feed the default output's monitor into snd-aloop for SpeakoFlow meetings";
          After = ["pipewire.service" "wireplumber.service"];
        };
        Service = {
          ExecStart = "${systemAudioBridge}";
          Restart = "always";
          RestartSec = 2;
        };
        Install.WantedBy = ["graphical-session.target"];
      };
    };
}
