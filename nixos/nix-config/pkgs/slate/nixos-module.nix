# NixOS module for Slate (https://github.com/daylerees/slate): what upstream's
# packaging/nixos.nix asks for, plus the "Slate" login session, as options.
#
# Written to be upstreamable as-is: nothing here refers to this repo. An
# upstream flake.nix could expose it as
#   nixosModules.default = {pkgs, lib, ...}: {
#     imports = [./packaging/nix/nixos-module.nix];
#     programs.slate.package = lib.mkDefault self.packages.${pkgs.stdenv.hostPlatform.system}.default;
#   };
#
# Every service is set with mkDefault, so a host's own choices win.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.slate;
in {
  options.programs.slate = {
    enable = lib.mkEnableOption "Slate, a desktop shell for Hyprland built with Quickshell (adds a \"Slate\" login session)";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix {};
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix {}";
      description = "The Slate package.";
    };

    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = with pkgs; [
        qt6Packages.qt6ct
        qt6.qtdeclarative
        qt6.qtsvg
        qt6.qtmultimedia # click sound, and sounds without a delay
        adw-gtk3 # light-mode GTK
        papirus-icon-theme # Settings -> Icons -> Folder color
        gsettings-desktop-schemas
        hyprland-guiutils
        btop
        system-config-printer # Settings -> Printers & Scanners
        simple-scan
        orca # screen reader (Settings -> Accessibility)
        ddcutil # monitor brightness over DDC/CI (needs the i2c group)
        whisper-cpp # Nova's voice input
        flatpak # Slate Software (also set services.flatpak.enable)
        hyprlandPlugins.hyprbars # optional title bars; link it into ~/.local/share/slate/plugins/hyprbars.so
      ];
      defaultText = lib.literalMD "upstream's optional extras from `packaging/nixos.nix`";
      description = "Optional apps and tools Slate's features use. Override to trim.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Hyprland 0.57+ (Slate's session config is Lua). Under UWSM slate-session
    # runs through `uwsm start`, which activates graphical-session.target so
    # the portals and other user services start.
    programs.hyprland = {
      enable = true;
      withUWSM = lib.mkDefault true;
    };

    services.upower.enable = lib.mkDefault true;
    services.power-profiles-daemon.enable = lib.mkDefault true;
    hardware.sensor.iio.enable = lib.mkDefault true; # Automatic brightness
    hardware.i2c.enable = lib.mkDefault true; # monitor brightness over DDC/CI
    networking.networkmanager.enable = lib.mkDefault true;
    hardware.bluetooth.enable = lib.mkDefault true;
    security.polkit.enable = lib.mkDefault true;
    services.pipewire = {
      enable = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
      wireplumber.enable = lib.mkDefault true;
    };
    services.accounts-daemon.enable = lib.mkDefault true; # account picture
    services.gvfs.enable = lib.mkDefault true; # the Waste Basket's trash:
    programs.dconf.enable = lib.mkDefault true; # theme settings (gsettings) stick

    # xdg-desktop-portal-hyprland comes from programs.hyprland (built against
    # its package); listing it again here would install a second copy.
    xdg.portal = {
      enable = lib.mkDefault true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk]; # Flatpak/Snap light or dark
    };

    # Settings -> Printers & Scanners
    services.printing.enable = lib.mkDefault true;
    services.avahi = {
      enable = lib.mkDefault true;
      nssmdns4 = lib.mkDefault true;
    };
    hardware.sane = {
      enable = lib.mkDefault true;
      extraBackends = [pkgs.sane-airscan];
    };

    fonts.packages = [
      pkgs.geist-font
      pkgs.noto-fonts-color-emoji # the emoji picker, the launcher's :emoji
    ];

    # Puts `slate`, Slate Settings' desktop entry and icon, Slate Cursors and
    # the Geist fonts in /run/current-system/sw.
    environment.systemPackages = [cfg.package] ++ cfg.extraPackages;

    # "Slate" on the login screen (slate-session-install's job elsewhere)
    services.displayManager.sessionPackages = [cfg.package];
  };
}
