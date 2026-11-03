{self, ...}: {
  # Trialled for meetings only, alongside SpeakoFlow (which keeps dictation).
  #
  # No NixOS half: upstream's nixosModule only sets up ydotool + uinput +
  # group membership for Wayland paste, which users.nix and hyprland.nix
  # already provide. Meetings need no aloop bridge like SpeakoFlow's — the
  # app records PipeWire's default sink monitor directly.
  #
  # No autostart service either: there's no documented start-hidden flag, so
  # launch it before calls. Its dictation hotkey must stay off our Hyprland
  # binds — it re-binds via hyprctl on every launch, unbinding any clash.
  flake.modules.homeManager.openwhispr = {
    pkgs,
    lib,
    osConfig,
    ...
  }:
    lib.mkIf osConfig.vitorf7.desktop.openwhispr.enable {
      home.packages = [self.packages.${pkgs.stdenv.hostPlatform.system}.openwhispr];
    };
}
