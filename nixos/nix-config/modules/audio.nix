{...}: {
  flake.modules.nixos.audio = {
    config,
    lib,
    ...
  }:
    lib.mkIf config.vitorf7.desktop.hyprland.enable {
      security.rtkit.enable = true;

      # hardware.alsa.enable is false (PipeWire is the sound server, not raw
      # ALSA) so this defaults to false too and nothing ever saves/restores
      # the ALSA mixer (Master/Speaker/Headphone volume+mute) across
      # reboots — the ALC287 codec's power-on default is Master muted at
      # 0%, so internal speakers were silently unusable on every single
      # fresh boot regardless of any PipeWire/WirePlumber routing/priority.
      # This option only wires up alsactl store-on-shutdown/restore-on-boot;
      # it does NOT set hardware.alsa.enable and does not disable PipeWire.
      hardware.alsa.enablePersistence = true;

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
        wireplumber.extraConfig."99-volume-limit" = {
          "monitor.alsa.rules" = [
            {
              matches = [{"node.name" = "~alsa_output.*";}];
              actions.update-props = {
                "channelmix.max-volume" = 1.5;
              };
            }
            {
              # The Elgato Wave:3 gets an auto-assigned priority (1109) higher
              # than every other output — including bluez5 (1010) — purely
              # because it's a USB device WirePlumber saw plugged in. It's a
              # streaming mic/interface with its own separate physical
              # headphone-monitoring jack, not a speaker; it has no business
              # winning "default playback device" on every re-evaluation
              # (which happens on ~any node add/remove, e.g. an app
              # restarting), which is what kept silently stealing back the
              # default out from under manually-picked internal/HDMI/BT
              # outputs. Drop it below all real playback outputs — you can
              # still pick it manually when you actually want to monitor
              # through its jack.
              matches = [{"node.name" = "~alsa_output.*Elgato.*";}];
              actions.update-props = {
                "priority.driver" = 100;
                "priority.session" = 100;
              };
            }
            # Default-microphone fallback order: Wave:3 > Bluetooth headset mic
            # (bluez rule below) > built-in laptop mic. WirePlumber picks the
            # highest priority.session among available sources whenever no
            # remembered user choice is present, so unplugging/replugging walks
            # this order. Apps must record the real device (not EasyEffects'
            # virtual source) so the Wave:3's hardware mute button actually mutes.
            {
              matches = [{"node.name" = "~alsa_input.*Elgato.*";}];
              actions.update-props = {
                "priority.driver" = 3000;
                "priority.session" = 3000;
              };
            }
            {
              matches = [{"node.name" = "~alsa_input.pci-.*";}];
              actions.update-props = {
                "priority.driver" = 1000;
                "priority.session" = 1000;
              };
            }
            {
              # USB webcam mics (C922) get an auto priority (~2109) above the
              # BT headset; keep them as the last resort, below the laptop mic.
              matches = [{"node.name" = "~alsa_input.*Webcam.*";}];
              actions.update-props = {
                "priority.driver" = 500;
                "priority.session" = 500;
              };
            }
          ];
          # A BT headset only exposes a mic in its headset (HFP) profile;
          # WirePlumber autoswitches to it when an app starts recording.
          "monitor.bluez.rules" = [
            {
              matches = [{"node.name" = "~bluez_input.*";}];
              actions.update-props = {
                "priority.driver" = 2000;
                "priority.session" = 2000;
              };
            }
          ];
        };
      };
    };
}
