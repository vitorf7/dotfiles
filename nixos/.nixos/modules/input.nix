{...}: {
  flake.modules.darwin.input = {...}: {
    homebrew.casks = [
      "karabiner-elements"
      "homerow"
      "keycastr"
      "mouseless@preview"
      "openlogi"
    ];
  };

  flake.modules.nixos.input = {pkgs, ...}: {
    services.udev.packages = [pkgs.openlogi];
  };

  flake.modules.homeManager.input = {
    config,
    pkgs,
    lib,
    ...
  }: {
    home.packages = lib.optionals pkgs.stdenv.isLinux [pkgs.openlogi];

    systemd.user.services.openlogi-agent = lib.mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "OpenLogi background agent (Logitech HID++ device control)";
        After = ["graphical-session.target"];
        PartOf = ["graphical-session.target"];
      };
      Service = {
        ExecStart = "${pkgs.openlogi}/bin/openlogi-agent";
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install.WantedBy = ["graphical-session.target"];
    };

    xdg.configFile = lib.mkIf pkgs.stdenv.isDarwin {
      "karabiner".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/karabiner/.config/karabiner";
    };
  };
}
